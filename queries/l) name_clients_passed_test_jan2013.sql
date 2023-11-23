SELECT DISTINCT C.name
FROM EasyDriveMotorSchool.dbo.DrivingTest
INNER JOIN EasyDriveMotorSchool.dbo.Client C on C.id = DrivingTest.client_id
WHERE MONTH(date_taken) = 1 AND YEAR(date_taken) = 2013
