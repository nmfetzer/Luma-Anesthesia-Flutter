/// Curated Vasopressors, Infusions & Transfusions drug set (34 drugs).
///
/// Filtering by explicit ID list — durable against category renames.
/// EXCLUDED: all insulin infusions, lidocaine patch 5%, esketamine/Spravato.
const List<String> vasopressorInfusionIds = [
  // Cardiac & Hemodynamics — 18
  '6aaa807db81b981e8d29fad2', // Adenosine
  '6aaa807db81b981e8d29fad5', // Amiodarone
  '6aaa805e5da5b22c17c9f001', // Angiotensin II (Giapreza)
  '6aaa807db81b981e8d29fad9', // Clevidipine (Cleviprex)
  '6aaa807db81b981e8d29fadb', // Diltiazem
  '6aaa807db81b981e8d29fadd', // Ephedrine
  '6aaa8062c92c14141e6a2038', // Esmolol
  '6aaa8062c92c14141e6a203d', // Hydralazine
  '6aaa8062c92c14141e6a2042', // Isoproterenol
  '6aaa8062c92c14141e6a2043', // Labetalol
  '6aaa8062c92c14141e6a2045', // Lidocaine (Xylocaine IV)
  '6aaa8062c92c14141e6a2049', // Metoprolol
  '6aaa8062c92c14141e6a204a', // Nicardipine (Cardene)
  '6aaa8062c92c14141e6a204b', // Nitroglycerin IV
  '6aaa8062c92c14141e6a204d', // Norepinephrine
  '6aaa8062c92c14141e6a204e', // Norepi + Vaso combo
  '6aaa8062c92c14141e6a2050', // Phenylephrine
  '6aaa8062c92c14141e6a205a', // Vasopressin

  // Emergency & Crisis — 7
  '6aaa8062c92c14141e6a2087', // Calcium Chloride
  '6aaa8062c92c14141e6a208a', // Dobutamine
  '6aaa8062c92c14141e6a208b', // Dopamine
  '6aaa8062c92c14141e6a208c', // Epinephrine (ACLS)
  '6aaa8062c92c14141e6a2092', // Milrinone
  '6aaa8062c92c14141e6a2095', // Nicardipine IV
  '6aaa8062c92c14141e6a2096', // Nitroprusside

  // Sedatives & Hypnotics — 2
  '6aaa8064c92c14141e6a2136', // Dexmedetomidine Low-Dose Bolus
  '6aaa8064c92c14141e6a2137', // Dexmedetomidine (Precedex)

  // Analgesics — 1
  '6aaa807bb81b981e8d29f952', // Remifentanil

  // Endocrine — 1
  '6aaa8064c92c14141e6a2120', // Oxytocin

  // Anesthetics-IV induction — 2
  '6aaa8064c92c14141e6a213a', // Ketamine (Induction)
  '6aaa8064c92c14141e6a213f', // Propofol (Diprivan)
];
