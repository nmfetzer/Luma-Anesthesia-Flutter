/// Explicit public projection. Never select "*" or deep_dive_content.
const medicationPublicFields =
    'id,name,brand_name,class_short,category,high_alert,dea_schedule,'
    'adult_dose,peds_dose,onset_duration,black_box_warning,created_at,updated_at,'
    'classification,lasa_warning,secondary_categories,indications,mechanism,'
    'dose_mg_per_kg_min,dose_mg_per_kg_max,dose_unit,is_infusion,'
    'concentration_mixing,requires_dilution,target_concentration,standard_recipe,'
    'final_volume_ml,diluent,alternative_concentrations,stability_hours_room_temp,'
    'stability_hours_refrigerated,mixing_pearls,notes,common_concentrations,'
    'dosage_forms,routes,onset_minutes,duration_minutes,contraindications,'
    'side_effects,serious_effects,drug_interactions,interactions_critical,'
    'administration_details,special_populations,pregnancy_lactation,'
    'warnings_precautions,pharmacokinetics,antidote_reversal,clinical_pearls,'
    'special_considerations,monitoring_parameters,sources,last_reviewed,'
    'clinical_reviewer,review_cycle_months,hemodynamic_tags,vasoactive_role';
