use EasyDriveMotorSchool;
GO;

CREATE OR ALTER VIEW Client_Booked_Lessons
AS
SELECT
    c.id, c.name, COUNT(l.id) as lessons_number
FROM Client c
LEFT JOIN Lesson L on c.id = L.client_id
GROUP BY c.id, c.name;
GO;

SELECT * FROM Client_Booked_Lessons ORDER BY  lessons_number DESC;
GO;