SELECT
    c.registration_number
FROM EasyDriveMotorSchool.dbo.InstructorCar c
INNER JOIN EasyDriveMotorSchool.dbo.CarInspection ci on c.registration_number = ci.registration_number
GROUP BY c.registration_number
HAVING  COUNT(CASE WHEN ci.has_faults = 1 THEN 1 END) = 0
