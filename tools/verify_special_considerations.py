"""Read-back verification against the imported source, without clinical review."""
import hashlib
import json
import pathlib
import sys

from migrate_special_considerations import PROJECT, SECTIONS, tool, unwrap_rows

folder = pathlib.Path(sys.argv[1])
expected = {
    r["slug"]: r
    for r in json.loads((folder / "normalized_90_records.json").read_text())
}
query = """
SELECT c.slug,c.title,c.category,c.review_status,c.reviewed_at,c.reviewed_by,
       c.is_guest_preview,c.search_tags,b.subtitle,b.severity_tag,b.content,
       b.citations,b.crisis_hub_links,d.body,d.review_status AS deep_status,
       i.original,i.source_sha256
FROM public.special_consideration_catalog c
JOIN public.special_considerations b USING(slug)
JOIN public.special_consideration_deep_dives d USING(slug)
JOIN public.special_consideration_imports i USING(slug)
ORDER BY c.slug;
"""
actual = unwrap_rows(tool("execute_sql", {"project_id": PROJECT, "query": query}))
# Later additive batches may exist. Verify this original source set without
# requiring the complete catalog to remain frozen at its first 90 records.
selected = [row for row in actual if row["slug"] in expected]
assert len(selected) == len(expected) == 90
for row in selected:
    source = expected[row["slug"]]
    assert row["original"] == source, row["slug"]
    assert row["source_sha256"] == hashlib.sha256(
        json.dumps(source, ensure_ascii=False, sort_keys=True).encode()
    ).hexdigest()
    for key in ("title", "category", "subtitle", "severity_tag", "crisis_hub_links"):
        assert row[key] == source[key], (row["slug"], key)
    assert row["content"] == {k: source[k] for k in SECTIONS}
    assert row["body"] == source["deep_dive"]
    assert row["citations"] == [
        c for c in source["citations"] if c["url"].startswith(("https://", "http://"))
    ]
    assert row["search_tags"] == [
        t.strip() for tag in source["search_tags"] for t in tag.split(",") if t.strip()
    ]
    assert row["review_status"] == row["deep_status"] == "needs_review"
    assert row["reviewed_at"] is None and row["reviewed_by"] is None
    assert row["is_guest_preview"] is False

# Rerun one batch and require exact equality. The importer is insert-only.
tool("execute_sql", {
    "project_id": PROJECT, "query": (folder / "seed_01.sql").read_text()
})
after = unwrap_rows(tool("execute_sql", {"project_id": PROJECT, "query": query}))
assert after == actual
access_query = """
BEGIN;
SET LOCAL ROLE anon;
SELECT jsonb_build_object(
 'catalog', (SELECT count(*) FROM public.special_consideration_catalog),
 'basic', (SELECT count(*) FROM public.special_considerations),
 'deep', (SELECT count(*) FROM public.special_consideration_deep_dives)
) AS counts;
ROLLBACK;
"""
access = unwrap_rows(tool("execute_sql", {"project_id": PROJECT, "query": access_query}))
assert access[0]["counts"] == {"catalog": len(actual), "basic": 0, "deep": 0}
report = {
    "records_verified": 90,
    "originals_match": True,
    "clinical_sections_and_deep_dives_match": True,
    "repeat_import_unchanged": True,
    "anonymous_counts": access[0]["counts"],
    "clinical_review_performed": False,
}
(folder / "verification_report.json").write_text(json.dumps(report, indent=2) + "\n")
print(json.dumps(report, indent=2))
