use EasyDriveMotorSchool;
GO;

CREATE or ALTER VIEW Lesson_Info AS
SELECT
    cl.LessonID,
    cl.LessonDate,
    cl.StartTime,
    cl.EndTime,
    cl.PriceGroupName,
    cl.ClientID,
    cl.ClientName,
    cl.ClientGender,
    cl.ClientBirthDate,
    cl.ClientPhone,
    cl.ClientOfficeID,
    cl.UsedCarNumber,
    s.id AS InstructorID,
    s.name AS InstructorName
FROM
    Client_Lesson cl
        INNER JOIN
    Lesson l ON cl.LessonID = l.id
        INNER JOIN
    Staff s ON l.instructor_staff_id = s.id;
GO;

SELECT * FROM Lesson_Info;
GO;
