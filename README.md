# SchoolManagement Legacy MVC

SchoolManagement Legacy MVC is an inherited ASP.NET Framework application that supports basic academic operations for a school administration team. The system manages students, lecturers, courses, enrollments, user accounts, and role-based access for staff workflows.

The repository is intentionally preserved as a legacy baseline before modernization. The current goal is not to redesign the system immediately. The goal is to assess the existing application, document its behavior, identify modernization risks, protect current business behavior, and then plan an incremental migration to ASP.NET Core on .NET 10.

## Current baseline

- ASP.NET MVC 5
- .NET Framework 4.6.1 baseline to be reviewed before moving to .NET Framework 4.8
- Entity Framework 6 Database First with EDMX-generated models
- ASP.NET Identity 2
- OWIN/Katana authentication middleware
- `packages.config` package management
- `web.config` application configuration
- `Global.asax` startup registration
- Bootstrap 3, jQuery, jQuery UI, and legacy ASP.NET bundling
- LocalDB SQL Server connection strings

## Target modernization direction

The intended modernization path is:

1. Establish and document the current ASP.NET Framework MVC baseline.
2. Move the legacy baseline to .NET Framework 4.8 where practical.
3. Assess the application with GitHub Copilot modernization.
4. Review generated assessment, options, plan, and task artifacts.
5. Protect existing behavior with characterization checks and targeted tests.
6. Migrate the application toward ASP.NET Core MVC on .NET 10.
7. Review authentication, authorization, data access, configuration, dependencies, and UI migration risks.
8. Prepare a modernization pull request with build evidence, validation evidence, and reviewer notes.

## Business capabilities

The system currently includes these business areas:

- Student record management
- Lecturer record management
- Course management
- Student enrollment management
- Role-based user registration and authentication
- Basic staff navigation and secured workflows

## Known baseline characteristics

The application contains several patterns that are normal in older ASP.NET MVC applications but require review before modernization:

- Direct `DbContext` construction in MVC controllers
- EF6 Database First / EDMX-generated model classes
- System.Web-based MVC controllers, routing, filters, and bundling
- `web.config`-based connection strings and assembly redirects
- OWIN-based authentication and ASP.NET Identity 2
- Inconsistent authorization coverage across controllers and actions
- AJAX endpoints that require explicit review for authorization and anti-forgery protection
- Legacy JavaScript/CSS asset management through ASP.NET bundling

## Important modernization rule

Do not start by rewriting the application. First assess, document, and validate the inherited behavior. Modernization changes should be incremental, reviewable, and supported by build/test evidence.

## Recommended local setup

1. Open `SchoolManagement.sln` in Visual Studio.
2. Restore NuGet packages.
3. Confirm LocalDB is available.
4. Create the local database by running the SQL bootstrap script:

   ```powershell
   sqlcmd -S "(localdb)\MSSQLLocalDB" -i database/create-schoolmanagement-db.sql
   ```

5. Review `SchoolManagement/Web.config` connection strings and confirm they point to `SchoolManagement_DB`.
6. Build the solution before making modernization changes.
7. Run the application locally and verify the main user workflows.
8. Register a user through the application registration workflow.

## Database setup resource

The `database/` folder contains an idempotent SQL Server bootstrap script that creates the `SchoolManagement_DB` database expected by the inherited application.

The script creates:

- ASP.NET Identity 2 tables used by `ApplicationDbContext`
- EF6 Database First school-management tables used by `SchoolManagement_DBEntities`
- baseline roles: Admin, Teacher, Supervisor
- sample courses, students, lecturers, and enrollments

The script does not seed default users. Users should be created through the application registration workflow so ASP.NET Identity generates password hashes correctly.

## Baseline review documents

See the `docs/` folder for the modernization assessment checklist, dependency inventory, business rules, risk register, validation checklist, and pull request checklist.

## AI-assisted modernization prompts

See the `prompts/` folder for structured prompts that can be used with GitHub Copilot Chat or GitHub Copilot modernization when assessing and planning the migration.