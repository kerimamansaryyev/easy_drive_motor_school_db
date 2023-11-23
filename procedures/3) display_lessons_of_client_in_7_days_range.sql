use EasyDriveMotorSchool
GO;

CREATE OR ALTER PROCEDURE GetClientLessonsByDateRange
    @client_id INT,
    @start_date DATE
AS
BEGIN
    SELECT
        l.id AS LessonID,
        l.booked_date AS LessonDate,
        l.start_time AS StartTime,
        l.end_time AS EndTime,
        l.price_group_name AS PriceGroupName,
        l.instructor_staff_id AS InstructorID,
        s.name AS InstructorName,
        lp.used_car_number AS UsedCarNumber,
        lp.notes AS LessonNotes,
        lp.mileage AS LessonMileage,
        lp.mileage_fee AS MileageFee
    FROM
        Lesson l
            INNER JOIN
        Staff s ON l.instructor_staff_id = s.id
            LEFT JOIN
        LessonProgress lp ON l.id = lp.lesson_id
    WHERE
            l.client_id = @client_id
      AND l.booked_date BETWEEN @start_date AND DATEADD(DAY, 7, @start_date);
END
GO;

EXEC GetClientLessonsByDateRange 1, '2023-11-08'
GO;