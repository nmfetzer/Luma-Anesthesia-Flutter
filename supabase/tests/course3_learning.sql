-- All fixtures and provider preview completions are rolled back.
begin;
do $$
declare u uuid; meta jsonb; args jsonb; a jsonb; r jsonb; h jsonb;
 bank jsonb; answers jsonb; ratings jsonb; completed jsonb; denied boolean;
begin
 select user_id into u from public.ce_course3_reviewers limit 1;
 assert u is not null;
 perform set_config('request.jwt.claim.sub',u::text,true);
 perform set_config('request.jwt.claims',jsonb_build_object('sub',u,'is_anonymous',false)::text,true);
 delete from public.ce_course3_state where user_id=u;
 assert jsonb_array_length(public.ce_course3('catalog')->'modules')=11;
 assert (select sum((v->>'credits')::numeric)=20
   and sum((v->>'pharmacology_credits')::numeric)=0
   and sum((v->>'pain_credits')::numeric)=0
   from public.ce_course3_catalog,jsonb_array_elements(metadata->'modules') v);
 perform public.ce_course3('access');
 perform public.ce_course3('profile','{"full_name":"Course Three Test","credentials":"CRNA","aana_id":"","location":"Rochester, NY","participation_start_on":"2026-10-01","participation_end_on":"2026-10-03"}');
 for meta in select value from public.ce_course3_catalog,
   jsonb_array_elements(metadata->'modules') loop
   args:=jsonb_build_object('module_id',meta->>'id');
   r:=public.ce_course3('document',args);
   assert encode(sha256(decode(r->>'base64','base64')),'hex')=r->>'sha256';
   perform public.ce_course3('read',args);
   select data into bank from public.ce_course3_resources where id=(meta->>'resource_prefix')||'_questions';
   assert jsonb_array_length(bank)=25;
   a:=public.ce_course3('quiz',args);
   assert jsonb_array_length(a->'questions')=15;
   assert not jsonb_path_exists(a,'$.questions[*].correct_choice');
   assert public.ce_course3('quiz',args)->>'attempt_id'=a->>'attempt_id';
   for r in select value from jsonb_array_elements(a->'questions') loop
     h:=public.ce_course3('hint',args||jsonb_build_object('attempt_id',a->>'attempt_id','question_id',r->>'question_id'));
     assert jsonb_array_length(h->'eliminated')=2;
     assert not(h->'eliminated' ? (select value->>'correct_choice'
       from jsonb_array_elements(bank) where value->>'question_id'=r->>'question_id'));
   end loop;
   select jsonb_object_agg(q->>'question_id',b->>'correct_choice') into answers
     from jsonb_array_elements(a->'questions') q join jsonb_array_elements(bank) b
       on q->>'question_id'=b->>'question_id';
   r:=public.ce_course3('submit',args||jsonb_build_object('attempt_id',a->>'attempt_id','answers',answers));
   assert r->>'score'='15' and r->>'passed'='true';
   select jsonb_agg(1) into ratings from generate_series(1,
     jsonb_array_length(meta->'objectives')+jsonb_array_length(meta->'evaluation_items'));
   completed:=public.ce_course3('evaluate',args||jsonb_build_object(
     'ratings',ratings,'learned','Recognize uncommon perioperative emergencies',
     'barriers','None','attestation',true));
   assert completed->>'module_id'=meta->>'id' and completed->>'module_credits'='0';
   assert completed->'learner'->>'full_name'='Course Three Test';
   assert completed->>'user_id'=u::text;
   assert public.ce_course3('evaluate',args)=completed;
 end loop;
 assert public.ce_course3_records(null,false,0)->>'total'='0';
 assert public.ce_course3_records(null,true,0)->>'total'='11';
 assert public.ce_course3_certificate('status')->>'can_issue'='false';
 assert public.ce_course3_certificate('preview')->'certificate'->>'credits_awarded'='0';
 assert (select released=false from public.ce_course3_catalog);
 assert (select enabled=false from public.ce_course3_certificate_settings);
 assert not has_table_privilege('authenticated','public.ce_course3_resources','select');
 assert not has_function_privilege('anon','public.ce_course3_certificate(text)','execute');
 delete from public.ce_course3_reviewers where user_id=u;
 denied:=false;
 begin perform public.ce_course3_records(null,true,0); exception when others then denied:=true; end;
 assert denied;
 assert public.ce_course3('access',args)->>'has_access'='false';
end $$;
rollback;
select 'PASS: 11 modules, 275-item banks, safe hints, private PDF hashes, linked evaluations, 20/0/0 allocation, provider records and preview-only gating' as course3_test;
