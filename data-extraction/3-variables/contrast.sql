
-- Performing an imaging test  
-- Arterial contrast administration (catheterization) before AKIN1 diagnosis

-- use radiology_detail and the exam code to determine if there is contrast
-- FROM `physionet-data.mimiciv_note.radiology_detail`
WITH img_contrast AS
(
    SELECT co.hadm_id
        , r.charttime
        -- exclude anything that says without contrast
        -- example exam names:
        -- ABDOMINAL FLUORO WITHOUT RADIOLOGIST
        -- BARIUM SWALLOW/ESOPHAGUS
        -- CHEST FLUORO
        -- CT ABD & PELVIS W & W/O CONTRAST, ADDL SECTIONS
        -- CT ABD & PELVIS WITH CONTRAST
        -- CT ABD W&W/O C
        -- CT ABDOMEN AND PELVIS W/CONTRAST W/ONC TABLES
        -- CT ABDOMEN W & W/O CONTRAST W/ONC TABLES
        -- CT ABDOMEN W/CONTRAST
        -- CT C-SPINE W/CONTRAST
        -- CT CHEST W&W/O C
        -- CT HEAD W/O CONTRAST
        , CASE
            -- with and without
            WHEN LOWER(rd.field_value) LIKE '%w & w/o c%' THEN 1
            WHEN LOWER(rd.field_value) LIKE '%w&w/o c%' THEN 1
            -- without contrast
            WHEN LOWER(rd.field_value) LIKE '%without contrast%' THEN 0
            WHEN LOWER(rd.field_value) LIKE '%without c%' THEN 0
            WHEN LOWER(rd.field_value) LIKE '%w/o contrast%' THEN 0
            WHEN LOWER(rd.field_value) LIKE '%w/o c%' THEN 0
            -- with contrast
            WHEN LOWER(rd.field_value) LIKE '%with contrast%' THEN 1
            WHEN LOWER(rd.field_value) LIKE '%with c%' THEN 1
            WHEN LOWER(rd.field_value) LIKE '%w/ contrast%' THEN 1
            WHEN LOWER(rd.field_value) LIKE '%w/ c%' THEN 1
            -- other
            WHEN LOWER(rd.field_value) LIKE '%contrast%' THEN 1
            ELSE 0
        END AS with_contrast
        , rd.field_value AS exam_name
    FROM aki_study.cohort co
    INNER JOIN physionet-data.mimiciv_note.radiology r
        ON co.hadm_id = r.hadm_id
        AND r.charttime >= co.aki_window_starttime
        AND r.charttime <= co.aki_window_endtime
    INNER JOIN physionet-data.mimiciv_note.radiology_detail rd
        ON r.note_id = rd.note_id
        AND rd.field_name = 'exam_name'
)
SELECT hadm_id
    , charttime
    , with_contrast
    , exam_name
FROM img_contrast
WHERE with_contrast = 1