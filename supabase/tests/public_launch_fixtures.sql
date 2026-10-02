-- Disposable-only data to exercise activation guards. Not learner content.
do $$
declare n integer; expected integer; modules jsonb;
begin
  if current_database() not like 'luma_review_test_%'
  then raise exception 'Local tests only'; end if;
  for n in 1..3 loop
    expected:=case n when 2 then 10 else 11 end;
    select jsonb_agg(jsonb_build_object(
      'id',format('course_%s_module_%s',n,x),
      'credits',case when expected=10 then 2 when x=11 then 5 else 1.5 end,
      'resource_prefix','fixture','bank_size',25,'question_count',15,
      'document_sha256',encode(sha256(convert_to('test fixture','UTF8')),'hex')))
      into modules from generate_series(1,expected) x;
    execute format('update public.ce_course%s_catalog
      set metadata=jsonb_build_object(''modules'',$1)',n) using modules;
    execute format('insert into public.ce_course%s_resources values(
      ''fixture_pdf'',jsonb_build_object(''base64'',encode(convert_to(''test fixture'',''UTF8''),''base64''),
      ''sha256'',encode(sha256(convert_to(''test fixture'',''UTF8'')),''hex'')))',n);
    execute format('update public.ce_course%s_certificate_settings
      set approved_at=now(),signature_png_base64=''LOCAL-TEST-ONLY''',n);
  end loop;
end $$;
