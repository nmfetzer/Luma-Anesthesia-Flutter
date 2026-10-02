-- PREPARED ONLY. Separate approval required before changing production FKs.
-- Keeps certificate/payment ledgers intact after login removal. Copies required
-- learning evidence into a restricted archive in the SAME transaction as auth
-- deletion. Never deletes an auth user itself; no public erasure endpoint.
begin;
create table public.luma_deleted_account_ce_records (
  id uuid primary key default gen_random_uuid(),
  request_id uuid not null references public.luma_account_deletion_requests(id),
  former_user_id uuid not null,
  source_table text not null,
  record jsonb not null,
  retained_at timestamptz not null default now(),
  -- Conservative operational floor, not a claim that AANA defines this start.
  review_not_before timestamptz not null default now()+interval '60 months',
  unique(request_id,source_table)
);
alter table public.luma_deleted_account_ce_records enable row level security;
revoke all on public.luma_deleted_account_ce_records from public, anon, authenticated;
grant select,insert on public.luma_deleted_account_ce_records to service_role;
comment on table public.luma_deleted_account_ce_records is
  'Restricted CE program evidence retained after account deletion. Manual retention review after floor; no automatic purge. Original certificate and purchase ledgers remain unchanged.';

-- Auth deletion must not destroy required evidence, and cannot be made possible
-- by removing a certificate from the award ledger. Keep its former user UUID.
-- Existing certificate immutability triggers and provider reporting are unchanged.
do $$
declare tbl text; fk record; total integer;
begin
  foreach tbl in array array['ce_course1_certificates','ce_course2_certificates',
    'ce_course3_certificates','luma_ce_bonus_purchases'] loop
    total:=0;
    for fk in
      select k.conname from pg_catalog.pg_constraint k
      join pg_catalog.pg_attribute a on a.attrelid=k.conrelid and a.attnum=any(k.conkey)
      where k.conrelid=pg_catalog.to_regclass('public.' || tbl)
        and k.contype='f' and k.confrelid='auth.users'::regclass
        and a.attname='user_id'
    loop
      total:=total+1;
      execute format('alter table public.%I drop constraint %I',tbl,fk.conname);
    end loop;
    if total<>1 then raise exception 'Unexpected auth FK shape for %',tbl; end if;
  end loop;
end $$;

-- Replacement write validation: no new award/purchase may target a missing
-- login, while retained records can still receive permitted archive/refund updates.
create function public.luma_retained_ledger_user_guard()
returns trigger language plpgsql security definer set search_path='' as $$
begin
  if tg_op='UPDATE' then
    if new.user_id=old.user_id then return new; end if;
  end if;
  if not exists(select 1 from auth.users where id=new.user_id for key share) then
    raise exception 'A live account is required for a new ledger association';
  end if;
  return new;
end $$;
revoke all on function public.luma_retained_ledger_user_guard() from public,anon,authenticated;
do $$
declare tbl text;
begin
  foreach tbl in array array['ce_course1_certificates','ce_course2_certificates',
    'ce_course3_certificates','luma_ce_bonus_purchases'] loop
    execute format('create trigger retained_user_guard before insert or update of user_id on public.%I for each row execute function public.luma_retained_ledger_user_guard()',tbl);
  end loop;
end $$;

-- The operator attests completion of external steps BEFORE Auth Admin removal.
-- No credentials or data are removed by this preparation RPC.
create function public.luma_prepare_account_deletion(p_request_id uuid, p_evidence jsonb)
returns void language plpgsql security definer set search_path='' as $$
declare r public.luma_account_deletion_requests; k text;
begin
  select * into strict r from public.luma_account_deletion_requests
    where id=p_request_id and status='pending' for update;
  if r.user_id is null then raise exception 'Account already removed; review completion instead'; end if;
  foreach k in array array['nonretained_data_removed','processors_addressed',
    'signin_tokens_addressed','sessions_revoked','certificate_archives_verified'] loop
    if (p_evidence->k) is distinct from 'true'::jsonb then
      raise exception 'Missing pre-erasure evidence: %',k;
    end if;
  end loop;
  if length(trim(coalesce(p_evidence->>'operator','')))<3
    or length(trim(coalesce(p_evidence->>'note','')))<20 then
    raise exception 'Operator and fulfillment note required';
  end if;
  update public.luma_account_deletion_requests
    set fulfillment_evidence=p_evidence || jsonb_build_object('prepared_at',now())
    where id=p_request_id;
end $$;
revoke all on function public.luma_prepare_account_deletion(uuid,jsonb) from public,anon,authenticated;
grant execute on function public.luma_prepare_account_deletion(uuid,jsonb) to service_role;

create function public.luma_archive_ce_before_auth_deletion()
returns trigger language plpgsql security definer set search_path='' as $$
declare
  r public.luma_account_deletion_requests;
  tbl text; payload jsonb; has_unarchived boolean; k text;
begin
  select * into r from public.luma_account_deletion_requests
    where user_id=old.id and status='pending' for update;
  if not found then
    raise exception 'Record and verify an account-deletion request before removing this login';
  end if;
  foreach k in array array['nonretained_data_removed','processors_addressed',
    'signin_tokens_addressed','sessions_revoked','certificate_archives_verified'] loop
    if (r.fulfillment_evidence->k) is distinct from 'true'::jsonb then
      raise exception 'Deletion fulfillment must be prepared before login removal';
    end if;
  end loop;
  if coalesce((r.fulfillment_evidence->>'prepared_at')::timestamptz,'epoch') < now()-interval '1 hour' then
    raise exception 'Deletion preparation expired; recheck external fulfillment';
  end if;
  -- New CE tables must be reviewed before any deletion can proceed. Do not
  -- silently skip a course added by another session or future release.
  if exists(
    select 1 from information_schema.tables where table_schema='public'
      and (table_name like 'ce_course%_state' or table_name like 'ce_course%_certificates')
      and table_name not in ('ce_course1_state','ce_course2_state','ce_course3_state',
        'ce_course1_certificates','ce_course2_certificates','ce_course3_certificates')
  ) then raise exception 'New CE tables require retention review'; end if;

  foreach tbl in array array['ce_course1_certificates','ce_course2_certificates','ce_course3_certificates'] loop
    -- Lock awards; do not modify or relocate their rows or stored PDF paths.
    execute format('select exists(select 1 from public.%I where user_id=$1 and (archive_path is null or archive_sha256 is null or archived_at is null))',tbl)
      into has_unarchived using old.id;
    if has_unarchived then raise exception 'Finish and verify certificate PDF archives before deletion'; end if;
    execute format('select coalesce(jsonb_agg(to_jsonb(c)),''[]''::jsonb) from (select * from public.%I where user_id=$1 for update) c',tbl)
      into payload using old.id;
    if jsonb_array_length(payload)>0 then
      insert into public.luma_deleted_account_ce_records(request_id,former_user_id,source_table,record)
        values(r.id,old.id,tbl,payload);
    end if;
  end loop;
  foreach tbl in array array['ce_course1_state','ce_course2_state','ce_course3_state'] loop
    -- Locks also serialize in-flight assessment/progress writes.
    execute format('select to_jsonb(s) from public.%I s where user_id=$1 for update',tbl)
      into payload using old.id;
    if payload is not null and payload->>'is_preview'='false' then
      insert into public.luma_deleted_account_ce_records(request_id,former_user_id,source_table,record)
        values(r.id,old.id,tbl,payload);
    end if;
  end loop;
  update public.luma_account_deletion_requests
    set fulfillment_evidence=fulfillment_evidence || jsonb_build_object(
      'retention_verified',true,'retention_archived_at',now())
    where id=r.id;
  return old;
end $$;
revoke all on function public.luma_archive_ce_before_auth_deletion() from public,anon,authenticated;
create trigger luma_retain_ce_on_auth_deletion before delete on auth.users
  for each row execute function public.luma_archive_ce_before_auth_deletion();
commit;
