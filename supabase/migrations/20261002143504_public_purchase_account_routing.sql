-- Applied migration 20261002143504. Keep sandbox eligibility for review, but never route paying learners to
-- sandbox ownership or preview certificates after verified production activity.
begin;
create or replace function luma_review.is_tester(uid uuid)
returns boolean language plpgsql stable security definer set search_path='' as $$
declare n integer; occupied boolean;
begin
  if not exists (
    select 1 from luma_review.accounts a join auth.users u on u.id=a.user_id
    where a.user_id=uid and a.revoked_at is null and a.expires_at>now()
      and u.is_anonymous=false and u.email_confirmed_at is not null
      and (u.banned_until is null or u.banned_until<=now())
  ) then return false; end if;
  if exists(select 1 from public.luma_ce_bonus_purchases where user_id=uid)
    or exists(select 1 from public.luma_content_entitlements where user_id=uid)
    or exists(select 1 from public.luma_revenuecat_access
      where user_id=uid and active and valid_until>now())
  then return false; end if;
  for n in 1..3 loop
    execute format(
      'select exists(select 1 from public.ce_course%s_reviewers where user_id=$1)
       or exists(select 1 from public.ce_course%s_certificates where user_id=$1)
       or exists(select 1 from public.ce_course%s_state
         where user_id=$1 and not is_preview)',n,n,n)
      into occupied using uid;
    if occupied then return false; end if;
  end loop;
  return true;
end $$;
revoke all on function luma_review.is_tester(uuid)
  from public,anon,authenticated,service_role;
commit;
