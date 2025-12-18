CREATE DATABASE HomeServicesDB;
GO
USE HomeServicesDB;
GO

CREATE TYPE UDT_Id            FROM BIGINT;
CREATE TYPE UDT_Name          FROM NVARCHAR(100);
CREATE TYPE UDT_Email         FROM NVARCHAR(150);
CREATE TYPE UDT_Phone         FROM NVARCHAR(20);
CREATE TYPE UDT_Status        FROM NVARCHAR(30);
CREATE TYPE UDT_Description   FROM NVARCHAR(500);
GO

CREATE TABLE Users (
    UserId          UDT_Id IDENTITY PRIMARY KEY,
    Email           UDT_Email NOT NULL UNIQUE,
    Phone           UDT_Phone NULL,
    PasswordHash    NVARCHAR(256) NOT NULL,
    IsOnline        BIT NOT NULL DEFAULT 0,
    
    IsActive        BIT NOT NULL DEFAULT 1,
    CreatedBy       UDT_Name NOT NULL,
    CreatedDate     DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME(),
    UpdatedBy       UDT_Name NULL,
    UpdatedDate     DATETIME2 NULL,

    ValidFrom       DATETIME2 GENERATED ALWAYS AS ROW START,
    ValidTo         DATETIME2 GENERATED ALWAYS AS ROW END,
    PERIOD FOR SYSTEM_TIME (ValidFrom, ValidTo)
)
WITH (SYSTEM_VERSIONING = ON (HISTORY_TABLE = dbo.Users_History));
GO

CREATE TABLE Roles (
    RoleId      UDT_Id IDENTITY PRIMARY KEY,
    RoleName    UDT_Name NOT NULL UNIQUE
);
GO

INSERT INTO Roles (RoleName)
VALUES ('Customer'), ('Captain'), ('Admin');
GO

CREATE TABLE UserRoles (
    UserRoleId  UDT_Id IDENTITY PRIMARY KEY,
    UserId      UDT_Id NOT NULL,
    RoleId      UDT_Id NOT NULL,

    IsActive    BIT NOT NULL DEFAULT 1,
    CreatedBy   UDT_Name NOT NULL,
    CreatedDate DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME(),

    CONSTRAINT FK_UserRoles_Users FOREIGN KEY (UserId) REFERENCES Users(UserId),
    CONSTRAINT FK_UserRoles_Roles FOREIGN KEY (RoleId) REFERENCES Roles(RoleId)
);
GO

CREATE TABLE Addresses (
    AddressId      UDT_Id IDENTITY PRIMARY KEY,
    UserId         UDT_Id NULL,
    AddressLine    NVARCHAR(300),
    City           NVARCHAR(100),
    Area           NVARCHAR(100),
    Pincode        NVARCHAR(10),

    IsActive       BIT DEFAULT 1,
    CreatedDate    DATETIME2 DEFAULT SYSUTCDATETIME()
);


CREATE TABLE UserProfiles (
    ProfileId       UDT_Id IDENTITY PRIMARY KEY,
    UserId          UDT_Id NOT NULL,
    AddressId       UDT_Id NOT NULL,
    FullName        UDT_Name NOT NULL,

    IsActive        BIT NOT NULL DEFAULT 1,
    CreatedBy       UDT_Name NOT NULL,
    CreatedDate     DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME(),
    UpdatedBy       UDT_Name NULL,
    UpdatedDate     DATETIME2 NULL,

    ValidFrom       DATETIME2 GENERATED ALWAYS AS ROW START,
    ValidTo         DATETIME2 GENERATED ALWAYS AS ROW END,
    PERIOD FOR SYSTEM_TIME (ValidFrom, ValidTo),

    CONSTRAINT FK_UserProfiles_Users FOREIGN KEY (UserId) REFERENCES Users(UserId),
    CONSTRAINT FK_UserProfiles_Addresses FOREIGN KEY (AddressId) REFERENCES Addresses(AddressId)
)
WITH (SYSTEM_VERSIONING = ON (HISTORY_TABLE = dbo.UserProfiles_History));
GO

CREATE TABLE SkillTypes (
    SkillId     UDT_Id IDENTITY PRIMARY KEY,
    SkillName   UDT_Name NOT NULL UNIQUE,

    IsActive    BIT NOT NULL DEFAULT 1,
    CreatedBy   UDT_Name NOT NULL,
    CreatedDate DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME()
);
GO

INSERT INTO SkillTypes (SkillName, CreatedBy)
VALUES ('Plumber','System'), ('Electrician','System'),
       ('Cook','System'), ('Laundry','System');
GO

CREATE TABLE UserSkills (
    UserSkillId     UDT_Id IDENTITY PRIMARY KEY,
    UserId          UDT_Id NOT NULL,
    SkillId         UDT_Id NOT NULL,

    IsVerified      BIT NOT NULL DEFAULT 0,
    VerificationStatus UDT_Status NOT NULL DEFAULT 'Pending',

    IsActive        BIT NOT NULL DEFAULT 1,
    CreatedBy       UDT_Name NOT NULL,
    CreatedDate     DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME(),
    UpdatedBy       UDT_Name NULL,
    UpdatedDate     DATETIME2 NULL,

    ValidFrom       DATETIME2 GENERATED ALWAYS AS ROW START,
    ValidTo         DATETIME2 GENERATED ALWAYS AS ROW END,
    PERIOD FOR SYSTEM_TIME (ValidFrom, ValidTo),

    CONSTRAINT FK_UserSkills_Users FOREIGN KEY (UserId) REFERENCES Users(UserId),
    CONSTRAINT FK_UserSkills_Skills FOREIGN KEY (SkillId) REFERENCES SkillTypes(SkillId)
)
WITH (SYSTEM_VERSIONING = ON (HISTORY_TABLE = dbo.UserSkills_History));
GO

CREATE TABLE Bookings (
    BookingId       UDT_Id IDENTITY PRIMARY KEY,
    CustomerId      UDT_Id NOT NULL,
    SkillId         UDT_Id NOT NULL,
    BookingStatus   UDT_Status NOT NULL DEFAULT 'Requested',
    ServiceAddress  NVARCHAR(300),
    Description     UDT_Description,

    IsActive        BIT NOT NULL DEFAULT 1,
    CreatedBy       UDT_Name NOT NULL,
    CreatedDate     DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME(),
    UpdatedBy       UDT_Name NULL,
    UpdatedDate     DATETIME2 NULL,

    ValidFrom       DATETIME2 GENERATED ALWAYS AS ROW START,
    ValidTo         DATETIME2 GENERATED ALWAYS AS ROW END,
    PERIOD FOR SYSTEM_TIME (ValidFrom, ValidTo),

    CONSTRAINT FK_Bookings_Customer FOREIGN KEY (CustomerId) REFERENCES Users(UserId),
    CONSTRAINT FK_Bookings_Skill FOREIGN KEY (SkillId) REFERENCES SkillTypes(SkillId)
)
WITH (SYSTEM_VERSIONING = ON (HISTORY_TABLE = dbo.Bookings_History));
GO

CREATE TABLE BookingAssignments (
    AssignmentId    UDT_Id IDENTITY PRIMARY KEY,
    BookingId       UDT_Id NOT NULL,
    CaptainId       UDT_Id NOT NULL,
    AssignedStatus  UDT_Status NOT NULL DEFAULT 'Assigned',

    IsActive        BIT NOT NULL DEFAULT 1,
    CreatedBy       UDT_Name NOT NULL,
    CreatedDate     DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME(),

    CONSTRAINT FK_Assignments_Booking FOREIGN KEY (BookingId) REFERENCES Bookings(BookingId),
    CONSTRAINT FK_Assignments_Captain FOREIGN KEY (CaptainId) REFERENCES Users(UserId)
);
GO
