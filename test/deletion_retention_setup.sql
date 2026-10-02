-- DISPOSABLE TEST CLUSTER ONLY. Minimal shapes of the verified live tables.
do $$
declare n integer;
begin
  for n in 1..3 loop
    execute format('create table public.ce_course%s_state (
      user_id uuid primary key references auth.users(id) on delete cascade,
      profile jsonb, progress jsonb, is_preview boolean not null)',n);
    execute format('create table public.ce_course%s_certificates (
      id uuid primary key default gen_random_uuid(),
      user_id uuid not null references auth.users(id) on delete restrict,
      snapshot jsonb, archive_path text, archive_sha256 text, archived_at timestamptz)',n);
  end loop;
end $$;
create table public.luma_ce_bonus_purchases (
  transaction_id text primary key, user_id uuid not null references auth.users(id),
  revoked_at timestamptz
);
insert into auth.users values
  ('00000000-0000-0000-0000-000000000004','retention@example.test',false);
do $$
declare n integer;
begin
  for n in 1..3 loop
    execute format('insert into public.ce_course%s_state values($1,$2,$3,$4)',n)
      using '00000000-0000-0000-0000-000000000004'::uuid,
        '{"full_name":"Test learner","aana_id":"test-number"}'::jsonb,
        '{"attempts":[{"score":12}],"evaluation":{"attestation":true}}'::jsonb,
        n=3;
    execute format('insert into public.ce_course%s_certificates(user_id,snapshot,archive_path,archive_sha256,archived_at) values($1,$2,$3,$4,now())',n)
      using '00000000-0000-0000-0000-000000000004'::uuid,
        '{"credits_awarded":1,"learner":{"aana_id":"test-number"}}'::jsonb,
        'fixture/test.pdf',repeat('a',64);
  end loop;
end $$;
insert into public.luma_ce_bonus_purchases(transaction_id,user_id)
  values('fixture-transaction','00000000-0000-0000-0000-000000000004');
update public.luma_account_deletion_settings set enabled=true,worker_checked_at=now();
set role authenticated;
select set_config('request.jwt.claim.sub','00000000-0000-0000-0000-000000000004',false);
select public.luma_request_account_deletion('DELETE MY ACCOUNT');
reset role;
