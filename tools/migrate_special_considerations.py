"""Lossless source conversion and insert-only import. No clinical text generation.

Usage: python tools/migrate_special_considerations.py SOURCE_DIRECTORY OUTPUT_DIRECTORY
       python tools/migrate_special_considerations.py SOURCE_DIRECTORY OUTPUT_DIRECTORY --apply
"""
import argparse
import collections
import hashlib
import json
import pathlib
import re
import subprocess

PROJECT = "xuckkusbbcxplpqclbxt"
COMBINED = "Special-Considerations--All-80-Records-Base44-Import.json"
CARDIAC = "Special-Considerations--Cardiac-Adult-Part-1-Records-110.md"
SECTIONS = [
    "snapshot", "pathophysiology", "preop_considerations",
    "airway_access_positioning", "intraop_management", "emergence_postop",
    "what_could_go_wrong", "pearls",
]


def convert_cardiac(text):
    records = []
    for block in re.split(r"(?m)^## Record \d+ [—–-] .+\n", text)[1:]:
        block = block.split("\n---")[0].strip()
        metadata = dict(re.findall(r"(?m)^- \*\*(\w+):\*\* (.+)$", block))
        assert metadata.keys() >= {"title", "slug", "category", "subtitle"}
        record = {k: v.strip("`") for k, v in metadata.items()}
        chunks = re.split(r"(?m)^\*\*(\w+)\*\*\s*\n", block)
        record.update({chunks[i]: chunks[i + 1].strip()
                       for i in range(1, len(chunks), 2)})
        record["crisis_hub_links"] = [
            line[2:].strip() for line in record["crisis_hub_links"].splitlines()
            if line.startswith("- ")
        ]
        citations = []
        for line in record["citations"].splitlines():
            if not line.strip():
                continue
            match = re.fullmatch(r"- (.+?) [—–] (https?://\S+)", line.strip())
            assert match, f"Unparsed citation: {line}"
            citations.append({"label": match[1], "url": match[2]})
        record["citations"] = citations
        record["search_tags"] = [x.strip() for x in record["search_tags"].split(",")]
        # These are source assertions, NOT a new clinical review.
        record["last_reviewed"] = "2026-09-17"
        record["reviewer"] = "CE HALO Clinical Review"
        record["is_published"] = False
        records.append(record)
    assert len(records) == 10
    return records


def tool(name, arguments):
    p = subprocess.run(
        ["pplx", "connector", "call", "supabase", name,
         "--input", json.dumps(arguments)],
        text=True, capture_output=True, check=True,
    )
    result = json.loads(p.stdout)
    if result.get("is_error") or result.get("error"):
        raise RuntimeError(result)
    return result


def unwrap_rows(result):
    value = result["result"]
    if isinstance(value, str):
        value = json.loads(value)
    raw = value["result"]
    match = re.search(r"<untrusted-data-[^>]+>\s*(\[[\s\S]*?\])\s*</untrusted-data-", raw)
    assert match, raw
    return json.loads(match[1])


def literal(value):
    text = json.dumps(value, ensure_ascii=False, separators=(",", ":"))
    assert "$luma_import$" not in text
    return "$luma_import$" + text + "$luma_import$::jsonb"


def seed_sql(rows, raw_by_slug, source_names):
    entries = []
    for r in rows:
        raw = raw_by_slug[r["slug"]]
        entries.append({
            "slug": r["slug"], "title": r["title"], "category": r["category"],
            "search_tags": [t.strip() for tag in r["search_tags"] for t in tag.split(",") if t.strip()],
            "content": {k: r[k] for k in SECTIONS},
            # The original exporter accidentally included author checklists as
            # citations with empty URLs. Preserve these in the private original
            # but do not display them as references.
            "citations": [c for c in r["citations"]
                          if c["url"].startswith(("https://", "http://"))],
            "crisis_hub_links": r["crisis_hub_links"],
            "subtitle": r["subtitle"], "severity_tag": r["severity_tag"],
            "deep_dive": r["deep_dive"], "original": raw,
            "source_file": source_names[r["slug"]],
            "source_sha256": hashlib.sha256(
                json.dumps(raw, ensure_ascii=False, sort_keys=True).encode()).hexdigest(),
        })
    # Every conflict skips: reruns never overwrite clinician edits.
    return f"""BEGIN;
WITH source AS (SELECT value AS r FROM jsonb_array_elements({literal(entries)})),
catalog AS (
 INSERT INTO public.special_consideration_catalog(slug,title,category,search_tags)
 SELECT r->>'slug',r->>'title',r->>'category',ARRAY(SELECT jsonb_array_elements_text(r->'search_tags')) FROM source
 ON CONFLICT (slug) DO NOTHING
),
imports AS (
INSERT INTO public.special_consideration_imports(slug,source_file,source_sha256,original)
SELECT r->>'slug',r->>'source_file',r->>'source_sha256',r->'original' FROM source
ON CONFLICT (slug) DO NOTHING
),
basic AS (
INSERT INTO public.special_considerations(slug,subtitle,severity_tag,content,citations,crisis_hub_links)
SELECT r->>'slug',r->>'subtitle',r->>'severity_tag',r->'content',r->'citations',r->'crisis_hub_links' FROM source
ON CONFLICT (slug) DO NOTHING
)
INSERT INTO public.special_consideration_deep_dives(slug,body)
SELECT r->>'slug',r->>'deep_dive' FROM source
ON CONFLICT (slug) DO NOTHING;
COMMIT;"""


def main():
    p = argparse.ArgumentParser()
    p.add_argument("source", type=pathlib.Path)
    p.add_argument("output", type=pathlib.Path)
    p.add_argument("--apply", action="store_true")
    args = p.parse_args()
    original = json.loads((args.source / COMBINED).read_text())
    cardiac = convert_cardiac((args.source / CARDIAC).read_text())
    rows = original + cardiac
    assert len(original) == 80 and len(rows) == 90
    assert len({r["slug"] for r in rows}) == 90
    for r in rows:
        for key in [*SECTIONS, "deep_dive", "subtitle", "citations", "crisis_hub_links"]:
            assert r.get(key), (r["slug"], key)
        assert all(set(c) >= {"label", "url"} for c in r["citations"])
        assert any(c["url"].startswith(("https://", "http://")) for c in r["citations"])
    raw = {r["slug"]: r for r in rows}
    names = {r["slug"]: COMBINED if i < 80 else CARDIAC for i, r in enumerate(rows)}
    args.output.mkdir(parents=True, exist_ok=True)
    (args.output / "normalized_90_records.json").write_text(
        json.dumps(rows, ensure_ascii=False, indent=2) + "\n")
    batches = [rows[i:i+5] for i in range(0, len(rows), 5)]
    for i, batch in enumerate(batches, 1):
        sql = seed_sql(batch, raw, names)
        assert len(json.dumps({"project_id": PROJECT, "query": sql}).encode()) < 120000
        (args.output / f"seed_{i:02}.sql").write_text(sql)
        if args.apply:
            result = tool("execute_sql", {"project_id": PROJECT, "query": sql})
            (args.output / f"receipt_{i:02}.json").write_text(json.dumps(result))
            print(f"Imported batch {i}/{len(batches)}", flush=True)
    report = {
        "total": len(rows),
        "categories": dict(collections.Counter(r["category"] for r in rows)),
        "unique_slugs": len(raw),
        "base44_text_preserved": rows[:80] == original,
        "cardiac_records_converted": len(cardiac),
        "review_status": "needs_review",
        "deep_dive_status": "needs_review",
        "clinical_review_performed": False,
        "non_url_citations_retained_in_archive_only": sum(
            not c["url"].startswith(("https://", "http://"))
            for r in rows for c in r["citations"]),
        "source_files": {name: hashlib.sha256((args.source / name).read_bytes()).hexdigest()
                         for name in (COMBINED, CARDIAC)},
    }
    (args.output / "import_report.json").write_text(json.dumps(report, indent=2) + "\n")
    print(json.dumps(report, indent=2))


if __name__ == "__main__":
    main()
