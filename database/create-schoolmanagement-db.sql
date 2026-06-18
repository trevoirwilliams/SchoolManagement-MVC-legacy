/*
    SchoolManagement Legacy MVC - Database Bootstrap Script with Expanded Seed Data

    Purpose:
    Creates the LocalDB/SQL Server database expected by the inherited ASP.NET MVC 5 application.

    Default connection strings in SchoolManagement/Web.config point to:
    - Server: (LocalDb)\MSSQLLocalDB
    - Database: SchoolManagement_DB

    Recommended local command:
    sqlcmd -S "(localdb)\MSSQLLocalDB" -i database/create-schoolmanagement-db.sql

    Expanded seed data:
    - 24 courses across grades 6, 7, and 8 plus electives/advisory.
    - 12 lecturers across core and enrichment subjects.
    - 48 students representing two intake years: 2023-2024 and 2024-2025.
    - 384 enrollment records with a mix of completed grades and in-progress NULL grades.

    Important modeling note:
    The current EF6 Database First schema has no AcademicYear, Term, Section, or GradeLevel table.
    The expanded seed data therefore simulates two years through enrollment dates, grade-banded course names,
    and a realistic spread of course enrollments without changing the EDMX-compatible schema.

    Notes:
    - This script is intentionally non-destructive.
    - It creates missing tables and inserts missing seed rows by fixed IDs.
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
   Seed baseline roles
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

/* ============================================================
   Expanded seed data: courses, lecturers, students, enrollments
   ============================================================ */

SET IDENTITY_INSERT [dbo].[Course] ON;
IF NOT EXISTS (SELECT 1 FROM [dbo].[Course] WHERE [CourseId] = 1)
BEGIN
    INSERT INTO [dbo].[Course] ([CourseId], [Title], [Credits])
    VALUES (1, N'Grade 6 Mathematics', 3);
END
IF NOT EXISTS (SELECT 1 FROM [dbo].[Course] WHERE [CourseId] = 2)
BEGIN
    INSERT INTO [dbo].[Course] ([CourseId], [Title], [Credits])
    VALUES (2, N'Grade 6 English Language Arts', 3);
END
IF NOT EXISTS (SELECT 1 FROM [dbo].[Course] WHERE [CourseId] = 3)
BEGIN
    INSERT INTO [dbo].[Course] ([CourseId], [Title], [Credits])
    VALUES (3, N'Grade 6 Integrated Science', 4);
END
IF NOT EXISTS (SELECT 1 FROM [dbo].[Course] WHERE [CourseId] = 4)
BEGIN
    INSERT INTO [dbo].[Course] ([CourseId], [Title], [Credits])
    VALUES (4, N'Grade 6 Social Studies', 3);
END
IF NOT EXISTS (SELECT 1 FROM [dbo].[Course] WHERE [CourseId] = 5)
BEGIN
    INSERT INTO [dbo].[Course] ([CourseId], [Title], [Credits])
    VALUES (5, N'Grade 6 Computer Studies', 3);
END
IF NOT EXISTS (SELECT 1 FROM [dbo].[Course] WHERE [CourseId] = 6)
BEGIN
    INSERT INTO [dbo].[Course] ([CourseId], [Title], [Credits])
    VALUES (6, N'Grade 6 Bible and Character', 2);
END
IF NOT EXISTS (SELECT 1 FROM [dbo].[Course] WHERE [CourseId] = 7)
BEGIN
    INSERT INTO [dbo].[Course] ([CourseId], [Title], [Credits])
    VALUES (7, N'Grade 7 Mathematics', 3);
END
IF NOT EXISTS (SELECT 1 FROM [dbo].[Course] WHERE [CourseId] = 8)
BEGIN
    INSERT INTO [dbo].[Course] ([CourseId], [Title], [Credits])
    VALUES (8, N'Grade 7 English Language Arts', 3);
END
IF NOT EXISTS (SELECT 1 FROM [dbo].[Course] WHERE [CourseId] = 9)
BEGIN
    INSERT INTO [dbo].[Course] ([CourseId], [Title], [Credits])
    VALUES (9, N'Grade 7 Integrated Science', 4);
END
IF NOT EXISTS (SELECT 1 FROM [dbo].[Course] WHERE [CourseId] = 10)
BEGIN
    INSERT INTO [dbo].[Course] ([CourseId], [Title], [Credits])
    VALUES (10, N'Grade 7 Social Studies', 3);
END
IF NOT EXISTS (SELECT 1 FROM [dbo].[Course] WHERE [CourseId] = 11)
BEGIN
    INSERT INTO [dbo].[Course] ([CourseId], [Title], [Credits])
    VALUES (11, N'Grade 7 Computer Studies', 3);
END
IF NOT EXISTS (SELECT 1 FROM [dbo].[Course] WHERE [CourseId] = 12)
BEGIN
    INSERT INTO [dbo].[Course] ([CourseId], [Title], [Credits])
    VALUES (12, N'Grade 7 Bible and Character', 2);
END
IF NOT EXISTS (SELECT 1 FROM [dbo].[Course] WHERE [CourseId] = 13)
BEGIN
    INSERT INTO [dbo].[Course] ([CourseId], [Title], [Credits])
    VALUES (13, N'Grade 8 Mathematics', 3);
END
IF NOT EXISTS (SELECT 1 FROM [dbo].[Course] WHERE [CourseId] = 14)
BEGIN
    INSERT INTO [dbo].[Course] ([CourseId], [Title], [Credits])
    VALUES (14, N'Grade 8 English Language Arts', 3);
END
IF NOT EXISTS (SELECT 1 FROM [dbo].[Course] WHERE [CourseId] = 15)
BEGIN
    INSERT INTO [dbo].[Course] ([CourseId], [Title], [Credits])
    VALUES (15, N'Grade 8 Integrated Science', 4);
END
IF NOT EXISTS (SELECT 1 FROM [dbo].[Course] WHERE [CourseId] = 16)
BEGIN
    INSERT INTO [dbo].[Course] ([CourseId], [Title], [Credits])
    VALUES (16, N'Grade 8 Social Studies', 3);
END
IF NOT EXISTS (SELECT 1 FROM [dbo].[Course] WHERE [CourseId] = 17)
BEGIN
    INSERT INTO [dbo].[Course] ([CourseId], [Title], [Credits])
    VALUES (17, N'Grade 8 Computer Studies', 3);
END
IF NOT EXISTS (SELECT 1 FROM [dbo].[Course] WHERE [CourseId] = 18)
BEGIN
    INSERT INTO [dbo].[Course] ([CourseId], [Title], [Credits])
    VALUES (18, N'Grade 8 Bible and Character', 2);
END
IF NOT EXISTS (SELECT 1 FROM [dbo].[Course] WHERE [CourseId] = 19)
BEGIN
    INSERT INTO [dbo].[Course] ([CourseId], [Title], [Credits])
    VALUES (19, N'Physical Education', 2);
END
IF NOT EXISTS (SELECT 1 FROM [dbo].[Course] WHERE [CourseId] = 20)
BEGIN
    INSERT INTO [dbo].[Course] ([CourseId], [Title], [Credits])
    VALUES (20, N'Music Appreciation', 2);
END
IF NOT EXISTS (SELECT 1 FROM [dbo].[Course] WHERE [CourseId] = 21)
BEGIN
    INSERT INTO [dbo].[Course] ([CourseId], [Title], [Credits])
    VALUES (21, N'Visual Arts', 2);
END
IF NOT EXISTS (SELECT 1 FROM [dbo].[Course] WHERE [CourseId] = 22)
BEGIN
    INSERT INTO [dbo].[Course] ([CourseId], [Title], [Credits])
    VALUES (22, N'Spanish Foundations', 2);
END
IF NOT EXISTS (SELECT 1 FROM [dbo].[Course] WHERE [CourseId] = 23)
BEGIN
    INSERT INTO [dbo].[Course] ([CourseId], [Title], [Credits])
    VALUES (23, N'Study Skills and Advisory', 1);
END
IF NOT EXISTS (SELECT 1 FROM [dbo].[Course] WHERE [CourseId] = 24)
BEGIN
    INSERT INTO [dbo].[Course] ([CourseId], [Title], [Credits])
    VALUES (24, N'Technology Lab', 2);
END

SET IDENTITY_INSERT [dbo].[Course] OFF;
GO

SET IDENTITY_INSERT [dbo].[Lecturers] ON;
IF NOT EXISTS (SELECT 1 FROM [dbo].[Lecturers] WHERE [Id] = 1)
BEGIN
    INSERT INTO [dbo].[Lecturers] ([Id], [First Name], [Last Name])
    VALUES (1, N'Olivia', N'Grant');
END
IF NOT EXISTS (SELECT 1 FROM [dbo].[Lecturers] WHERE [Id] = 2)
BEGIN
    INSERT INTO [dbo].[Lecturers] ([Id], [First Name], [Last Name])
    VALUES (2, N'Michael', N'Brown');
END
IF NOT EXISTS (SELECT 1 FROM [dbo].[Lecturers] WHERE [Id] = 3)
BEGIN
    INSERT INTO [dbo].[Lecturers] ([Id], [First Name], [Last Name])
    VALUES (3, N'Natalie', N'Campbell');
END
IF NOT EXISTS (SELECT 1 FROM [dbo].[Lecturers] WHERE [Id] = 4)
BEGIN
    INSERT INTO [dbo].[Lecturers] ([Id], [First Name], [Last Name])
    VALUES (4, N'Andre', N'Smith');
END
IF NOT EXISTS (SELECT 1 FROM [dbo].[Lecturers] WHERE [Id] = 5)
BEGIN
    INSERT INTO [dbo].[Lecturers] ([Id], [First Name], [Last Name])
    VALUES (5, N'Priya', N'Singh');
END
IF NOT EXISTS (SELECT 1 FROM [dbo].[Lecturers] WHERE [Id] = 6)
BEGIN
    INSERT INTO [dbo].[Lecturers] ([Id], [First Name], [Last Name])
    VALUES (6, N'Marcus', N'Johnson');
END
IF NOT EXISTS (SELECT 1 FROM [dbo].[Lecturers] WHERE [Id] = 7)
BEGIN
    INSERT INTO [dbo].[Lecturers] ([Id], [First Name], [Last Name])
    VALUES (7, N'Elena', N'Rodriguez');
END
IF NOT EXISTS (SELECT 1 FROM [dbo].[Lecturers] WHERE [Id] = 8)
BEGIN
    INSERT INTO [dbo].[Lecturers] ([Id], [First Name], [Last Name])
    VALUES (8, N'David', N'Miller');
END
IF NOT EXISTS (SELECT 1 FROM [dbo].[Lecturers] WHERE [Id] = 9)
BEGIN
    INSERT INTO [dbo].[Lecturers] ([Id], [First Name], [Last Name])
    VALUES (9, N'Karen', N'Lee');
END
IF NOT EXISTS (SELECT 1 FROM [dbo].[Lecturers] WHERE [Id] = 10)
BEGIN
    INSERT INTO [dbo].[Lecturers] ([Id], [First Name], [Last Name])
    VALUES (10, N'Samuel', N'Thompson');
END
IF NOT EXISTS (SELECT 1 FROM [dbo].[Lecturers] WHERE [Id] = 11)
BEGIN
    INSERT INTO [dbo].[Lecturers] ([Id], [First Name], [Last Name])
    VALUES (11, N'Grace', N'Anderson');
END
IF NOT EXISTS (SELECT 1 FROM [dbo].[Lecturers] WHERE [Id] = 12)
BEGIN
    INSERT INTO [dbo].[Lecturers] ([Id], [First Name], [Last Name])
    VALUES (12, N'Renee', N'Foster');
END

SET IDENTITY_INSERT [dbo].[Lecturers] OFF;
GO

SET IDENTITY_INSERT [dbo].[Student] ON;
IF NOT EXISTS (SELECT 1 FROM [dbo].[Student] WHERE [StudentID] = 1)
BEGIN
    INSERT INTO [dbo].[Student] ([StudentID], [LastName], [FirstName], [EnrollmentDate], [MiddleName], [DateOfBirth])
    VALUES (1, N'Bennett', N'Alicia', '2023-09-04', N'Marie', '2011-04-18');
END
IF NOT EXISTS (SELECT 1 FROM [dbo].[Student] WHERE [StudentID] = 2)
BEGIN
    INSERT INTO [dbo].[Student] ([StudentID], [LastName], [FirstName], [EnrollmentDate], [MiddleName], [DateOfBirth])
    VALUES (2, N'Clarke', N'Daniel', '2023-09-04', NULL, '2010-11-02');
END
IF NOT EXISTS (SELECT 1 FROM [dbo].[Student] WHERE [StudentID] = 3)
BEGIN
    INSERT INTO [dbo].[Student] ([StudentID], [LastName], [FirstName], [EnrollmentDate], [MiddleName], [DateOfBirth])
    VALUES (3, N'Johnson', N'Maya', '2023-09-04', N'Grace', '2011-07-26');
END
IF NOT EXISTS (SELECT 1 FROM [dbo].[Student] WHERE [StudentID] = 4)
BEGIN
    INSERT INTO [dbo].[Student] ([StudentID], [LastName], [FirstName], [EnrollmentDate], [MiddleName], [DateOfBirth])
    VALUES (4, N'Morgan', N'Ethan', '2023-09-04', NULL, '2010-02-14');
END
IF NOT EXISTS (SELECT 1 FROM [dbo].[Student] WHERE [StudentID] = 5)
BEGIN
    INSERT INTO [dbo].[Student] ([StudentID], [LastName], [FirstName], [EnrollmentDate], [MiddleName], [DateOfBirth])
    VALUES (5, N'Williams', N'Sophia', '2023-09-04', N'Anne', '2011-09-09');
END
IF NOT EXISTS (SELECT 1 FROM [dbo].[Student] WHERE [StudentID] = 6)
BEGIN
    INSERT INTO [dbo].[Student] ([StudentID], [LastName], [FirstName], [EnrollmentDate], [MiddleName], [DateOfBirth])
    VALUES (6, N'Campbell', N'Noah', '2023-09-04', N'James', '2010-05-21');
END
IF NOT EXISTS (SELECT 1 FROM [dbo].[Student] WHERE [StudentID] = 7)
BEGIN
    INSERT INTO [dbo].[Student] ([StudentID], [LastName], [FirstName], [EnrollmentDate], [MiddleName], [DateOfBirth])
    VALUES (7, N'Robinson', N'Zoe', '2023-09-04', N'Elaine', '2011-12-03');
END
IF NOT EXISTS (SELECT 1 FROM [dbo].[Student] WHERE [StudentID] = 8)
BEGIN
    INSERT INTO [dbo].[Student] ([StudentID], [LastName], [FirstName], [EnrollmentDate], [MiddleName], [DateOfBirth])
    VALUES (8, N'Davis', N'Liam', '2023-09-04', NULL, '2010-03-29');
END
IF NOT EXISTS (SELECT 1 FROM [dbo].[Student] WHERE [StudentID] = 9)
BEGIN
    INSERT INTO [dbo].[Student] ([StudentID], [LastName], [FirstName], [EnrollmentDate], [MiddleName], [DateOfBirth])
    VALUES (9, N'Hall', N'Isabella', '2023-09-04', N'Rose', '2011-01-15');
END
IF NOT EXISTS (SELECT 1 FROM [dbo].[Student] WHERE [StudentID] = 10)
BEGIN
    INSERT INTO [dbo].[Student] ([StudentID], [LastName], [FirstName], [EnrollmentDate], [MiddleName], [DateOfBirth])
    VALUES (10, N'Evans', N'Caleb', '2023-09-04', N'Ryan', '2010-08-18');
END
IF NOT EXISTS (SELECT 1 FROM [dbo].[Student] WHERE [StudentID] = 11)
BEGIN
    INSERT INTO [dbo].[Student] ([StudentID], [LastName], [FirstName], [EnrollmentDate], [MiddleName], [DateOfBirth])
    VALUES (11, N'Thompson', N'Ava', '2023-09-04', N'Nicole', '2011-10-27');
END
IF NOT EXISTS (SELECT 1 FROM [dbo].[Student] WHERE [StudentID] = 12)
BEGIN
    INSERT INTO [dbo].[Student] ([StudentID], [LastName], [FirstName], [EnrollmentDate], [MiddleName], [DateOfBirth])
    VALUES (12, N'King', N'Joshua', '2023-09-04', N'Lee', '2010-06-12');
END
IF NOT EXISTS (SELECT 1 FROM [dbo].[Student] WHERE [StudentID] = 13)
BEGIN
    INSERT INTO [dbo].[Student] ([StudentID], [LastName], [FirstName], [EnrollmentDate], [MiddleName], [DateOfBirth])
    VALUES (13, N'Green', N'Mia', '2023-09-04', N'Faith', '2011-02-22');
END
IF NOT EXISTS (SELECT 1 FROM [dbo].[Student] WHERE [StudentID] = 14)
BEGIN
    INSERT INTO [dbo].[Student] ([StudentID], [LastName], [FirstName], [EnrollmentDate], [MiddleName], [DateOfBirth])
    VALUES (14, N'Turner', N'Nathan', '2023-09-04', NULL, '2010-09-30');
END
IF NOT EXISTS (SELECT 1 FROM [dbo].[Student] WHERE [StudentID] = 15)
BEGIN
    INSERT INTO [dbo].[Student] ([StudentID], [LastName], [FirstName], [EnrollmentDate], [MiddleName], [DateOfBirth])
    VALUES (15, N'Phillips', N'Amelia', '2023-09-04', N'Joy', '2011-05-06');
END
IF NOT EXISTS (SELECT 1 FROM [dbo].[Student] WHERE [StudentID] = 16)
BEGIN
    INSERT INTO [dbo].[Student] ([StudentID], [LastName], [FirstName], [EnrollmentDate], [MiddleName], [DateOfBirth])
    VALUES (16, N'Edwards', N'Isaiah', '2023-09-04', N'Paul', '2010-12-19');
END
IF NOT EXISTS (SELECT 1 FROM [dbo].[Student] WHERE [StudentID] = 17)
BEGIN
    INSERT INTO [dbo].[Student] ([StudentID], [LastName], [FirstName], [EnrollmentDate], [MiddleName], [DateOfBirth])
    VALUES (17, N'Morris', N'Chloe', '2023-09-04', N'Ruth', '2012-03-11');
END
IF NOT EXISTS (SELECT 1 FROM [dbo].[Student] WHERE [StudentID] = 18)
BEGIN
    INSERT INTO [dbo].[Student] ([StudentID], [LastName], [FirstName], [EnrollmentDate], [MiddleName], [DateOfBirth])
    VALUES (18, N'Bailey', N'Elijah', '2023-09-04', NULL, '2011-06-24');
END
IF NOT EXISTS (SELECT 1 FROM [dbo].[Student] WHERE [StudentID] = 19)
BEGIN
    INSERT INTO [dbo].[Student] ([StudentID], [LastName], [FirstName], [EnrollmentDate], [MiddleName], [DateOfBirth])
    VALUES (19, N'Parker', N'Lily', '2023-09-04', N'Hope', '2012-01-08');
END
IF NOT EXISTS (SELECT 1 FROM [dbo].[Student] WHERE [StudentID] = 20)
BEGIN
    INSERT INTO [dbo].[Student] ([StudentID], [LastName], [FirstName], [EnrollmentDate], [MiddleName], [DateOfBirth])
    VALUES (20, N'Reid', N'Gabriel', '2023-09-04', N'John', '2011-10-05');
END
IF NOT EXISTS (SELECT 1 FROM [dbo].[Student] WHERE [StudentID] = 21)
BEGIN
    INSERT INTO [dbo].[Student] ([StudentID], [LastName], [FirstName], [EnrollmentDate], [MiddleName], [DateOfBirth])
    VALUES (21, N'Lewis', N'Emma', '2023-09-04', N'Claire', '2012-04-20');
END
IF NOT EXISTS (SELECT 1 FROM [dbo].[Student] WHERE [StudentID] = 22)
BEGIN
    INSERT INTO [dbo].[Student] ([StudentID], [LastName], [FirstName], [EnrollmentDate], [MiddleName], [DateOfBirth])
    VALUES (22, N'Walker', N'Aaron', '2023-09-04', N'Miles', '2011-07-07');
END
IF NOT EXISTS (SELECT 1 FROM [dbo].[Student] WHERE [StudentID] = 23)
BEGIN
    INSERT INTO [dbo].[Student] ([StudentID], [LastName], [FirstName], [EnrollmentDate], [MiddleName], [DateOfBirth])
    VALUES (23, N'Scott', N'Hannah', '2023-09-04', N'Beth', '2012-09-16');
END
IF NOT EXISTS (SELECT 1 FROM [dbo].[Student] WHERE [StudentID] = 24)
BEGIN
    INSERT INTO [dbo].[Student] ([StudentID], [LastName], [FirstName], [EnrollmentDate], [MiddleName], [DateOfBirth])
    VALUES (24, N'Young', N'Jacob', '2023-09-04', NULL, '2011-11-28');
END
IF NOT EXISTS (SELECT 1 FROM [dbo].[Student] WHERE [StudentID] = 25)
BEGIN
    INSERT INTO [dbo].[Student] ([StudentID], [LastName], [FirstName], [EnrollmentDate], [MiddleName], [DateOfBirth])
    VALUES (25, N'Allen', N'Madison', '2024-09-02', N'Skye', '2012-02-04');
END
IF NOT EXISTS (SELECT 1 FROM [dbo].[Student] WHERE [StudentID] = 26)
BEGIN
    INSERT INTO [dbo].[Student] ([StudentID], [LastName], [FirstName], [EnrollmentDate], [MiddleName], [DateOfBirth])
    VALUES (26, N'Wright', N'Samuel', '2024-09-02', N'Dean', '2011-08-09');
END
IF NOT EXISTS (SELECT 1 FROM [dbo].[Student] WHERE [StudentID] = 27)
BEGIN
    INSERT INTO [dbo].[Student] ([StudentID], [LastName], [FirstName], [EnrollmentDate], [MiddleName], [DateOfBirth])
    VALUES (27, N'Nelson', N'Aria', '2024-09-02', N'Kate', '2012-12-13');
END
IF NOT EXISTS (SELECT 1 FROM [dbo].[Student] WHERE [StudentID] = 28)
BEGIN
    INSERT INTO [dbo].[Student] ([StudentID], [LastName], [FirstName], [EnrollmentDate], [MiddleName], [DateOfBirth])
    VALUES (28, N'Carter', N'Benjamin', '2024-09-02', N'Luke', '2011-03-17');
END
IF NOT EXISTS (SELECT 1 FROM [dbo].[Student] WHERE [StudentID] = 29)
BEGIN
    INSERT INTO [dbo].[Student] ([StudentID], [LastName], [FirstName], [EnrollmentDate], [MiddleName], [DateOfBirth])
    VALUES (29, N'Mitchell', N'Ella', '2024-09-02', N'Jane', '2012-05-25');
END
IF NOT EXISTS (SELECT 1 FROM [dbo].[Student] WHERE [StudentID] = 30)
BEGIN
    INSERT INTO [dbo].[Student] ([StudentID], [LastName], [FirstName], [EnrollmentDate], [MiddleName], [DateOfBirth])
    VALUES (30, N'Perez', N'Lucas', '2024-09-02', N'Mateo', '2011-09-02');
END
IF NOT EXISTS (SELECT 1 FROM [dbo].[Student] WHERE [StudentID] = 31)
BEGIN
    INSERT INTO [dbo].[Student] ([StudentID], [LastName], [FirstName], [EnrollmentDate], [MiddleName], [DateOfBirth])
    VALUES (31, N'Cooper', N'Grace', '2024-09-02', N'Lynn', '2012-10-10');
END
IF NOT EXISTS (SELECT 1 FROM [dbo].[Student] WHERE [StudentID] = 32)
BEGIN
    INSERT INTO [dbo].[Student] ([StudentID], [LastName], [FirstName], [EnrollmentDate], [MiddleName], [DateOfBirth])
    VALUES (32, N'Richardson', N'Owen', '2024-09-02', NULL, '2011-01-31');
END
IF NOT EXISTS (SELECT 1 FROM [dbo].[Student] WHERE [StudentID] = 33)
BEGIN
    INSERT INTO [dbo].[Student] ([StudentID], [LastName], [FirstName], [EnrollmentDate], [MiddleName], [DateOfBirth])
    VALUES (33, N'Gray', N'Leah', '2024-09-02', N'Noelle', '2013-04-02');
END
IF NOT EXISTS (SELECT 1 FROM [dbo].[Student] WHERE [StudentID] = 34)
BEGIN
    INSERT INTO [dbo].[Student] ([StudentID], [LastName], [FirstName], [EnrollmentDate], [MiddleName], [DateOfBirth])
    VALUES (34, N'James', N'Matthew', '2024-09-02', N'Cole', '2012-06-06');
END
IF NOT EXISTS (SELECT 1 FROM [dbo].[Student] WHERE [StudentID] = 35)
BEGIN
    INSERT INTO [dbo].[Student] ([StudentID], [LastName], [FirstName], [EnrollmentDate], [MiddleName], [DateOfBirth])
    VALUES (35, N'Foster', N'Nora', '2024-09-02', N'Jean', '2013-03-12');
END
IF NOT EXISTS (SELECT 1 FROM [dbo].[Student] WHERE [StudentID] = 36)
BEGIN
    INSERT INTO [dbo].[Student] ([StudentID], [LastName], [FirstName], [EnrollmentDate], [MiddleName], [DateOfBirth])
    VALUES (36, N'Brooks', N'Andrew', '2024-09-02', N'Kai', '2012-11-22');
END
IF NOT EXISTS (SELECT 1 FROM [dbo].[Student] WHERE [StudentID] = 37)
BEGIN
    INSERT INTO [dbo].[Student] ([StudentID], [LastName], [FirstName], [EnrollmentDate], [MiddleName], [DateOfBirth])
    VALUES (37, N'Russell', N'Victoria', '2024-09-02', N'Mae', '2013-07-19');
END
IF NOT EXISTS (SELECT 1 FROM [dbo].[Student] WHERE [StudentID] = 38)
BEGIN
    INSERT INTO [dbo].[Student] ([StudentID], [LastName], [FirstName], [EnrollmentDate], [MiddleName], [DateOfBirth])
    VALUES (38, N'Bryant', N'Christopher', '2024-09-02', N'Eli', '2012-05-14');
END
IF NOT EXISTS (SELECT 1 FROM [dbo].[Student] WHERE [StudentID] = 39)
BEGIN
    INSERT INTO [dbo].[Student] ([StudentID], [LastName], [FirstName], [EnrollmentDate], [MiddleName], [DateOfBirth])
    VALUES (39, N'Harris', N'Kayla', '2024-09-02', N'Simone', '2013-01-26');
END
IF NOT EXISTS (SELECT 1 FROM [dbo].[Student] WHERE [StudentID] = 40)
BEGIN
    INSERT INTO [dbo].[Student] ([StudentID], [LastName], [FirstName], [EnrollmentDate], [MiddleName], [DateOfBirth])
    VALUES (40, N'Watson', N'Jonathan', '2024-09-02', NULL, '2012-08-30');
END
IF NOT EXISTS (SELECT 1 FROM [dbo].[Student] WHERE [StudentID] = 41)
BEGIN
    INSERT INTO [dbo].[Student] ([StudentID], [LastName], [FirstName], [EnrollmentDate], [MiddleName], [DateOfBirth])
    VALUES (41, N'Fleming', N'Sienna', '2024-09-02', N'Rae', '2013-09-03');
END
IF NOT EXISTS (SELECT 1 FROM [dbo].[Student] WHERE [StudentID] = 42)
BEGIN
    INSERT INTO [dbo].[Student] ([StudentID], [LastName], [FirstName], [EnrollmentDate], [MiddleName], [DateOfBirth])
    VALUES (42, N'Gibson', N'Micah', '2024-09-02', N'Reese', '2012-12-07');
END
IF NOT EXISTS (SELECT 1 FROM [dbo].[Student] WHERE [StudentID] = 43)
BEGIN
    INSERT INTO [dbo].[Student] ([StudentID], [LastName], [FirstName], [EnrollmentDate], [MiddleName], [DateOfBirth])
    VALUES (43, N'Howard', N'Ariana', '2024-09-02', N'Belle', '2013-02-18');
END
IF NOT EXISTS (SELECT 1 FROM [dbo].[Student] WHERE [StudentID] = 44)
BEGIN
    INSERT INTO [dbo].[Student] ([StudentID], [LastName], [FirstName], [EnrollmentDate], [MiddleName], [DateOfBirth])
    VALUES (44, N'Murray', N'Dominic', '2024-09-02', N'Sean', '2012-07-11');
END
IF NOT EXISTS (SELECT 1 FROM [dbo].[Student] WHERE [StudentID] = 45)
BEGIN
    INSERT INTO [dbo].[Student] ([StudentID], [LastName], [FirstName], [EnrollmentDate], [MiddleName], [DateOfBirth])
    VALUES (45, N'Barnes', N'Naomi', '2024-09-02', N'Paige', '2013-06-27');
END
IF NOT EXISTS (SELECT 1 FROM [dbo].[Student] WHERE [StudentID] = 46)
BEGIN
    INSERT INTO [dbo].[Student] ([StudentID], [LastName], [FirstName], [EnrollmentDate], [MiddleName], [DateOfBirth])
    VALUES (46, N'Coleman', N'Jeremiah', '2024-09-02', N'Noel', '2012-04-04');
END
IF NOT EXISTS (SELECT 1 FROM [dbo].[Student] WHERE [StudentID] = 47)
BEGIN
    INSERT INTO [dbo].[Student] ([StudentID], [LastName], [FirstName], [EnrollmentDate], [MiddleName], [DateOfBirth])
    VALUES (47, N'Powell', N'Adah', '2024-09-02', N'Marie', '2013-10-15');
END
IF NOT EXISTS (SELECT 1 FROM [dbo].[Student] WHERE [StudentID] = 48)
BEGIN
    INSERT INTO [dbo].[Student] ([StudentID], [LastName], [FirstName], [EnrollmentDate], [MiddleName], [DateOfBirth])
    VALUES (48, N'Francis', N'Xavier', '2024-09-02', N'Thomas', '2012-01-21');
END

SET IDENTITY_INSERT [dbo].[Student] OFF;
GO

SET IDENTITY_INSERT [dbo].[Enrollment] ON;
IF NOT EXISTS (SELECT 1 FROM [dbo].[Enrollment] WHERE [EnrollmentID] = 1)
BEGIN
    INSERT INTO [dbo].[Enrollment] ([EnrollmentID], [Grade], [CourseID], [StudentID], [LecturerId])
    VALUES (1, 3.70, 13, 1, 1);
END
IF NOT EXISTS (SELECT 1 FROM [dbo].[Enrollment] WHERE [EnrollmentID] = 2)
BEGIN
    INSERT INTO [dbo].[Enrollment] ([EnrollmentID], [Grade], [CourseID], [StudentID], [LecturerId])
    VALUES (2, 2.60, 14, 1, 2);
END
IF NOT EXISTS (SELECT 1 FROM [dbo].[Enrollment] WHERE [EnrollmentID] = 3)
BEGIN
    INSERT INTO [dbo].[Enrollment] ([EnrollmentID], [Grade], [CourseID], [StudentID], [LecturerId])
    VALUES (3, 3.30, 15, 1, 3);
END
IF NOT EXISTS (SELECT 1 FROM [dbo].[Enrollment] WHERE [EnrollmentID] = 4)
BEGIN
    INSERT INTO [dbo].[Enrollment] ([EnrollmentID], [Grade], [CourseID], [StudentID], [LecturerId])
    VALUES (4, 4.00, 16, 1, 5);
END
IF NOT EXISTS (SELECT 1 FROM [dbo].[Enrollment] WHERE [EnrollmentID] = 5)
BEGIN
    INSERT INTO [dbo].[Enrollment] ([EnrollmentID], [Grade], [CourseID], [StudentID], [LecturerId])
    VALUES (5, 2.90, 17, 1, 4);
END
IF NOT EXISTS (SELECT 1 FROM [dbo].[Enrollment] WHERE [EnrollmentID] = 6)
BEGIN
    INSERT INTO [dbo].[Enrollment] ([EnrollmentID], [Grade], [CourseID], [StudentID], [LecturerId])
    VALUES (6, 3.60, 18, 1, 10);
END
IF NOT EXISTS (SELECT 1 FROM [dbo].[Enrollment] WHERE [EnrollmentID] = 7)
BEGIN
    INSERT INTO [dbo].[Enrollment] ([EnrollmentID], [Grade], [CourseID], [StudentID], [LecturerId])
    VALUES (7, 2.50, 19, 1, 6);
END
IF NOT EXISTS (SELECT 1 FROM [dbo].[Enrollment] WHERE [EnrollmentID] = 8)
BEGIN
    INSERT INTO [dbo].[Enrollment] ([EnrollmentID], [Grade], [CourseID], [StudentID], [LecturerId])
    VALUES (8, 3.90, 21, 1, 8);
END
IF NOT EXISTS (SELECT 1 FROM [dbo].[Enrollment] WHERE [EnrollmentID] = 9)
BEGIN
    INSERT INTO [dbo].[Enrollment] ([EnrollmentID], [Grade], [CourseID], [StudentID], [LecturerId])
    VALUES (9, 3.20, 13, 2, 1);
END
IF NOT EXISTS (SELECT 1 FROM [dbo].[Enrollment] WHERE [EnrollmentID] = 10)
BEGIN
    INSERT INTO [dbo].[Enrollment] ([EnrollmentID], [Grade], [CourseID], [StudentID], [LecturerId])
    VALUES (10, 3.90, 14, 2, 2);
END
IF NOT EXISTS (SELECT 1 FROM [dbo].[Enrollment] WHERE [EnrollmentID] = 11)
BEGIN
    INSERT INTO [dbo].[Enrollment] ([EnrollmentID], [Grade], [CourseID], [StudentID], [LecturerId])
    VALUES (11, 2.80, 15, 2, 3);
END
IF NOT EXISTS (SELECT 1 FROM [dbo].[Enrollment] WHERE [EnrollmentID] = 12)
BEGIN
    INSERT INTO [dbo].[Enrollment] ([EnrollmentID], [Grade], [CourseID], [StudentID], [LecturerId])
    VALUES (12, 3.50, 16, 2, 5);
END
IF NOT EXISTS (SELECT 1 FROM [dbo].[Enrollment] WHERE [EnrollmentID] = 13)
BEGIN
    INSERT INTO [dbo].[Enrollment] ([EnrollmentID], [Grade], [CourseID], [StudentID], [LecturerId])
    VALUES (13, 2.40, 17, 2, 4);
END
IF NOT EXISTS (SELECT 1 FROM [dbo].[Enrollment] WHERE [EnrollmentID] = 14)
BEGIN
    INSERT INTO [dbo].[Enrollment] ([EnrollmentID], [Grade], [CourseID], [StudentID], [LecturerId])
    VALUES (14, 3.10, 18, 2, 10);
END
IF NOT EXISTS (SELECT 1 FROM [dbo].[Enrollment] WHERE [EnrollmentID] = 15)
BEGIN
    INSERT INTO [dbo].[Enrollment] ([EnrollmentID], [Grade], [CourseID], [StudentID], [LecturerId])
    VALUES (15, 3.80, 19, 2, 6);
END
IF NOT EXISTS (SELECT 1 FROM [dbo].[Enrollment] WHERE [EnrollmentID] = 16)
BEGIN
    INSERT INTO [dbo].[Enrollment] ([EnrollmentID], [Grade], [CourseID], [StudentID], [LecturerId])
    VALUES (16, 2.70, 20, 2, 9);
END
IF NOT EXISTS (SELECT 1 FROM [dbo].[Enrollment] WHERE [EnrollmentID] = 17)
BEGIN
    INSERT INTO [dbo].[Enrollment] ([EnrollmentID], [Grade], [CourseID], [StudentID], [LecturerId])
    VALUES (17, 2.70, 13, 3, 1);
END
IF NOT EXISTS (SELECT 1 FROM [dbo].[Enrollment] WHERE [EnrollmentID] = 18)
BEGIN
    INSERT INTO [dbo].[Enrollment] ([EnrollmentID], [Grade], [CourseID], [StudentID], [LecturerId])
    VALUES (18, 3.40, 14, 3, 2);
END
IF NOT EXISTS (SELECT 1 FROM [dbo].[Enrollment] WHERE [EnrollmentID] = 19)
BEGIN
    INSERT INTO [dbo].[Enrollment] ([EnrollmentID], [Grade], [CourseID], [StudentID], [LecturerId])
    VALUES (19, 2.30, 15, 3, 3);
END
IF NOT EXISTS (SELECT 1 FROM [dbo].[Enrollment] WHERE [EnrollmentID] = 20)
BEGIN
    INSERT INTO [dbo].[Enrollment] ([EnrollmentID], [Grade], [CourseID], [StudentID], [LecturerId])
    VALUES (20, 3.00, 16, 3, 5);
END
IF NOT EXISTS (SELECT 1 FROM [dbo].[Enrollment] WHERE [EnrollmentID] = 21)
BEGIN
    INSERT INTO [dbo].[Enrollment] ([EnrollmentID], [Grade], [CourseID], [StudentID], [LecturerId])
    VALUES (21, 3.70, 17, 3, 4);
END
IF NOT EXISTS (SELECT 1 FROM [dbo].[Enrollment] WHERE [EnrollmentID] = 22)
BEGIN
    INSERT INTO [dbo].[Enrollment] ([EnrollmentID], [Grade], [CourseID], [StudentID], [LecturerId])
    VALUES (22, 2.60, 18, 3, 10);
END
IF NOT EXISTS (SELECT 1 FROM [dbo].[Enrollment] WHERE [EnrollmentID] = 23)
BEGIN
    INSERT INTO [dbo].[Enrollment] ([EnrollmentID], [Grade], [CourseID], [StudentID], [LecturerId])
    VALUES (23, 3.30, 19, 3, 6);
END
IF NOT EXISTS (SELECT 1 FROM [dbo].[Enrollment] WHERE [EnrollmentID] = 24)
BEGIN
    INSERT INTO [dbo].[Enrollment] ([EnrollmentID], [Grade], [CourseID], [StudentID], [LecturerId])
    VALUES (24, 2.90, 21, 3, 8);
END
IF NOT EXISTS (SELECT 1 FROM [dbo].[Enrollment] WHERE [EnrollmentID] = 25)
BEGIN
    INSERT INTO [dbo].[Enrollment] ([EnrollmentID], [Grade], [CourseID], [StudentID], [LecturerId])
    VALUES (25, 4.00, 13, 4, 1);
END
IF NOT EXISTS (SELECT 1 FROM [dbo].[Enrollment] WHERE [EnrollmentID] = 26)
BEGIN
    INSERT INTO [dbo].[Enrollment] ([EnrollmentID], [Grade], [CourseID], [StudentID], [LecturerId])
    VALUES (26, 2.90, 14, 4, 2);
END
IF NOT EXISTS (SELECT 1 FROM [dbo].[Enrollment] WHERE [EnrollmentID] = 27)
BEGIN
    INSERT INTO [dbo].[Enrollment] ([EnrollmentID], [Grade], [CourseID], [StudentID], [LecturerId])
    VALUES (27, 3.60, 15, 4, 3);
END
IF NOT EXISTS (SELECT 1 FROM [dbo].[Enrollment] WHERE [EnrollmentID] = 28)
BEGIN
    INSERT INTO [dbo].[Enrollment] ([EnrollmentID], [Grade], [CourseID], [StudentID], [LecturerId])
    VALUES (28, 2.50, 16, 4, 5);
END
IF NOT EXISTS (SELECT 1 FROM [dbo].[Enrollment] WHERE [EnrollmentID] = 29)
BEGIN
    INSERT INTO [dbo].[Enrollment] ([EnrollmentID], [Grade], [CourseID], [StudentID], [LecturerId])
    VALUES (29, 3.20, 17, 4, 4);
END
IF NOT EXISTS (SELECT 1 FROM [dbo].[Enrollment] WHERE [EnrollmentID] = 30)
BEGIN
    INSERT INTO [dbo].[Enrollment] ([EnrollmentID], [Grade], [CourseID], [StudentID], [LecturerId])
    VALUES (30, 3.90, 18, 4, 10);
END
IF NOT EXISTS (SELECT 1 FROM [dbo].[Enrollment] WHERE [EnrollmentID] = 31)
BEGIN
    INSERT INTO [dbo].[Enrollment] ([EnrollmentID], [Grade], [CourseID], [StudentID], [LecturerId])
    VALUES (31, 2.80, 19, 4, 6);
END
IF NOT EXISTS (SELECT 1 FROM [dbo].[Enrollment] WHERE [EnrollmentID] = 32)
BEGIN
    INSERT INTO [dbo].[Enrollment] ([EnrollmentID], [Grade], [CourseID], [StudentID], [LecturerId])
    VALUES (32, 3.50, 20, 4, 9);
END
IF NOT EXISTS (SELECT 1 FROM [dbo].[Enrollment] WHERE [EnrollmentID] = 33)
BEGIN
    INSERT INTO [dbo].[Enrollment] ([EnrollmentID], [Grade], [CourseID], [StudentID], [LecturerId])
    VALUES (33, 3.50, 13, 5, 1);
END
IF NOT EXISTS (SELECT 1 FROM [dbo].[Enrollment] WHERE [EnrollmentID] = 34)
BEGIN
    INSERT INTO [dbo].[Enrollment] ([EnrollmentID], [Grade], [CourseID], [StudentID], [LecturerId])
    VALUES (34, 2.40, 14, 5, 2);
END
IF NOT EXISTS (SELECT 1 FROM [dbo].[Enrollment] WHERE [EnrollmentID] = 35)
BEGIN
    INSERT INTO [dbo].[Enrollment] ([EnrollmentID], [Grade], [CourseID], [StudentID], [LecturerId])
    VALUES (35, 3.10, 15, 5, 3);
END
IF NOT EXISTS (SELECT 1 FROM [dbo].[Enrollment] WHERE [EnrollmentID] = 36)
BEGIN
    INSERT INTO [dbo].[Enrollment] ([EnrollmentID], [Grade], [CourseID], [StudentID], [LecturerId])
    VALUES (36, 3.80, 16, 5, 5);
END
IF NOT EXISTS (SELECT 1 FROM [dbo].[Enrollment] WHERE [EnrollmentID] = 37)
BEGIN
    INSERT INTO [dbo].[Enrollment] ([EnrollmentID], [Grade], [CourseID], [StudentID], [LecturerId])
    VALUES (37, 2.70, 17, 5, 4);
END
IF NOT EXISTS (SELECT 1 FROM [dbo].[Enrollment] WHERE [EnrollmentID] = 38)
BEGIN
    INSERT INTO [dbo].[Enrollment] ([EnrollmentID], [Grade], [CourseID], [StudentID], [LecturerId])
    VALUES (38, 3.40, 18, 5, 10);
END
IF NOT EXISTS (SELECT 1 FROM [dbo].[Enrollment] WHERE [EnrollmentID] = 39)
BEGIN
    INSERT INTO [dbo].[Enrollment] ([EnrollmentID], [Grade], [CourseID], [StudentID], [LecturerId])
    VALUES (39, 2.30, 19, 5, 6);
END
IF NOT EXISTS (SELECT 1 FROM [dbo].[Enrollment] WHERE [EnrollmentID] = 40)
BEGIN
    INSERT INTO [dbo].[Enrollment] ([EnrollmentID], [Grade], [CourseID], [StudentID], [LecturerId])
    VALUES (40, 3.70, 21, 5, 8);
END
IF NOT EXISTS (SELECT 1 FROM [dbo].[Enrollment] WHERE [EnrollmentID] = 41)
BEGIN
    INSERT INTO [dbo].[Enrollment] ([EnrollmentID], [Grade], [CourseID], [StudentID], [LecturerId])
    VALUES (41, 3.00, 13, 6, 1);
END
IF NOT EXISTS (SELECT 1 FROM [dbo].[Enrollment] WHERE [EnrollmentID] = 42)
BEGIN
    INSERT INTO [dbo].[Enrollment] ([EnrollmentID], [Grade], [CourseID], [StudentID], [LecturerId])
    VALUES (42, 3.70, 14, 6, 2);
END
IF NOT EXISTS (SELECT 1 FROM [dbo].[Enrollment] WHERE [EnrollmentID] = 43)
BEGIN
    INSERT INTO [dbo].[Enrollment] ([EnrollmentID], [Grade], [CourseID], [StudentID], [LecturerId])
    VALUES (43, 2.60, 15, 6, 3);
END
IF NOT EXISTS (SELECT 1 FROM [dbo].[Enrollment] WHERE [EnrollmentID] = 44)
BEGIN
    INSERT INTO [dbo].[Enrollment] ([EnrollmentID], [Grade], [CourseID], [StudentID], [LecturerId])
    VALUES (44, 3.30, 16, 6, 5);
END
IF NOT EXISTS (SELECT 1 FROM [dbo].[Enrollment] WHERE [EnrollmentID] = 45)
BEGIN
    INSERT INTO [dbo].[Enrollment] ([EnrollmentID], [Grade], [CourseID], [StudentID], [LecturerId])
    VALUES (45, 4.00, 17, 6, 4);
END
IF NOT EXISTS (SELECT 1 FROM [dbo].[Enrollment] WHERE [EnrollmentID] = 46)
BEGIN
    INSERT INTO [dbo].[Enrollment] ([EnrollmentID], [Grade], [CourseID], [StudentID], [LecturerId])
    VALUES (46, 2.90, 18, 6, 10);
END
IF NOT EXISTS (SELECT 1 FROM [dbo].[Enrollment] WHERE [EnrollmentID] = 47)
BEGIN
    INSERT INTO [dbo].[Enrollment] ([EnrollmentID], [Grade], [CourseID], [StudentID], [LecturerId])
    VALUES (47, 3.60, 19, 6, 6);
END
IF NOT EXISTS (SELECT 1 FROM [dbo].[Enrollment] WHERE [EnrollmentID] = 48)
BEGIN
    INSERT INTO [dbo].[Enrollment] ([EnrollmentID], [Grade], [CourseID], [StudentID], [LecturerId])
    VALUES (48, 2.50, 20, 6, 9);
END
IF NOT EXISTS (SELECT 1 FROM [dbo].[Enrollment] WHERE [EnrollmentID] = 49)
BEGIN
    INSERT INTO [dbo].[Enrollment] ([EnrollmentID], [Grade], [CourseID], [StudentID], [LecturerId])
    VALUES (49, 2.50, 13, 7, 1);
END
IF NOT EXISTS (SELECT 1 FROM [dbo].[Enrollment] WHERE [EnrollmentID] = 50)
BEGIN
    INSERT INTO [dbo].[Enrollment] ([EnrollmentID], [Grade], [CourseID], [StudentID], [LecturerId])
    VALUES (50, 3.20, 14, 7, 2);
END
IF NOT EXISTS (SELECT 1 FROM [dbo].[Enrollment] WHERE [EnrollmentID] = 51)
BEGIN
    INSERT INTO [dbo].[Enrollment] ([EnrollmentID], [Grade], [CourseID], [StudentID], [LecturerId])
    VALUES (51, 3.90, 15, 7, 3);
END
IF NOT EXISTS (SELECT 1 FROM [dbo].[Enrollment] WHERE [EnrollmentID] = 52)
BEGIN
    INSERT INTO [dbo].[Enrollment] ([EnrollmentID], [Grade], [CourseID], [StudentID], [LecturerId])
    VALUES (52, 2.80, 16, 7, 5);
END
IF NOT EXISTS (SELECT 1 FROM [dbo].[Enrollment] WHERE [EnrollmentID] = 53)
BEGIN
    INSERT INTO [dbo].[Enrollment] ([EnrollmentID], [Grade], [CourseID], [StudentID], [LecturerId])
    VALUES (53, 3.50, 17, 7, 4);
END
IF NOT EXISTS (SELECT 1 FROM [dbo].[Enrollment] WHERE [EnrollmentID] = 54)
BEGIN
    INSERT INTO [dbo].[Enrollment] ([EnrollmentID], [Grade], [CourseID], [StudentID], [LecturerId])
    VALUES (54, 2.40, 18, 7, 10);
END
IF NOT EXISTS (SELECT 1 FROM [dbo].[Enrollment] WHERE [EnrollmentID] = 55)
BEGIN
    INSERT INTO [dbo].[Enrollment] ([EnrollmentID], [Grade], [CourseID], [StudentID], [LecturerId])
    VALUES (55, 3.10, 19, 7, 6);
END
IF NOT EXISTS (SELECT 1 FROM [dbo].[Enrollment] WHERE [EnrollmentID] = 56)
BEGIN
    INSERT INTO [dbo].[Enrollment] ([EnrollmentID], [Grade], [CourseID], [StudentID], [LecturerId])
    VALUES (56, 2.70, 21, 7, 8);
END
IF NOT EXISTS (SELECT 1 FROM [dbo].[Enrollment] WHERE [EnrollmentID] = 57)
BEGIN
    INSERT INTO [dbo].[Enrollment] ([EnrollmentID], [Grade], [CourseID], [StudentID], [LecturerId])
    VALUES (57, 3.80, 13, 8, 1);
END
IF NOT EXISTS (SELECT 1 FROM [dbo].[Enrollment] WHERE [EnrollmentID] = 58)
BEGIN
    INSERT INTO [dbo].[Enrollment] ([EnrollmentID], [Grade], [CourseID], [StudentID], [LecturerId])
    VALUES (58, 2.70, 14, 8, 2);
END
IF NOT EXISTS (SELECT 1 FROM [dbo].[Enrollment] WHERE [EnrollmentID] = 59)
BEGIN
    INSERT INTO [dbo].[Enrollment] ([EnrollmentID], [Grade], [CourseID], [StudentID], [LecturerId])
    VALUES (59, 3.40, 15, 8, 3);
END
IF NOT EXISTS (SELECT 1 FROM [dbo].[Enrollment] WHERE [EnrollmentID] = 60)
BEGIN
    INSERT INTO [dbo].[Enrollment] ([EnrollmentID], [Grade], [CourseID], [StudentID], [LecturerId])
    VALUES (60, 2.30, 16, 8, 5);
END
IF NOT EXISTS (SELECT 1 FROM [dbo].[Enrollment] WHERE [EnrollmentID] = 61)
BEGIN
    INSERT INTO [dbo].[Enrollment] ([EnrollmentID], [Grade], [CourseID], [StudentID], [LecturerId])
    VALUES (61, 3.00, 17, 8, 4);
END
IF NOT EXISTS (SELECT 1 FROM [dbo].[Enrollment] WHERE [EnrollmentID] = 62)
BEGIN
    INSERT INTO [dbo].[Enrollment] ([EnrollmentID], [Grade], [CourseID], [StudentID], [LecturerId])
    VALUES (62, 3.70, 18, 8, 10);
END
IF NOT EXISTS (SELECT 1 FROM [dbo].[Enrollment] WHERE [EnrollmentID] = 63)
BEGIN
    INSERT INTO [dbo].[Enrollment] ([EnrollmentID], [Grade], [CourseID], [StudentID], [LecturerId])
    VALUES (63, 2.60, 19, 8, 6);
END
IF NOT EXISTS (SELECT 1 FROM [dbo].[Enrollment] WHERE [EnrollmentID] = 64)
BEGIN
    INSERT INTO [dbo].[Enrollment] ([EnrollmentID], [Grade], [CourseID], [StudentID], [LecturerId])
    VALUES (64, 3.30, 20, 8, 9);
END
IF NOT EXISTS (SELECT 1 FROM [dbo].[Enrollment] WHERE [EnrollmentID] = 65)
BEGIN
    INSERT INTO [dbo].[Enrollment] ([EnrollmentID], [Grade], [CourseID], [StudentID], [LecturerId])
    VALUES (65, 3.30, 13, 9, 1);
END
IF NOT EXISTS (SELECT 1 FROM [dbo].[Enrollment] WHERE [EnrollmentID] = 66)
BEGIN
    INSERT INTO [dbo].[Enrollment] ([EnrollmentID], [Grade], [CourseID], [StudentID], [LecturerId])
    VALUES (66, 4.00, 14, 9, 2);
END
IF NOT EXISTS (SELECT 1 FROM [dbo].[Enrollment] WHERE [EnrollmentID] = 67)
BEGIN
    INSERT INTO [dbo].[Enrollment] ([EnrollmentID], [Grade], [CourseID], [StudentID], [LecturerId])
    VALUES (67, 2.90, 15, 9, 3);
END
IF NOT EXISTS (SELECT 1 FROM [dbo].[Enrollment] WHERE [EnrollmentID] = 68)
BEGIN
    INSERT INTO [dbo].[Enrollment] ([EnrollmentID], [Grade], [CourseID], [StudentID], [LecturerId])
    VALUES (68, 3.60, 16, 9, 5);
END
IF NOT EXISTS (SELECT 1 FROM [dbo].[Enrollment] WHERE [EnrollmentID] = 69)
BEGIN
    INSERT INTO [dbo].[Enrollment] ([EnrollmentID], [Grade], [CourseID], [StudentID], [LecturerId])
    VALUES (69, 2.50, 17, 9, 4);
END
IF NOT EXISTS (SELECT 1 FROM [dbo].[Enrollment] WHERE [EnrollmentID] = 70)
BEGIN
    INSERT INTO [dbo].[Enrollment] ([EnrollmentID], [Grade], [CourseID], [StudentID], [LecturerId])
    VALUES (70, 3.20, 18, 9, 10);
END
IF NOT EXISTS (SELECT 1 FROM [dbo].[Enrollment] WHERE [EnrollmentID] = 71)
BEGIN
    INSERT INTO [dbo].[Enrollment] ([EnrollmentID], [Grade], [CourseID], [StudentID], [LecturerId])
    VALUES (71, 3.90, 19, 9, 6);
END
IF NOT EXISTS (SELECT 1 FROM [dbo].[Enrollment] WHERE [EnrollmentID] = 72)
BEGIN
    INSERT INTO [dbo].[Enrollment] ([EnrollmentID], [Grade], [CourseID], [StudentID], [LecturerId])
    VALUES (72, 3.50, 21, 9, 8);
END
IF NOT EXISTS (SELECT 1 FROM [dbo].[Enrollment] WHERE [EnrollmentID] = 73)
BEGIN
    INSERT INTO [dbo].[Enrollment] ([EnrollmentID], [Grade], [CourseID], [StudentID], [LecturerId])
    VALUES (73, 2.80, 13, 10, 1);
END
IF NOT EXISTS (SELECT 1 FROM [dbo].[Enrollment] WHERE [EnrollmentID] = 74)
BEGIN
    INSERT INTO [dbo].[Enrollment] ([EnrollmentID], [Grade], [CourseID], [StudentID], [LecturerId])
    VALUES (74, 3.50, 14, 10, 2);
END
IF NOT EXISTS (SELECT 1 FROM [dbo].[Enrollment] WHERE [EnrollmentID] = 75)
BEGIN
    INSERT INTO [dbo].[Enrollment] ([EnrollmentID], [Grade], [CourseID], [StudentID], [LecturerId])
    VALUES (75, 2.40, 15, 10, 3);
END
IF NOT EXISTS (SELECT 1 FROM [dbo].[Enrollment] WHERE [EnrollmentID] = 76)
BEGIN
    INSERT INTO [dbo].[Enrollment] ([EnrollmentID], [Grade], [CourseID], [StudentID], [LecturerId])
    VALUES (76, 3.10, 16, 10, 5);
END
IF NOT EXISTS (SELECT 1 FROM [dbo].[Enrollment] WHERE [EnrollmentID] = 77)
BEGIN
    INSERT INTO [dbo].[Enrollment] ([EnrollmentID], [Grade], [CourseID], [StudentID], [LecturerId])
    VALUES (77, 3.80, 17, 10, 4);
END
IF NOT EXISTS (SELECT 1 FROM [dbo].[Enrollment] WHERE [EnrollmentID] = 78)
BEGIN
    INSERT INTO [dbo].[Enrollment] ([EnrollmentID], [Grade], [CourseID], [StudentID], [LecturerId])
    VALUES (78, 2.70, 18, 10, 10);
END
IF NOT EXISTS (SELECT 1 FROM [dbo].[Enrollment] WHERE [EnrollmentID] = 79)
BEGIN
    INSERT INTO [dbo].[Enrollment] ([EnrollmentID], [Grade], [CourseID], [StudentID], [LecturerId])
    VALUES (79, 3.40, 19, 10, 6);
END
IF NOT EXISTS (SELECT 1 FROM [dbo].[Enrollment] WHERE [EnrollmentID] = 80)
BEGIN
    INSERT INTO [dbo].[Enrollment] ([EnrollmentID], [Grade], [CourseID], [StudentID], [LecturerId])
    VALUES (80, 2.30, 20, 10, 9);
END
IF NOT EXISTS (SELECT 1 FROM [dbo].[Enrollment] WHERE [EnrollmentID] = 81)
BEGIN
    INSERT INTO [dbo].[Enrollment] ([EnrollmentID], [Grade], [CourseID], [StudentID], [LecturerId])
    VALUES (81, 2.30, 13, 11, 1);
END
IF NOT EXISTS (SELECT 1 FROM [dbo].[Enrollment] WHERE [EnrollmentID] = 82)
BEGIN
    INSERT INTO [dbo].[Enrollment] ([EnrollmentID], [Grade], [CourseID], [StudentID], [LecturerId])
    VALUES (82, 3.00, 14, 11, 2);
END
IF NOT EXISTS (SELECT 1 FROM [dbo].[Enrollment] WHERE [EnrollmentID] = 83)
BEGIN
    INSERT INTO [dbo].[Enrollment] ([EnrollmentID], [Grade], [CourseID], [StudentID], [LecturerId])
    VALUES (83, 3.70, 15, 11, 3);
END
IF NOT EXISTS (SELECT 1 FROM [dbo].[Enrollment] WHERE [EnrollmentID] = 84)
BEGIN
    INSERT INTO [dbo].[Enrollment] ([EnrollmentID], [Grade], [CourseID], [StudentID], [LecturerId])
    VALUES (84, 2.60, 16, 11, 5);
END
IF NOT EXISTS (SELECT 1 FROM [dbo].[Enrollment] WHERE [EnrollmentID] = 85)
BEGIN
    INSERT INTO [dbo].[Enrollment] ([EnrollmentID], [Grade], [CourseID], [StudentID], [LecturerId])
    VALUES (85, 3.30, 17, 11, 4);
END
IF NOT EXISTS (SELECT 1 FROM [dbo].[Enrollment] WHERE [EnrollmentID] = 86)
BEGIN
    INSERT INTO [dbo].[Enrollment] ([EnrollmentID], [Grade], [CourseID], [StudentID], [LecturerId])
    VALUES (86, 4.00, 18, 11, 10);
END
IF NOT EXISTS (SELECT 1 FROM [dbo].[Enrollment] WHERE [EnrollmentID] = 87)
BEGIN
    INSERT INTO [dbo].[Enrollment] ([EnrollmentID], [Grade], [CourseID], [StudentID], [LecturerId])
    VALUES (87, 2.90, 19, 11, 6);
END
IF NOT EXISTS (SELECT 1 FROM [dbo].[Enrollment] WHERE [EnrollmentID] = 88)
BEGIN
    INSERT INTO [dbo].[Enrollment] ([EnrollmentID], [Grade], [CourseID], [StudentID], [LecturerId])
    VALUES (88, 2.50, 21, 11, 8);
END
IF NOT EXISTS (SELECT 1 FROM [dbo].[Enrollment] WHERE [EnrollmentID] = 89)
BEGIN
    INSERT INTO [dbo].[Enrollment] ([EnrollmentID], [Grade], [CourseID], [StudentID], [LecturerId])
    VALUES (89, 3.60, 13, 12, 1);
END
IF NOT EXISTS (SELECT 1 FROM [dbo].[Enrollment] WHERE [EnrollmentID] = 90)
BEGIN
    INSERT INTO [dbo].[Enrollment] ([EnrollmentID], [Grade], [CourseID], [StudentID], [LecturerId])
    VALUES (90, 2.50, 14, 12, 2);
END
IF NOT EXISTS (SELECT 1 FROM [dbo].[Enrollment] WHERE [EnrollmentID] = 91)
BEGIN
    INSERT INTO [dbo].[Enrollment] ([EnrollmentID], [Grade], [CourseID], [StudentID], [LecturerId])
    VALUES (91, 3.20, 15, 12, 3);
END
IF NOT EXISTS (SELECT 1 FROM [dbo].[Enrollment] WHERE [EnrollmentID] = 92)
BEGIN
    INSERT INTO [dbo].[Enrollment] ([EnrollmentID], [Grade], [CourseID], [StudentID], [LecturerId])
    VALUES (92, 3.90, 16, 12, 5);
END
IF NOT EXISTS (SELECT 1 FROM [dbo].[Enrollment] WHERE [EnrollmentID] = 93)
BEGIN
    INSERT INTO [dbo].[Enrollment] ([EnrollmentID], [Grade], [CourseID], [StudentID], [LecturerId])
    VALUES (93, 2.80, 17, 12, 4);
END
IF NOT EXISTS (SELECT 1 FROM [dbo].[Enrollment] WHERE [EnrollmentID] = 94)
BEGIN
    INSERT INTO [dbo].[Enrollment] ([EnrollmentID], [Grade], [CourseID], [StudentID], [LecturerId])
    VALUES (94, 3.50, 18, 12, 10);
END
IF NOT EXISTS (SELECT 1 FROM [dbo].[Enrollment] WHERE [EnrollmentID] = 95)
BEGIN
    INSERT INTO [dbo].[Enrollment] ([EnrollmentID], [Grade], [CourseID], [StudentID], [LecturerId])
    VALUES (95, 2.40, 19, 12, 6);
END
IF NOT EXISTS (SELECT 1 FROM [dbo].[Enrollment] WHERE [EnrollmentID] = 96)
BEGIN
    INSERT INTO [dbo].[Enrollment] ([EnrollmentID], [Grade], [CourseID], [StudentID], [LecturerId])
    VALUES (96, 3.10, 20, 12, 9);
END
IF NOT EXISTS (SELECT 1 FROM [dbo].[Enrollment] WHERE [EnrollmentID] = 97)
BEGIN
    INSERT INTO [dbo].[Enrollment] ([EnrollmentID], [Grade], [CourseID], [StudentID], [LecturerId])
    VALUES (97, 3.10, 13, 13, 1);
END
IF NOT EXISTS (SELECT 1 FROM [dbo].[Enrollment] WHERE [EnrollmentID] = 98)
BEGIN
    INSERT INTO [dbo].[Enrollment] ([EnrollmentID], [Grade], [CourseID], [StudentID], [LecturerId])
    VALUES (98, 3.80, 14, 13, 2);
END
IF NOT EXISTS (SELECT 1 FROM [dbo].[Enrollment] WHERE [EnrollmentID] = 99)
BEGIN
    INSERT INTO [dbo].[Enrollment] ([EnrollmentID], [Grade], [CourseID], [StudentID], [LecturerId])
    VALUES (99, 2.70, 15, 13, 3);
END
IF NOT EXISTS (SELECT 1 FROM [dbo].[Enrollment] WHERE [EnrollmentID] = 100)
BEGIN
    INSERT INTO [dbo].[Enrollment] ([EnrollmentID], [Grade], [CourseID], [StudentID], [LecturerId])
    VALUES (100, 3.40, 16, 13, 5);
END
IF NOT EXISTS (SELECT 1 FROM [dbo].[Enrollment] WHERE [EnrollmentID] = 101)
BEGIN
    INSERT INTO [dbo].[Enrollment] ([EnrollmentID], [Grade], [CourseID], [StudentID], [LecturerId])
    VALUES (101, 2.30, 17, 13, 4);
END
IF NOT EXISTS (SELECT 1 FROM [dbo].[Enrollment] WHERE [EnrollmentID] = 102)
BEGIN
    INSERT INTO [dbo].[Enrollment] ([EnrollmentID], [Grade], [CourseID], [StudentID], [LecturerId])
    VALUES (102, 3.00, 18, 13, 10);
END
IF NOT EXISTS (SELECT 1 FROM [dbo].[Enrollment] WHERE [EnrollmentID] = 103)
BEGIN
    INSERT INTO [dbo].[Enrollment] ([EnrollmentID], [Grade], [CourseID], [StudentID], [LecturerId])
    VALUES (103, 3.70, 19, 13, 6);
END
IF NOT EXISTS (SELECT 1 FROM [dbo].[Enrollment] WHERE [EnrollmentID] = 104)
BEGIN
    INSERT INTO [dbo].[Enrollment] ([EnrollmentID], [Grade], [CourseID], [StudentID], [LecturerId])
    VALUES (104, 3.30, 21, 13, 8);
END
IF NOT EXISTS (SELECT 1 FROM [dbo].[Enrollment] WHERE [EnrollmentID] = 105)
BEGIN
    INSERT INTO [dbo].[Enrollment] ([EnrollmentID], [Grade], [CourseID], [StudentID], [LecturerId])
    VALUES (105, 2.60, 13, 14, 1);
END
IF NOT EXISTS (SELECT 1 FROM [dbo].[Enrollment] WHERE [EnrollmentID] = 106)
BEGIN
    INSERT INTO [dbo].[Enrollment] ([EnrollmentID], [Grade], [CourseID], [StudentID], [LecturerId])
    VALUES (106, 3.30, 14, 14, 2);
END
IF NOT EXISTS (SELECT 1 FROM [dbo].[Enrollment] WHERE [EnrollmentID] = 107)
BEGIN
    INSERT INTO [dbo].[Enrollment] ([EnrollmentID], [Grade], [CourseID], [StudentID], [LecturerId])
    VALUES (107, 4.00, 15, 14, 3);
END
IF NOT EXISTS (SELECT 1 FROM [dbo].[Enrollment] WHERE [EnrollmentID] = 108)
BEGIN
    INSERT INTO [dbo].[Enrollment] ([EnrollmentID], [Grade], [CourseID], [StudentID], [LecturerId])
    VALUES (108, 2.90, 16, 14, 5);
END
IF NOT EXISTS (SELECT 1 FROM [dbo].[Enrollment] WHERE [EnrollmentID] = 109)
BEGIN
    INSERT INTO [dbo].[Enrollment] ([EnrollmentID], [Grade], [CourseID], [StudentID], [LecturerId])
    VALUES (109, 3.60, 17, 14, 4);
END
IF NOT EXISTS (SELECT 1 FROM [dbo].[Enrollment] WHERE [EnrollmentID] = 110)
BEGIN
    INSERT INTO [dbo].[Enrollment] ([EnrollmentID], [Grade], [CourseID], [StudentID], [LecturerId])
    VALUES (110, 2.50, 18, 14, 10);
END
IF NOT EXISTS (SELECT 1 FROM [dbo].[Enrollment] WHERE [EnrollmentID] = 111)
BEGIN
    INSERT INTO [dbo].[Enrollment] ([EnrollmentID], [Grade], [CourseID], [StudentID], [LecturerId])
    VALUES (111, 3.20, 19, 14, 6);
END
IF NOT EXISTS (SELECT 1 FROM [dbo].[Enrollment] WHERE [EnrollmentID] = 112)
BEGIN
    INSERT INTO [dbo].[Enrollment] ([EnrollmentID], [Grade], [CourseID], [StudentID], [LecturerId])
    VALUES (112, 3.90, 20, 14, 9);
END
IF NOT EXISTS (SELECT 1 FROM [dbo].[Enrollment] WHERE [EnrollmentID] = 113)
BEGIN
    INSERT INTO [dbo].[Enrollment] ([EnrollmentID], [Grade], [CourseID], [StudentID], [LecturerId])
    VALUES (113, 3.90, 13, 15, 1);
END
IF NOT EXISTS (SELECT 1 FROM [dbo].[Enrollment] WHERE [EnrollmentID] = 114)
BEGIN
    INSERT INTO [dbo].[Enrollment] ([EnrollmentID], [Grade], [CourseID], [StudentID], [LecturerId])
    VALUES (114, 2.80, 14, 15, 2);
END
IF NOT EXISTS (SELECT 1 FROM [dbo].[Enrollment] WHERE [EnrollmentID] = 115)
BEGIN
    INSERT INTO [dbo].[Enrollment] ([EnrollmentID], [Grade], [CourseID], [StudentID], [LecturerId])
    VALUES (115, 3.50, 15, 15, 3);
END
IF NOT EXISTS (SELECT 1 FROM [dbo].[Enrollment] WHERE [EnrollmentID] = 116)
BEGIN
    INSERT INTO [dbo].[Enrollment] ([EnrollmentID], [Grade], [CourseID], [StudentID], [LecturerId])
    VALUES (116, 2.40, 16, 15, 5);
END
IF NOT EXISTS (SELECT 1 FROM [dbo].[Enrollment] WHERE [EnrollmentID] = 117)
BEGIN
    INSERT INTO [dbo].[Enrollment] ([EnrollmentID], [Grade], [CourseID], [StudentID], [LecturerId])
    VALUES (117, 3.10, 17, 15, 4);
END
IF NOT EXISTS (SELECT 1 FROM [dbo].[Enrollment] WHERE [EnrollmentID] = 118)
BEGIN
    INSERT INTO [dbo].[Enrollment] ([EnrollmentID], [Grade], [CourseID], [StudentID], [LecturerId])
    VALUES (118, 3.80, 18, 15, 10);
END
IF NOT EXISTS (SELECT 1 FROM [dbo].[Enrollment] WHERE [EnrollmentID] = 119)
BEGIN
    INSERT INTO [dbo].[Enrollment] ([EnrollmentID], [Grade], [CourseID], [StudentID], [LecturerId])
    VALUES (119, 2.70, 19, 15, 6);
END
IF NOT EXISTS (SELECT 1 FROM [dbo].[Enrollment] WHERE [EnrollmentID] = 120)
BEGIN
    INSERT INTO [dbo].[Enrollment] ([EnrollmentID], [Grade], [CourseID], [StudentID], [LecturerId])
    VALUES (120, 2.30, 21, 15, 8);
END
IF NOT EXISTS (SELECT 1 FROM [dbo].[Enrollment] WHERE [EnrollmentID] = 121)
BEGIN
    INSERT INTO [dbo].[Enrollment] ([EnrollmentID], [Grade], [CourseID], [StudentID], [LecturerId])
    VALUES (121, 3.40, 13, 16, 1);
END
IF NOT EXISTS (SELECT 1 FROM [dbo].[Enrollment] WHERE [EnrollmentID] = 122)
BEGIN
    INSERT INTO [dbo].[Enrollment] ([EnrollmentID], [Grade], [CourseID], [StudentID], [LecturerId])
    VALUES (122, 2.30, 14, 16, 2);
END
IF NOT EXISTS (SELECT 1 FROM [dbo].[Enrollment] WHERE [EnrollmentID] = 123)
BEGIN
    INSERT INTO [dbo].[Enrollment] ([EnrollmentID], [Grade], [CourseID], [StudentID], [LecturerId])
    VALUES (123, 3.00, 15, 16, 3);
END
IF NOT EXISTS (SELECT 1 FROM [dbo].[Enrollment] WHERE [EnrollmentID] = 124)
BEGIN
    INSERT INTO [dbo].[Enrollment] ([EnrollmentID], [Grade], [CourseID], [StudentID], [LecturerId])
    VALUES (124, 3.70, 16, 16, 5);
END
IF NOT EXISTS (SELECT 1 FROM [dbo].[Enrollment] WHERE [EnrollmentID] = 125)
BEGIN
    INSERT INTO [dbo].[Enrollment] ([EnrollmentID], [Grade], [CourseID], [StudentID], [LecturerId])
    VALUES (125, 2.60, 17, 16, 4);
END
IF NOT EXISTS (SELECT 1 FROM [dbo].[Enrollment] WHERE [EnrollmentID] = 126)
BEGIN
    INSERT INTO [dbo].[Enrollment] ([EnrollmentID], [Grade], [CourseID], [StudentID], [LecturerId])
    VALUES (126, 3.30, 18, 16, 10);
END
IF NOT EXISTS (SELECT 1 FROM [dbo].[Enrollment] WHERE [EnrollmentID] = 127)
BEGIN
    INSERT INTO [dbo].[Enrollment] ([EnrollmentID], [Grade], [CourseID], [StudentID], [LecturerId])
    VALUES (127, 4.00, 19, 16, 6);
END
IF NOT EXISTS (SELECT 1 FROM [dbo].[Enrollment] WHERE [EnrollmentID] = 128)
BEGIN
    INSERT INTO [dbo].[Enrollment] ([EnrollmentID], [Grade], [CourseID], [StudentID], [LecturerId])
    VALUES (128, 2.90, 20, 16, 9);
END
IF NOT EXISTS (SELECT 1 FROM [dbo].[Enrollment] WHERE [EnrollmentID] = 129)
BEGIN
    INSERT INTO [dbo].[Enrollment] ([EnrollmentID], [Grade], [CourseID], [StudentID], [LecturerId])
    VALUES (129, 2.30, 7, 17, 1);
END
IF NOT EXISTS (SELECT 1 FROM [dbo].[Enrollment] WHERE [EnrollmentID] = 130)
BEGIN
    INSERT INTO [dbo].[Enrollment] ([EnrollmentID], [Grade], [CourseID], [StudentID], [LecturerId])
    VALUES (130, 3.00, 8, 17, 2);
END
IF NOT EXISTS (SELECT 1 FROM [dbo].[Enrollment] WHERE [EnrollmentID] = 131)
BEGIN
    INSERT INTO [dbo].[Enrollment] ([EnrollmentID], [Grade], [CourseID], [StudentID], [LecturerId])
    VALUES (131, 3.70, 9, 17, 3);
END
IF NOT EXISTS (SELECT 1 FROM [dbo].[Enrollment] WHERE [EnrollmentID] = 132)
BEGIN
    INSERT INTO [dbo].[Enrollment] ([EnrollmentID], [Grade], [CourseID], [StudentID], [LecturerId])
    VALUES (132, 2.60, 10, 17, 5);
END
IF NOT EXISTS (SELECT 1 FROM [dbo].[Enrollment] WHERE [EnrollmentID] = 133)
BEGIN
    INSERT INTO [dbo].[Enrollment] ([EnrollmentID], [Grade], [CourseID], [StudentID], [LecturerId])
    VALUES (133, 3.30, 11, 17, 4);
END
IF NOT EXISTS (SELECT 1 FROM [dbo].[Enrollment] WHERE [EnrollmentID] = 134)
BEGIN
    INSERT INTO [dbo].[Enrollment] ([EnrollmentID], [Grade], [CourseID], [StudentID], [LecturerId])
    VALUES (134, 4.00, 12, 17, 10);
END
IF NOT EXISTS (SELECT 1 FROM [dbo].[Enrollment] WHERE [EnrollmentID] = 135)
BEGIN
    INSERT INTO [dbo].[Enrollment] ([EnrollmentID], [Grade], [CourseID], [StudentID], [LecturerId])
    VALUES (135, 3.50, 19, 17, 6);
END
IF NOT EXISTS (SELECT 1 FROM [dbo].[Enrollment] WHERE [EnrollmentID] = 136)
BEGIN
    INSERT INTO [dbo].[Enrollment] ([EnrollmentID], [Grade], [CourseID], [StudentID], [LecturerId])
    VALUES (136, 2.70, 23, 17, 11);
END
IF NOT EXISTS (SELECT 1 FROM [dbo].[Enrollment] WHERE [EnrollmentID] = 137)
BEGIN
    INSERT INTO [dbo].[Enrollment] ([EnrollmentID], [Grade], [CourseID], [StudentID], [LecturerId])
    VALUES (137, 3.60, 7, 18, 1);
END
IF NOT EXISTS (SELECT 1 FROM [dbo].[Enrollment] WHERE [EnrollmentID] = 138)
BEGIN
    INSERT INTO [dbo].[Enrollment] ([EnrollmentID], [Grade], [CourseID], [StudentID], [LecturerId])
    VALUES (138, 2.50, 8, 18, 2);
END
IF NOT EXISTS (SELECT 1 FROM [dbo].[Enrollment] WHERE [EnrollmentID] = 139)
BEGIN
    INSERT INTO [dbo].[Enrollment] ([EnrollmentID], [Grade], [CourseID], [StudentID], [LecturerId])
    VALUES (139, 3.20, 9, 18, 3);
END
IF NOT EXISTS (SELECT 1 FROM [dbo].[Enrollment] WHERE [EnrollmentID] = 140)
BEGIN
    INSERT INTO [dbo].[Enrollment] ([EnrollmentID], [Grade], [CourseID], [StudentID], [LecturerId])
    VALUES (140, 3.90, 10, 18, 5);
END
IF NOT EXISTS (SELECT 1 FROM [dbo].[Enrollment] WHERE [EnrollmentID] = 141)
BEGIN
    INSERT INTO [dbo].[Enrollment] ([EnrollmentID], [Grade], [CourseID], [StudentID], [LecturerId])
    VALUES (141, 2.80, 11, 18, 4);
END
IF NOT EXISTS (SELECT 1 FROM [dbo].[Enrollment] WHERE [EnrollmentID] = 142)
BEGIN
    INSERT INTO [dbo].[Enrollment] ([EnrollmentID], [Grade], [CourseID], [StudentID], [LecturerId])
    VALUES (142, 3.50, 12, 18, 10);
END
IF NOT EXISTS (SELECT 1 FROM [dbo].[Enrollment] WHERE [EnrollmentID] = 143)
BEGIN
    INSERT INTO [dbo].[Enrollment] ([EnrollmentID], [Grade], [CourseID], [StudentID], [LecturerId])
    VALUES (143, 3.00, 19, 18, 6);
END
IF NOT EXISTS (SELECT 1 FROM [dbo].[Enrollment] WHERE [EnrollmentID] = 144)
BEGIN
    INSERT INTO [dbo].[Enrollment] ([EnrollmentID], [Grade], [CourseID], [StudentID], [LecturerId])
    VALUES (144, 3.30, 22, 18, 7);
END
IF NOT EXISTS (SELECT 1 FROM [dbo].[Enrollment] WHERE [EnrollmentID] = 145)
BEGIN
    INSERT INTO [dbo].[Enrollment] ([EnrollmentID], [Grade], [CourseID], [StudentID], [LecturerId])
    VALUES (145, 3.10, 7, 19, 1);
END
IF NOT EXISTS (SELECT 1 FROM [dbo].[Enrollment] WHERE [EnrollmentID] = 146)
BEGIN
    INSERT INTO [dbo].[Enrollment] ([EnrollmentID], [Grade], [CourseID], [StudentID], [LecturerId])
    VALUES (146, 3.80, 8, 19, 2);
END
IF NOT EXISTS (SELECT 1 FROM [dbo].[Enrollment] WHERE [EnrollmentID] = 147)
BEGIN
    INSERT INTO [dbo].[Enrollment] ([EnrollmentID], [Grade], [CourseID], [StudentID], [LecturerId])
    VALUES (147, 2.70, 9, 19, 3);
END
IF NOT EXISTS (SELECT 1 FROM [dbo].[Enrollment] WHERE [EnrollmentID] = 148)
BEGIN
    INSERT INTO [dbo].[Enrollment] ([EnrollmentID], [Grade], [CourseID], [StudentID], [LecturerId])
    VALUES (148, 3.40, 10, 19, 5);
END
IF NOT EXISTS (SELECT 1 FROM [dbo].[Enrollment] WHERE [EnrollmentID] = 149)
BEGIN
    INSERT INTO [dbo].[Enrollment] ([EnrollmentID], [Grade], [CourseID], [StudentID], [LecturerId])
    VALUES (149, 2.30, 11, 19, 4);
END
IF NOT EXISTS (SELECT 1 FROM [dbo].[Enrollment] WHERE [EnrollmentID] = 150)
BEGIN
    INSERT INTO [dbo].[Enrollment] ([EnrollmentID], [Grade], [CourseID], [StudentID], [LecturerId])
    VALUES (150, 3.00, 12, 19, 10);
END
IF NOT EXISTS (SELECT 1 FROM [dbo].[Enrollment] WHERE [EnrollmentID] = 151)
BEGIN
    INSERT INTO [dbo].[Enrollment] ([EnrollmentID], [Grade], [CourseID], [StudentID], [LecturerId])
    VALUES (151, 2.50, 19, 19, 6);
END
IF NOT EXISTS (SELECT 1 FROM [dbo].[Enrollment] WHERE [EnrollmentID] = 152)
BEGIN
    INSERT INTO [dbo].[Enrollment] ([EnrollmentID], [Grade], [CourseID], [StudentID], [LecturerId])
    VALUES (152, 3.50, 23, 19, 11);
END
IF NOT EXISTS (SELECT 1 FROM [dbo].[Enrollment] WHERE [EnrollmentID] = 153)
BEGIN
    INSERT INTO [dbo].[Enrollment] ([EnrollmentID], [Grade], [CourseID], [StudentID], [LecturerId])
    VALUES (153, 2.60, 7, 20, 1);
END
IF NOT EXISTS (SELECT 1 FROM [dbo].[Enrollment] WHERE [EnrollmentID] = 154)
BEGIN
    INSERT INTO [dbo].[Enrollment] ([EnrollmentID], [Grade], [CourseID], [StudentID], [LecturerId])
    VALUES (154, 3.30, 8, 20, 2);
END
IF NOT EXISTS (SELECT 1 FROM [dbo].[Enrollment] WHERE [EnrollmentID] = 155)
BEGIN
    INSERT INTO [dbo].[Enrollment] ([EnrollmentID], [Grade], [CourseID], [StudentID], [LecturerId])
    VALUES (155, 4.00, 9, 20, 3);
END
IF NOT EXISTS (SELECT 1 FROM [dbo].[Enrollment] WHERE [EnrollmentID] = 156)
BEGIN
    INSERT INTO [dbo].[Enrollment] ([EnrollmentID], [Grade], [CourseID], [StudentID], [LecturerId])
    VALUES (156, 2.90, 10, 20, 5);
END
IF NOT EXISTS (SELECT 1 FROM [dbo].[Enrollment] WHERE [EnrollmentID] = 157)
BEGIN
    INSERT INTO [dbo].[Enrollment] ([EnrollmentID], [Grade], [CourseID], [StudentID], [LecturerId])
    VALUES (157, 3.60, 11, 20, 4);
END
IF NOT EXISTS (SELECT 1 FROM [dbo].[Enrollment] WHERE [EnrollmentID] = 158)
BEGIN
    INSERT INTO [dbo].[Enrollment] ([EnrollmentID], [Grade], [CourseID], [StudentID], [LecturerId])
    VALUES (158, 2.50, 12, 20, 10);
END
IF NOT EXISTS (SELECT 1 FROM [dbo].[Enrollment] WHERE [EnrollmentID] = 159)
BEGIN
    INSERT INTO [dbo].[Enrollment] ([EnrollmentID], [Grade], [CourseID], [StudentID], [LecturerId])
    VALUES (159, 3.80, 19, 20, 6);
END
IF NOT EXISTS (SELECT 1 FROM [dbo].[Enrollment] WHERE [EnrollmentID] = 160)
BEGIN
    INSERT INTO [dbo].[Enrollment] ([EnrollmentID], [Grade], [CourseID], [StudentID], [LecturerId])
    VALUES (160, 2.30, 22, 20, 7);
END
IF NOT EXISTS (SELECT 1 FROM [dbo].[Enrollment] WHERE [EnrollmentID] = 161)
BEGIN
    INSERT INTO [dbo].[Enrollment] ([EnrollmentID], [Grade], [CourseID], [StudentID], [LecturerId])
    VALUES (161, 3.90, 7, 21, 1);
END
IF NOT EXISTS (SELECT 1 FROM [dbo].[Enrollment] WHERE [EnrollmentID] = 162)
BEGIN
    INSERT INTO [dbo].[Enrollment] ([EnrollmentID], [Grade], [CourseID], [StudentID], [LecturerId])
    VALUES (162, 2.80, 8, 21, 2);
END
IF NOT EXISTS (SELECT 1 FROM [dbo].[Enrollment] WHERE [EnrollmentID] = 163)
BEGIN
    INSERT INTO [dbo].[Enrollment] ([EnrollmentID], [Grade], [CourseID], [StudentID], [LecturerId])
    VALUES (163, 3.50, 9, 21, 3);
END
IF NOT EXISTS (SELECT 1 FROM [dbo].[Enrollment] WHERE [EnrollmentID] = 164)
BEGIN
    INSERT INTO [dbo].[Enrollment] ([EnrollmentID], [Grade], [CourseID], [StudentID], [LecturerId])
    VALUES (164, 2.40, 10, 21, 5);
END
IF NOT EXISTS (SELECT 1 FROM [dbo].[Enrollment] WHERE [EnrollmentID] = 165)
BEGIN
    INSERT INTO [dbo].[Enrollment] ([EnrollmentID], [Grade], [CourseID], [StudentID], [LecturerId])
    VALUES (165, 3.10, 11, 21, 4);
END
IF NOT EXISTS (SELECT 1 FROM [dbo].[Enrollment] WHERE [EnrollmentID] = 166)
BEGIN
    INSERT INTO [dbo].[Enrollment] ([EnrollmentID], [Grade], [CourseID], [StudentID], [LecturerId])
    VALUES (166, 3.80, 12, 21, 10);
END
IF NOT EXISTS (SELECT 1 FROM [dbo].[Enrollment] WHERE [EnrollmentID] = 167)
BEGIN
    INSERT INTO [dbo].[Enrollment] ([EnrollmentID], [Grade], [CourseID], [StudentID], [LecturerId])
    VALUES (167, 3.30, 19, 21, 6);
END
IF NOT EXISTS (SELECT 1 FROM [dbo].[Enrollment] WHERE [EnrollmentID] = 168)
BEGIN
    INSERT INTO [dbo].[Enrollment] ([EnrollmentID], [Grade], [CourseID], [StudentID], [LecturerId])
    VALUES (168, 2.50, 23, 21, 11);
END
IF NOT EXISTS (SELECT 1 FROM [dbo].[Enrollment] WHERE [EnrollmentID] = 169)
BEGIN
    INSERT INTO [dbo].[Enrollment] ([EnrollmentID], [Grade], [CourseID], [StudentID], [LecturerId])
    VALUES (169, 3.40, 7, 22, 1);
END
IF NOT EXISTS (SELECT 1 FROM [dbo].[Enrollment] WHERE [EnrollmentID] = 170)
BEGIN
    INSERT INTO [dbo].[Enrollment] ([EnrollmentID], [Grade], [CourseID], [StudentID], [LecturerId])
    VALUES (170, 2.30, 8, 22, 2);
END
IF NOT EXISTS (SELECT 1 FROM [dbo].[Enrollment] WHERE [EnrollmentID] = 171)
BEGIN
    INSERT INTO [dbo].[Enrollment] ([EnrollmentID], [Grade], [CourseID], [StudentID], [LecturerId])
    VALUES (171, 3.00, 9, 22, 3);
END
IF NOT EXISTS (SELECT 1 FROM [dbo].[Enrollment] WHERE [EnrollmentID] = 172)
BEGIN
    INSERT INTO [dbo].[Enrollment] ([EnrollmentID], [Grade], [CourseID], [StudentID], [LecturerId])
    VALUES (172, 3.70, 10, 22, 5);
END
IF NOT EXISTS (SELECT 1 FROM [dbo].[Enrollment] WHERE [EnrollmentID] = 173)
BEGIN
    INSERT INTO [dbo].[Enrollment] ([EnrollmentID], [Grade], [CourseID], [StudentID], [LecturerId])
    VALUES (173, 2.60, 11, 22, 4);
END
IF NOT EXISTS (SELECT 1 FROM [dbo].[Enrollment] WHERE [EnrollmentID] = 174)
BEGIN
    INSERT INTO [dbo].[Enrollment] ([EnrollmentID], [Grade], [CourseID], [StudentID], [LecturerId])
    VALUES (174, 3.30, 12, 22, 10);
END
IF NOT EXISTS (SELECT 1 FROM [dbo].[Enrollment] WHERE [EnrollmentID] = 175)
BEGIN
    INSERT INTO [dbo].[Enrollment] ([EnrollmentID], [Grade], [CourseID], [StudentID], [LecturerId])
    VALUES (175, 2.80, 19, 22, 6);
END
IF NOT EXISTS (SELECT 1 FROM [dbo].[Enrollment] WHERE [EnrollmentID] = 176)
BEGIN
    INSERT INTO [dbo].[Enrollment] ([EnrollmentID], [Grade], [CourseID], [StudentID], [LecturerId])
    VALUES (176, 3.10, 22, 22, 7);
END
IF NOT EXISTS (SELECT 1 FROM [dbo].[Enrollment] WHERE [EnrollmentID] = 177)
BEGIN
    INSERT INTO [dbo].[Enrollment] ([EnrollmentID], [Grade], [CourseID], [StudentID], [LecturerId])
    VALUES (177, 2.90, 7, 23, 1);
END
IF NOT EXISTS (SELECT 1 FROM [dbo].[Enrollment] WHERE [EnrollmentID] = 178)
BEGIN
    INSERT INTO [dbo].[Enrollment] ([EnrollmentID], [Grade], [CourseID], [StudentID], [LecturerId])
    VALUES (178, 3.60, 8, 23, 2);
END
IF NOT EXISTS (SELECT 1 FROM [dbo].[Enrollment] WHERE [EnrollmentID] = 179)
BEGIN
    INSERT INTO [dbo].[Enrollment] ([EnrollmentID], [Grade], [CourseID], [StudentID], [LecturerId])
    VALUES (179, 2.50, 9, 23, 3);
END
IF NOT EXISTS (SELECT 1 FROM [dbo].[Enrollment] WHERE [EnrollmentID] = 180)
BEGIN
    INSERT INTO [dbo].[Enrollment] ([EnrollmentID], [Grade], [CourseID], [StudentID], [LecturerId])
    VALUES (180, 3.20, 10, 23, 5);
END
IF NOT EXISTS (SELECT 1 FROM [dbo].[Enrollment] WHERE [EnrollmentID] = 181)
BEGIN
    INSERT INTO [dbo].[Enrollment] ([EnrollmentID], [Grade], [CourseID], [StudentID], [LecturerId])
    VALUES (181, 3.90, 11, 23, 4);
END
IF NOT EXISTS (SELECT 1 FROM [dbo].[Enrollment] WHERE [EnrollmentID] = 182)
BEGIN
    INSERT INTO [dbo].[Enrollment] ([EnrollmentID], [Grade], [CourseID], [StudentID], [LecturerId])
    VALUES (182, 2.80, 12, 23, 10);
END
IF NOT EXISTS (SELECT 1 FROM [dbo].[Enrollment] WHERE [EnrollmentID] = 183)
BEGIN
    INSERT INTO [dbo].[Enrollment] ([EnrollmentID], [Grade], [CourseID], [StudentID], [LecturerId])
    VALUES (183, 2.30, 19, 23, 6);
END
IF NOT EXISTS (SELECT 1 FROM [dbo].[Enrollment] WHERE [EnrollmentID] = 184)
BEGIN
    INSERT INTO [dbo].[Enrollment] ([EnrollmentID], [Grade], [CourseID], [StudentID], [LecturerId])
    VALUES (184, 3.30, 23, 23, 11);
END
IF NOT EXISTS (SELECT 1 FROM [dbo].[Enrollment] WHERE [EnrollmentID] = 185)
BEGIN
    INSERT INTO [dbo].[Enrollment] ([EnrollmentID], [Grade], [CourseID], [StudentID], [LecturerId])
    VALUES (185, 2.40, 7, 24, 1);
END
IF NOT EXISTS (SELECT 1 FROM [dbo].[Enrollment] WHERE [EnrollmentID] = 186)
BEGIN
    INSERT INTO [dbo].[Enrollment] ([EnrollmentID], [Grade], [CourseID], [StudentID], [LecturerId])
    VALUES (186, 3.10, 8, 24, 2);
END
IF NOT EXISTS (SELECT 1 FROM [dbo].[Enrollment] WHERE [EnrollmentID] = 187)
BEGIN
    INSERT INTO [dbo].[Enrollment] ([EnrollmentID], [Grade], [CourseID], [StudentID], [LecturerId])
    VALUES (187, 3.80, 9, 24, 3);
END
IF NOT EXISTS (SELECT 1 FROM [dbo].[Enrollment] WHERE [EnrollmentID] = 188)
BEGIN
    INSERT INTO [dbo].[Enrollment] ([EnrollmentID], [Grade], [CourseID], [StudentID], [LecturerId])
    VALUES (188, 2.70, 10, 24, 5);
END
IF NOT EXISTS (SELECT 1 FROM [dbo].[Enrollment] WHERE [EnrollmentID] = 189)
BEGIN
    INSERT INTO [dbo].[Enrollment] ([EnrollmentID], [Grade], [CourseID], [StudentID], [LecturerId])
    VALUES (189, 3.40, 11, 24, 4);
END
IF NOT EXISTS (SELECT 1 FROM [dbo].[Enrollment] WHERE [EnrollmentID] = 190)
BEGIN
    INSERT INTO [dbo].[Enrollment] ([EnrollmentID], [Grade], [CourseID], [StudentID], [LecturerId])
    VALUES (190, 2.30, 12, 24, 10);
END
IF NOT EXISTS (SELECT 1 FROM [dbo].[Enrollment] WHERE [EnrollmentID] = 191)
BEGIN
    INSERT INTO [dbo].[Enrollment] ([EnrollmentID], [Grade], [CourseID], [StudentID], [LecturerId])
    VALUES (191, 3.60, 19, 24, 6);
END
IF NOT EXISTS (SELECT 1 FROM [dbo].[Enrollment] WHERE [EnrollmentID] = 192)
BEGIN
    INSERT INTO [dbo].[Enrollment] ([EnrollmentID], [Grade], [CourseID], [StudentID], [LecturerId])
    VALUES (192, 3.90, 22, 24, 7);
END
IF NOT EXISTS (SELECT 1 FROM [dbo].[Enrollment] WHERE [EnrollmentID] = 193)
BEGIN
    INSERT INTO [dbo].[Enrollment] ([EnrollmentID], [Grade], [CourseID], [StudentID], [LecturerId])
    VALUES (193, 3.70, 7, 25, 1);
END
IF NOT EXISTS (SELECT 1 FROM [dbo].[Enrollment] WHERE [EnrollmentID] = 194)
BEGIN
    INSERT INTO [dbo].[Enrollment] ([EnrollmentID], [Grade], [CourseID], [StudentID], [LecturerId])
    VALUES (194, 2.60, 8, 25, 2);
END
IF NOT EXISTS (SELECT 1 FROM [dbo].[Enrollment] WHERE [EnrollmentID] = 195)
BEGIN
    INSERT INTO [dbo].[Enrollment] ([EnrollmentID], [Grade], [CourseID], [StudentID], [LecturerId])
    VALUES (195, 3.30, 9, 25, 3);
END
IF NOT EXISTS (SELECT 1 FROM [dbo].[Enrollment] WHERE [EnrollmentID] = 196)
BEGIN
    INSERT INTO [dbo].[Enrollment] ([EnrollmentID], [Grade], [CourseID], [StudentID], [LecturerId])
    VALUES (196, 4.00, 10, 25, 5);
END
IF NOT EXISTS (SELECT 1 FROM [dbo].[Enrollment] WHERE [EnrollmentID] = 197)
BEGIN
    INSERT INTO [dbo].[Enrollment] ([EnrollmentID], [Grade], [CourseID], [StudentID], [LecturerId])
    VALUES (197, 2.90, 11, 25, 4);
END
IF NOT EXISTS (SELECT 1 FROM [dbo].[Enrollment] WHERE [EnrollmentID] = 198)
BEGIN
    INSERT INTO [dbo].[Enrollment] ([EnrollmentID], [Grade], [CourseID], [StudentID], [LecturerId])
    VALUES (198, 3.60, 12, 25, 10);
END
IF NOT EXISTS (SELECT 1 FROM [dbo].[Enrollment] WHERE [EnrollmentID] = 199)
BEGIN
    INSERT INTO [dbo].[Enrollment] ([EnrollmentID], [Grade], [CourseID], [StudentID], [LecturerId])
    VALUES (199, 3.10, 19, 25, 6);
END
IF NOT EXISTS (SELECT 1 FROM [dbo].[Enrollment] WHERE [EnrollmentID] = 200)
BEGIN
    INSERT INTO [dbo].[Enrollment] ([EnrollmentID], [Grade], [CourseID], [StudentID], [LecturerId])
    VALUES (200, 2.30, 23, 25, 11);
END
IF NOT EXISTS (SELECT 1 FROM [dbo].[Enrollment] WHERE [EnrollmentID] = 201)
BEGIN
    INSERT INTO [dbo].[Enrollment] ([EnrollmentID], [Grade], [CourseID], [StudentID], [LecturerId])
    VALUES (201, 3.20, 7, 26, 1);
END
IF NOT EXISTS (SELECT 1 FROM [dbo].[Enrollment] WHERE [EnrollmentID] = 202)
BEGIN
    INSERT INTO [dbo].[Enrollment] ([EnrollmentID], [Grade], [CourseID], [StudentID], [LecturerId])
    VALUES (202, 3.90, 8, 26, 2);
END
IF NOT EXISTS (SELECT 1 FROM [dbo].[Enrollment] WHERE [EnrollmentID] = 203)
BEGIN
    INSERT INTO [dbo].[Enrollment] ([EnrollmentID], [Grade], [CourseID], [StudentID], [LecturerId])
    VALUES (203, 2.80, 9, 26, 3);
END
IF NOT EXISTS (SELECT 1 FROM [dbo].[Enrollment] WHERE [EnrollmentID] = 204)
BEGIN
    INSERT INTO [dbo].[Enrollment] ([EnrollmentID], [Grade], [CourseID], [StudentID], [LecturerId])
    VALUES (204, 3.50, 10, 26, 5);
END
IF NOT EXISTS (SELECT 1 FROM [dbo].[Enrollment] WHERE [EnrollmentID] = 205)
BEGIN
    INSERT INTO [dbo].[Enrollment] ([EnrollmentID], [Grade], [CourseID], [StudentID], [LecturerId])
    VALUES (205, 2.40, 11, 26, 4);
END
IF NOT EXISTS (SELECT 1 FROM [dbo].[Enrollment] WHERE [EnrollmentID] = 206)
BEGIN
    INSERT INTO [dbo].[Enrollment] ([EnrollmentID], [Grade], [CourseID], [StudentID], [LecturerId])
    VALUES (206, 3.10, 12, 26, 10);
END
IF NOT EXISTS (SELECT 1 FROM [dbo].[Enrollment] WHERE [EnrollmentID] = 207)
BEGIN
    INSERT INTO [dbo].[Enrollment] ([EnrollmentID], [Grade], [CourseID], [StudentID], [LecturerId])
    VALUES (207, 2.60, 19, 26, 6);
END
IF NOT EXISTS (SELECT 1 FROM [dbo].[Enrollment] WHERE [EnrollmentID] = 208)
BEGIN
    INSERT INTO [dbo].[Enrollment] ([EnrollmentID], [Grade], [CourseID], [StudentID], [LecturerId])
    VALUES (208, 2.90, 22, 26, 7);
END
IF NOT EXISTS (SELECT 1 FROM [dbo].[Enrollment] WHERE [EnrollmentID] = 209)
BEGIN
    INSERT INTO [dbo].[Enrollment] ([EnrollmentID], [Grade], [CourseID], [StudentID], [LecturerId])
    VALUES (209, 2.70, 7, 27, 1);
END
IF NOT EXISTS (SELECT 1 FROM [dbo].[Enrollment] WHERE [EnrollmentID] = 210)
BEGIN
    INSERT INTO [dbo].[Enrollment] ([EnrollmentID], [Grade], [CourseID], [StudentID], [LecturerId])
    VALUES (210, 3.40, 8, 27, 2);
END
IF NOT EXISTS (SELECT 1 FROM [dbo].[Enrollment] WHERE [EnrollmentID] = 211)
BEGIN
    INSERT INTO [dbo].[Enrollment] ([EnrollmentID], [Grade], [CourseID], [StudentID], [LecturerId])
    VALUES (211, 2.30, 9, 27, 3);
END
IF NOT EXISTS (SELECT 1 FROM [dbo].[Enrollment] WHERE [EnrollmentID] = 212)
BEGIN
    INSERT INTO [dbo].[Enrollment] ([EnrollmentID], [Grade], [CourseID], [StudentID], [LecturerId])
    VALUES (212, 3.00, 10, 27, 5);
END
IF NOT EXISTS (SELECT 1 FROM [dbo].[Enrollment] WHERE [EnrollmentID] = 213)
BEGIN
    INSERT INTO [dbo].[Enrollment] ([EnrollmentID], [Grade], [CourseID], [StudentID], [LecturerId])
    VALUES (213, 3.70, 11, 27, 4);
END
IF NOT EXISTS (SELECT 1 FROM [dbo].[Enrollment] WHERE [EnrollmentID] = 214)
BEGIN
    INSERT INTO [dbo].[Enrollment] ([EnrollmentID], [Grade], [CourseID], [StudentID], [LecturerId])
    VALUES (214, 2.60, 12, 27, 10);
END
IF NOT EXISTS (SELECT 1 FROM [dbo].[Enrollment] WHERE [EnrollmentID] = 215)
BEGIN
    INSERT INTO [dbo].[Enrollment] ([EnrollmentID], [Grade], [CourseID], [StudentID], [LecturerId])
    VALUES (215, 3.90, 19, 27, 6);
END
IF NOT EXISTS (SELECT 1 FROM [dbo].[Enrollment] WHERE [EnrollmentID] = 216)
BEGIN
    INSERT INTO [dbo].[Enrollment] ([EnrollmentID], [Grade], [CourseID], [StudentID], [LecturerId])
    VALUES (216, 3.10, 23, 27, 11);
END
IF NOT EXISTS (SELECT 1 FROM [dbo].[Enrollment] WHERE [EnrollmentID] = 217)
BEGIN
    INSERT INTO [dbo].[Enrollment] ([EnrollmentID], [Grade], [CourseID], [StudentID], [LecturerId])
    VALUES (217, 4.00, 7, 28, 1);
END
IF NOT EXISTS (SELECT 1 FROM [dbo].[Enrollment] WHERE [EnrollmentID] = 218)
BEGIN
    INSERT INTO [dbo].[Enrollment] ([EnrollmentID], [Grade], [CourseID], [StudentID], [LecturerId])
    VALUES (218, 2.90, 8, 28, 2);
END
IF NOT EXISTS (SELECT 1 FROM [dbo].[Enrollment] WHERE [EnrollmentID] = 219)
BEGIN
    INSERT INTO [dbo].[Enrollment] ([EnrollmentID], [Grade], [CourseID], [StudentID], [LecturerId])
    VALUES (219, 3.60, 9, 28, 3);
END
IF NOT EXISTS (SELECT 1 FROM [dbo].[Enrollment] WHERE [EnrollmentID] = 220)
BEGIN
    INSERT INTO [dbo].[Enrollment] ([EnrollmentID], [Grade], [CourseID], [StudentID], [LecturerId])
    VALUES (220, 2.50, 10, 28, 5);
END
IF NOT EXISTS (SELECT 1 FROM [dbo].[Enrollment] WHERE [EnrollmentID] = 221)
BEGIN
    INSERT INTO [dbo].[Enrollment] ([EnrollmentID], [Grade], [CourseID], [StudentID], [LecturerId])
    VALUES (221, 3.20, 11, 28, 4);
END
IF NOT EXISTS (SELECT 1 FROM [dbo].[Enrollment] WHERE [EnrollmentID] = 222)
BEGIN
    INSERT INTO [dbo].[Enrollment] ([EnrollmentID], [Grade], [CourseID], [StudentID], [LecturerId])
    VALUES (222, 3.90, 12, 28, 10);
END
IF NOT EXISTS (SELECT 1 FROM [dbo].[Enrollment] WHERE [EnrollmentID] = 223)
BEGIN
    INSERT INTO [dbo].[Enrollment] ([EnrollmentID], [Grade], [CourseID], [StudentID], [LecturerId])
    VALUES (223, 3.40, 19, 28, 6);
END
IF NOT EXISTS (SELECT 1 FROM [dbo].[Enrollment] WHERE [EnrollmentID] = 224)
BEGIN
    INSERT INTO [dbo].[Enrollment] ([EnrollmentID], [Grade], [CourseID], [StudentID], [LecturerId])
    VALUES (224, 3.70, 22, 28, 7);
END
IF NOT EXISTS (SELECT 1 FROM [dbo].[Enrollment] WHERE [EnrollmentID] = 225)
BEGIN
    INSERT INTO [dbo].[Enrollment] ([EnrollmentID], [Grade], [CourseID], [StudentID], [LecturerId])
    VALUES (225, 3.50, 7, 29, 1);
END
IF NOT EXISTS (SELECT 1 FROM [dbo].[Enrollment] WHERE [EnrollmentID] = 226)
BEGIN
    INSERT INTO [dbo].[Enrollment] ([EnrollmentID], [Grade], [CourseID], [StudentID], [LecturerId])
    VALUES (226, 2.40, 8, 29, 2);
END
IF NOT EXISTS (SELECT 1 FROM [dbo].[Enrollment] WHERE [EnrollmentID] = 227)
BEGIN
    INSERT INTO [dbo].[Enrollment] ([EnrollmentID], [Grade], [CourseID], [StudentID], [LecturerId])
    VALUES (227, 3.10, 9, 29, 3);
END
IF NOT EXISTS (SELECT 1 FROM [dbo].[Enrollment] WHERE [EnrollmentID] = 228)
BEGIN
    INSERT INTO [dbo].[Enrollment] ([EnrollmentID], [Grade], [CourseID], [StudentID], [LecturerId])
    VALUES (228, 3.80, 10, 29, 5);
END
IF NOT EXISTS (SELECT 1 FROM [dbo].[Enrollment] WHERE [EnrollmentID] = 229)
BEGIN
    INSERT INTO [dbo].[Enrollment] ([EnrollmentID], [Grade], [CourseID], [StudentID], [LecturerId])
    VALUES (229, 2.70, 11, 29, 4);
END
IF NOT EXISTS (SELECT 1 FROM [dbo].[Enrollment] WHERE [EnrollmentID] = 230)
BEGIN
    INSERT INTO [dbo].[Enrollment] ([EnrollmentID], [Grade], [CourseID], [StudentID], [LecturerId])
    VALUES (230, 3.40, 12, 29, 10);
END
IF NOT EXISTS (SELECT 1 FROM [dbo].[Enrollment] WHERE [EnrollmentID] = 231)
BEGIN
    INSERT INTO [dbo].[Enrollment] ([EnrollmentID], [Grade], [CourseID], [StudentID], [LecturerId])
    VALUES (231, 2.90, 19, 29, 6);
END
IF NOT EXISTS (SELECT 1 FROM [dbo].[Enrollment] WHERE [EnrollmentID] = 232)
BEGIN
    INSERT INTO [dbo].[Enrollment] ([EnrollmentID], [Grade], [CourseID], [StudentID], [LecturerId])
    VALUES (232, 3.90, 23, 29, 11);
END
IF NOT EXISTS (SELECT 1 FROM [dbo].[Enrollment] WHERE [EnrollmentID] = 233)
BEGIN
    INSERT INTO [dbo].[Enrollment] ([EnrollmentID], [Grade], [CourseID], [StudentID], [LecturerId])
    VALUES (233, 3.00, 7, 30, 1);
END
IF NOT EXISTS (SELECT 1 FROM [dbo].[Enrollment] WHERE [EnrollmentID] = 234)
BEGIN
    INSERT INTO [dbo].[Enrollment] ([EnrollmentID], [Grade], [CourseID], [StudentID], [LecturerId])
    VALUES (234, 3.70, 8, 30, 2);
END
IF NOT EXISTS (SELECT 1 FROM [dbo].[Enrollment] WHERE [EnrollmentID] = 235)
BEGIN
    INSERT INTO [dbo].[Enrollment] ([EnrollmentID], [Grade], [CourseID], [StudentID], [LecturerId])
    VALUES (235, 2.60, 9, 30, 3);
END
IF NOT EXISTS (SELECT 1 FROM [dbo].[Enrollment] WHERE [EnrollmentID] = 236)
BEGIN
    INSERT INTO [dbo].[Enrollment] ([EnrollmentID], [Grade], [CourseID], [StudentID], [LecturerId])
    VALUES (236, 3.30, 10, 30, 5);
END
IF NOT EXISTS (SELECT 1 FROM [dbo].[Enrollment] WHERE [EnrollmentID] = 237)
BEGIN
    INSERT INTO [dbo].[Enrollment] ([EnrollmentID], [Grade], [CourseID], [StudentID], [LecturerId])
    VALUES (237, 4.00, 11, 30, 4);
END
IF NOT EXISTS (SELECT 1 FROM [dbo].[Enrollment] WHERE [EnrollmentID] = 238)
BEGIN
    INSERT INTO [dbo].[Enrollment] ([EnrollmentID], [Grade], [CourseID], [StudentID], [LecturerId])
    VALUES (238, 2.90, 12, 30, 10);
END
IF NOT EXISTS (SELECT 1 FROM [dbo].[Enrollment] WHERE [EnrollmentID] = 239)
BEGIN
    INSERT INTO [dbo].[Enrollment] ([EnrollmentID], [Grade], [CourseID], [StudentID], [LecturerId])
    VALUES (239, 2.40, 19, 30, 6);
END
IF NOT EXISTS (SELECT 1 FROM [dbo].[Enrollment] WHERE [EnrollmentID] = 240)
BEGIN
    INSERT INTO [dbo].[Enrollment] ([EnrollmentID], [Grade], [CourseID], [StudentID], [LecturerId])
    VALUES (240, 2.70, 22, 30, 7);
END
IF NOT EXISTS (SELECT 1 FROM [dbo].[Enrollment] WHERE [EnrollmentID] = 241)
BEGIN
    INSERT INTO [dbo].[Enrollment] ([EnrollmentID], [Grade], [CourseID], [StudentID], [LecturerId])
    VALUES (241, 2.50, 7, 31, 1);
END
IF NOT EXISTS (SELECT 1 FROM [dbo].[Enrollment] WHERE [EnrollmentID] = 242)
BEGIN
    INSERT INTO [dbo].[Enrollment] ([EnrollmentID], [Grade], [CourseID], [StudentID], [LecturerId])
    VALUES (242, 3.20, 8, 31, 2);
END
IF NOT EXISTS (SELECT 1 FROM [dbo].[Enrollment] WHERE [EnrollmentID] = 243)
BEGIN
    INSERT INTO [dbo].[Enrollment] ([EnrollmentID], [Grade], [CourseID], [StudentID], [LecturerId])
    VALUES (243, 3.90, 9, 31, 3);
END
IF NOT EXISTS (SELECT 1 FROM [dbo].[Enrollment] WHERE [EnrollmentID] = 244)
BEGIN
    INSERT INTO [dbo].[Enrollment] ([EnrollmentID], [Grade], [CourseID], [StudentID], [LecturerId])
    VALUES (244, 2.80, 10, 31, 5);
END
IF NOT EXISTS (SELECT 1 FROM [dbo].[Enrollment] WHERE [EnrollmentID] = 245)
BEGIN
    INSERT INTO [dbo].[Enrollment] ([EnrollmentID], [Grade], [CourseID], [StudentID], [LecturerId])
    VALUES (245, 3.50, 11, 31, 4);
END
IF NOT EXISTS (SELECT 1 FROM [dbo].[Enrollment] WHERE [EnrollmentID] = 246)
BEGIN
    INSERT INTO [dbo].[Enrollment] ([EnrollmentID], [Grade], [CourseID], [StudentID], [LecturerId])
    VALUES (246, 2.40, 12, 31, 10);
END
IF NOT EXISTS (SELECT 1 FROM [dbo].[Enrollment] WHERE [EnrollmentID] = 247)
BEGIN
    INSERT INTO [dbo].[Enrollment] ([EnrollmentID], [Grade], [CourseID], [StudentID], [LecturerId])
    VALUES (247, 3.70, 19, 31, 6);
END
IF NOT EXISTS (SELECT 1 FROM [dbo].[Enrollment] WHERE [EnrollmentID] = 248)
BEGIN
    INSERT INTO [dbo].[Enrollment] ([EnrollmentID], [Grade], [CourseID], [StudentID], [LecturerId])
    VALUES (248, 2.90, 23, 31, 11);
END
IF NOT EXISTS (SELECT 1 FROM [dbo].[Enrollment] WHERE [EnrollmentID] = 249)
BEGIN
    INSERT INTO [dbo].[Enrollment] ([EnrollmentID], [Grade], [CourseID], [StudentID], [LecturerId])
    VALUES (249, 3.80, 7, 32, 1);
END
IF NOT EXISTS (SELECT 1 FROM [dbo].[Enrollment] WHERE [EnrollmentID] = 250)
BEGIN
    INSERT INTO [dbo].[Enrollment] ([EnrollmentID], [Grade], [CourseID], [StudentID], [LecturerId])
    VALUES (250, 2.70, 8, 32, 2);
END
IF NOT EXISTS (SELECT 1 FROM [dbo].[Enrollment] WHERE [EnrollmentID] = 251)
BEGIN
    INSERT INTO [dbo].[Enrollment] ([EnrollmentID], [Grade], [CourseID], [StudentID], [LecturerId])
    VALUES (251, 3.40, 9, 32, 3);
END
IF NOT EXISTS (SELECT 1 FROM [dbo].[Enrollment] WHERE [EnrollmentID] = 252)
BEGIN
    INSERT INTO [dbo].[Enrollment] ([EnrollmentID], [Grade], [CourseID], [StudentID], [LecturerId])
    VALUES (252, 2.30, 10, 32, 5);
END
IF NOT EXISTS (SELECT 1 FROM [dbo].[Enrollment] WHERE [EnrollmentID] = 253)
BEGIN
    INSERT INTO [dbo].[Enrollment] ([EnrollmentID], [Grade], [CourseID], [StudentID], [LecturerId])
    VALUES (253, 3.00, 11, 32, 4);
END
IF NOT EXISTS (SELECT 1 FROM [dbo].[Enrollment] WHERE [EnrollmentID] = 254)
BEGIN
    INSERT INTO [dbo].[Enrollment] ([EnrollmentID], [Grade], [CourseID], [StudentID], [LecturerId])
    VALUES (254, 3.70, 12, 32, 10);
END
IF NOT EXISTS (SELECT 1 FROM [dbo].[Enrollment] WHERE [EnrollmentID] = 255)
BEGIN
    INSERT INTO [dbo].[Enrollment] ([EnrollmentID], [Grade], [CourseID], [StudentID], [LecturerId])
    VALUES (255, 3.20, 19, 32, 6);
END
IF NOT EXISTS (SELECT 1 FROM [dbo].[Enrollment] WHERE [EnrollmentID] = 256)
BEGIN
    INSERT INTO [dbo].[Enrollment] ([EnrollmentID], [Grade], [CourseID], [StudentID], [LecturerId])
    VALUES (256, 3.50, 22, 32, 7);
END
IF NOT EXISTS (SELECT 1 FROM [dbo].[Enrollment] WHERE [EnrollmentID] = 257)
BEGIN
    INSERT INTO [dbo].[Enrollment] ([EnrollmentID], [Grade], [CourseID], [StudentID], [LecturerId])
    VALUES (257, 2.70, 1, 33, 1);
END
IF NOT EXISTS (SELECT 1 FROM [dbo].[Enrollment] WHERE [EnrollmentID] = 258)
BEGIN
    INSERT INTO [dbo].[Enrollment] ([EnrollmentID], [Grade], [CourseID], [StudentID], [LecturerId])
    VALUES (258, NULL, 2, 33, 2);
END
IF NOT EXISTS (SELECT 1 FROM [dbo].[Enrollment] WHERE [EnrollmentID] = 259)
BEGIN
    INSERT INTO [dbo].[Enrollment] ([EnrollmentID], [Grade], [CourseID], [StudentID], [LecturerId])
    VALUES (259, 2.30, 3, 33, 3);
END
IF NOT EXISTS (SELECT 1 FROM [dbo].[Enrollment] WHERE [EnrollmentID] = 260)
BEGIN
    INSERT INTO [dbo].[Enrollment] ([EnrollmentID], [Grade], [CourseID], [StudentID], [LecturerId])
    VALUES (260, 3.00, 4, 33, 5);
END
IF NOT EXISTS (SELECT 1 FROM [dbo].[Enrollment] WHERE [EnrollmentID] = 261)
BEGIN
    INSERT INTO [dbo].[Enrollment] ([EnrollmentID], [Grade], [CourseID], [StudentID], [LecturerId])
    VALUES (261, 3.70, 5, 33, 4);
END
IF NOT EXISTS (SELECT 1 FROM [dbo].[Enrollment] WHERE [EnrollmentID] = 262)
BEGIN
    INSERT INTO [dbo].[Enrollment] ([EnrollmentID], [Grade], [CourseID], [StudentID], [LecturerId])
    VALUES (262, 2.60, 6, 33, 10);
END
IF NOT EXISTS (SELECT 1 FROM [dbo].[Enrollment] WHERE [EnrollmentID] = 263)
BEGIN
    INSERT INTO [dbo].[Enrollment] ([EnrollmentID], [Grade], [CourseID], [StudentID], [LecturerId])
    VALUES (263, 2.70, 19, 33, 6);
END
IF NOT EXISTS (SELECT 1 FROM [dbo].[Enrollment] WHERE [EnrollmentID] = 264)
BEGIN
    INSERT INTO [dbo].[Enrollment] ([EnrollmentID], [Grade], [CourseID], [StudentID], [LecturerId])
    VALUES (264, 3.00, 22, 33, 7);
END
IF NOT EXISTS (SELECT 1 FROM [dbo].[Enrollment] WHERE [EnrollmentID] = 265)
BEGIN
    INSERT INTO [dbo].[Enrollment] ([EnrollmentID], [Grade], [CourseID], [StudentID], [LecturerId])
    VALUES (265, NULL, 1, 34, 1);
END
IF NOT EXISTS (SELECT 1 FROM [dbo].[Enrollment] WHERE [EnrollmentID] = 266)
BEGIN
    INSERT INTO [dbo].[Enrollment] ([EnrollmentID], [Grade], [CourseID], [StudentID], [LecturerId])
    VALUES (266, 2.90, 2, 34, 2);
END
IF NOT EXISTS (SELECT 1 FROM [dbo].[Enrollment] WHERE [EnrollmentID] = 267)
BEGIN
    INSERT INTO [dbo].[Enrollment] ([EnrollmentID], [Grade], [CourseID], [StudentID], [LecturerId])
    VALUES (267, 3.60, 3, 34, 3);
END
IF NOT EXISTS (SELECT 1 FROM [dbo].[Enrollment] WHERE [EnrollmentID] = 268)
BEGIN
    INSERT INTO [dbo].[Enrollment] ([EnrollmentID], [Grade], [CourseID], [StudentID], [LecturerId])
    VALUES (268, 2.50, 4, 34, 5);
END
IF NOT EXISTS (SELECT 1 FROM [dbo].[Enrollment] WHERE [EnrollmentID] = 269)
BEGIN
    INSERT INTO [dbo].[Enrollment] ([EnrollmentID], [Grade], [CourseID], [StudentID], [LecturerId])
    VALUES (269, 3.20, 5, 34, 4);
END
IF NOT EXISTS (SELECT 1 FROM [dbo].[Enrollment] WHERE [EnrollmentID] = 270)
BEGIN
    INSERT INTO [dbo].[Enrollment] ([EnrollmentID], [Grade], [CourseID], [StudentID], [LecturerId])
    VALUES (270, 3.90, 6, 34, 10);
END
IF NOT EXISTS (SELECT 1 FROM [dbo].[Enrollment] WHERE [EnrollmentID] = 271)
BEGIN
    INSERT INTO [dbo].[Enrollment] ([EnrollmentID], [Grade], [CourseID], [StudentID], [LecturerId])
    VALUES (271, 4.00, 19, 34, 6);
END
IF NOT EXISTS (SELECT 1 FROM [dbo].[Enrollment] WHERE [EnrollmentID] = 272)
BEGIN
    INSERT INTO [dbo].[Enrollment] ([EnrollmentID], [Grade], [CourseID], [StudentID], [LecturerId])
    VALUES (272, 3.90, 24, 34, 12);
END
IF NOT EXISTS (SELECT 1 FROM [dbo].[Enrollment] WHERE [EnrollmentID] = 273)
BEGIN
    INSERT INTO [dbo].[Enrollment] ([EnrollmentID], [Grade], [CourseID], [StudentID], [LecturerId])
    VALUES (273, 3.50, 1, 35, 1);
END
IF NOT EXISTS (SELECT 1 FROM [dbo].[Enrollment] WHERE [EnrollmentID] = 274)
BEGIN
    INSERT INTO [dbo].[Enrollment] ([EnrollmentID], [Grade], [CourseID], [StudentID], [LecturerId])
    VALUES (274, 2.40, 2, 35, 2);
END
IF NOT EXISTS (SELECT 1 FROM [dbo].[Enrollment] WHERE [EnrollmentID] = 275)
BEGIN
    INSERT INTO [dbo].[Enrollment] ([EnrollmentID], [Grade], [CourseID], [StudentID], [LecturerId])
    VALUES (275, 3.10, 3, 35, 3);
END
IF NOT EXISTS (SELECT 1 FROM [dbo].[Enrollment] WHERE [EnrollmentID] = 276)
BEGIN
    INSERT INTO [dbo].[Enrollment] ([EnrollmentID], [Grade], [CourseID], [StudentID], [LecturerId])
    VALUES (276, 3.80, 4, 35, 5);
END
IF NOT EXISTS (SELECT 1 FROM [dbo].[Enrollment] WHERE [EnrollmentID] = 277)
BEGIN
    INSERT INTO [dbo].[Enrollment] ([EnrollmentID], [Grade], [CourseID], [StudentID], [LecturerId])
    VALUES (277, 2.70, 5, 35, 4);
END
IF NOT EXISTS (SELECT 1 FROM [dbo].[Enrollment] WHERE [EnrollmentID] = 278)
BEGIN
    INSERT INTO [dbo].[Enrollment] ([EnrollmentID], [Grade], [CourseID], [StudentID], [LecturerId])
    VALUES (278, 3.40, 6, 35, 10);
END
IF NOT EXISTS (SELECT 1 FROM [dbo].[Enrollment] WHERE [EnrollmentID] = 279)
BEGIN
    INSERT INTO [dbo].[Enrollment] ([EnrollmentID], [Grade], [CourseID], [StudentID], [LecturerId])
    VALUES (279, 3.50, 19, 35, 6);
END
IF NOT EXISTS (SELECT 1 FROM [dbo].[Enrollment] WHERE [EnrollmentID] = 280)
BEGIN
    INSERT INTO [dbo].[Enrollment] ([EnrollmentID], [Grade], [CourseID], [StudentID], [LecturerId])
    VALUES (280, 3.80, 22, 35, 7);
END
IF NOT EXISTS (SELECT 1 FROM [dbo].[Enrollment] WHERE [EnrollmentID] = 281)
BEGIN
    INSERT INTO [dbo].[Enrollment] ([EnrollmentID], [Grade], [CourseID], [StudentID], [LecturerId])
    VALUES (281, 3.00, 1, 36, 1);
END
IF NOT EXISTS (SELECT 1 FROM [dbo].[Enrollment] WHERE [EnrollmentID] = 282)
BEGIN
    INSERT INTO [dbo].[Enrollment] ([EnrollmentID], [Grade], [CourseID], [StudentID], [LecturerId])
    VALUES (282, 3.70, 2, 36, 2);
END
IF NOT EXISTS (SELECT 1 FROM [dbo].[Enrollment] WHERE [EnrollmentID] = 283)
BEGIN
    INSERT INTO [dbo].[Enrollment] ([EnrollmentID], [Grade], [CourseID], [StudentID], [LecturerId])
    VALUES (283, 2.60, 3, 36, 3);
END
IF NOT EXISTS (SELECT 1 FROM [dbo].[Enrollment] WHERE [EnrollmentID] = 284)
BEGIN
    INSERT INTO [dbo].[Enrollment] ([EnrollmentID], [Grade], [CourseID], [StudentID], [LecturerId])
    VALUES (284, 3.30, 4, 36, 5);
END
IF NOT EXISTS (SELECT 1 FROM [dbo].[Enrollment] WHERE [EnrollmentID] = 285)
BEGIN
    INSERT INTO [dbo].[Enrollment] ([EnrollmentID], [Grade], [CourseID], [StudentID], [LecturerId])
    VALUES (285, 4.00, 5, 36, 4);
END
IF NOT EXISTS (SELECT 1 FROM [dbo].[Enrollment] WHERE [EnrollmentID] = 286)
BEGIN
    INSERT INTO [dbo].[Enrollment] ([EnrollmentID], [Grade], [CourseID], [StudentID], [LecturerId])
    VALUES (286, NULL, 6, 36, 10);
END
IF NOT EXISTS (SELECT 1 FROM [dbo].[Enrollment] WHERE [EnrollmentID] = 287)
BEGIN
    INSERT INTO [dbo].[Enrollment] ([EnrollmentID], [Grade], [CourseID], [StudentID], [LecturerId])
    VALUES (287, 3.00, 19, 36, 6);
END
IF NOT EXISTS (SELECT 1 FROM [dbo].[Enrollment] WHERE [EnrollmentID] = 288)
BEGIN
    INSERT INTO [dbo].[Enrollment] ([EnrollmentID], [Grade], [CourseID], [StudentID], [LecturerId])
    VALUES (288, 2.90, 24, 36, 12);
END
IF NOT EXISTS (SELECT 1 FROM [dbo].[Enrollment] WHERE [EnrollmentID] = 289)
BEGIN
    INSERT INTO [dbo].[Enrollment] ([EnrollmentID], [Grade], [CourseID], [StudentID], [LecturerId])
    VALUES (289, 2.50, 1, 37, 1);
END
IF NOT EXISTS (SELECT 1 FROM [dbo].[Enrollment] WHERE [EnrollmentID] = 290)
BEGIN
    INSERT INTO [dbo].[Enrollment] ([EnrollmentID], [Grade], [CourseID], [StudentID], [LecturerId])
    VALUES (290, 3.20, 2, 37, 2);
END
IF NOT EXISTS (SELECT 1 FROM [dbo].[Enrollment] WHERE [EnrollmentID] = 291)
BEGIN
    INSERT INTO [dbo].[Enrollment] ([EnrollmentID], [Grade], [CourseID], [StudentID], [LecturerId])
    VALUES (291, 3.90, 3, 37, 3);
END
IF NOT EXISTS (SELECT 1 FROM [dbo].[Enrollment] WHERE [EnrollmentID] = 292)
BEGIN
    INSERT INTO [dbo].[Enrollment] ([EnrollmentID], [Grade], [CourseID], [StudentID], [LecturerId])
    VALUES (292, 2.80, 4, 37, 5);
END
IF NOT EXISTS (SELECT 1 FROM [dbo].[Enrollment] WHERE [EnrollmentID] = 293)
BEGIN
    INSERT INTO [dbo].[Enrollment] ([EnrollmentID], [Grade], [CourseID], [StudentID], [LecturerId])
    VALUES (293, NULL, 5, 37, 4);
END
IF NOT EXISTS (SELECT 1 FROM [dbo].[Enrollment] WHERE [EnrollmentID] = 294)
BEGIN
    INSERT INTO [dbo].[Enrollment] ([EnrollmentID], [Grade], [CourseID], [StudentID], [LecturerId])
    VALUES (294, 2.40, 6, 37, 10);
END
IF NOT EXISTS (SELECT 1 FROM [dbo].[Enrollment] WHERE [EnrollmentID] = 295)
BEGIN
    INSERT INTO [dbo].[Enrollment] ([EnrollmentID], [Grade], [CourseID], [StudentID], [LecturerId])
    VALUES (295, 2.50, 19, 37, 6);
END
IF NOT EXISTS (SELECT 1 FROM [dbo].[Enrollment] WHERE [EnrollmentID] = 296)
BEGIN
    INSERT INTO [dbo].[Enrollment] ([EnrollmentID], [Grade], [CourseID], [StudentID], [LecturerId])
    VALUES (296, 2.80, 22, 37, 7);
END
IF NOT EXISTS (SELECT 1 FROM [dbo].[Enrollment] WHERE [EnrollmentID] = 297)
BEGIN
    INSERT INTO [dbo].[Enrollment] ([EnrollmentID], [Grade], [CourseID], [StudentID], [LecturerId])
    VALUES (297, 3.80, 1, 38, 1);
END
IF NOT EXISTS (SELECT 1 FROM [dbo].[Enrollment] WHERE [EnrollmentID] = 298)
BEGIN
    INSERT INTO [dbo].[Enrollment] ([EnrollmentID], [Grade], [CourseID], [StudentID], [LecturerId])
    VALUES (298, 2.70, 2, 38, 2);
END
IF NOT EXISTS (SELECT 1 FROM [dbo].[Enrollment] WHERE [EnrollmentID] = 299)
BEGIN
    INSERT INTO [dbo].[Enrollment] ([EnrollmentID], [Grade], [CourseID], [StudentID], [LecturerId])
    VALUES (299, 3.40, 3, 38, 3);
END
IF NOT EXISTS (SELECT 1 FROM [dbo].[Enrollment] WHERE [EnrollmentID] = 300)
BEGIN
    INSERT INTO [dbo].[Enrollment] ([EnrollmentID], [Grade], [CourseID], [StudentID], [LecturerId])
    VALUES (300, NULL, 4, 38, 5);
END
IF NOT EXISTS (SELECT 1 FROM [dbo].[Enrollment] WHERE [EnrollmentID] = 301)
BEGIN
    INSERT INTO [dbo].[Enrollment] ([EnrollmentID], [Grade], [CourseID], [StudentID], [LecturerId])
    VALUES (301, 3.00, 5, 38, 4);
END
IF NOT EXISTS (SELECT 1 FROM [dbo].[Enrollment] WHERE [EnrollmentID] = 302)
BEGIN
    INSERT INTO [dbo].[Enrollment] ([EnrollmentID], [Grade], [CourseID], [StudentID], [LecturerId])
    VALUES (302, 3.70, 6, 38, 10);
END
IF NOT EXISTS (SELECT 1 FROM [dbo].[Enrollment] WHERE [EnrollmentID] = 303)
BEGIN
    INSERT INTO [dbo].[Enrollment] ([EnrollmentID], [Grade], [CourseID], [StudentID], [LecturerId])
    VALUES (303, 3.80, 19, 38, 6);
END
IF NOT EXISTS (SELECT 1 FROM [dbo].[Enrollment] WHERE [EnrollmentID] = 304)
BEGIN
    INSERT INTO [dbo].[Enrollment] ([EnrollmentID], [Grade], [CourseID], [StudentID], [LecturerId])
    VALUES (304, 3.70, 24, 38, 12);
END
IF NOT EXISTS (SELECT 1 FROM [dbo].[Enrollment] WHERE [EnrollmentID] = 305)
BEGIN
    INSERT INTO [dbo].[Enrollment] ([EnrollmentID], [Grade], [CourseID], [StudentID], [LecturerId])
    VALUES (305, 3.30, 1, 39, 1);
END
IF NOT EXISTS (SELECT 1 FROM [dbo].[Enrollment] WHERE [EnrollmentID] = 306)
BEGIN
    INSERT INTO [dbo].[Enrollment] ([EnrollmentID], [Grade], [CourseID], [StudentID], [LecturerId])
    VALUES (306, 4.00, 2, 39, 2);
END
IF NOT EXISTS (SELECT 1 FROM [dbo].[Enrollment] WHERE [EnrollmentID] = 307)
BEGIN
    INSERT INTO [dbo].[Enrollment] ([EnrollmentID], [Grade], [CourseID], [StudentID], [LecturerId])
    VALUES (307, NULL, 3, 39, 3);
END
IF NOT EXISTS (SELECT 1 FROM [dbo].[Enrollment] WHERE [EnrollmentID] = 308)
BEGIN
    INSERT INTO [dbo].[Enrollment] ([EnrollmentID], [Grade], [CourseID], [StudentID], [LecturerId])
    VALUES (308, 3.60, 4, 39, 5);
END
IF NOT EXISTS (SELECT 1 FROM [dbo].[Enrollment] WHERE [EnrollmentID] = 309)
BEGIN
    INSERT INTO [dbo].[Enrollment] ([EnrollmentID], [Grade], [CourseID], [StudentID], [LecturerId])
    VALUES (309, 2.50, 5, 39, 4);
END
IF NOT EXISTS (SELECT 1 FROM [dbo].[Enrollment] WHERE [EnrollmentID] = 310)
BEGIN
    INSERT INTO [dbo].[Enrollment] ([EnrollmentID], [Grade], [CourseID], [StudentID], [LecturerId])
    VALUES (310, 3.20, 6, 39, 10);
END
IF NOT EXISTS (SELECT 1 FROM [dbo].[Enrollment] WHERE [EnrollmentID] = 311)
BEGIN
    INSERT INTO [dbo].[Enrollment] ([EnrollmentID], [Grade], [CourseID], [StudentID], [LecturerId])
    VALUES (311, 3.30, 19, 39, 6);
END
IF NOT EXISTS (SELECT 1 FROM [dbo].[Enrollment] WHERE [EnrollmentID] = 312)
BEGIN
    INSERT INTO [dbo].[Enrollment] ([EnrollmentID], [Grade], [CourseID], [StudentID], [LecturerId])
    VALUES (312, 3.60, 22, 39, 7);
END
IF NOT EXISTS (SELECT 1 FROM [dbo].[Enrollment] WHERE [EnrollmentID] = 313)
BEGIN
    INSERT INTO [dbo].[Enrollment] ([EnrollmentID], [Grade], [CourseID], [StudentID], [LecturerId])
    VALUES (313, 2.80, 1, 40, 1);
END
IF NOT EXISTS (SELECT 1 FROM [dbo].[Enrollment] WHERE [EnrollmentID] = 314)
BEGIN
    INSERT INTO [dbo].[Enrollment] ([EnrollmentID], [Grade], [CourseID], [StudentID], [LecturerId])
    VALUES (314, NULL, 2, 40, 2);
END
IF NOT EXISTS (SELECT 1 FROM [dbo].[Enrollment] WHERE [EnrollmentID] = 315)
BEGIN
    INSERT INTO [dbo].[Enrollment] ([EnrollmentID], [Grade], [CourseID], [StudentID], [LecturerId])
    VALUES (315, 2.40, 3, 40, 3);
END
IF NOT EXISTS (SELECT 1 FROM [dbo].[Enrollment] WHERE [EnrollmentID] = 316)
BEGIN
    INSERT INTO [dbo].[Enrollment] ([EnrollmentID], [Grade], [CourseID], [StudentID], [LecturerId])
    VALUES (316, 3.10, 4, 40, 5);
END
IF NOT EXISTS (SELECT 1 FROM [dbo].[Enrollment] WHERE [EnrollmentID] = 317)
BEGIN
    INSERT INTO [dbo].[Enrollment] ([EnrollmentID], [Grade], [CourseID], [StudentID], [LecturerId])
    VALUES (317, 3.80, 5, 40, 4);
END
IF NOT EXISTS (SELECT 1 FROM [dbo].[Enrollment] WHERE [EnrollmentID] = 318)
BEGIN
    INSERT INTO [dbo].[Enrollment] ([EnrollmentID], [Grade], [CourseID], [StudentID], [LecturerId])
    VALUES (318, 2.70, 6, 40, 10);
END
IF NOT EXISTS (SELECT 1 FROM [dbo].[Enrollment] WHERE [EnrollmentID] = 319)
BEGIN
    INSERT INTO [dbo].[Enrollment] ([EnrollmentID], [Grade], [CourseID], [StudentID], [LecturerId])
    VALUES (319, 2.80, 19, 40, 6);
END
IF NOT EXISTS (SELECT 1 FROM [dbo].[Enrollment] WHERE [EnrollmentID] = 320)
BEGIN
    INSERT INTO [dbo].[Enrollment] ([EnrollmentID], [Grade], [CourseID], [StudentID], [LecturerId])
    VALUES (320, 2.70, 24, 40, 12);
END
IF NOT EXISTS (SELECT 1 FROM [dbo].[Enrollment] WHERE [EnrollmentID] = 321)
BEGIN
    INSERT INTO [dbo].[Enrollment] ([EnrollmentID], [Grade], [CourseID], [StudentID], [LecturerId])
    VALUES (321, NULL, 1, 41, 1);
END
IF NOT EXISTS (SELECT 1 FROM [dbo].[Enrollment] WHERE [EnrollmentID] = 322)
BEGIN
    INSERT INTO [dbo].[Enrollment] ([EnrollmentID], [Grade], [CourseID], [StudentID], [LecturerId])
    VALUES (322, 3.00, 2, 41, 2);
END
IF NOT EXISTS (SELECT 1 FROM [dbo].[Enrollment] WHERE [EnrollmentID] = 323)
BEGIN
    INSERT INTO [dbo].[Enrollment] ([EnrollmentID], [Grade], [CourseID], [StudentID], [LecturerId])
    VALUES (323, 3.70, 3, 41, 3);
END
IF NOT EXISTS (SELECT 1 FROM [dbo].[Enrollment] WHERE [EnrollmentID] = 324)
BEGIN
    INSERT INTO [dbo].[Enrollment] ([EnrollmentID], [Grade], [CourseID], [StudentID], [LecturerId])
    VALUES (324, 2.60, 4, 41, 5);
END
IF NOT EXISTS (SELECT 1 FROM [dbo].[Enrollment] WHERE [EnrollmentID] = 325)
BEGIN
    INSERT INTO [dbo].[Enrollment] ([EnrollmentID], [Grade], [CourseID], [StudentID], [LecturerId])
    VALUES (325, 3.30, 5, 41, 4);
END
IF NOT EXISTS (SELECT 1 FROM [dbo].[Enrollment] WHERE [EnrollmentID] = 326)
BEGIN
    INSERT INTO [dbo].[Enrollment] ([EnrollmentID], [Grade], [CourseID], [StudentID], [LecturerId])
    VALUES (326, 4.00, 6, 41, 10);
END
IF NOT EXISTS (SELECT 1 FROM [dbo].[Enrollment] WHERE [EnrollmentID] = 327)
BEGIN
    INSERT INTO [dbo].[Enrollment] ([EnrollmentID], [Grade], [CourseID], [StudentID], [LecturerId])
    VALUES (327, 2.30, 19, 41, 6);
END
IF NOT EXISTS (SELECT 1 FROM [dbo].[Enrollment] WHERE [EnrollmentID] = 328)
BEGIN
    INSERT INTO [dbo].[Enrollment] ([EnrollmentID], [Grade], [CourseID], [StudentID], [LecturerId])
    VALUES (328, 2.60, 22, 41, 7);
END
IF NOT EXISTS (SELECT 1 FROM [dbo].[Enrollment] WHERE [EnrollmentID] = 329)
BEGIN
    INSERT INTO [dbo].[Enrollment] ([EnrollmentID], [Grade], [CourseID], [StudentID], [LecturerId])
    VALUES (329, 3.60, 1, 42, 1);
END
IF NOT EXISTS (SELECT 1 FROM [dbo].[Enrollment] WHERE [EnrollmentID] = 330)
BEGIN
    INSERT INTO [dbo].[Enrollment] ([EnrollmentID], [Grade], [CourseID], [StudentID], [LecturerId])
    VALUES (330, 2.50, 2, 42, 2);
END
IF NOT EXISTS (SELECT 1 FROM [dbo].[Enrollment] WHERE [EnrollmentID] = 331)
BEGIN
    INSERT INTO [dbo].[Enrollment] ([EnrollmentID], [Grade], [CourseID], [StudentID], [LecturerId])
    VALUES (331, 3.20, 3, 42, 3);
END
IF NOT EXISTS (SELECT 1 FROM [dbo].[Enrollment] WHERE [EnrollmentID] = 332)
BEGIN
    INSERT INTO [dbo].[Enrollment] ([EnrollmentID], [Grade], [CourseID], [StudentID], [LecturerId])
    VALUES (332, 3.90, 4, 42, 5);
END
IF NOT EXISTS (SELECT 1 FROM [dbo].[Enrollment] WHERE [EnrollmentID] = 333)
BEGIN
    INSERT INTO [dbo].[Enrollment] ([EnrollmentID], [Grade], [CourseID], [StudentID], [LecturerId])
    VALUES (333, 2.80, 5, 42, 4);
END
IF NOT EXISTS (SELECT 1 FROM [dbo].[Enrollment] WHERE [EnrollmentID] = 334)
BEGIN
    INSERT INTO [dbo].[Enrollment] ([EnrollmentID], [Grade], [CourseID], [StudentID], [LecturerId])
    VALUES (334, 3.50, 6, 42, 10);
END
IF NOT EXISTS (SELECT 1 FROM [dbo].[Enrollment] WHERE [EnrollmentID] = 335)
BEGIN
    INSERT INTO [dbo].[Enrollment] ([EnrollmentID], [Grade], [CourseID], [StudentID], [LecturerId])
    VALUES (335, 3.60, 19, 42, 6);
END
IF NOT EXISTS (SELECT 1 FROM [dbo].[Enrollment] WHERE [EnrollmentID] = 336)
BEGIN
    INSERT INTO [dbo].[Enrollment] ([EnrollmentID], [Grade], [CourseID], [StudentID], [LecturerId])
    VALUES (336, 3.50, 24, 42, 12);
END
IF NOT EXISTS (SELECT 1 FROM [dbo].[Enrollment] WHERE [EnrollmentID] = 337)
BEGIN
    INSERT INTO [dbo].[Enrollment] ([EnrollmentID], [Grade], [CourseID], [StudentID], [LecturerId])
    VALUES (337, 3.10, 1, 43, 1);
END
IF NOT EXISTS (SELECT 1 FROM [dbo].[Enrollment] WHERE [EnrollmentID] = 338)
BEGIN
    INSERT INTO [dbo].[Enrollment] ([EnrollmentID], [Grade], [CourseID], [StudentID], [LecturerId])
    VALUES (338, 3.80, 2, 43, 2);
END
IF NOT EXISTS (SELECT 1 FROM [dbo].[Enrollment] WHERE [EnrollmentID] = 339)
BEGIN
    INSERT INTO [dbo].[Enrollment] ([EnrollmentID], [Grade], [CourseID], [StudentID], [LecturerId])
    VALUES (339, 2.70, 3, 43, 3);
END
IF NOT EXISTS (SELECT 1 FROM [dbo].[Enrollment] WHERE [EnrollmentID] = 340)
BEGIN
    INSERT INTO [dbo].[Enrollment] ([EnrollmentID], [Grade], [CourseID], [StudentID], [LecturerId])
    VALUES (340, 3.40, 4, 43, 5);
END
IF NOT EXISTS (SELECT 1 FROM [dbo].[Enrollment] WHERE [EnrollmentID] = 341)
BEGIN
    INSERT INTO [dbo].[Enrollment] ([EnrollmentID], [Grade], [CourseID], [StudentID], [LecturerId])
    VALUES (341, 2.30, 5, 43, 4);
END
IF NOT EXISTS (SELECT 1 FROM [dbo].[Enrollment] WHERE [EnrollmentID] = 342)
BEGIN
    INSERT INTO [dbo].[Enrollment] ([EnrollmentID], [Grade], [CourseID], [StudentID], [LecturerId])
    VALUES (342, NULL, 6, 43, 10);
END
IF NOT EXISTS (SELECT 1 FROM [dbo].[Enrollment] WHERE [EnrollmentID] = 343)
BEGIN
    INSERT INTO [dbo].[Enrollment] ([EnrollmentID], [Grade], [CourseID], [StudentID], [LecturerId])
    VALUES (343, 3.10, 19, 43, 6);
END
IF NOT EXISTS (SELECT 1 FROM [dbo].[Enrollment] WHERE [EnrollmentID] = 344)
BEGIN
    INSERT INTO [dbo].[Enrollment] ([EnrollmentID], [Grade], [CourseID], [StudentID], [LecturerId])
    VALUES (344, 3.40, 22, 43, 7);
END
IF NOT EXISTS (SELECT 1 FROM [dbo].[Enrollment] WHERE [EnrollmentID] = 345)
BEGIN
    INSERT INTO [dbo].[Enrollment] ([EnrollmentID], [Grade], [CourseID], [StudentID], [LecturerId])
    VALUES (345, 2.60, 1, 44, 1);
END
IF NOT EXISTS (SELECT 1 FROM [dbo].[Enrollment] WHERE [EnrollmentID] = 346)
BEGIN
    INSERT INTO [dbo].[Enrollment] ([EnrollmentID], [Grade], [CourseID], [StudentID], [LecturerId])
    VALUES (346, 3.30, 2, 44, 2);
END
IF NOT EXISTS (SELECT 1 FROM [dbo].[Enrollment] WHERE [EnrollmentID] = 347)
BEGIN
    INSERT INTO [dbo].[Enrollment] ([EnrollmentID], [Grade], [CourseID], [StudentID], [LecturerId])
    VALUES (347, 4.00, 3, 44, 3);
END
IF NOT EXISTS (SELECT 1 FROM [dbo].[Enrollment] WHERE [EnrollmentID] = 348)
BEGIN
    INSERT INTO [dbo].[Enrollment] ([EnrollmentID], [Grade], [CourseID], [StudentID], [LecturerId])
    VALUES (348, 2.90, 4, 44, 5);
END
IF NOT EXISTS (SELECT 1 FROM [dbo].[Enrollment] WHERE [EnrollmentID] = 349)
BEGIN
    INSERT INTO [dbo].[Enrollment] ([EnrollmentID], [Grade], [CourseID], [StudentID], [LecturerId])
    VALUES (349, NULL, 5, 44, 4);
END
IF NOT EXISTS (SELECT 1 FROM [dbo].[Enrollment] WHERE [EnrollmentID] = 350)
BEGIN
    INSERT INTO [dbo].[Enrollment] ([EnrollmentID], [Grade], [CourseID], [StudentID], [LecturerId])
    VALUES (350, 2.50, 6, 44, 10);
END
IF NOT EXISTS (SELECT 1 FROM [dbo].[Enrollment] WHERE [EnrollmentID] = 351)
BEGIN
    INSERT INTO [dbo].[Enrollment] ([EnrollmentID], [Grade], [CourseID], [StudentID], [LecturerId])
    VALUES (351, 2.60, 19, 44, 6);
END
IF NOT EXISTS (SELECT 1 FROM [dbo].[Enrollment] WHERE [EnrollmentID] = 352)
BEGIN
    INSERT INTO [dbo].[Enrollment] ([EnrollmentID], [Grade], [CourseID], [StudentID], [LecturerId])
    VALUES (352, 2.50, 24, 44, 12);
END
IF NOT EXISTS (SELECT 1 FROM [dbo].[Enrollment] WHERE [EnrollmentID] = 353)
BEGIN
    INSERT INTO [dbo].[Enrollment] ([EnrollmentID], [Grade], [CourseID], [StudentID], [LecturerId])
    VALUES (353, 3.90, 1, 45, 1);
END
IF NOT EXISTS (SELECT 1 FROM [dbo].[Enrollment] WHERE [EnrollmentID] = 354)
BEGIN
    INSERT INTO [dbo].[Enrollment] ([EnrollmentID], [Grade], [CourseID], [StudentID], [LecturerId])
    VALUES (354, 2.80, 2, 45, 2);
END
IF NOT EXISTS (SELECT 1 FROM [dbo].[Enrollment] WHERE [EnrollmentID] = 355)
BEGIN
    INSERT INTO [dbo].[Enrollment] ([EnrollmentID], [Grade], [CourseID], [StudentID], [LecturerId])
    VALUES (355, 3.50, 3, 45, 3);
END
IF NOT EXISTS (SELECT 1 FROM [dbo].[Enrollment] WHERE [EnrollmentID] = 356)
BEGIN
    INSERT INTO [dbo].[Enrollment] ([EnrollmentID], [Grade], [CourseID], [StudentID], [LecturerId])
    VALUES (356, NULL, 4, 45, 5);
END
IF NOT EXISTS (SELECT 1 FROM [dbo].[Enrollment] WHERE [EnrollmentID] = 357)
BEGIN
    INSERT INTO [dbo].[Enrollment] ([EnrollmentID], [Grade], [CourseID], [StudentID], [LecturerId])
    VALUES (357, 3.10, 5, 45, 4);
END
IF NOT EXISTS (SELECT 1 FROM [dbo].[Enrollment] WHERE [EnrollmentID] = 358)
BEGIN
    INSERT INTO [dbo].[Enrollment] ([EnrollmentID], [Grade], [CourseID], [StudentID], [LecturerId])
    VALUES (358, 3.80, 6, 45, 10);
END
IF NOT EXISTS (SELECT 1 FROM [dbo].[Enrollment] WHERE [EnrollmentID] = 359)
BEGIN
    INSERT INTO [dbo].[Enrollment] ([EnrollmentID], [Grade], [CourseID], [StudentID], [LecturerId])
    VALUES (359, 3.90, 19, 45, 6);
END
IF NOT EXISTS (SELECT 1 FROM [dbo].[Enrollment] WHERE [EnrollmentID] = 360)
BEGIN
    INSERT INTO [dbo].[Enrollment] ([EnrollmentID], [Grade], [CourseID], [StudentID], [LecturerId])
    VALUES (360, 2.40, 22, 45, 7);
END
IF NOT EXISTS (SELECT 1 FROM [dbo].[Enrollment] WHERE [EnrollmentID] = 361)
BEGIN
    INSERT INTO [dbo].[Enrollment] ([EnrollmentID], [Grade], [CourseID], [StudentID], [LecturerId])
    VALUES (361, 3.40, 1, 46, 1);
END
IF NOT EXISTS (SELECT 1 FROM [dbo].[Enrollment] WHERE [EnrollmentID] = 362)
BEGIN
    INSERT INTO [dbo].[Enrollment] ([EnrollmentID], [Grade], [CourseID], [StudentID], [LecturerId])
    VALUES (362, 2.30, 2, 46, 2);
END
IF NOT EXISTS (SELECT 1 FROM [dbo].[Enrollment] WHERE [EnrollmentID] = 363)
BEGIN
    INSERT INTO [dbo].[Enrollment] ([EnrollmentID], [Grade], [CourseID], [StudentID], [LecturerId])
    VALUES (363, NULL, 3, 46, 3);
END
IF NOT EXISTS (SELECT 1 FROM [dbo].[Enrollment] WHERE [EnrollmentID] = 364)
BEGIN
    INSERT INTO [dbo].[Enrollment] ([EnrollmentID], [Grade], [CourseID], [StudentID], [LecturerId])
    VALUES (364, 3.70, 4, 46, 5);
END
IF NOT EXISTS (SELECT 1 FROM [dbo].[Enrollment] WHERE [EnrollmentID] = 365)
BEGIN
    INSERT INTO [dbo].[Enrollment] ([EnrollmentID], [Grade], [CourseID], [StudentID], [LecturerId])
    VALUES (365, 2.60, 5, 46, 4);
END
IF NOT EXISTS (SELECT 1 FROM [dbo].[Enrollment] WHERE [EnrollmentID] = 366)
BEGIN
    INSERT INTO [dbo].[Enrollment] ([EnrollmentID], [Grade], [CourseID], [StudentID], [LecturerId])
    VALUES (366, 3.30, 6, 46, 10);
END
IF NOT EXISTS (SELECT 1 FROM [dbo].[Enrollment] WHERE [EnrollmentID] = 367)
BEGIN
    INSERT INTO [dbo].[Enrollment] ([EnrollmentID], [Grade], [CourseID], [StudentID], [LecturerId])
    VALUES (367, 3.40, 19, 46, 6);
END
IF NOT EXISTS (SELECT 1 FROM [dbo].[Enrollment] WHERE [EnrollmentID] = 368)
BEGIN
    INSERT INTO [dbo].[Enrollment] ([EnrollmentID], [Grade], [CourseID], [StudentID], [LecturerId])
    VALUES (368, 3.30, 24, 46, 12);
END
IF NOT EXISTS (SELECT 1 FROM [dbo].[Enrollment] WHERE [EnrollmentID] = 369)
BEGIN
    INSERT INTO [dbo].[Enrollment] ([EnrollmentID], [Grade], [CourseID], [StudentID], [LecturerId])
    VALUES (369, 2.90, 1, 47, 1);
END
IF NOT EXISTS (SELECT 1 FROM [dbo].[Enrollment] WHERE [EnrollmentID] = 370)
BEGIN
    INSERT INTO [dbo].[Enrollment] ([EnrollmentID], [Grade], [CourseID], [StudentID], [LecturerId])
    VALUES (370, NULL, 2, 47, 2);
END
IF NOT EXISTS (SELECT 1 FROM [dbo].[Enrollment] WHERE [EnrollmentID] = 371)
BEGIN
    INSERT INTO [dbo].[Enrollment] ([EnrollmentID], [Grade], [CourseID], [StudentID], [LecturerId])
    VALUES (371, 2.50, 3, 47, 3);
END
IF NOT EXISTS (SELECT 1 FROM [dbo].[Enrollment] WHERE [EnrollmentID] = 372)
BEGIN
    INSERT INTO [dbo].[Enrollment] ([EnrollmentID], [Grade], [CourseID], [StudentID], [LecturerId])
    VALUES (372, 3.20, 4, 47, 5);
END
IF NOT EXISTS (SELECT 1 FROM [dbo].[Enrollment] WHERE [EnrollmentID] = 373)
BEGIN
    INSERT INTO [dbo].[Enrollment] ([EnrollmentID], [Grade], [CourseID], [StudentID], [LecturerId])
    VALUES (373, 3.90, 5, 47, 4);
END
IF NOT EXISTS (SELECT 1 FROM [dbo].[Enrollment] WHERE [EnrollmentID] = 374)
BEGIN
    INSERT INTO [dbo].[Enrollment] ([EnrollmentID], [Grade], [CourseID], [StudentID], [LecturerId])
    VALUES (374, 2.80, 6, 47, 10);
END
IF NOT EXISTS (SELECT 1 FROM [dbo].[Enrollment] WHERE [EnrollmentID] = 375)
BEGIN
    INSERT INTO [dbo].[Enrollment] ([EnrollmentID], [Grade], [CourseID], [StudentID], [LecturerId])
    VALUES (375, 2.90, 19, 47, 6);
END
IF NOT EXISTS (SELECT 1 FROM [dbo].[Enrollment] WHERE [EnrollmentID] = 376)
BEGIN
    INSERT INTO [dbo].[Enrollment] ([EnrollmentID], [Grade], [CourseID], [StudentID], [LecturerId])
    VALUES (376, 3.20, 22, 47, 7);
END
IF NOT EXISTS (SELECT 1 FROM [dbo].[Enrollment] WHERE [EnrollmentID] = 377)
BEGIN
    INSERT INTO [dbo].[Enrollment] ([EnrollmentID], [Grade], [CourseID], [StudentID], [LecturerId])
    VALUES (377, NULL, 1, 48, 1);
END
IF NOT EXISTS (SELECT 1 FROM [dbo].[Enrollment] WHERE [EnrollmentID] = 378)
BEGIN
    INSERT INTO [dbo].[Enrollment] ([EnrollmentID], [Grade], [CourseID], [StudentID], [LecturerId])
    VALUES (378, 3.10, 2, 48, 2);
END
IF NOT EXISTS (SELECT 1 FROM [dbo].[Enrollment] WHERE [EnrollmentID] = 379)
BEGIN
    INSERT INTO [dbo].[Enrollment] ([EnrollmentID], [Grade], [CourseID], [StudentID], [LecturerId])
    VALUES (379, 3.80, 3, 48, 3);
END
IF NOT EXISTS (SELECT 1 FROM [dbo].[Enrollment] WHERE [EnrollmentID] = 380)
BEGIN
    INSERT INTO [dbo].[Enrollment] ([EnrollmentID], [Grade], [CourseID], [StudentID], [LecturerId])
    VALUES (380, 2.70, 4, 48, 5);
END
IF NOT EXISTS (SELECT 1 FROM [dbo].[Enrollment] WHERE [EnrollmentID] = 381)
BEGIN
    INSERT INTO [dbo].[Enrollment] ([EnrollmentID], [Grade], [CourseID], [StudentID], [LecturerId])
    VALUES (381, 3.40, 5, 48, 4);
END
IF NOT EXISTS (SELECT 1 FROM [dbo].[Enrollment] WHERE [EnrollmentID] = 382)
BEGIN
    INSERT INTO [dbo].[Enrollment] ([EnrollmentID], [Grade], [CourseID], [StudentID], [LecturerId])
    VALUES (382, 2.30, 6, 48, 10);
END
IF NOT EXISTS (SELECT 1 FROM [dbo].[Enrollment] WHERE [EnrollmentID] = 383)
BEGIN
    INSERT INTO [dbo].[Enrollment] ([EnrollmentID], [Grade], [CourseID], [StudentID], [LecturerId])
    VALUES (383, 2.40, 19, 48, 6);
END
IF NOT EXISTS (SELECT 1 FROM [dbo].[Enrollment] WHERE [EnrollmentID] = 384)
BEGIN
    INSERT INTO [dbo].[Enrollment] ([EnrollmentID], [Grade], [CourseID], [StudentID], [LecturerId])
    VALUES (384, 2.30, 24, 48, 12);
END

SET IDENTITY_INSERT [dbo].[Enrollment] OFF;
GO

PRINT 'SchoolManagement_DB database bootstrap completed.';
PRINT 'Seed summary: 24 courses, 12 lecturers, 48 students, and 384 enrollments targeted.';
GO
