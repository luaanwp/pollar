create extension if not exists pgtap with schema extensions;

begin;
select plan(15);

select has_table('public', 'accounts', 'accounts table exists');
select has_table('public', 'sync_mutations', 'idempotency ledger exists');
select has_function('public', 'apply_sync_mutations', array['uuid', 'jsonb'], 'push RPC exists');
select has_function('public', 'pull_sync_changes', array['bigint', 'integer'], 'pull RPC exists');
select policies_are('public', 'accounts', array['accounts_read_own'], 'accounts exposes only an own-row policy');
select policies_are('public', 'transactions', array['transactions_read_own'], 'transactions exposes only an own-row policy');

insert into auth.users (id, email)
values
  ('10000000-0000-0000-0000-000000000001', 'one@example.test'),
  ('20000000-0000-0000-0000-000000000002', 'two@example.test');

set local role authenticated;
set local request.jwt.claim.sub = '10000000-0000-0000-0000-000000000001';

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
  1::bigint,
  'first pull page stops at its last visible cursor'
);
select is(
  (public.pull_sync_changes(1, 1)->>'cursor')::bigint,
  2::bigint,
  'next pull page resumes without skipping a change'
);

set local request.jwt.claim.sub = '20000000-0000-0000-0000-000000000002';
select is(
  (select count(*) from public.accounts),
  0::bigint,
  'RLS hides another user account'
);
select is(
  jsonb_array_length(public.pull_sync_changes(0, 500)->'changes'),
  0,
  'pull also hides another user changes'
);

select * from finish();
rollback;
