# Baseline Assessment Checklist

Use this checklist before any modernization work begins. The goal is to establish what the inherited application currently does, what it depends on, and where modernization risk is concentrated.

## Repository and solution structure

| Check | Evidence | Status |
|---|---|---|
| Confirm the solution opens successfully | `SchoolManagement.sln` | Not started |
| Confirm project file format | `SchoolManagement/SchoolManagement.csproj` | Not started |
| Confirm target framework | `.NET Framework 4.6.1` currently | Not started |
| Confirm package management format | `packages.config` | Not started |
| Confirm build configurations | Debug and Release | Not started |

## Application startup

Review these files before migration:

- `Global.asax`
- `Global.asax.cs`
- `App_Start/RouteConfig.cs`
- `App_Start/FilterConfig.cs`
- `App_Start/BundleConfig.cs`
- `Startup.cs`
- `App_Start/Startup.Auth.cs`

Assessment questions:

- Which startup responsibilities belong in ASP.NET Core `Program.cs`?
- Which routes must be preserved?
- Which filters apply globally?
- Which static assets are bundled today?
- Which authentication behavior is configured through OWIN?

## Data access

Review these files and folders:

- `Models/SchoolManagementDBModel.edmx`
- `Models/SchoolManagementDBModel.Context.cs`
- `Models/SchoolManagementDBModel.cs`
- generated entity files
- `Migrations/`
- `Web.config` connection strings

Assessment questions:

- Is the EF6 EDMX model generated from an existing database?
- Is the database schema available and reproducible?
- Which entities are generated and should not be edited manually?
- Does the application use more than one data context?
- Should EF6 remain temporarily, or should EF Core be introduced during migration?

## Authentication and authorization

Review:

- `Controllers/AccountController.cs`
- `Controllers/ManageController.cs`
- `Models/IdentityModels.cs`
- `App_Start/IdentityConfig.cs`
- `Startup.cs`
- `App_Start/Startup.Auth.cs`

Assessment questions:

- Which roles exist?
- Which controllers and actions require authentication?
- Which actions are anonymous by design?
- How are roles assigned during registration?
- Which OWIN behavior needs an ASP.NET Core equivalent?

## MVC controllers and views

Review controllers:

- `StudentsController`
- `CoursesController`
- `EnrollmentsController`
- `LecturersController`
- `HomeController`
- `AccountController`
- `ManageController`

Assessment questions:

- Which workflows are CRUD-only?
- Which workflows contain business rules?
- Which actions return JSON or partial views?
- Which actions use anti-forgery validation?
- Which actions expose student, enrollment, lecturer, or account data?
- Where is direct `DbContext` access used?

## Configuration and dependencies

Review:

- `Web.config`
- `packages.config`
- assembly binding redirects
- Application Insights module configuration
- CodeDOM compiler configuration
- LocalDB connection strings

Assessment questions:

- Which settings move to `appsettings.json`?
- Which settings become environment-specific configuration?
- Which packages are incompatible with ASP.NET Core?
- Which frontend packages should move to a modern static asset approach?

## Baseline validation evidence

Before modernization, capture evidence for:

- package restore
- solution build
- database setup
- application launch
- login workflow
- role creation behavior
- student CRUD behavior
- course CRUD behavior
- lecturer CRUD behavior
- enrollment CRUD behavior
- AJAX enrollment workflow behavior

## Initial risk register

| Risk | Area | Impact | Suggested Handling |
|---|---|---|---|
| EF6 EDMX migration uncertainty | Data access | High | Verify database schema and scaffold strategy before changing data layer |
| OWIN and Identity migration complexity | Authentication | High | Document login, registration, roles, and account workflows first |
| Inconsistent authorization | Security | High | Identify expected access rules before migration |
| Missing anti-forgery validation on selected endpoints | Security | Medium | Review all POST endpoints and JSON workflows |
| `web.config` dependency | Configuration | Medium | Map settings to ASP.NET Core configuration before deleting legacy config |
| Legacy bundling | UI/static assets | Medium | Replace with ASP.NET Core static file strategy or build pipeline |
| `packages.config` dependency model | Dependencies | Medium | Inventory packages before SDK-style conversion |