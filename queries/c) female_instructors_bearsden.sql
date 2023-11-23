SELECT name
FROM  EasyDriveMotorSchool.dbo.Staff s
JOIN  EasyDriveMotorSchool.dbo.Office o
    ON s.gender = 'F' AND s.office_id = o.id AND o.city = 'Bearsden';