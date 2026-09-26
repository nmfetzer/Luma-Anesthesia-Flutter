-- Additive Base44 migration. Clinical drafts are NOT published by this migration.
BEGIN;
CREATE TABLE public.crisis_catalog (
  slug text PRIMARY KEY,
  title text NOT NULL,
  category text NOT NULL CHECK (category IN
    ('cardiac','airway','toxicity','ob','pediatric','metabolic')),
  sort_order integer NOT NULL DEFAULT 50,
  search_terms text NOT NULL DEFAULT '',
  is_free boolean NOT NULL DEFAULT false,
  release_status text NOT NULL DEFAULT 'draft'
    CHECK (release_status IN ('draft','published')),
  source_ids jsonb NOT NULL DEFAULT '[]'::jsonb
);
CREATE TABLE public.crisis_protocols (
  slug text PRIMARY KEY REFERENCES public.crisis_catalog(slug),
  content jsonb NOT NULL CHECK (jsonb_typeof(content) = 'object')
);
CREATE TABLE public.crisis_reviewers (
  user_id uuid PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE
);
ALTER TABLE public.crisis_catalog ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.crisis_protocols ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.crisis_reviewers ENABLE ROW LEVEL SECURITY;
REVOKE ALL ON public.crisis_catalog, public.crisis_protocols,
  public.crisis_reviewers FROM PUBLIC, anon, authenticated;
GRANT SELECT ON public.crisis_catalog, public.crisis_protocols TO anon, authenticated;
GRANT ALL ON public.crisis_catalog, public.crisis_protocols, public.crisis_reviewers TO service_role;

CREATE FUNCTION public.is_crisis_reviewer() RETURNS boolean
LANGUAGE sql STABLE SECURITY DEFINER SET search_path = ''
AS $$
  SELECT EXISTS (SELECT 1 FROM public.crisis_reviewers
    WHERE user_id = (SELECT auth.uid()))
$$;
REVOKE ALL ON FUNCTION public.is_crisis_reviewer() FROM PUBLIC, anon;
GRANT EXECUTE ON FUNCTION public.is_crisis_reviewer() TO authenticated;

CREATE POLICY crisis_catalog_read ON public.crisis_catalog
  FOR SELECT TO anon, authenticated USING (true);
CREATE POLICY crisis_free_published ON public.crisis_protocols
  FOR SELECT TO anon, authenticated USING (
    EXISTS (SELECT 1 FROM public.crisis_catalog c
      WHERE c.slug = crisis_protocols.slug
        AND c.release_status = 'published' AND c.is_free)
  );
CREATE POLICY crisis_paid_published ON public.crisis_protocols
  FOR SELECT TO authenticated USING (
    (SELECT public.has_clinical_premium_access()) AND
    EXISTS (SELECT 1 FROM public.crisis_catalog c
      WHERE c.slug = crisis_protocols.slug AND c.release_status = 'published')
  );
CREATE POLICY crisis_reviewer_drafts ON public.crisis_protocols
  FOR SELECT TO authenticated USING ((SELECT public.is_crisis_reviewer()));
COMMENT ON TABLE public.crisis_protocols IS
 'Base44 migration; draft contents restricted to explicitly assigned reviewers. No client write policies.';
COMMIT;
