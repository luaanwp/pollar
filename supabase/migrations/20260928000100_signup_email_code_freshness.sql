-- Confirmed first-time email signups use the email/signup AMR method instead
-- of otp or magiclink. They still require AAL2 and a recent confirmation.
create or replace function public.has_recent_email_code()
returns boolean
language sql
stable
set search_path = public, pg_temp
as $$
  select coalesce(auth.jwt()->>'aal', '') = 'aal2' and exists (
    select 1
    from jsonb_array_elements(coalesce(auth.jwt()->'amr', '[]'::jsonb)) method
    where method->>'method' in ('otp', 'magiclink', 'email/signup')
      and (method->>'timestamp')::bigint >= extract(epoch from now() - interval '10 days')::bigint
  );
$$;
