-- Run only as database owner. Every fixture/change is rolled back.
begin;
do $$
declare uid uuid; response jsonb; blocked boolean;
begin
  if has_function_privilege('anon','public.ce_course1_certificate(text)','EXECUTE')
    or has_table_privilege('authenticated','public.ce_course1_certificates','INSERT')
    or has_table_privilege('authenticated','public.ce_course1_certificates','SELECT')
    or has_table_privilege('authenticated','public.ce_course1_certificate_settings','UPDATE') then
    raise exception 'Certificate grants too broad';
  end if;
  perform set_config('request.jwt.claim.sub','',true);
  blocked := false;
  begin perform public.ce_course1_certificate('status');
  exception when others then blocked := true; end;
  if not blocked then raise exception 'Unauthenticated access allowed'; end if;

  select user_id into uid from public.ce_course1_reviewers limit 1;
  if uid is null then raise exception 'Provider fixture unavailable'; end if;
  perform set_config('request.jwt.claim.sub',uid::text,true);
  response := public.ce_course1_certificate('status');
  if response->>'can_issue' <> 'false' or response->>'can_preview' <> 'true'
    or jsonb_array_length(response->'modules')<>11 then
    raise exception 'Provider status incorrect';
  end if;
  response := public.ce_course1_certificate('preview');
  if response->'certificate'->>'credits_awarded'<>'0'
    or response->'certificate'->>'is_preview'<>'true'
    or exists(select 1 from public.ce_course1_certificates where user_id=uid) then
    raise exception 'Preview improperly creates award';
  end if;
  blocked := false;
  begin perform public.ce_course1_certificate('issue');
  exception when others then blocked := true; end;
  if not blocked then raise exception 'Provider issued real credit'; end if;

  -- Never touches a real learner or receipt. This synthetic account is rolled back.
  uid := gen_random_uuid();
  insert into auth.users(id,is_anonymous) values(uid,false);
  insert into public.ce_course1_state(user_id,is_preview,profile)
    values(uid,false,'{"full_name":"Test Learner","credentials":"CRNA","location":"Test City, NY"}');
  perform set_config('request.jwt.claim.sub',uid::text,true);
  response := public.ce_course1_certificate('status');
  if response->>'can_issue'<>'false' or response->>'can_preview'<>'false' then
    raise exception 'Unpaid/incomplete learner eligible';
  end if;
  blocked := false;
  begin perform public.ce_course1_certificate('preview');
  exception when others then blocked := true; end;
  if not blocked then raise exception 'Non-provider preview allowed'; end if;
  blocked := false;
  begin perform public.ce_course1_certificate('issue');
  exception when others then blocked := true; end;
  if not blocked then raise exception 'Unpaid learner issued certificate'; end if;
  -- Stored snapshots are stable on repeat retrieval and isolated by auth.uid().
  insert into public.ce_course1_certificates(user_id,course_id,completed_at,snapshot)
    values(uid,'1047239',now(),'{"id":"TEST-ROLLBACK","learner":{"full_name":"Snapshot Name"}}');
  update public.ce_course1_state set profile=jsonb_set(profile,'{full_name}','"Changed Name"') where user_id=uid;
  response := public.ce_course1_certificate('status');
  if response->'certificate'->'learner'->>'full_name'<>'Snapshot Name'
    or response is distinct from public.ce_course1_certificate('issue') then
    raise exception 'Stored certificate changed or not idempotent';
  end if;
  perform set_config('request.jwt.claim.sub',(select user_id::text from public.ce_course1_reviewers limit 1),true);
  if public.ce_course1_certificate('status')->>'state'='issued' then
    raise exception 'Cross-account certificate exposure';
  end if;
end $$;
rollback;
select 'PASS: preview, registration, role isolation, no credit issuance, idempotent snapshot and grants' as certificate_safety;
