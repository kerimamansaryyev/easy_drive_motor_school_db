SELECT city,
       COUNT(CASE WHEN c.gender = 'M' THEN 1 END) AS count_male,
       COUNT(CASE WHEN c.gender = 'F' THEN 1 END) AS count_female
FROM EasyDriveMotorSchool.dbo.Office o
INNER JOIN EasyDriveMotorSchool.dbo.Client c on o.id = c.office_id
GROUP BY city;