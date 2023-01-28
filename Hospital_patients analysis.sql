SELECT *
FROM [dbo].[patient_info]

SELECT *
FROM [dbo].[ID_mapping]

SELECT COUNT(time_in_hospital)
FROM [dbo].[patient_info] 
GROUP BY time_in_hospital 
ORDER BY time_in_hospital


--the distribution of time spent by patients in the hospital
SELECT FLOOR(time_in_hospital/3.00)*3 As time_in_hospital, 
       COUNT(*) AS [time_in_hospital Count]
FROM [dbo].[patient_info]
GROUP BY FLOOR(time_in_hospital/3.00)*3
ORDER BY 1


--***list of all specialties and the average total of the number of procedures currently practiced at the hospital.

SELECT DISTINCT medical_specialty, COUNT(medical_specialty) as total, 
        ROUND (AVG(num_procedures),1) as average_procedures
FROM [dbo].[patient_info]
WHERE  medical_specialty != '?'
GROUP BY medical_specialty
ORDER BY average_procedures DESC;



SELECT DISTINCT medical_specialty, COUNT(medical_specialty) as total, 
        ROUND (AVG(num_procedures),1) as average_procedures
FROM [dbo].[patient_info]
WHERE  medical_specialty != '?'
GROUP BY medical_specialty
HAVING total > 50 AND average_procedures > 2.5
ORDER BY average_procedures DESC;



--difference in treatment based on race at the hospital. 
SELECT d.race, ROUND(AVG(h.num_lab_procedures),1) as average_num_lab_procedures
FROM [dbo].[patient_info] h
JOIN [dbo].[patient_info] d
ON h.patient_nbr=d.patient_nbr
GROUP BY d.race
ORDER BY average_num_lab_procedures DESC;


--Do people need more procedures if they stay longer in the hospital?
SELECT MIN(num_lab_procedures) as minimum, ROUND(AVG(num_lab_procedures),0) as average, 
      MAX(num_lab_procedures) as maximum
FROM [dbo].[patient_info]


SELECT  ROUND(AVG(time_in_hospital), 0) as days_stay, 
      CASE WHEN num_lab_procedures >= 0 AND num_lab_procedures < 25 THEN 'few'
          WHEN num_lab_procedures >= 25 AND num_lab_procedures < 55 THEN 'average'
          WHEN num_lab_procedures >= 55 THEN 'many' 
		  END AS procedure_frequency
      
FROM [dbo].[patient_info]
GROUP BY procedure_frequency
ORDER BY days_stay;


--list of patient IDs who are African American and have “up” for metformin.
SELECT patient_nbr FROM [dbo].[patient_info] d WHERE race = 'Africa American'
UNION
SELECT patient_nbr FROM [dbo].[patient_info]h  WHERE metformin = 'Up';


WITH total_patients AS (
 SELECT patient_nbr FROM [dbo].[patient_info]  WHERE race = 'Africa American'
 UNION
 SELECT patient_nbr FROM [dbo].[patient_info]  WHERE metformin = 'Up'
)
SELECT COUNT(patient_nbr)
FROM total_patients;

--Succes stories when patients came into the hospital with an emergency (admission_type_id of 1) but stayed less than the average time in the hospital.
WITH average_time_hospital AS(
 SELECT AVG(time_in_hospital) as average
 FROM [dbo].[patient_info]
)
SELECT COUNT(*) as successful_case
FROM [dbo].[patient_info] 
WHERE admission_type_id = 1
AND time_in_hospital < (SELECT* FROM average_time_hospital);


SELECT DISTINCT COUNT(*) as total_patients
FROM [dbo].[patient_info]



--summary for the top 50 medication patients
SELECT CONCAT('Patient ', patient_nbr,' was ',race,' and ',
      CASE WHEN readmitted = 'NO' THEN ' was not readmitted. They had ' ELSE 
            ' was readmiited. They had ' END,
   num_medications, ' medications and', num_lab_procedures, ' lab procedures') as summary
FROM [dbo].[patient_info]

ORDER BY num_medications DESC, num_lab_procedures DESC

