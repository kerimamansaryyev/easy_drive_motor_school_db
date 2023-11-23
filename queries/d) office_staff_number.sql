SELECT
    o.street + ' ' + o.city as office,
    (
        SELECT COUNT(*)
        FROM EasyDriveMotorSchool.dbo.Staff s
        WHERE s.office_id = o.id
    ) as staff_number
FROM EasyDriveMotorSchool.dbo.Office o;