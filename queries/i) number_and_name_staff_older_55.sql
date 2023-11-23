SELECT s.name, s.phone_number, DATEDIFF(YEAR, s.birth_date, GETDATE()) as age
FROM EasyDriveMotorSchool.dbo.Staff s
WHERE (role_name = 'Instructor' OR role_name = 'Senior Instructor') AND DATEDIFF(YEAR, s.birth_date, GETDATE()) >= 55;
