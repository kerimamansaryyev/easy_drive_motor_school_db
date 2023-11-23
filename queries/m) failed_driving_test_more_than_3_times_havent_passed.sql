SELECT  c.name
FROM EasyDriveMotorSchool.dbo.DrivingTest t
INNER JOIN EasyDriveMotorSchool.dbo.Client c on c.id = t.client_id
GROUP BY c.name, c.id, t.passed
HAVING COUNT(CASE WHEN t.passed = 0 THEN 1 END) > 3 AND COUNT(CASE WHEN t.passed = 1 THEN 1 END) = 0
