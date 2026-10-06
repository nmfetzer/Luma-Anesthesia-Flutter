// HPB display groups reuse canonical clinical records across specialties.
const surgicalHpbGroups = <String, List<String>>{
  "Planning & liver physiology": [
    "hepatobiliary-anesthesia-framework",
    "cirrhosis-portal-hypertension-perioperative",
  ],
  "Gallbladder & biliary surgery": [
    "laparoscopic-cholecystectomy",
    "robotic-cholecystectomy",
    "open-cholecystectomy",
    "bile-duct-exploration",
    "biliary-reconstruction-hepaticojejunostomy",
  ],
  "Liver resection & donation": [
    "hepatic-resection-open-laparoscopic",
    "living-donor-hepatectomy",
  ],
  "Pancreatic surgery & endocrine overlap": [
    "whipple-procedure-pancreaticoduodenectomy",
    "distal-pancreatectomy",
    "pancreatic-enucleation",
    "insulinoma-resection",
    "pancreatic-neuroendocrine-tumor-resection",
  ],
  "Urgent HPB & interventional cases": [
    "cholangitis-obstructed-biliary-drainage",
    "ercp-endoscopic-retrograde-cholangiopancreatography",
    "variceal-banding-hemorrhage",
    "pancreatitis-necrosis-intervention",
    "tips-portal-decompression",
    "hpb-hemorrhage-bile-leak-emergencies",
  ],
  "Transplant recipient physiology": ["liver-transplant"],
};
