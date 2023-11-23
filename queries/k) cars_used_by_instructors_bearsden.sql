SELECT registration_number
FROM EasyDriveMotorSchool.dbo.InstructorCar ic
INNER JOIN EasyDriveMotorSchool.dbo.Staff s
    on s.id = ic.staff_id AND (s.role_name = 'Instructor' OR s.role_name = 'Senior Instructor')
INNER JOIN EasyDriveMotorSchool.dbo.Office O on O.id = ic.office_id AND o.city = 'Bearsden'