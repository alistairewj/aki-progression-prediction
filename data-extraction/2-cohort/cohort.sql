SELECT 
    subject_id, hadm_id
    , admittime, dischtime

    -- time of a-line
    , starttime_aki
    , aki_stage_creat

    -- columns which help filter data
    , aki_window_starttime
    , aki_window_endtime
FROM aki_study.eligible
WHERE exclude_not_ed = 0
AND exclude_not_aki_stage_1 = 0
;