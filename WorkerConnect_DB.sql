CREATE DATABASE WorkerConnect;
GO

USE WorkerConnect;
GO

--------------------------------------
-------USER DEFINED DATA TYPES--------
--------------------------------------
-- Numeric Types
CREATE TYPE UDT_Int     FROM INT;
CREATE TYPE UDT_BigInt  FROM BIGINT;
CREATE TYPE UDT_Decimal FROM DECIMAL(10,2);
GO

-- String Types
CREATE TYPE UDT_VarChar50   FROM VARCHAR(50);
CREATE TYPE UDT_VarChar100  FROM VARCHAR(100);
CREATE TYPE UDT_NVarchar50  FROM NVARCHAR(50);
CREATE TYPE UDT_NVarchar100 FROM NVARCHAR(100);
CREATE TYPE UDT_NVarchar255 FROM NVARCHAR(255);
GO
-- Boolean
CREATE TYPE UDT_Bool FROM BIT;
GO
-- DateTime
CREATE TYPE UDT_DateTime FROM DATETIME2;
GO
-- Special (Phone Number, Email, etc.)
CREATE TYPE UDT_PhoneNumber FROM BIGINT;  -- Better than string for uniform validation
CREATE TYPE UDT_Email       FROM NVARCHAR(100);
GO
--------------------------------------
-------=TEMPORALTABLES=======--------
--------------------------------------

CREATE TABLE Users (
    UserId        UDT_Int      IDENTITY PRIMARY KEY,
    FullName      UDT_NVarchar100 NOT NULL,
    Email		  UDT_Email UNIQUE NOT NULL,
    Phone		  UDT_PhoneNumber UNIQUE NOT NULL,
    PasswordHash  UDT_NVarchar255 NOT NULL,
    Role		  UDT_NVarchar50 NOT NULL CHECK (Role IN ('Customer','Worker','Admin')),
    CreatedAt     UDT_DateTime DEFAULT SYSUTCDATETIME(),
    IsActive      UDT_Bool DEFAULT 1,

    -- Temporal table system columns
    ValidFrom DATETIME2 GENERATED ALWAYS AS ROW START NOT NULL,
    ValidTo DATETIME2 GENERATED ALWAYS AS ROW END NOT NULL,
    PERIOD FOR SYSTEM_TIME (ValidFrom, ValidTo)
)
WITH (SYSTEM_VERSIONING = ON (HISTORY_TABLE = dbo.UsersHistory));
GO


CREATE TABLE WorkerProfiles (
    WorkerId UDT_Int PRIMARY KEY FOREIGN KEY REFERENCES Users(UserId),
    Skill UDT_NVarchar100 NOT NULL,
    HourlyRate UDT_Decimal NOT NULL,
    Location UDT_NVarchar100 NOT NULL,
    ExperienceYears UDT_Int NULL,
    IsApproved UDT_Bool DEFAULT 0,
    CreatedAt UDT_DateTime DEFAULT SYSUTCDATETIME(),

    -- Temporal support
    ValidFrom DATETIME2 GENERATED ALWAYS AS ROW START NOT NULL,
    ValidTo DATETIME2 GENERATED ALWAYS AS ROW END NOT NULL,
    PERIOD FOR SYSTEM_TIME (ValidFrom, ValidTo)
)
WITH (SYSTEM_VERSIONING = ON (HISTORY_TABLE = dbo.WorkerProfilesHistory));
GO


CREATE TABLE Bookings (
    BookingId UDT_Int IDENTITY PRIMARY KEY,
    CustomerId UDT_Int FOREIGN KEY REFERENCES Users(UserId),
    WorkerId UDT_Int FOREIGN KEY REFERENCES Users(UserId),
    BookingDate UDT_DateTime NOT NULL,
    ScheduledDate UDT_DateTime NULL,
    Status UDT_NVarchar50 NOT NULL DEFAULT 'Pending' 
        CHECK (Status IN ('Pending','Accepted','Rejected','Completed')),
    Notes UDT_NVarchar255 NULL,
    CreatedAt UDT_DateTime DEFAULT SYSUTCDATETIME(),

    -- Temporal
    ValidFrom DATETIME2 GENERATED ALWAYS AS ROW START NOT NULL,
    ValidTo DATETIME2 GENERATED ALWAYS AS ROW END NOT NULL,
    PERIOD FOR SYSTEM_TIME (ValidFrom, ValidTo)
)
WITH (SYSTEM_VERSIONING = ON (HISTORY_TABLE = dbo.BookingsHistory));


CREATE TABLE AdminActions (
    ActionId UDT_Int IDENTITY PRIMARY KEY,
    AdminId UDT_Int FOREIGN KEY REFERENCES Users(UserId),
    WorkerId UDT_Int FOREIGN KEY REFERENCES Users(UserId),
    ActionType UDT_NVarchar50 NOT NULL,   -- ApproveWorker, RejectWorker
    ActionDate UDT_DateTime DEFAULT SYSUTCDATETIME(),
    Remarks UDT_NVarchar255 NULL,

    -- Temporal
    ValidFrom DATETIME2 GENERATED ALWAYS AS ROW START NOT NULL,
    ValidTo DATETIME2 GENERATED ALWAYS AS ROW END NOT NULL,
    PERIOD FOR SYSTEM_TIME (ValidFrom, ValidTo)
)
WITH (SYSTEM_VERSIONING = ON (HISTORY_TABLE = dbo.AdminActionsHistory));



