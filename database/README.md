# Database Setup Resource

This folder contains the SQL Server database bootstrap script for the SchoolManagement Legacy MVC application.

## Script

```text
create-schoolmanagement-db.sql
```

The script creates the database expected by the current `SchoolManagement/Web.config` connection strings:

```text
SchoolManagement_DB
```

It creates:

- ASP.NET Identity 2 tables used by `ApplicationDbContext`
- EF6 Database First school-management tables used by `SchoolManagement_DBEntities`
- baseline roles: Admin, Teacher, Supervisor
- sample courses, students, lecturers, and enrollments

## Why this script exists

The application uses an EF6 Database First / EDMX model for the school-management tables. A freshly cloned repository does not automatically contain the local SQL Server database required by the generated model. This script gives every reviewer and learner a repeatable way to create the expected database before running the application or starting modernization work.

## Run with LocalDB

From the repository root:

```powershell
sqlcmd -S "(localdb)\MSSQLLocalDB" -i database/create-schoolmanagement-db.sql
```

## Run with SQL Server Management Studio

1. Open SQL Server Management Studio.
2. Connect to `(localdb)\MSSQLLocalDB` or your local SQL Server instance.
3. Open `database/create-schoolmanagement-db.sql`.
4. Execute the script.
5. Confirm the `SchoolManagement_DB` database was created.

## Important notes

- The script is non-destructive. It creates missing objects and inserts sample data only when the relevant tables are empty.
- The script does not create default users because ASP.NET Identity password hashes should be created through the application registration workflow.
- The current application startup also creates missing roles when the app starts. The script seeds the same baseline roles so the database is usable immediately after creation.
- Roles are seeded so that the registration page and role workflows have usable baseline data.
- The table and column names intentionally match the EF6 EDMX model, including the `Lecturers` table columns named `[First Name]` and `[Last Name]`.

## Suggested baseline validation

After running the script:

1. Open `SchoolManagement.sln` in Visual Studio.
2. Restore NuGet packages.
3. Build the solution.
4. Run the application.
5. Register a user through the application.
6. Validate student, course, lecturer, and enrollment workflows.

## Validation evidence to capture

When using this repository for modernization work, record:

- the command used to run the script
- the SQL Server or LocalDB instance name
- confirmation that `SchoolManagement_DB` exists
- whether the application launched successfully
- whether registration successfully created a user
- whether the core school-management workflows loaded sample data correctly