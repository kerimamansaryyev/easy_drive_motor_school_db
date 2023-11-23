use EasyDriveMotorSchool;
GO;

CREATE OR ALTER VIEW TotalPriceForLesson
AS
SELECT  l.*,
        LPG.amount as sub_total_price,
        LP.mileage_fee as mileage_fee,
        CONCAT(CONVERT(NVARCHAR, (LP.mileage_fee+LPG.amount)), '$') as total_price
FROM Lesson l
INNER JOIN LessonProgress LP on l.id = LP.lesson_id
INNER JOIN LessonPriceGroup LPG on LPG.group_name = l.price_group_name;
GO;

SELECT * FROM TotalPriceForLesson;