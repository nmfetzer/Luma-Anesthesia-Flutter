-- LOCAL TEST FIXTURES ONLY, used by scripts/test_apple_review_db.mjs.
DO $$
DECLARE n integer; cid text; modules jsonb;
BEGIN
  IF current_database() NOT LIKE 'luma_review_test_%' THEN RAISE EXCEPTION 'Local tests only'; END IF;
  FOR n IN 1..3 LOOP
    cid:=CASE n WHEN 1 THEN '1047239' WHEN 2 THEN '1047241' ELSE '1047243' END;
    EXECUTE format('CREATE TABLE IF NOT EXISTS public.ce_course%s_catalog(id text PRIMARY KEY,metadata jsonb,released boolean NOT NULL DEFAULT false)',n);
    SELECT jsonb_agg(jsonb_build_object('id',format('course_%s_module_%s',n,x),'title','Fixture module',
      'objectives',jsonb_build_array('objective'),'evaluation_items',jsonb_build_array('evaluation'),
      'credits',2,'pharmacology_credits',0,'pain_credits',0,'resource_prefix','fixture'))
      INTO modules FROM generate_series(1,CASE n WHEN 2 THEN 10 ELSE 11 END) x;
    EXECUTE format('INSERT INTO public.ce_course%s_catalog VALUES($1,$2,false)
      ON CONFLICT(id) DO UPDATE SET metadata=excluded.metadata',n)
      USING cid,jsonb_build_object('modules',modules);
    EXECUTE format('CREATE TABLE public.ce_course%s_resources(id text PRIMARY KEY,data jsonb)',n);
    EXECUTE format('INSERT INTO public.ce_course%s_resources(id,data) SELECT ''fixture_questions'',
      jsonb_agg(jsonb_build_object(''question_id'',''q''||x,''stem'',''Fixture question'',
      ''choice_a'',''Correct'',''choice_b'',''Wrong'',''choice_c'',''Wrong'',''choice_d'',''Wrong'',
      ''correct_choice'',''a'')) FROM generate_series(1,25) x',n);
    EXECUTE format('CREATE TABLE public.ce_course%s_reviewers(user_id uuid PRIMARY KEY REFERENCES auth.users(id))',n);
    EXECUTE format('CREATE TABLE public.ce_course%s_state(user_id uuid PRIMARY KEY REFERENCES auth.users(id),
      profile jsonb NOT NULL DEFAULT ''{}'',progress jsonb NOT NULL DEFAULT ''{}'',
      is_preview boolean NOT NULL,updated_at timestamptz NOT NULL DEFAULT now())',n);
    EXECUTE format('CREATE TABLE IF NOT EXISTS public.ce_course%s_store_products(store text,product_id text,PRIMARY KEY(store,product_id))',n);
    EXECUTE format('CREATE TABLE public.ce_course%s_certificate_settings(
      course_id text PRIMARY KEY,enabled boolean NOT NULL DEFAULT false,
      template_version text DEFAULT ''test'',provider_city_state text DEFAULT ''Test'',
      signer_name text DEFAULT ''Test'',signer_title text DEFAULT ''Test'',
      signature_png_base64 text,approved_at timestamptz)',n);
    EXECUTE format('INSERT INTO public.ce_course%s_certificate_settings(course_id) VALUES($1)',n) USING cid;
    EXECUTE format('CREATE TABLE public.ce_course%s_certificates(
      id uuid PRIMARY KEY DEFAULT gen_random_uuid(),user_id uuid NOT NULL,course_id text NOT NULL,
      issued_at timestamptz NOT NULL DEFAULT now(),completed_at timestamptz NOT NULL,
      snapshot jsonb NOT NULL,UNIQUE(user_id,course_id))',n);
  END LOOP;
END $$;
