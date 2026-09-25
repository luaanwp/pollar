-- Entity IDs are local ledger identifiers, not globally unique identifiers.
-- Existing users may already have the same seeded or imported IDs.
alter table public.accounts drop constraint accounts_pkey;
alter table public.accounts add primary key (user_id, id);
alter table public.transactions drop constraint transactions_pkey;
alter table public.transactions add primary key (user_id, id);

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
  if coalesce(auth.jwt()->>'aal', '') <> 'aal2' then
    raise exception 'second factor required' using errcode = '42501';
  end if;
  if jsonb_typeof(p_mutations) <> 'array' then raise exception 'p_mutations must be an array'; end if;

  perform pg_advisory_xact_lock(hashtextextended(v_user_id::text, 0));

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
      on conflict (user_id, id) do update set payload = excluded.payload, version = excluded.version,
        deleted_at = excluded.deleted_at, updated_at = now();
    else
      insert into public.transactions (id, user_id, payload, version, deleted_at)
      values (v_entity_id, v_user_id, v_payload, v_current_version, case when v_deleted then now() end)
      on conflict (user_id, id) do update set payload = excluded.payload, version = excluded.version,
        deleted_at = excluded.deleted_at, updated_at = now();
    end if;

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
  select case when auth.uid() is null or coalesce(auth.jwt()->>'aal', '') <> 'aal2' then
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
      and coalesce(auth.jwt()->>'aal', '') = 'aal2'
    order by c.cursor limit least(greatest(p_limit, 1), 1000)
  ) page;
$$;

-- Security-definer RPCs bypass row policies; direct table reads must also require MFA.
create policy "profiles_mfa" on public.profiles as restrictive for all to authenticated
  using ((select auth.jwt()->>'aal') = 'aal2')
  with check ((select auth.jwt()->>'aal') = 'aal2');
create policy "devices_mfa" on public.devices as restrictive for all to authenticated
  using ((select auth.jwt()->>'aal') = 'aal2')
  with check ((select auth.jwt()->>'aal') = 'aal2');
create policy "accounts_mfa" on public.accounts as restrictive for all to authenticated
  using ((select auth.jwt()->>'aal') = 'aal2')
  with check ((select auth.jwt()->>'aal') = 'aal2');
create policy "transactions_mfa" on public.transactions as restrictive for all to authenticated
  using ((select auth.jwt()->>'aal') = 'aal2')
  with check ((select auth.jwt()->>'aal') = 'aal2');
create policy "mutations_mfa" on public.sync_mutations as restrictive for all to authenticated
  using ((select auth.jwt()->>'aal') = 'aal2')
  with check ((select auth.jwt()->>'aal') = 'aal2');
create policy "changes_mfa" on public.sync_changes as restrictive for all to authenticated
  using ((select auth.jwt()->>'aal') = 'aal2')
  with check ((select auth.jwt()->>'aal') = 'aal2');
