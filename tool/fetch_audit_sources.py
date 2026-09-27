import json
from pathlib import Path
import pplx_sdk

root = Path("/home/user/workspace/luma-quick-reference/docs/quick-reference-audit")
urls = json.loads((root / "source-urls.json").read_text())
out = root / "source-evidence.jsonl"
existing = {}
if out.exists():
    existing = {r["url"]: r for r in map(json.loads, out.read_text().splitlines())}
remaining = [u for u in urls if u not in existing]
for start in range(0, len(remaining), 20):
    batch = remaining[start:start+20]
    results = pplx_sdk.content.fetch(batch)
    with out.open("a") as f:
        for r in results:
            row = r.to_dict()
            f.write(json.dumps(row) + "\n")
    print(f"Checkpoint: {start+len(batch)}/{len(remaining)} fetched", flush=True)
rows = list(map(json.loads, out.read_text().splitlines()))
print(out)
print(json.dumps({"total": len(rows), "errors": [{"url":r["url"],"error":r.get("error")} for r in rows if r.get("error")], "short": [r["url"] for r in rows if len(r.get("content") or "")<250]}))
