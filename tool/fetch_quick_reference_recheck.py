"""Record supporting evidence for the post-addition library recheck."""
import json
from pathlib import Path
import pplx_sdk

root = Path("docs/quick-reference-audit")
urls = [
    "https://pmc.ncbi.nlm.nih.gov/articles/PMC9482594/",
    "https://pmc.ncbi.nlm.nih.gov/articles/PMC11702345/",
    "https://e-safe-anaesthesia.org/e_library/05/Bronchospasm_during_anaesthesia_Update_2011.pdf",
]
results = pplx_sdk.content.fetch(
    urls,
    prompt=(
        "Extract adult perioperative bronchospasm ketamine and IV magnesium "
        "doses, administration times, indications, adverse effects, and evidence "
        "limitations. Distinguish systematic-review outcome evidence from "
        "anesthesia expert-review recommendations. Include publication year."
    ),
)
out = root / "recheck-evidence.jsonl"
pplx_sdk.utils.write_jsonl(str(out), [r.to_dict() for r in results])
print(out)
pplx_sdk.utils.print_preview_jsonl(str(out), limit=3, max_chars=14000)
assert all(not r.error and len(r.content or "") > 250 for r in results)
