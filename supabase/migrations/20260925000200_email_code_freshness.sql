-- An AAL2 session is not enough once its email verification is over ten days old.
-- Supabase records the first-factor verification time in the signed JWT's AMR.
create function public.has_recent_email_code()
returns boolean
language sql
stable
set search_path = public, pg_temp
as $$
  select coalesce(auth.jwt()->>'aal', '') = 'aal2' and exists (
    select 1
    from jsonb_array_elements(coalesce(auth.jwt()->'amr', '[]'::jsonb)) method
    where method->>'method' in ('otp', 'magiclink')
      and (method->>'timestamp')::bigint >= extract(epoch from now() - interval '10 days')::bigint
  );
$$;

-- Restrictive policies compose with both ownership and the existing AAL2 rule.
create policy "profiles_recent_email" on public.profiles as restrictive for all to authenticated
  using ((select public.has_recent_email_code()))
  with check ((select public.has_recent_email_code()));
create policy "devices_recent_email" on public.devices as restrictive for all to authenticated
  using ((select public.has_recent_email_code()))
  with check ((select public.has_recent_email_code()));
create policy "accounts_recent_email" on public.accounts as restrictive for all to authenticated
  using ((select public.has_recent_email_code()))
  with check ((select public.has_recent_email_code()));
create policy "transactions_recent_email" on public.transactions as restrictive for all to authenticated
  using ((select public.has_recent_email_code()))
  with check ((select public.has_recent_email_code()));
create policy "mutations_recent_email" on public.sync_mutations as restrictive for all to authenticated
  using ((select public.has_recent_email_code()))
  with check ((select public.has_recent_email_code()));
create policy "changes_recent_email" on public.sync_changes as restrictive for all to authenticated
  using ((select public.has_recent_email_code()))
  with check ((select public.has_recent_email_code()));

-- The original RPCs are SECURITY DEFINER and bypass RLS, so gate them too.
alter function public.apply_sync_mutations(uuid, jsonb) rename to apply_sync_mutations_verified;
alter function public.pull_sync_changes(bigint, integer) rename to pull_sync_changes_verified;
revoke all on function public.apply_sync_mutations_verified(uuid, jsonb) from public, anon, authenticated;
revoke all on function public.pull_sync_changes_verified(bigint, integer) from public, anon, authenticated;

create function public.apply_sync_mutations(p_device_id uuid, p_mutations jsonb)
returns table (
  operation_id uuid, entity_type text, entity_id text, applied boolean,
  remote_version bigint, remote_deleted boolean, remote_payload jsonb, reason text
)
language plpgsql
security definer set search_path = public, pg_temp
as $$
begin
  if not public.has_recent_email_code() then
    raise exception 'recent email code required' using errcode = '42501';
  end if;
  return query select * from public.apply_sync_mutations_verified(p_device_id, p_mutations);
end;
$$;

create function public.pull_sync_changes(p_after_cursor bigint, p_limit integer default 500)
returns jsonb
language plpgsql
stable
security definer set search_path = public, pg_temp
as $$
begin
  if not public.has_recent_email_code() then
    raise exception 'recent email code required' using errcode = '42501';
  end if;
  return public.pull_sync_changes_verified(p_after_cursor, p_limit);
end;
$$;

revoke all on function public.apply_sync_mutations(uuid, jsonb) from public, anon;
revoke all on function public.pull_sync_changes(bigint, integer) from public, anon;
grant execute on function public.apply_sync_mutations(uuid, jsonb) to authenticated;
grant execute on function public.pull_sync_changes(bigint, integer) to authenticated;
