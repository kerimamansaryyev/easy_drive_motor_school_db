use EasyDriveMotorSchool;
GO;

CREATE OR ALTER VIEW Client_Lesson AS
SELECT
    l.id AS LessonID,
    l.booked_date AS LessonDate,
    l.start_time AS StartTime,
    l.end_time AS EndTime,
    l.price_group_name AS PriceGroupName,
    l.client_id AS ClientID,
    c.name AS ClientName,
    c.gender AS ClientGender,
    c.birth_date AS ClientBirthDate,
    c.phone AS ClientPhone,
    c.office_id AS ClientOfficeID,
    lp.used_car_number AS UsedCarNumber
FROM
    Lesson l
        INNER JOIN
    Client c ON l.client_id = c.id
        LEFT JOIN LessonProgress LP
             ON l.id = LP.lesson_id;
GO;

SELECT * FROM Client_Lesson;