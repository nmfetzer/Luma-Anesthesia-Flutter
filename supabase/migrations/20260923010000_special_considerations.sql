-- Additive migration. No existing medication, auth, or profile data is changed.
-- Titles are browsable before publication; draft clinical prose is server-only.
CREATE TABLE public.special_consideration_catalog (
  slug text PRIMARY KEY CHECK (slug ~ '^[a-z0-9]+(-[a-z0-9]+)*$'),
  title text NOT NULL,
  category text NOT NULL,
  search_tags text[] NOT NULL DEFAULT '{}',
  review_status text NOT NULL DEFAULT 'needs_review'
    CHECK (review_status IN ('needs_review','published','archived')),
  is_guest_preview boolean NOT NULL DEFAULT false,
  reviewed_at timestamptz,
  reviewed_by text,
  created_at timestamptz NOT NULL DEFAULT now(),
  CHECK (review_status <> 'published' OR
    (reviewed_at IS NOT NULL AND nullif(btrim(reviewed_by),'') IS NOT NULL))
);
CREATE INDEX sc_catalog_category_idx ON public.special_consideration_catalog(category,title);
CREATE UNIQUE INDEX sc_one_guest_preview_per_category
  ON public.special_consideration_catalog(category) WHERE is_guest_preview;

CREATE TABLE public.special_considerations (
  slug text PRIMARY KEY REFERENCES public.special_consideration_catalog(slug),
  subtitle text NOT NULL,
  severity_tag text,
  content jsonb NOT NULL CHECK (jsonb_typeof(content) = 'object'),
  citations jsonb NOT NULL CHECK (jsonb_typeof(citations) = 'array'),
  crisis_hub_links jsonb NOT NULL CHECK (jsonb_typeof(crisis_hub_links) = 'array')
);

CREATE TABLE public.special_consideration_deep_dives (
  slug text PRIMARY KEY REFERENCES public.special_consideration_catalog(slug),
  body text NOT NULL,
  review_status text NOT NULL DEFAULT 'needs_review'
    CHECK (review_status IN ('needs_review','published','archived')),
  reviewed_at timestamptz,
  reviewed_by text,
  CHECK (review_status <> 'published' OR
    (reviewed_at IS NOT NULL AND nullif(btrim(reviewed_by),'') IS NOT NULL))
);

-- Retain source assertions (including old review dates) without endorsing them.
CREATE TABLE public.special_consideration_imports (
  slug text PRIMARY KEY REFERENCES public.special_consideration_catalog(slug),
  source_file text NOT NULL,
  source_sha256 text NOT NULL,
  original jsonb NOT NULL,
  imported_at timestamptz NOT NULL DEFAULT now()
);

-- Server-maintained subscription authority. Never trust client-editable profile
-- subscription fields. Billing integration will populate this table later.
CREATE TABLE public.luma_content_entitlements (
  user_id uuid NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  entitlement text NOT NULL CHECK (entitlement = 'clinical_premium'),
  valid_until timestamptz NOT NULL,
  revoked_at timestamptz,
  PRIMARY KEY(user_id, entitlement)
);

ALTER TABLE public.special_consideration_catalog ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.special_considerations ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.special_consideration_deep_dives ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.special_consideration_imports ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.luma_content_entitlements ENABLE ROW LEVEL SECURITY;

REVOKE ALL ON public.special_consideration_catalog, public.special_considerations,
 public.special_consideration_deep_dives, public.special_consideration_imports,
 public.luma_content_entitlements FROM PUBLIC, anon, authenticated;
GRANT SELECT ON public.special_consideration_catalog, public.special_considerations,
 public.special_consideration_deep_dives TO anon, authenticated;
GRANT SELECT ON public.luma_content_entitlements TO authenticated;
GRANT ALL ON public.special_consideration_catalog, public.special_considerations,
 public.special_consideration_deep_dives, public.special_consideration_imports,
 public.luma_content_entitlements TO service_role;

CREATE POLICY sc_catalog_browse ON public.special_consideration_catalog
 FOR SELECT TO anon, authenticated USING (review_status <> 'archived');
CREATE POLICY sc_guest_basic ON public.special_considerations
 FOR SELECT TO anon, authenticated USING (
   EXISTS (SELECT 1 FROM public.special_consideration_catalog c
     WHERE c.slug = special_considerations.slug AND c.review_status = 'published'
       AND c.is_guest_preview)
 );
CREATE POLICY sc_account_basic ON public.special_considerations
 FOR SELECT TO authenticated USING (
   (SELECT auth.uid()) IS NOT NULL
   AND COALESCE((SELECT auth.jwt()->>'is_anonymous'), 'true') = 'false'
   AND EXISTS (SELECT 1 FROM public.special_consideration_catalog c
     WHERE c.slug = special_considerations.slug AND c.review_status = 'published')
 );
CREATE POLICY sc_entitlements_own ON public.luma_content_entitlements
 FOR SELECT TO authenticated USING (user_id = (SELECT auth.uid()));
CREATE POLICY sc_premium_deep_dive ON public.special_consideration_deep_dives
 FOR SELECT TO authenticated USING (
   review_status = 'published'
   AND (SELECT auth.uid()) IS NOT NULL
   AND COALESCE((SELECT auth.jwt()->>'is_anonymous'), 'true') = 'false'
   AND EXISTS (SELECT 1 FROM public.special_consideration_catalog c
     WHERE c.slug = special_consideration_deep_dives.slug AND c.review_status = 'published')
   AND EXISTS (SELECT 1 FROM public.luma_content_entitlements e
     WHERE e.user_id = (SELECT auth.uid()) AND e.entitlement = 'clinical_premium'
       AND e.revoked_at IS NULL AND e.valid_until > now())
 );
COMMENT ON TABLE public.special_consideration_catalog IS
 'Imported titles are visible; clinical prose requires explicit reviewed publication. Preserve source taxonomy.';
NOTIFY pgrst, 'reload schema';
