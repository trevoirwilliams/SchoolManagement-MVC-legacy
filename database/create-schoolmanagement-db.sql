/*
    SchoolManagement Legacy MVC - Database Bootstrap Script

    Purpose:
    Creates the LocalDB/SQL Server database expected by the inherited ASP.NET MVC 5 application.

    Default connection strings in SchoolManagement/Web.config point to:
    - Server: (LocalDb)\MSSQLLocalDB
    - Database: SchoolManagement_DB

    Recommended local command:
    sqlcmd -S "(localdb)\MSSQLLocalDB" -i database/create-schoolmanagement-db.sql

    Notes:
    - This script is intentionally non-destructive.
    - It creates missing tables and inserts sample school data only when the tables are empty.
    - It creates the ASP.NET Identity tables required by ApplicationDbContext.
    - It seeds roles only. Users should be created through the application registration workflow.
*/

IF DB_ID(N'SchoolManagement_DB') IS NULL
BEGIN
    CREATE DATABASE [SchoolManagement_DB];
END
GO

USE [SchoolManagement_DB];
GO

SET ANSI_NULLS ON;
SET QUOTED_IDENTIFIER ON;
GO

/* ============================================================
   ASP.NET Identity 2 tables used by ApplicationDbContext
   ============================================================ */

IF OBJECT_ID(N'[dbo].[AspNetRoles]', N'U') IS NULL
BEGIN
    CREATE TABLE [dbo].[AspNetRoles]
    (
        [Id] NVARCHAR(128) NOT NULL,
        [Name] NVARCHAR(256) NOT NULL,
        CONSTRAINT [PK_dbo.AspNetRoles] PRIMARY KEY CLUSTERED ([Id] ASC)
    );

    CREATE UNIQUE NONCLUSTERED INDEX [RoleNameIndex]
        ON [dbo].[AspNetRoles]([Name] ASC);
END
GO

IF OBJECT_ID(N'[dbo].[AspNetUsers]', N'U') IS NULL
BEGIN
    CREATE TABLE [dbo].[AspNetUsers]
    (
        [Id] NVARCHAR(128) NOT NULL,
        [Email] NVARCHAR(256) NULL,
        [EmailConfirmed] BIT NOT NULL CONSTRAINT [DF_AspNetUsers_EmailConfirmed] DEFAULT (0),
        [PasswordHash] NVARCHAR(MAX) NULL,
        [SecurityStamp] NVARCHAR(MAX) NULL,
        [PhoneNumber] NVARCHAR(MAX) NULL,
        [PhoneNumberConfirmed] BIT NOT NULL CONSTRAINT [DF_AspNetUsers_PhoneNumberConfirmed] DEFAULT (0),
        [TwoFactorEnabled] BIT NOT NULL CONSTRAINT [DF_AspNetUsers_TwoFactorEnabled] DEFAULT (0),
        [LockoutEndDateUtc] DATETIME NULL,
        [LockoutEnabled] BIT NOT NULL CONSTRAINT [DF_AspNetUsers_LockoutEnabled] DEFAULT (0),
        [AccessFailedCount] INT NOT NULL CONSTRAINT [DF_AspNetUsers_AccessFailedCount] DEFAULT (0),
        [UserName] NVARCHAR(256) NOT NULL,
        [BirthDate] DATETIME NOT NULL CONSTRAINT [DF_AspNetUsers_BirthDate] DEFAULT ('19000101'),
        CONSTRAINT [PK_dbo.AspNetUsers] PRIMARY KEY CLUSTERED ([Id] ASC)
    );

    CREATE UNIQUE NONCLUSTERED INDEX [UserNameIndex]
        ON [dbo].[AspNetUsers]([UserName] ASC);
END
GO

IF OBJECT_ID(N'[dbo].[AspNetUserClaims]', N'U') IS NULL
BEGIN
    CREATE TABLE [dbo].[AspNetUserClaims]
    (
        [Id] INT IDENTITY(1,1) NOT NULL,
        [UserId] NVARCHAR(128) NOT NULL,
        [ClaimType] NVARCHAR(MAX) NULL,
        [ClaimValue] NVARCHAR(MAX) NULL,
        CONSTRAINT [PK_dbo.AspNetUserClaims] PRIMARY KEY CLUSTERED ([Id] ASC),
        CONSTRAINT [FK_dbo.AspNetUserClaims_dbo.AspNetUsers_UserId]
            FOREIGN KEY ([UserId]) REFERENCES [dbo].[AspNetUsers]([Id]) ON DELETE CASCADE
    );

    CREATE NONCLUSTERED INDEX [IX_UserId]
        ON [dbo].[AspNetUserClaims]([UserId] ASC);
END
GO

IF OBJECT_ID(N'[dbo].[AspNetUserLogins]', N'U') IS NULL
BEGIN
    CREATE TABLE [dbo].[AspNetUserLogins]
    (
        [LoginProvider] NVARCHAR(128) NOT NULL,
        [ProviderKey] NVARCHAR(128) NOT NULL,
        [UserId] NVARCHAR(128) NOT NULL,
        CONSTRAINT [PK_dbo.AspNetUserLogins]
            PRIMARY KEY CLUSTERED ([LoginProvider] ASC, [ProviderKey] ASC, [UserId] ASC),
        CONSTRAINT [FK_dbo.AspNetUserLogins_dbo.AspNetUsers_UserId]
            FOREIGN KEY ([UserId]) REFERENCES [dbo].[AspNetUsers]([Id]) ON DELETE CASCADE
    );

    CREATE NONCLUSTERED INDEX [IX_UserId]
        ON [dbo].[AspNetUserLogins]([UserId] ASC);
END
GO

IF OBJECT_ID(N'[dbo].[AspNetUserRoles]', N'U') IS NULL
BEGIN
    CREATE TABLE [dbo].[AspNetUserRoles]
    (
        [UserId] NVARCHAR(128) NOT NULL,
        [RoleId] NVARCHAR(128) NOT NULL,
        CONSTRAINT [PK_dbo.AspNetUserRoles]
            PRIMARY KEY CLUSTERED ([UserId] ASC, [RoleId] ASC),
        CONSTRAINT [FK_dbo.AspNetUserRoles_dbo.AspNetUsers_UserId]
            FOREIGN KEY ([UserId]) REFERENCES [dbo].[AspNetUsers]([Id]) ON DELETE CASCADE,
        CONSTRAINT [FK_dbo.AspNetUserRoles_dbo.AspNetRoles_RoleId]
            FOREIGN KEY ([RoleId]) REFERENCES [dbo].[AspNetRoles]([Id]) ON DELETE CASCADE
    );

    CREATE NONCLUSTERED INDEX [IX_UserId]
        ON [dbo].[AspNetUserRoles]([UserId] ASC);

    CREATE NONCLUSTERED INDEX [IX_RoleId]
        ON [dbo].[AspNetUserRoles]([RoleId] ASC);
END
GO

/* ============================================================
   School management tables used by the EF6 Database First model
   ============================================================ */

IF OBJECT_ID(N'[dbo].[Course]', N'U') IS NULL
BEGIN
    CREATE TABLE [dbo].[Course]
    (
        [CourseId] INT IDENTITY(1,1) NOT NULL,
        [Title] NVARCHAR(50) NOT NULL,
        [Credits] INT NOT NULL,
        CONSTRAINT [PK_dbo.Course] PRIMARY KEY CLUSTERED ([CourseId] ASC)
    );
END
GO

IF OBJECT_ID(N'[dbo].[Student]', N'U') IS NULL
BEGIN
    CREATE TABLE [dbo].[Student]
    (
        [StudentID] INT IDENTITY(1,1) NOT NULL,
        [LastName] NVARCHAR(50) NULL,
        [FirstName] NVARCHAR(50) NULL,
        [EnrollmentDate] DATETIME NULL,
        [MiddleName] NVARCHAR(50) NULL,
        [DateOfBirth] DATETIME NULL,
        CONSTRAINT [PK_dbo.Student] PRIMARY KEY CLUSTERED ([StudentID] ASC)
    );
END
GO

IF OBJECT_ID(N'[dbo].[Lecturers]', N'U') IS NULL
BEGIN
    CREATE TABLE [dbo].[Lecturers]
    (
        [Id] INT IDENTITY(1,1) NOT NULL,
        [First Name] NVARCHAR(50) NULL,
        [Last Name] NVARCHAR(50) NULL,
        CONSTRAINT [PK_dbo.Lecturers] PRIMARY KEY CLUSTERED ([Id] ASC)
    );
END
GO

IF OBJECT_ID(N'[dbo].[Enrollment]', N'U') IS NULL
BEGIN
    CREATE TABLE [dbo].[Enrollment]
    (
        [EnrollmentID] INT IDENTITY(1,1) NOT NULL,
        [Grade] DECIMAL(3,2) NULL,
        [CourseID] INT NOT NULL,
        [StudentID] INT NOT NULL,
        [LecturerId] INT NULL,
        CONSTRAINT [PK_dbo.Enrollment] PRIMARY KEY CLUSTERED ([EnrollmentID] ASC),
        CONSTRAINT [FK_dbo_Enrollment_dbo_Course_CourseID]
            FOREIGN KEY ([CourseID]) REFERENCES [dbo].[Course]([CourseId]) ON DELETE CASCADE,
        CONSTRAINT [FK_dbo_Enrollment_dbo_Student_StudentID]
            FOREIGN KEY ([StudentID]) REFERENCES [dbo].[Student]([StudentID]) ON DELETE CASCADE,
        CONSTRAINT [FK_dbo_Enrollment_dbo_Lecturer_LecturerID]
            FOREIGN KEY ([LecturerId]) REFERENCES [dbo].[Lecturers]([Id]) ON DELETE CASCADE
    );

    CREATE NONCLUSTERED INDEX [IX_CourseID]
        ON [dbo].[Enrollment]([CourseID] ASC);

    CREATE NONCLUSTERED INDEX [IX_StudentID]
        ON [dbo].[Enrollment]([StudentID] ASC);

    CREATE NONCLUSTERED INDEX [IX_LecturerId]
        ON [dbo].[Enrollment]([LecturerId] ASC);
END
GO

/* ============================================================
   Seed baseline roles and sample school data
   ============================================================ */

IF NOT EXISTS (SELECT 1 FROM [dbo].[AspNetRoles] WHERE [Name] = N'Admin')
BEGIN
    INSERT INTO [dbo].[AspNetRoles] ([Id], [Name])
    VALUES (N'role-admin', N'Admin');
END

IF NOT EXISTS (SELECT 1 FROM [dbo].[AspNetRoles] WHERE [Name] = N'Teacher')
BEGIN
    INSERT INTO [dbo].[AspNetRoles] ([Id], [Name])
    VALUES (N'role-teacher', N'Teacher');
END

IF NOT EXISTS (SELECT 1 FROM [dbo].[AspNetRoles] WHERE [Name] = N'Supervisor')
BEGIN
    INSERT INTO [dbo].[AspNetRoles] ([Id], [Name])
    VALUES (N'role-supervisor', N'Supervisor');
END
GO

IF NOT EXISTS (SELECT 1 FROM [dbo].[Course])
BEGIN
    SET IDENTITY_INSERT [dbo].[Course] ON;

    INSERT INTO [dbo].[Course] ([CourseId], [Title], [Credits])
    VALUES
        (1, N'Mathematics', 3),
        (2, N'English Language Arts', 3),
        (3, N'Integrated Science', 4),
        (4, N'Computer Studies', 3),
        (5, N'History and Social Studies', 3);

    SET IDENTITY_INSERT [dbo].[Course] OFF;
END
GO

IF NOT EXISTS (SELECT 1 FROM [dbo].[Student])
BEGIN
    SET IDENTITY_INSERT [dbo].[Student] ON;

    INSERT INTO [dbo].[Student]
        ([StudentID], [LastName], [FirstName], [EnrollmentDate], [MiddleName], [DateOfBirth])
    VALUES
        (1, N'Bennett', N'Alicia', '2022-09-05', N'Marie', '2012-04-18'),
        (2, N'Clarke', N'Daniel', '2022-09-05', NULL, '2011-11-02'),
        (3, N'Johnson', N'Maya', '2023-09-04', N'Grace', '2012-07-26'),
        (4, N'Morgan', N'Ethan', '2023-09-04', NULL, '2011-02-14'),
        (5, N'Williams', N'Sophia', '2024-09-02', N'Anne', '2013-09-09');

    SET IDENTITY_INSERT [dbo].[Student] OFF;
END
GO

IF NOT EXISTS (SELECT 1 FROM [dbo].[Lecturers])
BEGIN
    SET IDENTITY_INSERT [dbo].[Lecturers] ON;

    INSERT INTO [dbo].[Lecturers] ([Id], [First Name], [Last Name])
    VALUES
        (1, N'Olivia', N'Grant'),
        (2, N'Michael', N'Brown'),
        (3, N'Natalie', N'Campbell'),
        (4, N'Andre', N'Smith');

    SET IDENTITY_INSERT [dbo].[Lecturers] OFF;
END
GO

IF NOT EXISTS (SELECT 1 FROM [dbo].[Enrollment])
BEGIN
    SET IDENTITY_INSERT [dbo].[Enrollment] ON;

    INSERT INTO [dbo].[Enrollment]
        ([EnrollmentID], [Grade], [CourseID], [StudentID], [LecturerId])
    VALUES
        (1, 3.60, 1, 1, 1),
        (2, 3.40, 2, 1, 2),
        (3, 3.20, 1, 2, 1),
        (4, 3.80, 3, 3, 3),
        (5, 3.10, 4, 4, 4),
        (6, NULL, 5, 5, NULL);

    SET IDENTITY_INSERT [dbo].[Enrollment] OFF;
END
GO

PRINT 'SchoolManagement_DB database bootstrap completed.';
GO
