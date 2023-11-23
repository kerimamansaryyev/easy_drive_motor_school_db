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
        -- Use CASE statement to update fee based on mileage conditions
        SET @Fee =
                CASE
                    WHEN @Mileage > 30 THEN @Fee + 10
                    WHEN @Mileage > 25 THEN @Fee + 8
                    WHEN @Mileage > 20 THEN @Fee + 5
                    ELSE @Fee
                    END;

        -- Update the Lesson table with the new fee
        UPDATE LessonProgress
        SET mileage_fee = @Fee
        WHERE lesson_id = @LessonID;

        -- Fetch the next row
        FETCH NEXT FROM LessonCursor INTO @LessonID, @Mileage, @Fee;
    END;

-- Close and deallocate the cursor
CLOSE LessonCursor;
DEALLOCATE LessonCursor;
GO;

SELECT * FROM LessonProgress;
GO;