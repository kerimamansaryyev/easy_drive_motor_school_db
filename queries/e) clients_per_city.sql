SELECT
    city,
    COUNT(c.office_id) as clients_number
FROM EasyDriveMotorSchool.dbo.Office o
LEFT JOIN EasyDriveMotorSchool.dbo.Client c ON c.office_id = o.id
GROUP BY city;