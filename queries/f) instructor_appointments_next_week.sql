use EasyDriveMotorSchool;
GO;

CREATE OR ALTER PROCEDURE InstructorAppointmentsNextWeek
    @instructor_id INT,
    @date_requested DATE
as
BEGIN
    SELECT
    CONCAT(i.booked_date, ' ', RIGHT(CONVERT(VARCHAR, i.booked_time, 100), 7)) as date_time,
    c.id as client_id, c.name as client_name, 'Interview' as appointment_type
    FROM EasyDriveMotorSchool.dbo.Interview i
    INNER JOIN EasyDriveMotorSchool.dbo.Client c on c.id = i.client_id
    WHERE (i.booked_date >= DATEADD(WEEK, DATEDIFF(WEEK, 0, @date_requested) + 1, 0)  -- Start of next week
      AND i.booked_date < DATEADD(WEEK, DATEDIFF(WEEK, 0, @date_requested) + 2, 0)) AND i.staff_id = @instructor_id -- Start of the week after next

    UNION

    SELECT
        CONCAT(l.booked_date, ' ', RIGHT(CONVERT(VARCHAR, l.start_time, 100), 7)) as date_time,
        c2.id as client_id, c2.name as client_name, 'Lesson' as appointment_type
    FROM EasyDriveMotorSchool.dbo.Lesson l
    INNER JOIN EasyDriveMotorSchool.dbo.Client c2 on C2.id = l.client_id
    WHERE (l.booked_date >= DATEADD(WEEK, DATEDIFF(WEEK, 0, @date_requested) + 1, 0)  -- Start of next week
        AND l.booked_date < DATEADD(WEEK, DATEDIFF(WEEK, 0, @date_requested) + 2, 0)) AND l.instructor_staff_id = @instructor_id -- Start of the week after next

    UNION

    SELECT
        t.date_taken as date_time,
        c2.id as client_id, c2.name as client_name, 'Driving Test' as appointment_type
    FROM EasyDriveMotorSchool.dbo.DrivingTest t
             INNER JOIN EasyDriveMotorSchool.dbo.Client c2 on C2.id = t.client_id
    WHERE (t.date_taken >= DATEADD(WEEK, DATEDIFF(WEEK, 0, @date_requested) + 1, 0)  -- Start of next week
        AND t.date_taken < DATEADD(WEEK, DATEDIFF(WEEK, 0, @date_requested) + 2, 0)) AND t.supervisor_id = @instructor_id -- Start of the week after next
END
GO;

EXEC InstructorAppointmentsNextWeek @instructor_id = 1, @date_requested = '2023-11-1';