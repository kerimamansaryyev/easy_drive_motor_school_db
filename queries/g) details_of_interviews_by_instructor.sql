use EasyDriveMotorSchool;
GO;

CREATE OR ALTER PROCEDURE InstructorInterviewDetails
    @instructor_id INT
as
BEGIN
    SELECT
        CONCAT(i.booked_date, ' ', RIGHT(CONVERT(VARCHAR, i.booked_time, 100), 7)) as date_time,
        c.id as client_id, c.name as client_name, i.notes, i.is_prov_license_valid
    FROM EasyDriveMotorSchool.dbo.Interview i
             INNER JOIN EasyDriveMotorSchool.dbo.Client c on c.id = i.client_id
    WHERE i.staff_id = @instructor_id
END
GO;

EXEC InstructorInterviewDetails @instructor_id = 1;