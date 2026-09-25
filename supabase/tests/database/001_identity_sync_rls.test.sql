create extension if not exists pgtap with schema extensions;

begin;
select plan(22);

select has_table('public', 'accounts', 'accounts table exists');
select has_table('public', 'sync_mutations', 'idempotency ledger exists');
select has_function('public', 'apply_sync_mutations', array['uuid', 'jsonb'], 'push RPC exists');
select has_function('public', 'pull_sync_changes', array['bigint', 'integer'], 'pull RPC exists');
select policies_are('public', 'accounts', array['accounts_read_own', 'accounts_mfa', 'accounts_recent_email'], 'accounts requires ownership, MFA and recent email');
select policies_are('public', 'transactions', array['transactions_read_own', 'transactions_mfa', 'transactions_recent_email'], 'transactions requires ownership, MFA and recent email');

insert into auth.users (id, email)
values
  ('10000000-0000-0000-0000-000000000001', 'one@example.test'),
  ('20000000-0000-0000-0000-000000000002', 'two@example.test');

set local role authenticated;
set local request.jwt.claim.sub = '10000000-0000-0000-0000-000000000001';
do $claims$ begin
  perform set_config('request.jwt.claims', jsonb_build_object(
    'sub', '10000000-0000-0000-0000-000000000001', 'aal', 'aal2',
    'amr', jsonb_build_array(jsonb_build_object('method', 'otp', 'timestamp', extract(epoch from now())::bigint))
  )::text, true);
end $claims$;

select is(
  (
    select remote_version from public.apply_sync_mutations(
      '10000000-0000-0000-0000-000000000010',
      jsonb_build_array(jsonb_build_object(
        'operation_id', '10000000-0000-0000-0000-000000000020',
        'entity_type', 'account',
        'entity_id', 'checking-main',
        'operation', 'upsert',
        'base_version', 0,
        'payload', jsonb_build_object(
          'id', 'checking-main',
          'name', 'Conta teste', 'type', 'checking',
          'currency_code', 'BRL', 'currency_decimal_digits', 2,
          'currency_symbol', 'R$', 'opening_balance_minor', 0,
          'status', 'active'
        )
      ))
    )
  ),
  1::bigint,
  'first operation creates remote version 1'
);

select is(
  (
    select remote_version from public.apply_sync_mutations(
      '10000000-0000-0000-0000-000000000010',
      jsonb_build_array(jsonb_build_object(
        'operation_id', '10000000-0000-0000-0000-000000000020',
        'entity_type', 'account',
        'entity_id', 'checking-main',
        'operation', 'upsert',
        'base_version', 0,
        'payload', jsonb_build_object(
          'id', 'checking-main',
          'name', 'Conta teste', 'type', 'checking',
          'currency_code', 'BRL', 'currency_decimal_digits', 2,
          'currency_symbol', 'R$', 'opening_balance_minor', 0,
          'status', 'active'
        )
      ))
    )
  ),
  1::bigint,
  'replaying an operation returns the original version'
);

select is(
  (select count(*) from public.sync_changes),
  1::bigint,
  'replaying an operation does not duplicate the change'
);
select is(
  (select count(*) from public.accounts),
  1::bigint,
  'the owner can read the synchronized account'
);

select is(
  (
    select remote_version from public.apply_sync_mutations(
      '10000000-0000-0000-0000-000000000010',
      jsonb_build_array(jsonb_build_object(
        'operation_id', '10000000-0000-0000-0000-000000000021',
        'entity_type', 'transaction',
        'entity_id', 'tx-local-1',
        'operation', 'upsert',
        'base_version', 0,
        'payload', jsonb_build_object(
          'id', 'tx-local-1', 'account_id', 'checking-main',
          'description', 'Despesa teste', 'amount_minor', 100
        )
      ))
    )
  ),
  1::bigint,
  'transaction can reference a seeded non-UUID account'
);

select is(
  (public.pull_sync_changes(0, 1)->>'cursor')::bigint,
  (select min(cursor) from public.sync_changes),
  'first pull page stops at its last visible cursor'
);
select is(
  (public.pull_sync_changes((select min(cursor) from public.sync_changes), 1)->>'cursor')::bigint,
  (select cursor from public.sync_changes order by cursor offset 1 limit 1),
  'next pull page resumes without skipping a change'
);

set local request.jwt.claim.sub = '20000000-0000-0000-0000-000000000002';
do $claims$ begin
  perform set_config('request.jwt.claims', jsonb_build_object(
    'sub', '20000000-0000-0000-0000-000000000002', 'aal', 'aal2',
    'amr', jsonb_build_array(jsonb_build_object('method', 'otp', 'timestamp', extract(epoch from now())::bigint))
  )::text, true);
end $claims$;
select is(
  (
    select remote_version from public.apply_sync_mutations(
      '20000000-0000-0000-0000-000000000010',
      jsonb_build_array(jsonb_build_object(
        'operation_id', '20000000-0000-0000-0000-000000000020',
        'entity_type', 'account', 'entity_id', 'checking-main',
        'operation', 'upsert', 'base_version', 0,
        'payload', jsonb_build_object(
          'id', 'checking-main', 'name', 'Outra conta', 'type', 'checking',
          'currency_code', 'BRL', 'currency_decimal_digits', 2,
          'currency_symbol', 'R$', 'opening_balance_minor', 0,
          'status', 'active'
        )
      ))
    )
  ),
  1::bigint,
  'different users can sync the same local account ID'
);
select is((select count(*) from public.accounts where id = 'checking-main'), 1::bigint,
  'each user sees only their own copy of a shared local ID');
select is(
  (select count(*) from public.accounts where payload->>'name' = 'Conta teste'),
  0::bigint,
  'RLS hides another user account'
);
select is(
  jsonb_array_length(public.pull_sync_changes(0, 500)->'changes'),
  1,
  'pull sees only this user change despite matching entity ID'
);

do $claims$ begin
  perform set_config('request.jwt.claims', jsonb_build_object(
    'sub', '20000000-0000-0000-0000-000000000002', 'aal', 'aal1',
    'amr', jsonb_build_array(jsonb_build_object('method', 'otp', 'timestamp', extract(epoch from now())::bigint))
  )::text, true);
end $claims$;
select is((select count(*) from public.accounts), 0::bigint,
  'first-factor session cannot read accounts');
select throws_ok(
  $$select public.pull_sync_changes(0, 500)$$,
  '42501', 'recent email code required',
  'first-factor session cannot pull changes'
);
select throws_ok(
  $$select * from public.apply_sync_mutations(
    '20000000-0000-0000-0000-000000000010', '[]'::jsonb)$$,
  '42501', 'recent email code required',
  'first-factor session cannot push mutations'
);

do $claims$ begin
  perform set_config('request.jwt.claims', jsonb_build_object(
    'sub', '20000000-0000-0000-0000-000000000002', 'aal', 'aal2',
    'amr', jsonb_build_array(jsonb_build_object('method', 'otp', 'timestamp', extract(epoch from now() - interval '11 days')::bigint))
  )::text, true);
end $claims$;
select is((select count(*) from public.accounts), 0::bigint,
  'expired email verification cannot read accounts');
select throws_ok(
  $$select public.pull_sync_changes(0, 500)$$,
  '42501', 'recent email code required',
  'expired email verification cannot pull changes'
);

select * from finish();
rollback;
