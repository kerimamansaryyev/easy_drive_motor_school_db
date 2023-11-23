use EasyDriveMotorSchool;
GO;


DECLARE @LessonID INT;
DECLARE @Mileage INT;
DECLARE @Fee DECIMAL(10, 2);


DECLARE LessonCursor CURSOR FOR
    SELECT id, mileage, mileage_fee
    FROM Lesson
    INNER JOIN LessonProgress LP on Lesson.id = LP.lesson_id

OPEN LessonCursor;


FETCH NEXT FROM LessonCursor INTO @LessonID, @Mileage, @Fee;


WHILE @@FETCH_STATUS = 0
    BEGIN
        IF @Mileage > 30
            SET @Fee = @Fee + 10;
        ELSE IF @Mileage > 25
            SET @Fee = @Fee + 8;
        ELSE IF @Mileage > 20
            SET @Fee = @Fee + 5;

        UPDATE LessonProgress
        SET mileage_fee = @Fee
        WHERE lesson_id = @LessonID;

        FETCH NEXT FROM LessonCursor INTO @LessonID, @Mileage, @Fee;
    END;

CLOSE LessonCursor;
DEALLOCATE LessonCursor;
GO;

SELECT * FROM  LessonProgress;