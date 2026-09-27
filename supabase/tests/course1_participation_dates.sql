-- Provider-only fixture changes are rolled back. Never writes an award.
begin;
do $$
declare uid uuid; response jsonb; blocked boolean; original jsonb; awards integer;
begin
  select count(*) into awards from public.ce_course1_certificates;
  if public.ce_course1_participation_error('','',false) is not null
    or public.ce_course1_participation_error('2026-10-01','2026-10-03',true) is not null
    or public.ce_course1_participation_error('2026-10-01','',true) is null
    or public.ce_course1_participation_error('2026-02-30','2026-10-03',true) is null
    or public.ce_course1_participation_error('2026-10-03','2026-10-01',true) is null
    or public.ce_course1_participation_error('2026-09-30','2026-10-03',true) is null
    or public.ce_course1_participation_error('2029-09-30','2029-10-01',true) is null then
    raise exception 'Date validation regression';
  end if;
  if (now() at time zone 'America/New_York')::date < date '2026-10-03'
    and public.ce_course1_participation_error('2026-10-01','2026-10-03',false) is null then
    raise exception 'Future actual participation dates allowed';
  end if;
  select user_id into uid from public.ce_course1_reviewers limit 1;
  perform set_config('request.jwt.claim.sub',uid::text,true);
  select profile into original from public.ce_course1_state where user_id=uid;
  response := public.ce_course1('profile', original || jsonb_build_object(
    'participation_start_on','2026-10-01','participation_end_on','2026-10-03'));
  response := public.ce_course1('access');
  if response->'profile'->>'participation_start_on'<>'2026-10-01'
    or response->'profile'->>'participation_end_on'<>'2026-10-03' then
    raise exception 'Dates not saved with profile';
  end if;
  -- Older app versions must not accidentally clear the new profile fields.
  perform public.ce_course1('profile',original-'participation_start_on'-'participation_end_on');
  response := public.ce_course1_certificate('preview');
  if response->'certificate'->>'participation_start_on'<>'2026-10-01'
    or response->'certificate'->>'participation_end_on'<>'2026-10-03'
    or response->'certificate'->>'completed_at' is not null
    or response->'certificate'->>'credits_awarded'<>'0' then
    raise exception 'Preview date mapping incorrect';
  end if;
  blocked := false;
  begin
    perform public.ce_course1('profile',original || jsonb_build_object(
      'participation_start_on','2026-10-05','participation_end_on','2026-10-03'));
  exception when others then blocked := true; end;
  if not blocked then raise exception 'Profile accepted reversed dates'; end if;
  perform public.ce_course1('profile',original || jsonb_build_object(
    'participation_start_on','','participation_end_on',''));
  if public.ce_course1('access')->'profile'->>'participation_start_on'<>''
    or (select count(*) from public.ce_course1_certificates)<>awards
    or exists(select 1 from public.ce_course1_certificate_settings where enabled or approved_at is not null)
    or exists(select 1 from public.ce_course1_catalog where id='1047239' and released) then
    raise exception 'Unexpected date clearing, award or release state';
  end if;
end $$;
rollback;
select 'PASS: dates validated, saved, previewed, legacy-compatible; no award or release changes' as participation_safety;
