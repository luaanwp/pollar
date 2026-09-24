create extension if not exists pgcrypto;

create table public.profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  email text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table public.devices (
  id uuid primary key,
  user_id uuid not null references auth.users(id) on delete cascade,
  last_seen_at timestamptz not null default now(),
  unique (user_id, id)
);

create table public.accounts (
  id text primary key,
  user_id uuid not null references auth.users(id) on delete cascade,
  payload jsonb not null,
  version bigint not null check (version > 0),
  deleted_at timestamptz,
  updated_at timestamptz not null default now()
);

create table public.transactions (
  id text primary key,
  user_id uuid not null references auth.users(id) on delete cascade,
  payload jsonb not null,
  version bigint not null check (version > 0),
  deleted_at timestamptz,
  updated_at timestamptz not null default now()
);

create table public.sync_mutations (
  operation_id uuid primary key,
  user_id uuid not null references auth.users(id) on delete cascade,
  device_id uuid not null,
  entity_type text not null check (entity_type in ('account', 'transaction')),
  entity_id text not null,
  applied boolean not null,
  remote_version bigint not null,
  remote_deleted boolean not null default false,
  remote_payload jsonb,
  reason text,
  created_at timestamptz not null default now()
);

create table public.sync_changes (
  cursor bigint generated always as identity primary key,
  user_id uuid not null references auth.users(id) on delete cascade,
  entity_type text not null check (entity_type in ('account', 'transaction')),
  entity_id text not null,
  version bigint not null,
  deleted boolean not null,
  payload jsonb not null,
  changed_at timestamptz not null default now()
);

create index sync_changes_user_cursor_idx on public.sync_changes (user_id, cursor);
create index sync_mutations_user_created_idx on public.sync_mutations (user_id, created_at);

alter table public.profiles enable row level security;
alter table public.devices enable row level security;
alter table public.accounts enable row level security;
alter table public.transactions enable row level security;
alter table public.sync_mutations enable row level security;
alter table public.sync_changes enable row level security;

create policy "profiles_read_own" on public.profiles for select to authenticated using (id = auth.uid());
create policy "profiles_update_own" on public.profiles for update to authenticated using (id = auth.uid()) with check (id = auth.uid());
create policy "devices_read_own" on public.devices for select to authenticated using (user_id = auth.uid());
create policy "accounts_read_own" on public.accounts for select to authenticated using (user_id = auth.uid());
create policy "transactions_read_own" on public.transactions for select to authenticated using (user_id = auth.uid());
create policy "mutations_read_own" on public.sync_mutations for select to authenticated using (user_id = auth.uid());
create policy "changes_read_own" on public.sync_changes for select to authenticated using (user_id = auth.uid());

create or replace function public.handle_new_user()
returns trigger
language plpgsql
security definer set search_path = public, pg_temp
as $$
begin
  insert into public.profiles (id, email) values (new.id, new.email)
  on conflict (id) do update set email = excluded.email, updated_at = now();
  return new;
end;
$$;

create trigger on_auth_user_created
after insert or update of email on auth.users
for each row execute procedure public.handle_new_user();

create or replace function public.apply_sync_mutations(
  p_device_id uuid,
  p_mutations jsonb
)
returns table (
  operation_id uuid,
  entity_type text,
  entity_id text,
  applied boolean,
  remote_version bigint,
  remote_deleted boolean,
  remote_payload jsonb,
  reason text
)
language plpgsql
security definer set search_path = public, pg_temp
as $$
declare
  v_user_id uuid := auth.uid();
  v_item jsonb;
  v_operation_id uuid;
  v_entity_type text;
  v_entity_id text;
  v_operation text;
  v_payload jsonb;
  v_base_version bigint;
  v_current_version bigint;
  v_current_payload jsonb;
  v_deleted boolean;
  v_prior public.sync_mutations%rowtype;
begin
  if v_user_id is null then raise exception 'authentication required' using errcode = '28000'; end if;
  if jsonb_typeof(p_mutations) <> 'array' then raise exception 'p_mutations must be an array'; end if;

  insert into public.devices (id, user_id, last_seen_at)
  values (p_device_id, v_user_id, now())
  on conflict (id) do update set last_seen_at = now()
  where devices.user_id = v_user_id;
  if not found then raise exception 'device belongs to another user' using errcode = '42501'; end if;

  for v_item in select value from jsonb_array_elements(p_mutations)
  loop
    v_operation_id := (v_item->>'operation_id')::uuid;
    v_entity_type := v_item->>'entity_type';
    v_entity_id := v_item->>'entity_id';
    v_operation := v_item->>'operation';
    v_payload := coalesce(v_item->'payload', '{}'::jsonb);
    v_base_version := coalesce((v_item->>'base_version')::bigint, 0);

    select * into v_prior from public.sync_mutations m
    where m.operation_id = v_operation_id;
    if found then
      if v_prior.user_id <> v_user_id then raise exception 'operation belongs to another user' using errcode = '42501'; end if;
      operation_id := v_prior.operation_id;
      entity_type := v_prior.entity_type;
      entity_id := v_prior.entity_id;
      applied := v_prior.applied;
      remote_version := v_prior.remote_version;
      remote_deleted := v_prior.remote_deleted;
      remote_payload := v_prior.remote_payload;
      reason := v_prior.reason;
      return next;
      continue;
    end if;

    if v_entity_type not in ('account', 'transaction') or v_operation not in ('upsert', 'delete') then
      raise exception 'unsupported mutation';
    end if;
    if v_payload <> '{}'::jsonb and v_payload->>'id' is distinct from v_entity_id then
      raise exception 'payload id does not match entity id';
    end if;
    if v_operation = 'upsert' and v_entity_type = 'account' and (
      coalesce(btrim(v_payload->>'name'), '') = '' or
      coalesce(btrim(v_payload->>'type'), '') = '' or
      coalesce(btrim(v_payload->>'currency_code'), '') = '' or
      not (v_payload ? 'opening_balance_minor')
    ) then raise exception 'invalid account payload'; end if;
    if v_operation = 'upsert' and v_entity_type = 'transaction' then
      if coalesce(btrim(v_payload->>'description'), '') = '' or
        coalesce((v_payload->>'amount_minor')::bigint, 0) <= 0 or
        not exists (
          select 1 from public.accounts a
          where a.id = v_payload->>'account_id'
            and a.user_id = v_user_id and a.deleted_at is null
        )
      then raise exception 'invalid transaction payload'; end if;
      if v_payload->>'counter_account_id' is not null and not exists (
        select 1 from public.accounts a
        where a.id = v_payload->>'counter_account_id'
          and a.user_id = v_user_id and a.deleted_at is null
      ) then raise exception 'invalid counter account'; end if;
    end if;

    if v_entity_type = 'account' then
      select a.version, a.payload, a.deleted_at is not null
      into v_current_version, v_current_payload, v_deleted
      from public.accounts a where a.id = v_entity_id and a.user_id = v_user_id for update;
    else
      select t.version, t.payload, t.deleted_at is not null
      into v_current_version, v_current_payload, v_deleted
      from public.transactions t where t.id = v_entity_id and t.user_id = v_user_id for update;
    end if;
    v_current_version := coalesce(v_current_version, 0);

    if v_current_version <> v_base_version then
      insert into public.sync_mutations (
        operation_id, user_id, device_id, entity_type, entity_id, applied,
        remote_version, remote_deleted, remote_payload, reason
      ) values (
        v_operation_id, v_user_id, p_device_id, v_entity_type, v_entity_id,
        false, v_current_version, coalesce(v_deleted, false),
        coalesce(v_current_payload, '{}'::jsonb), 'remote_version_changed'
      );
      operation_id := v_operation_id; entity_type := v_entity_type; entity_id := v_entity_id;
      applied := false; remote_version := v_current_version;
      remote_deleted := coalesce(v_deleted, false);
      remote_payload := coalesce(v_current_payload, '{}'::jsonb); reason := 'remote_version_changed';
      return next;
      continue;
    end if;

    v_current_version := v_current_version + 1;
    v_deleted := v_operation = 'delete';
    if v_entity_type = 'account' then
      insert into public.accounts (id, user_id, payload, version, deleted_at)
      values (v_entity_id, v_user_id, v_payload, v_current_version, case when v_deleted then now() end)
      on conflict (id) do update set payload = excluded.payload, version = excluded.version,
        deleted_at = excluded.deleted_at, updated_at = now()
      where accounts.user_id = v_user_id;
    else
      insert into public.transactions (id, user_id, payload, version, deleted_at)
      values (v_entity_id, v_user_id, v_payload, v_current_version, case when v_deleted then now() end)
      on conflict (id) do update set payload = excluded.payload, version = excluded.version,
        deleted_at = excluded.deleted_at, updated_at = now()
      where transactions.user_id = v_user_id;
    end if;
    if not found then raise exception 'entity belongs to another user' using errcode = '42501'; end if;

    insert into public.sync_changes (user_id, entity_type, entity_id, version, deleted, payload)
    values (v_user_id, v_entity_type, v_entity_id, v_current_version, v_deleted, v_payload);
    insert into public.sync_mutations (
      operation_id, user_id, device_id, entity_type, entity_id, applied,
      remote_version, remote_deleted, remote_payload, reason
    ) values (
      v_operation_id, v_user_id, p_device_id, v_entity_type, v_entity_id,
      true, v_current_version, v_deleted, v_payload, null
    );
    operation_id := v_operation_id; entity_type := v_entity_type; entity_id := v_entity_id;
    applied := true; remote_version := v_current_version; remote_payload := v_payload; reason := null;
    remote_deleted := v_deleted;
    return next;
  end loop;
end;
$$;

create or replace function public.pull_sync_changes(p_after_cursor bigint, p_limit integer default 500)
returns jsonb
language sql
stable
security definer set search_path = public, pg_temp
as $$
  select case when auth.uid() is null then
    jsonb_build_object('cursor', greatest(p_after_cursor, 0), 'changes', '[]'::jsonb)
  else jsonb_build_object(
    'cursor', coalesce(max(cursor), greatest(p_after_cursor, 0)),
    'changes', coalesce(jsonb_agg(jsonb_build_object(
      'cursor', cursor, 'entity_type', entity_type, 'entity_id', entity_id,
      'version', version, 'deleted', deleted, 'payload', payload
    ) order by cursor), '[]'::jsonb)
  ) end
  from (
    select c.cursor, c.entity_type, c.entity_id, c.version, c.deleted, c.payload
    from public.sync_changes c
    where c.user_id = auth.uid() and c.cursor > greatest(p_after_cursor, 0)
    order by c.cursor limit least(greatest(p_limit, 1), 1000)
  ) page;
$$;

revoke all on function public.apply_sync_mutations(uuid, jsonb) from public, anon;
revoke all on function public.pull_sync_changes(bigint, integer) from public, anon;
grant execute on function public.apply_sync_mutations(uuid, jsonb) to authenticated;
grant execute on function public.pull_sync_changes(bigint, integer) to authenticated;
grant select on public.profiles, public.devices, public.accounts, public.transactions,
  public.sync_mutations, public.sync_changes to authenticated;
