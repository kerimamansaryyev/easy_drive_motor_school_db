SELECT o.city, phone_number as manager_phone_number, s.id
FROM EasyDriveMotorSchool.dbo.Staff s
RIGHT JOIN EasyDriveMotorSchool.dbo.Office o ON o.manager_staff_id = s.id;