use EasyDriveMotorSchool;
GO;

CREATE OR ALTER FUNCTION dbo.GetTotalLessonsForClient
(@client_id INT)
    RETURNS INT
AS
BEGIN
    DECLARE @TotalLessons INT;

    SELECT @TotalLessons = COUNT(*)
    FROM Lesson
    WHERE client_id = @client_id
      AND booked_date <= GETDATE();

    RETURN @TotalLessons;
END;
GO;

SELECT dbo.GetTotalLessonsForClient(1) AS TotalLessons;
GO;