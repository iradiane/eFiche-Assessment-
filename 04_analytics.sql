-- ================================================
-- PART 3: FINAL ANALYTICS QUERIES
-- ================================================

-- 1. Number of encounters per month
SELECT 
    dd.year,
    dd.month_name,
    COUNT(*) AS encounter_count
FROM dwh.fact_encounter f
JOIN dwh.dim_date dd ON f.date_key = dd.date_key
GROUP BY dd.year, dd.month_name, dd.month  
ORDER BY dd.year, dd.month;                



-- 2. Most frequent diagnoses per age group
WITH age_groups AS (
    SELECT 
        patient_key,
        CASE 
            WHEN age < 18 THEN '0-17'
            WHEN age BETWEEN 18 AND 34 THEN '18-34'
            WHEN age BETWEEN 35 AND 54 THEN '35-54'
            ELSE '55+' 
        END AS age_group
    FROM dwh.dim_patient
    WHERE is_current = TRUE  -- Only current patient records
)
SELECT 
    ag.age_group,
    ddiag.code,
    COUNT(*) AS diagnosis_count
FROM dwh.fact_encounter f
JOIN age_groups ag ON f.patient_key = ag.patient_key
JOIN dwh.dim_diagnosis ddiag ON f.diagnosis_key = ddiag.diagnosis_key
GROUP BY ag.age_group, ddiag.code
ORDER BY ag.age_group, diagnosis_count desc
LIMIT 20;


-- 3. Average studies (encounters) per patient
SELECT 
    ROUND(AVG(study_count)::numeric, 2) AS avg_studies_per_patient
FROM (
    SELECT 
        e.patient_id, 
        COUNT(*) AS study_count
    FROM encounters e
    GROUP BY e.patient_id
) patient_studies;


-- 4. Top diagnosis clusters from report text (keyword-based)
SELECT 
    word, 
    COUNT(*) AS frequency
FROM (
    SELECT 
        unnest(string_to_array(
            lower(regexp_replace(COALESCE(text, ''), '[^a-záéíóúñ ]', '', 'g')
        ), ' ')) AS word
    FROM reports 
    WHERE text IS NOT NULL AND text <> ''
) words
WHERE word IN (
    'pneumonia', 'cardiomegaly', 'edema', 'effusion', 
    'atelectasis', 'normal', 'consolidation', 'infiltrates',
    'opacity', 'fracture', 'mass', 'nodule'
)
GROUP BY word
ORDER BY frequency DESC;