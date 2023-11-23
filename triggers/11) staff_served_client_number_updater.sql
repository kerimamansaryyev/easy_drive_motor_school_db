use EasyDriveMotorSchool;
GO;

CREATE OR ALTER TRIGGER trg_ClientAdded
    ON Interview
    AFTER INSERT
    AS
BEGIN
    UPDATE Staff
    SET total_clients_served = total_clients_served + 1
    FROM Staff s
             INNER JOIN inserted i ON s.id = i.staff_id;
END;
GO;

CREATE OR ALTER TRIGGER trg_ClientRemoved
        ON Interview
        AFTER DELETE
        AS
    BEGIN
        UPDATE Staff
        SET total_clients_served = IIF(total_clients_served > 0, total_clients_served - 1, 0)
        FROM Staff s
                 INNER JOIN deleted d ON s.id = d.staff_id;
END;
GO;