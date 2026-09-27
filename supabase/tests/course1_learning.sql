-- Run through an administrative connection. Everything is rolled back.
begin;
do $$
declare
 u uuid; r jsonb; a jsonb; h jsonb; b jsonb; q jsonb; answers jsonb;
 forms jsonb:='[]'; n int; overlap int; denied boolean:=false; completion jsonb;
begin
 select user_id into u from public.ce_course1_reviewers limit 1;
 if u is null then raise exception 'Owner reviewer not configured'; end if;
 perform set_config('request.jwt.claim.sub','',true);
 perform set_config('request.jwt.claims','{}',true);
 r:=public.ce_course1('catalog');
 assert r->>'title'='A Medication Review for the Experienced CRNA';
 assert r->>'purchases_enabled'='false';
 begin
   perform public.ce_course1('document');
 exception when others then denied:=true;
 end;
 assert denied, 'Anonymous content must be denied';
 perform set_config('request.jwt.claim.sub',u::text,true);
 perform set_config('request.jwt.claims',jsonb_build_object('sub',u,'is_anonymous',false)::text,true);
 -- Reset only inside this rolled-back test transaction.
 delete from public.ce_course1_state where user_id=u;
 r:=public.ce_course1('access');
 assert r->>'has_access'='true' and r->>'is_preview'='true';
 denied:=false;
 begin perform public.ce_course1('document'); exception when others then denied:=true; end;
 assert denied, 'Details must gate learning';
 perform public.ce_course1('profile','{"full_name":"Preview Tester","credentials":"CRNA","aana_id":"","location":"Rochester, NY, USA"}');
 r:=public.ce_course1('document');
 assert length(decode(r->>'base64','base64'))=655731;
 assert encode(sha256(decode(r->>'base64','base64')),'hex')=r->>'sha256', 'PDF byte integrity';
 perform public.ce_course1('read');
 for n in 1..3 loop
   a:=public.ce_course1('quiz');
   assert jsonb_array_length(a->'questions')=15;
   assert not jsonb_path_exists(a,'$.questions[*].correct_choice');
   assert not jsonb_path_exists(a,'$.questions[*].rationale');
   assert (a->>'number')::int=n;
   assert public.ce_course1('quiz')->>'attempt_id'=a->>'attempt_id', 'Resume must not consume another attempt';
   forms:=forms||jsonb_build_array(a->'questions');
   select data into b from public.ce_course1_resources where id='ketamine_questions';
   q:=a->'questions'->0;
   h:=public.ce_course1('hint',jsonb_build_object('attempt_id',a->>'attempt_id','question_id',q->>'question_id'));
   assert jsonb_array_length(h->'eliminated')=2;
   assert not(h->'eliminated' ? (select value->>'correct_choice' from jsonb_array_elements(b) where value->>'question_id'=q->>'question_id'));
   assert public.ce_course1('hint',jsonb_build_object('attempt_id',a->>'attempt_id','question_id',q->>'question_id'))=h;
   assert public.ce_course1('quiz')->'hints'->(q->>'question_id')=h->'eliminated', 'Hints persist on resume';
   denied:=false;
   begin perform public.ce_course1('evaluate','{}'); exception when others then denied:=true; end;
   assert denied, 'Evaluation must be denied before passing';
   if n<3 then
     -- Select remaining wrong answers even on the hinted question.
     select jsonb_object_agg(x->>'question_id',
       (select choice from unnest(array['a','b','c','d']) choice
         where choice<>k->>'correct_choice'
           and (x->>'question_id'<>q->>'question_id' or not(h->'eliminated' ? choice)) limit 1))
       into answers from jsonb_array_elements(a->'questions') x
       join jsonb_array_elements(b) k on k->>'question_id'=x->>'question_id';
   else
     select jsonb_object_agg(x->>'question_id',k->>'correct_choice') into answers
       from jsonb_array_elements(a->'questions') x join jsonb_array_elements(b) k on k->>'question_id'=x->>'question_id';
   end if;
   r:=public.ce_course1('submit',jsonb_build_object('attempt_id',a->>'attempt_id','answers',answers));
   assert (r->>'score')::int=case when n=3 then 15 else 0 end;
   assert public.ce_course1('submit',jsonb_build_object('attempt_id',a->>'attempt_id','answers',answers))=r,'Submit is idempotent';
 end loop;
 for n in 0..1 loop
   for overlap in (select count(*) from jsonb_array_elements(forms->n) x
     join jsonb_array_elements(forms->2) y on x->>'question_id'=y->>'question_id') loop
     assert overlap=7, 'Retake forms must share less than half the questions';
   end loop;
 end loop;
 select count(*) into overlap from jsonb_array_elements(forms->0) x join jsonb_array_elements(forms->1) y on x->>'question_id'=y->>'question_id';
 assert overlap=7;
 completion:=public.ce_course1('evaluate',
 '{"ratings":[5,5,5,5,5,5,5,5,5,5,5],"learned":"Reviewed ketamine pharmacology","barriers":"None","location":"Buffalo, NY, USA","signature":"Preview Tester","attestation":true}');
 assert completion->>'module_credits'='0';
 assert completion->>'is_preview'='true';
 assert completion->>'location'='Rochester, NY, USA', 'Location inherited from registration, not evaluation';
 assert completion->>'course_complete'='false';
 assert public.ce_course1('evaluate','{}')=completion;
 denied:=false;
 begin perform public.ce_course1('quiz'); exception when others then denied:=true; end;
 assert denied, 'No attempt after passing';
 -- Course gate still denies non-reviewers, including a clinical subscriber.
 delete from public.ce_course1_reviewers where user_id=u;
 assert public.ce_course1('access')->>'has_access'='false';
 denied:=false;
 begin perform public.ce_course1('document'); exception when others then denied:=true; end;
 assert denied;
 assert not has_table_privilege('authenticated','public.ce_course1_resources','select');
 assert not has_table_privilege('authenticated','public.ce_course1_state','select');
 assert not has_table_privilege('authenticated','public.ce_course1_reviewers','insert');
 assert not has_function_privilege('authenticated','public.record_verified_ce_bonus(text,text,text,uuid,timestamp with time zone)','execute');
end $$;
select 'Course 1 access, PDF, 15-question grading, hints, retakes, evaluation and privacy tests passed' as result;
rollback;
