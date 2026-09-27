import json
from pathlib import Path
import pplx_sdk

urls = [
    "https://labeling.pfizer.com/ShowLabeling.aspx?id=4408",
    "https://labeling.pfizer.com/ShowLabeling.aspx?id=4704",
    "https://www.accessdata.fda.gov/drugsatfda_docs/label/2021/020164s129lbl.pdf",
    "https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=147e033d-d997-4ef6-8bb5-a9ba372590b2",
]
rows = pplx_sdk.content.fetch(urls)
with Path("docs/quick-reference-audit/additional-evidence.jsonl").open("w") as output:
    for row in rows:
        output.write(json.dumps(row.to_dict()) + "\n")
        print(row.url, "ERROR:", row.error, "characters:", len(row.content or ""))
        import re
        text = re.sub(r"\s+", " ", row.content or "")
        patterns = {
            urls[0]: r"15 minutes|0.35 mg/kg",
            urls[1]: r"effects of local anesthetics are additive",
            urls[2]: r"12 hours|60%",
            urls[3]: r"440|2.3 hours|reserved for",
        }
        end = -1
        for match in re.finditer(patterns[row.url], text, re.I):
            if match.start() < end:
                continue
            end = match.end() + 450
            print(text[max(0, match.start()-170):end])
