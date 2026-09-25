-- Account creation identifies a reader; it does not grant paid content.
-- Keep explicitly designated guest previews and catalog browsing unchanged.
-- No clinical rows, accounts, or entitlements are modified.
ALTER POLICY sc_account_basic ON public.special_considerations
 USING (
   (SELECT auth.uid()) IS NOT NULL
   AND COALESCE((SELECT auth.jwt()->>'is_anonymous'), 'true') = 'false'
   AND EXISTS (SELECT 1 FROM public.special_consideration_catalog c
     WHERE c.slug = special_considerations.slug AND c.review_status = 'published')
   AND EXISTS (SELECT 1 FROM public.luma_content_entitlements e
     WHERE e.user_id = (SELECT auth.uid()) AND e.entitlement = 'clinical_premium'
       AND e.revoked_at IS NULL AND e.valid_until > now())
 );
NOTIFY pgrst, 'reload schema';
