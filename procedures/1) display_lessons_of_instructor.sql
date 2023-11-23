use EasyDriveMotorSchool;
GO;

CREATE OR ALTER PROCEDURE GetInstructorLessons
@instructor_staff_id INT
AS
BEGIN
    SELECT
        l.id AS LessonID,
        l.booked_date AS LessonDate,
        l.start_time AS StartTime,
        l.end_time AS EndTime,
        l.price_group_name AS PriceGroupName,
        l.client_id AS ClientID,
        c.name AS ClientName,
        lp.used_car_number AS UsedCarNumber,
        lp.notes AS LessonNotes,
        lp.mileage AS LessonMileage,
        lp.mileage_fee AS MileageFee
    FROM
        Lesson l
            INNER JOIN
        Client c ON l.client_id = c.id
            LEFT JOIN
        LessonProgress lp ON l.id = lp.lesson_id
    WHERE
            l.instructor_staff_id = @instructor_staff_id;
END;
GO;

EXEC GetInstructorLessons 3;
