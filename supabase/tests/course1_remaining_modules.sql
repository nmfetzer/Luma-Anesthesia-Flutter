-- Integration assertions roll back all test state and preview completions.
begin;
do $$
declare
 u uuid; meta jsonb; m text; args jsonb; a jsonb; r jsonb; h jsonb;
 bank jsonb; answers jsonb; completed jsonb; prior jsonb; earlier jsonb:='{}';
 n int; denied boolean;
begin
 select user_id into u from public.ce_course1_reviewers limit 1;
 assert u is not null;
 perform set_config('request.jwt.claim.sub',u::text,true);
 perform set_config('request.jwt.claims',jsonb_build_object('sub',u,'is_anonymous',false)::text,true);
 delete from public.ce_course1_state where user_id=u;
 assert jsonb_array_length(public.ce_course1('catalog')->'modules')=11;
 assert (select sum((v->>'credits')::numeric)=20 from public.ce_course1_catalog,
   jsonb_array_elements(metadata->'modules') v where id='1047239');
 perform public.ce_course1('access');
 perform public.ce_course1('profile','{"full_name":"Modules 5-11 Tester","credentials":"CRNA","aana_id":"","location":"Rochester, NY"}');
 for n in 1..4 loop
   m:='course_1_module_'||n; args:=jsonb_build_object('module_id',m);
   perform public.ce_course1('read',args);
   a:=public.ce_course1('quiz',args);
   earlier:=earlier||jsonb_build_object(m,a->>'attempt_id');
 end loop;
 select progress into prior from public.ce_course1_state where user_id=u;
 for meta in select value from public.ce_course1_catalog,
   jsonb_array_elements(metadata->'modules') where id='1047239' and (value->>'number')::int>=5 loop
   m:=meta->>'id'; args:=jsonb_build_object('module_id',m);
   r:=public.ce_course1('access',args);
   assert r->>'read'='false';
   r:=public.ce_course1('document',args);
   assert encode(sha256(decode(r->>'base64','base64')),'hex')=r->>'sha256';
   perform public.ce_course1('read',args);
   select data into bank from public.ce_course1_resources where id=(meta->>'resource_prefix')||'_questions';
   assert jsonb_array_length(bank)=25;
   a:=public.ce_course1('quiz',args);
   assert jsonb_array_length(a->'questions')=15;
   assert not jsonb_path_exists(a,'$.questions[*].correct_choice');
   assert public.ce_course1('quiz',args)->>'attempt_id'=a->>'attempt_id';
   denied:=false;
   begin perform public.ce_course1('submit',args||jsonb_build_object('attempt_id',earlier->>'course_1_module_1','answers','{}'::jsonb));
   exception when others then denied:=true; end;
   assert denied,'Cross-module submission denied';
   for r in select value from jsonb_array_elements(a->'questions') loop
     h:=public.ce_course1('hint',args||jsonb_build_object('attempt_id',a->>'attempt_id','question_id',r->>'question_id'));
     assert jsonb_array_length(h->'eliminated')=2;
     assert not(h->'eliminated' ? (select value->>'correct_choice' from jsonb_array_elements(bank) where value->>'question_id'=r->>'question_id'));
   end loop;
   select jsonb_object_agg(q->>'question_id',b->>'correct_choice') into answers
   from jsonb_array_elements(a->'questions') q
   join jsonb_array_elements(bank) b on q->>'question_id'=b->>'question_id';
   r:=public.ce_course1('submit',args||jsonb_build_object('attempt_id',a->>'attempt_id','answers',answers));
   assert r->>'score'='15' and r->>'passed'='true';
   completed:=public.ce_course1('evaluate',args||'{"ratings":[1,1,1,1,1,1,1,1,1,1],"learned":"Individualize medication selection","barriers":"None","attestation":true}'::jsonb);
   assert completed->>'module_id'=m and completed->>'module_credits'='0';
   assert completed->'learner'->>'full_name'='Modules 5-11 Tester';
   assert completed->>'location'='Rochester, NY';
   assert completed->>'user_id'=u::text;
   assert public.ce_course1('evaluate',args)=completed;
 end loop;
 for n in 1..4 loop
   m:='course_1_module_'||n;args:=jsonb_build_object('module_id',m);
   assert public.ce_course1('quiz',args)->>'attempt_id'=earlier->>m;
 end loop;
 assert public.ce_course1_records(null,false,0)->>'total'='0';
 r:=public.ce_course1_records(null,true,0);
 assert r->>'total'='7';
 assert not jsonb_path_exists(r,'$.rows[*] ? (@.full_course_awarded == true)');
 assert (select released=false from public.ce_course1_catalog where id='1047239');
 assert not has_table_privilege('authenticated','public.ce_course1_resources','select');
 delete from public.ce_course1_reviewers where user_id=u;
 denied:=false;
 begin perform public.ce_course1_records(null,true,0); exception when others then denied:=true; end;
 assert denied;
 assert public.ce_course1('access',args)->>'has_access'='false';
end $$;
select 'PASS: 11-module catalog, seven private PDF hashes, 175-question banks, 15-item forms, safe hints, inherited registration, linked evaluations, zero-credit preview, isolated progress, provider records and unreleased gating' as result;
rollback;
