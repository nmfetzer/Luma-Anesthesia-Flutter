-- Disposable PostgreSQL fixture only, never run on Supabase.
create role anon;
create role authenticated;
create role service_role bypassrls;
create schema auth;
create table auth.users(id uuid primary key, email text, is_anonymous boolean);
create function auth.uid() returns uuid language sql stable as $$
  select nullif(current_setting('request.jwt.claim.sub', true), '')::uuid;
$$;
grant usage on schema auth to authenticated, anon, service_role;
grant execute on function auth.uid() to authenticated, anon, service_role;
insert into auth.users values
  ('00000000-0000-0000-0000-000000000001','first@example.test',false),
  ('00000000-0000-0000-0000-000000000002','second@example.test',false);
