-- Run in an isolated PostgreSQL database after the migration.
-- Fixtures only; no real learners or clinical content.
\set ON_ERROR_STOP on
begin;
insert into auth.users(id) values
 ('00000000-0000-4000-8000-000000000001'),
 ('00000000-0000-4000-8000-000000000002'),
 ('00000000-0000-4000-8000-000000000003');
insert into academy_private.access(user_id,access_kind) values
 ('00000000-0000-4000-8000-000000000001','owner_review'),
 ('00000000-0000-4000-8000-000000000002','purchase');
insert into academy_private.packages(level_id,version,position,title,available,content)
values ('test','v2',1,'Test fixture',true,'{
 "decks":[{"id":"D1"}],"lessons":[{"id":"L1"}],"flashcards":[{"id":"F1"}],
 "practiceQuestions":[{"id":"P1","deckId":"D1","prompt":"Fixture","options":[{"id":"A"},{"id":"B"},{"id":"C"},{"id":"D"}],"correctOptionId":"B","rationale":"Fixture explanation"}],
 "masteryCheckpoint":{"items":[{"id":"Q1","prompt":"Fixture checkpoint","options":[{"id":"A"},{"id":"B"},{"id":"C"},{"id":"D"}],"correctOptionId":"C","rationale":"Private key"}]}
}');
insert into academy_private.documents values ('test','v2','Study guide','JVBERi0='),('test','v2','Mastery checkpoint','JVBERi0=');
set local role authenticated;
select set_config('request.jwt.claim.sub','00000000-0000-4000-8000-000000000001',true);
do $$
declare c jsonb; r jsonb;
begin
  c:=public.academy_level('test','v2');
  assert c#>>'{masteryCheckpoint,items,0,prompt}'='Fixture checkpoint';
  assert not ((c#>'{masteryCheckpoint,items,0}') ? 'correctOptionId');
  assert not ((c#>'{masteryCheckpoint,items,0}') ? 'rationale');
  perform public.academy_mark('test','v2','cards','F1');
  perform public.academy_mark('test','v2','cards','F1');
  assert jsonb_array_length(public.academy_progress()->'marks')=1;
  r:=public.academy_submit('test','v2','checkpoint','all','00000000-0000-4000-8000-000000000010','{"Q1":"C"}');
  assert (r->>'correct')::int=1;
  assert r#>>'{feedback,0,rationale}'='Private key';
  assert public.academy_submit('test','v2','checkpoint','all','00000000-0000-4000-8000-000000000010','{"Q1":"C"}')=r;
  assert jsonb_array_length(public.academy_progress()->'attempts')=1;
  begin
    perform public.academy_submit('test','v2','checkpoint','all','00000000-0000-4000-8000-000000000010','{"Q1":"B"}');
    raise exception 'duplicate overwrite accepted';
  exception when invalid_parameter_value then null; end;
  begin
    perform public.academy_mark('test','v2','cards','invented');
    raise exception 'invalid item accepted';
  exception when invalid_parameter_value then null; end;
  begin
    perform public.academy_mark('test','v1','cards','F1');
    raise exception 'old version accepted';
  exception when invalid_parameter_value then null; end;
  begin
    perform public.academy_submit('test','v2','checkpoint','all',gen_random_uuid(),'{}');
    raise exception 'partial answers accepted';
  exception when invalid_parameter_value then null; end;
  begin
    perform public.academy_submit('test','v2','checkpoint','all',gen_random_uuid(),'{"Q1":"Z"}');
    raise exception 'invalid option accepted';
  exception when invalid_parameter_value then null; end;
  begin
    perform public.academy_submit('test','v2','practice','invented',gen_random_uuid(),'{}');
    raise exception 'invented deck accepted';
  exception when invalid_parameter_value then null; end;
  begin
    perform * from academy_private.packages;
    raise exception 'direct paid content readable';
  exception when insufficient_privilege then null; end;
end $$;
-- Second entitled account must not see the first account's work or answer PDFs.
select set_config('request.jwt.claim.sub','00000000-0000-4000-8000-000000000002',true);
do $$ begin
  assert jsonb_array_length(public.academy_progress()->'marks')=0;
  assert jsonb_array_length(public.academy_progress()->'attempts')=0;
  assert jsonb_array_length(public.academy_level('test','v2')->'documents')=1;
  assert public.academy_document('test','v2','Study guide')='JVBERi0=';
  begin
    perform public.academy_document('test','v2','Mastery checkpoint');
    raise exception 'learner answer PDF leaked';
  exception when insufficient_privilege then null; end;
end $$;
-- Signed-in but not entitled: catalog only.
select set_config('request.jwt.claim.sub','00000000-0000-4000-8000-000000000003',true);
do $$ begin
  assert (public.academy_catalog()->>'hasAccess')::boolean=false;
  begin
    perform public.academy_level('test','v2');
    raise exception 'unentitled content readable';
  exception when insufficient_privilege then null; end;
  begin
    perform public.academy_progress();
    raise exception 'unentitled progress readable';
  exception when insufficient_privilege then null; end;
end $$;
set local role anon;
do $$ begin
  begin
    perform public.academy_catalog();
    raise exception 'anonymous RPC allowed';
  exception when insufficient_privilege then null; end;
end $$;
reset role;
update academy_private.access set revoked_at=now()
  where user_id='00000000-0000-4000-8000-000000000001';
set local role authenticated;
select set_config('request.jwt.claim.sub','00000000-0000-4000-8000-000000000001',true);
do $$ begin
  begin
    perform public.academy_level('test','v2');
    raise exception 'revoked access accepted';
  exception when insufficient_privilege then null; end;
end $$;
rollback;
select 'Academy security and shared-progress tests passed' as result;
