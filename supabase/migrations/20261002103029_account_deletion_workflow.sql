-- Applied October 2, 2026 after account_deletion_requests; intake remains disabled.
-- Intake/notifications only, NOT automatic account erasure.
begin;
alter table public.luma_account_deletion_settings
  add column worker_checked_at timestamptz,
  add column notification_email text check (
    notification_email is null or notification_email ~ '^[^[:space:]@]+@[^[:space:]@]+\.[^[:space:]@]+$'
  );
alter table public.luma_account_deletion_requests
  add column fulfillment_evidence jsonb,
  add column retained_records_summary text;

create table public.luma_account_deletion_mail (
  id uuid primary key default gen_random_uuid(),
  request_id uuid not null references public.luma_account_deletion_requests(id),
  kind text not null check (kind in ('staff_new','learner_received','staff_reminder','learner_completed')),
  dedupe_key text not null unique,
  -- Freeze recipient/body: provider idempotency requires identical retries.
  recipient text not null,
  subject text not null,
  body text not null,
  status text not null default 'queued'
    check (status in ('queued','sending','accepted','needs_attention')),
  attempts integer not null default 0,
  created_at timestamptz not null default now(),
  first_attempt_at timestamptz,
  next_attempt_at timestamptz not null default now(),
  lease_token uuid,
  lease_until timestamptz,
  provider_id text,
  accepted_at timestamptz,
  last_error_code text
);
create index deletion_mail_ready on public.luma_account_deletion_mail(next_attempt_at)
  where status in ('queued','sending');
alter table public.luma_account_deletion_mail enable row level security;
revoke all on public.luma_account_deletion_mail from public, anon, authenticated;
grant all on public.luma_account_deletion_mail to service_role;

-- One-use, short-lived dispatcher tokens minted inside the database by cron.
-- This avoids copying a long-lived scheduler secret between Vault and Edge.
create table public.luma_deletion_worker_tokens (
  token_hash bytea primary key,
  expires_at timestamptz not null
);
alter table public.luma_deletion_worker_tokens enable row level security;
revoke all on public.luma_deletion_worker_tokens from public,anon,authenticated;
grant all on public.luma_deletion_worker_tokens to service_role;
create function public.luma_consume_deletion_worker_token(p_token text)
returns boolean language plpgsql security definer set search_path='' as $$
begin
  if p_token is null or p_token !~ '^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$' then
    return false;
  end if;
  delete from public.luma_deletion_worker_tokens
    where token_hash=sha256(convert_to(p_token,'UTF8')) and expires_at>now();
  return found;
end $$;
revoke all on function public.luma_consume_deletion_worker_token(text) from public,anon,authenticated;
grant execute on function public.luma_consume_deletion_worker_token(text) to service_role;

-- Existing receipts remain readable during worker outages.
create function public.luma_my_account_deletion_request()
returns jsonb language sql stable security definer set search_path = '' as $$
  select jsonb_build_object('status',status,'request_id',id,'due_at',due_at)
  from public.luma_account_deletion_requests
  where user_id = (select auth.uid()) and status = 'pending'
  order by requested_at desc limit 1;
$$;
revoke all on function public.luma_my_account_deletion_request() from public, anon;
grant execute on function public.luma_my_account_deletion_request() to authenticated;

create or replace function public.luma_account_deletion_available()
returns boolean language sql stable security definer set search_path = '' as $$
  select auth.uid() is not null and exists (
    select 1 from public.luma_account_deletion_settings
    where id and enabled and notification_email is not null
      and worker_checked_at > now() - interval '15 minutes'
  );
$$;
create or replace function public.luma_request_account_deletion(confirmation text)
returns jsonb language plpgsql security definer set search_path = '' as $$
declare
  caller uuid := auth.uid();
  account_email text;
  receipt public.luma_account_deletion_requests;
begin
  if caller is null or confirmation is distinct from 'DELETE MY ACCOUNT' then
    raise exception 'Authenticated confirmation required' using errcode = '42501';
  end if;
  select email into account_email from auth.users
    where id = caller and not coalesce(is_anonymous, false);
  if account_email is null then
    raise exception 'A signed-in account is required' using errcode = '42501';
  end if;
  select * into receipt from public.luma_account_deletion_requests
    where user_id = caller and status = 'pending';
  if not found then
    if not public.luma_account_deletion_available() then
      raise exception 'Deletion request processing is not available';
    end if;
    insert into public.luma_account_deletion_requests(user_id, contact_email)
      values (caller, account_email)
      on conflict (user_id) where status = 'pending' do nothing;
    select * into strict receipt from public.luma_account_deletion_requests
      where user_id = caller and status = 'pending';
  end if;
  return jsonb_build_object('status','pending','request_id',receipt.id,'due_at',receipt.due_at);
end;
$$;

create function public.luma_deletion_queue_initial_mail()
returns trigger language plpgsql security definer set search_path = '' as $$
declare
  reference text := 'Request reference: ' || new.id::text;
  deadline text := to_char(new.due_at at time zone 'UTC','YYYY-MM-DD HH24:MI') || ' UTC';
  staff_recipient text;
begin
  select notification_email into strict staff_recipient
    from public.luma_account_deletion_settings where id;
  if staff_recipient is null then raise exception 'Configure deletion notification recipient first'; end if;
  insert into public.luma_account_deletion_mail
    (request_id,kind,dedupe_key,recipient,subject,body)
  values
    (new.id,'staff_new',new.id::text || ':staff_new',staff_recipient,
     'Luma Anesthesia: account deletion request',
     reference || E'\nAccount email: ' || new.contact_email || E'\nDue by: ' || deadline ||
     E'\n\nA signed-in user requested permanent account deletion. This is not yet completed.' ||
     E'\nReview the protected deletion queue. Preserve required CE program records, remove non-retained data, address processors and sign-in credentials, then record completion evidence.' ||
     E'\nDo not mark completed merely because this email was sent.'),
    (new.id,'learner_received',new.id::text || ':learner_received',new.contact_email,
     'Luma Anesthesia: deletion request received',
     reference || E'\nDue by: ' || deadline ||
     E'\n\nWe received your account-deletion request. Your account has not been deleted yet. CE HALO processes verified requests within seven calendar days and will email you when completed.' ||
     E'\nRequired CE program records may be retained for at least five years. See https://cehalo.com/privacy-policy for details.' ||
     E'\nDeleting your account does not cancel an Apple or Google subscription. Manage your store subscription separately to avoid future charges.' ||
     E'\nQuestions or did not request this? Contact info@cehalo.com.');
  return new;
end;
$$;
revoke all on function public.luma_deletion_queue_initial_mail() from public, anon, authenticated;
create trigger deletion_initial_mail after insert on public.luma_account_deletion_requests
  for each row execute function public.luma_deletion_queue_initial_mail();

-- Server-only RPCs. No caller-controlled recipients or message bodies.
create function public.luma_deletion_claim_mail()
returns setof public.luma_account_deletion_mail
language plpgsql security definer set search_path = '' as $$
begin
  insert into public.luma_account_deletion_mail
    (request_id,kind,dedupe_key,recipient,subject,body)
  select id,'staff_reminder',id::text || ':reminder:' || (now() at time zone 'UTC')::date::text,
    (select notification_email from public.luma_account_deletion_settings where id),
    'Luma Anesthesia: deletion deadline reminder',
    'Request reference: ' || id::text || E'\nDue by: ' ||
    to_char(due_at at time zone 'UTC','YYYY-MM-DD HH24:MI') || E' UTC\n\nThis request is still pending. Review and fulfill it; do not treat notification delivery as completed deletion.'
  from public.luma_account_deletion_requests
  where status = 'pending' and due_at <= now() + interval '2 days'
  on conflict (dedupe_key) do nothing;

  -- Stop before Resend's 24-hour idempotency window ends. Manual reconciliation
  -- is safer than an ambiguous resend with an expired provider key.
  update public.luma_account_deletion_mail
    set status='needs_attention', last_error_code='retry_window_or_attempts_exceeded',
        lease_token=null, lease_until=null
    where status in ('queued','sending')
      and (lease_until is null or lease_until < now())
      and (first_attempt_at < now() - interval '23 hours' or attempts >= 8);
  return query
    with ready as (
      select id from public.luma_account_deletion_mail
      where status in ('queued','sending') and next_attempt_at <= now()
        and (lease_until is null or lease_until < now())
      order by created_at for update skip locked limit 5
    )
    update public.luma_account_deletion_mail m
      set status='sending', attempts=attempts+1,
          first_attempt_at=coalesce(first_attempt_at,now()),
          lease_token=gen_random_uuid(), lease_until=now()+interval '2 minutes'
      from ready where m.id=ready.id returning m.*;
end;
$$;
create function public.luma_deletion_finish_mail(
  p_id uuid, p_lease uuid, p_provider_id text, p_error_code text default null
)
returns boolean language plpgsql security definer set search_path = '' as $$
begin
  update public.luma_account_deletion_mail
  set status=case when p_provider_id is not null then 'accepted'
                  when attempts >= 8 then 'needs_attention' else 'queued' end,
      provider_id=p_provider_id,
      accepted_at=case when p_provider_id is not null then now() else null end,
      last_error_code=case when p_provider_id is not null then null else left(p_error_code,80) end,
      next_attempt_at=now()+make_interval(secs => least(1800,60*(2^least(attempts,5))::integer)),
      lease_token=null, lease_until=null
  where id=p_id and status='sending' and lease_token=p_lease and lease_until > now();
  return found;
end;
$$;
create function public.luma_deletion_worker_healthy()
returns void language sql security definer set search_path = '' as $$
  update public.luma_account_deletion_settings set worker_checked_at=now()
  where id and not exists (
    select 1 from public.luma_account_deletion_mail
    where status <> 'accepted' and (status='needs_attention' or last_error_code is not null)
  );
$$;

-- Completion receipt, not erasure. Require evidence AND an absent auth account.
create function public.luma_complete_account_deletion(
  p_request_id uuid, p_evidence jsonb, p_retained_summary text
)
returns void language plpgsql security definer set search_path = '' as $$
declare r public.luma_account_deletion_requests; k text;
begin
  select * into strict r from public.luma_account_deletion_requests
    where id=p_request_id for update;
  if r.status='completed' then return; end if;
  if r.user_id is not null then raise exception 'Auth account has not been deleted'; end if;
  foreach k in array array['retention_verified','nonretained_data_removed',
    'processors_addressed','signin_tokens_addressed','sessions_revoked'] loop
    if (p_evidence->k) is distinct from 'true'::jsonb then
      raise exception 'Missing fulfillment evidence: %',k;
    end if;
  end loop;
  if length(trim(coalesce(p_evidence->>'operator',''))) < 3 or
     length(trim(coalesce(p_evidence->>'note',''))) < 20 or
     length(trim(coalesce(p_retained_summary,''))) < 10 then
    raise exception 'Operator, fulfillment note and retained-record explanation required';
  end if;
  update public.luma_account_deletion_requests
    set status='completed',completed_at=now(),fulfillment_note=p_evidence->>'note',
        fulfillment_evidence=p_evidence,retained_records_summary=p_retained_summary
    where id=p_request_id;
  insert into public.luma_account_deletion_mail
    (request_id,kind,dedupe_key,recipient,subject,body)
  values (r.id,'learner_completed',r.id::text || ':learner_completed',r.contact_email,
    'Luma Anesthesia: account deletion completed',
    'Request reference: ' || r.id::text ||
    E'\n\nYour Luma Anesthesia account deletion is complete. Non-retained personal data under our control has been removed or de-identified.' ||
    E'\nRetained records: ' || p_retained_summary ||
    E'\nThese records are restricted to the necessary purposes described at https://cehalo.com/privacy-policy.' ||
    E'\nAccount deletion does not cancel Apple or Google subscriptions or issue a refund. Manage subscriptions in your app-store account.' ||
    E'\nQuestions? Contact info@cehalo.com.')
  on conflict (dedupe_key) do nothing;
end;
$$;
revoke all on function public.luma_deletion_claim_mail(),
  public.luma_deletion_finish_mail(uuid,uuid,text,text),
  public.luma_deletion_worker_healthy(),
  public.luma_complete_account_deletion(uuid,jsonb,text)
  from public,anon,authenticated;
grant execute on function public.luma_deletion_claim_mail(),
  public.luma_deletion_finish_mail(uuid,uuid,text,text),
  public.luma_deletion_worker_healthy(),
  public.luma_complete_account_deletion(uuid,jsonb,text) to service_role;
commit;
