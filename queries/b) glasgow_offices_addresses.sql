SELECT street + ' ' + city + ', ' + zip_code as full_address
FROM EasyDriveMotorSchool.dbo.Office
WHERE city = 'Glasgow';