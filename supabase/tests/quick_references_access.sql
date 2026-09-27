-- Free published content, private drafts, no client writes. All fixtures roll back.
begin;
insert into public.quick_reference_catalog
 (id,reference_id,reference_title,title,keywords,sort_order,is_published)
values ('_qa_private_draft','_qa_private_draft','QA','Private draft','{}',0,false);
insert into public.quick_reference_sections (id,body,version)
values ('_qa_private_draft','Never public','QA');
select set_config('luma.qa.expected',
 (select count(*)::text from public.quick_reference_sections s
 join public.quick_reference_catalog c using(id) where c.is_published), true);
set local role anon;
select set_config('luma.qa.guest',(select count(*)::text from public.quick_reference_sections),true);
do $$ begin
 if exists(select 1 from public.quick_reference_sections where id='_qa_private_draft')
 then raise exception 'Guest can see unpublished body'; end if;
 if exists(select 1 from public.quick_reference_catalog where id='_qa_private_draft')
 then raise exception 'Guest can see unpublished catalog'; end if;
end $$;
reset role;
select set_config('request.jwt.claims',
 '{"sub":"00000000-0000-0000-0000-000000000001","role":"authenticated","is_anonymous":false}',true);
set local role authenticated;
select set_config('luma.qa.unpaid',(select count(*)::text from public.quick_reference_sections),true);
do $$ begin
 if exists(select 1 from public.quick_reference_sections where id='_qa_private_draft')
 then raise exception 'Unpaid user can see unpublished body'; end if;
end $$;
reset role;
do $$ begin
 if current_setting('luma.qa.guest') <> current_setting('luma.qa.expected')
 or current_setting('luma.qa.unpaid') <> current_setting('luma.qa.expected')
 then raise exception 'Published Quick References are not free for everyone'; end if;
 if exists(select 1 from pg_policies where schemaname='public'
 and tablename in ('quick_reference_catalog','quick_reference_sections') and cmd <> 'SELECT')
 then raise exception 'Unexpected client write policy'; end if;
end $$;
select jsonb_build_object(
 'published_bodies',current_setting('luma.qa.expected')::int,
 'guest_bodies',current_setting('luma.qa.guest')::int,
 'unpaid_bodies',current_setting('luma.qa.unpaid')::int,
 'unpublished_hidden',true,'no_client_write_policies',true
) as free_access_checks;
rollback;
