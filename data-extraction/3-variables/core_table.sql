with output1 as(
SELECT *, MAX(aki_stage) OVER (
  PARTITION BY hadm_id Order by UNIX_SECONDS(Timestamp(charttime))
  RANGE BETWEEN 0 PRECEDING AND 604800 FOLLOWING
)
as aki_in_7
FROM `physionet-data.mimic_derived.kdigo_stages` 
),
output2 as(
select hadm_id, adm.subject_id,icu.stay_id, charttime, creat,aki_stage_creat,aki_stage, aki_in_7, dischtime, hospital_expire_flag, los
from output1 join `physionet-data.mimic_core.admissions` adm using(hadm_id)
join  `physionet-data.mimic_icu.icustays` icu using(hadm_id)
where aki_stage !=0
),
output3 as (
  SELECT  stay_id,min(charttime) crrt_start FROM `physionet-data.mimic_derived.crrt` group by stay_id
)


select *, 
case when aki_stage = 1 and aki_in_7=3 then 1  
 when aki_stage = 1 and dischtime between output2.charttime and output2.charttime + interval 7 day and hospital_expire_flag=1 then 1
 when aki_stage = 1 and output3.crrt_start between output2.charttime and output2.charttime + interval 7 day then 1
 when aki_stage = 1 and dischtime between output2.charttime and output2.charttime + interval 7 day then 0
else 0
End as outcome

from output2 
join output3  using(stay_id)
