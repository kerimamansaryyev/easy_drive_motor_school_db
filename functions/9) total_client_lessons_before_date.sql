use EasyDriveMotorSchool;
GO;

CREATE OR ALTER FUNCTION dbo.GetTotalLessonsBeforeDate
    (@client_id INT, @target_date DATE)
RETURNS INT
AS
BEGIN
    DECLARE @TotalLessons INT;

    SELECT @TotalLessons = COUNT(*)
    FROM Lesson
    WHERE client_id = @client_id
      AND booked_date < @target_date;

    RETURN @TotalLessons;
END;
GO;

DECLARE @ClientID INT = 1;
DECLARE @TargetDate DATE = '2023-11-11';
SELECT dbo.GetTotalLessonsBeforeDate(@ClientID, @TargetDate) AS TotalLessons;
GO;