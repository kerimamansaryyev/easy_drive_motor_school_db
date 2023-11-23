use EasyDriveMotorSchool;
GO;
CREATE OR ALTER FUNCTION dbo.GetClientLessonDetails

(@client_id INT)
    RETURNS TABLE
        AS
        RETURN
            (
                SELECT
                       l.id,
                       booked_date,
                       start_time,
                       end_time,
                       price_group_name,
                       instructor_staff_id,
                       client_id,
                       name,
                       gender,
                       birth_date,
                       phone,
                       office_id

                FROM Lesson l
                         INNER JOIN dbo.Client C on C.id = l.client_id
                WHERE c.id = @client_id
            )

GO;

DECLARE @ClientID INT = 1;
SELECT *
FROM dbo.GetClientLessonDetails(@ClientID) AS ClientLessons;
GO;