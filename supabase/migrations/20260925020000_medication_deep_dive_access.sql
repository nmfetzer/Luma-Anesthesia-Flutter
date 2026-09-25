-- Preserve all data; restrict only the Deep Dive column.
REVOKE SELECT ON public.medication FROM PUBLIC, anon, authenticated;
DO $$
DECLARE free_columns text;
BEGIN
  SELECT string_agg(quote_ident(column_name), ', ' ORDER BY ordinal_position)
    INTO free_columns FROM information_schema.columns
    WHERE table_schema = 'public' AND table_name = 'medication'
      AND column_name <> 'deep_dive_content';
  EXECUTE 'GRANT SELECT (' || free_columns || ') ON public.medication TO anon, authenticated';
END $$;

CREATE OR REPLACE FUNCTION public.medication_deep_dive(p_medication_id text)
RETURNS jsonb
LANGUAGE plpgsql STABLE SECURITY DEFINER
SET search_path = ''
AS $$
DECLARE content text;
BEGIN
  IF (SELECT auth.uid()) IS NULL
    OR COALESCE((SELECT auth.jwt()->>'is_anonymous'), 'true') <> 'false'
    OR NOT EXISTS (
      SELECT 1 FROM public.luma_content_entitlements e
      WHERE e.user_id = (SELECT auth.uid())
        AND e.entitlement = 'clinical_premium'
        AND e.revoked_at IS NULL AND e.valid_until > now()
    ) THEN
    RETURN jsonb_build_object('allowed', false);
  END IF;
  SELECT m.deep_dive_content INTO content FROM public.medication m
    WHERE m.id = p_medication_id;
  RETURN jsonb_build_object('allowed', true, 'body', content);
END $$;
REVOKE ALL ON FUNCTION public.medication_deep_dive(text) FROM PUBLIC, anon;
GRANT EXECUTE ON FUNCTION public.medication_deep_dive(text) TO authenticated;
NOTIFY pgrst, 'reload schema';
