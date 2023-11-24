create table LessonPriceGroup
(
    group_name varchar(50) not null
        primary key,
    amount     decimal(10, 2)
)
go

create table Office
(
    id               int identity
        primary key,
    street           varchar(255),
    city             varchar(255),
    zip_code         varchar(10),
    phone            varchar(15),
    manager_staff_id int
)
go

create table Client
(
    id         int identity
        primary key,
    name       varchar(255),
    gender     char,
    birth_date date,
    phone      varchar(15),
    office_id  int
        references Office
)
go

create table StaffRole
(
    role_name varchar(50) not null
        primary key
)
go

create table Staff
(
    id                   int identity
        primary key,
    name                 varchar(255),
    gender               char,
    phone_number         varchar(15),
    birth_date           date,
    office_id            int
        references Office,
    role_name            varchar(50)
        references StaffRole,
    total_clients_served int
)
go

create table InstructorCar
(
    registration_number varchar(20) not null
        primary key,
    model               varchar(50),
    office_id           int
        references Office,
    staff_id            int
        unique
        references Staff
)
go

create table CarInspection
(
    id                  int identity
        primary key,
    registration_number varchar(20)
        references InstructorCar,
    inspected_date      date,
    has_faults          bit,
    notes               text
)
go

create table DrivingTest
(
    id              int identity
        primary key,
    date_taken      date,
    client_id       int
        references Client,
    supervisor_id   int
        references Staff,
    used_car_number varchar(20)
        references InstructorCar,
    written_grade   varchar(10),
    driving_grade   varchar(10),
    passed          bit,
    notes           text
)
go

CREATE TRIGGER CheckOfficeConsistency
    ON InstructorCar
    INSTEAD OF INSERT
    AS
BEGIN
    SET NOCOUNT ON;

    IF EXISTS (
        SELECT 1
        FROM inserted i
                 JOIN Staff s ON i.staff_id = s.id
        WHERE i.office_id <> s.office_id
    )
        BEGIN
            THROW 50000, 'Instructor office_id must match the car office_id.', 1;
        END
    ELSE
        BEGIN
            -- Perform the actual insert if the check passes
            INSERT INTO InstructorCar (registration_number, model, office_id, staff_id)
            SELECT registration_number, model, office_id, staff_id
            FROM inserted;
        END
END;
go

create table Interview
(
    id                    int identity
        primary key,
    booked_date           date,
    is_prov_license_valid bit,
    notes                 text,
    staff_id              int
        references Staff,
    client_id             int
        references Client,
    booked_time           time,
    constraint Interview_pk
        unique (booked_date, booked_time, staff_id)
)
go

CREATE   TRIGGER trg_ClientAdded
    ON Interview
    AFTER INSERT
    AS
BEGIN
    UPDATE Staff
    SET total_clients_served = total_clients_served + 1
    FROM Staff s
             INNER JOIN inserted i ON s.id = i.staff_id;
END;
go

CREATE   TRIGGER trg_ClientRemoved
    ON Interview
    AFTER DELETE
    AS
BEGIN
    UPDATE Staff
    SET total_clients_served = IIF(total_clients_served > 0, total_clients_served - 1, 0)
    FROM Staff s
             INNER JOIN deleted d ON s.id = d.staff_id;
END;
go

create table Lesson
(
    id                  int identity
        primary key,
    booked_date         date,
    start_time          time
        check ([start_time] >= '08:00:00' AND [start_time] <= '20:00:00'),
    end_time            time,
    price_group_name    varchar(50)
        references LessonPriceGroup,
    instructor_staff_id int
        references Staff,
    client_id           int
        references Client,
    check ([end_time] >= dateadd(hour, 1, [start_time]) AND [end_time] <= '21:00:00' AND [end_time] > [start_time])
)
go

create table LessonProgress
(
    lesson_id       int not null
        primary key
        references Lesson,
    notes           text,
    mileage         int,
    mileage_fee     decimal(10, 2),
    used_car_number varchar(20)
        references InstructorCar
)
go

alter table Office
    add constraint Office_Staff_Staff_fk
        foreign key (manager_staff_id) references Staff
go

CREATE   VIEW Client_Booked_Lessons
AS
SELECT
    c.id, c.name, COUNT(l.id) as lessons_number
FROM Client c
         LEFT JOIN Lesson L on c.id = L.client_id
GROUP BY c.id, c.name
go

CREATE   VIEW Client_Lesson AS
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
                  ON l.id = LP.lesson_id
go

CREATE   VIEW Lesson_Info AS
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
    Staff s ON l.instructor_staff_id = s.id
go

CREATE   VIEW TotalPriceForLesson
AS
SELECT  l.*,
        LPG.amount as sub_total_price,
        LP.mileage_fee as mileage_fee,
        CONCAT(CONVERT(NVARCHAR, (LP.mileage_fee+LPG.amount)), '$') as total_price
FROM Lesson l
         INNER JOIN LessonProgress LP on l.id = LP.lesson_id
         INNER JOIN LessonPriceGroup LPG on LPG.group_name = l.price_group_name
go

CREATE   PROCEDURE FindInstructorWithoutCar
    @office_id INT,
    @InstructorID INT OUTPUT
AS
BEGIN
    -- Find the first occurrence of id of an Instructor without an assigned car
    SELECT TOP 1 @InstructorID = s.id
    FROM Staff s
    WHERE (s.role_name = 'Instructor' OR s.role_name = 'Senior Instructor') AND s.office_id = @office_id
      AND s.id NOT IN (SELECT DISTINCT staff_id FROM InstructorCar WHERE staff_id IS NOT NULL);
END;
go

CREATE   FUNCTION dbo.GetClientLessonDetails

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
go

CREATE   PROCEDURE GetClientLessonsByDateRange
    @client_id INT,
    @start_date DATE
AS
BEGIN
    SELECT
        l.id AS LessonID,
        l.booked_date AS LessonDate,
        l.start_time AS StartTime,
        l.end_time AS EndTime,
        l.price_group_name AS PriceGroupName,
        l.instructor_staff_id AS InstructorID,
        s.name AS InstructorName,
        lp.used_car_number AS UsedCarNumber,
        lp.notes AS LessonNotes,
        lp.mileage AS LessonMileage,
        lp.mileage_fee AS MileageFee
    FROM
        Lesson l
            INNER JOIN
        Staff s ON l.instructor_staff_id = s.id
            LEFT JOIN
        LessonProgress lp ON l.id = lp.lesson_id
    WHERE
            l.client_id = @client_id
      AND l.booked_date BETWEEN @start_date AND DATEADD(DAY, 7, @start_date);
END
go

CREATE   PROCEDURE GetInstructorAppointmentsNextWeek
    @instructor_id INT,
    @date_requested DATE
as
BEGIN
    SELECT
        CONCAT(i.booked_date, ' ', RIGHT(CONVERT(VARCHAR, i.booked_time, 100), 7)) as date_time,
        c.id as client_id, c.name as client_name, 'Interview' as appointment_type
    FROM EasyDriveMotorSchool.dbo.Interview i
             INNER JOIN EasyDriveMotorSchool.dbo.Client c on c.id = i.client_id
    WHERE (i.booked_date >= DATEADD(WEEK, DATEDIFF(WEEK, 0, @date_requested) + 1, 0)  -- Start of next week
        AND i.booked_date < DATEADD(WEEK, DATEDIFF(WEEK, 0, @date_requested) + 2, 0)) AND i.staff_id = @instructor_id -- Start of the week after next

    UNION

    SELECT
        CONCAT(l.booked_date, ' ', RIGHT(CONVERT(VARCHAR, l.start_time, 100), 7)) as date_time,
        c2.id as client_id, c2.name as client_name, 'Lesson' as appointment_type
    FROM EasyDriveMotorSchool.dbo.Lesson l
             INNER JOIN EasyDriveMotorSchool.dbo.Client c2 on C2.id = l.client_id
    WHERE (l.booked_date >= DATEADD(WEEK, DATEDIFF(WEEK, 0, @date_requested) + 1, 0)  -- Start of next week
        AND l.booked_date < DATEADD(WEEK, DATEDIFF(WEEK, 0, @date_requested) + 2, 0)) AND l.instructor_staff_id = @instructor_id -- Start of the week after next

    UNION

    SELECT
        CONVERT(VARCHAR, date_taken) as date_time,
        c2.id as client_id, c2.name as client_name, 'Driving Test' as appointment_type
    FROM EasyDriveMotorSchool.dbo.DrivingTest t
             INNER JOIN EasyDriveMotorSchool.dbo.Client c2 on C2.id = t.client_id
    WHERE (t.date_taken >= DATEADD(WEEK, DATEDIFF(WEEK, 0, @date_requested) + 1, 0)  -- Start of next week
        AND t.date_taken < DATEADD(WEEK, DATEDIFF(WEEK, 0, @date_requested) + 2, 0)) AND t.supervisor_id = @instructor_id -- Start of the week after next
END
go

CREATE   PROCEDURE GetInstructorLessons
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
go

CREATE   PROCEDURE GetInstructorLessonsByDateRange
    @instructor_staff_id INT,
    @start_date DATE
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
            l.instructor_staff_id = @instructor_staff_id
      AND l.booked_date BETWEEN @start_date AND DATEADD(DAY, 7, @start_date);
END;
go

CREATE   FUNCTION dbo.GetTotalLessonsBeforeDate
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
END
go

CREATE   FUNCTION dbo.GetTotalLessonsForClient
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
END
go

CREATE   PROCEDURE InstructorInterviewDetails
@instructor_id INT
as
BEGIN
    SELECT
        CONCAT(i.booked_date, ' ', RIGHT(CONVERT(VARCHAR, i.booked_time, 100), 7)) as date_time,
        c.id as client_id, c.name as client_name, i.notes, i.is_prov_license_valid
    FROM EasyDriveMotorSchool.dbo.Interview i
             INNER JOIN EasyDriveMotorSchool.dbo.Client c on c.id = i.client_id
    WHERE i.staff_id = @instructor_id
END
go

