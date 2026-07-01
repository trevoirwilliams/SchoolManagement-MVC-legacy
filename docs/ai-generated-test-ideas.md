# AI-Generated Test Ideas

## Purpose

This document captures the AI-assisted test planning for the SchoolManagement MVC legacy baseline.

The goal is to identify practical, high-value tests and immediately convert the best first targets into working tests.

## Baseline

- Application type: ASP.NET MVC legacy application
- Current platform: .NET Framework MVC
- Modernization target: ASP.NET Core MVC on .NET 10

## Review Rule

AI-generated test ideas are drafts. A test idea is accepted only if it is supported by current code, documentation, configuration, or observable runtime 
behavior.


## Test Idea Table
| Test Idea ID | Area | Behavior or risk to test | Evidence source | Suggested test type | Feasibility: Easy, Moderate, Hard, or Defer | Priority: High, Medium, or Low | Why this test matters for modernization | Assumption status: Observed, Partially observed, or Assumption to verify |
|---|---|---|---|---|---|---|---|---|
| T01 | StudentsController authorization | Controller requires `Teacher` role, but `Index` explicitly allows anonymous access (requires MVC runtime hosting + auth middleware). | `SchoolManagement/Controllers/StudentsController.cs:14-21` | Integration (authorization) | Moderate | High | Prevents accidental access policy drift when moving to ASP.NET Core policies. | Observed |
| T02 | CoursesController authorization | All actions require authenticated user (no role restriction) (requires MVC runtime hosting + auth middleware). | `SchoolManagement/Controllers/CoursesController.cs:13-15` | Integration (authorization) | Moderate | High | Baseline must be preserved before redesigning role boundaries. | Observed |
| T03 | LecturersController authorization gap | No `[Authorize]` on controller/actions; potentially anonymous CRUD if no global auth filter (requires MVC runtime hosting). | `SchoolManagement/Controllers/LecturersController.cs:14-15`, `SchoolManagement/App_Start/FilterConfig.cs:8-11` | Integration/security regression | Moderate | High | High-risk behavior that could silently change during migration. | Observed |
| T04 | EnrollmentsController authorization gap | No `[Authorize]` on controller/actions; includes JSON/AJAX endpoints (requires MVC runtime hosting). | `SchoolManagement/Controllers/EnrollmentsController.cs:14-23,77-79,160-168` | Integration/security regression | Moderate | High | JSON endpoints are common migration blind spots. | Observed |
| T05 | AccountController anonymous overrides | `[Authorize]` class with `[AllowAnonymous]` on login/register/reset flows; ensure only intended actions are anonymous (requires OWIN + MVC hosting + Identity). | `SchoolManagement/Controllers/AccountController.cs:15,59,69,141,151,183,196,205,232,240,249,283,293,309,328,359,406` | Integration (auth flow matrix) | Hard | High | Critical for preserving login/register accessibility during auth stack migration. | Observed |
| T06 | Startup role creation | Startup creates roles `Admin`, `Teacher`, `Supervisor`; verify idempotent role seeding on app start (requires OWIN startup + Identity DB). | `SchoolManagement/Startup.cs:13-17,28-47` | Integration/startup | Hard | High | Role seeding behavior must be mapped to ASP.NET Core startup equivalents. | Observed |
| T07 | Registration role behavior | Registration allows user-selected role from dropdown excluding `Admin`; verify role assignment succeeds/fails as currently implemented (requires Identity setup + MVC hosting). | `SchoolManagement/Controllers/AccountController.cs:144,169`, `SchoolManagement/Views/Account/Register.cshtml:45-49`, `docs/business-rules-and-risks.md:36-37` | End-to-end auth workflow | Hard | High | Security-sensitive workflow likely to change; baseline evidence is required first. | Observed |
| T08 | Anti-forgery coverage on CRUD POSTs | Confirm CRUD POST actions enforce `[ValidateAntiForgeryToken]` across controllers (requires MVC runtime + form posting). | `CoursesController.cs:48-50,80-82,109-111`; `StudentsController.cs:51-53,83-85,112-114`; `LecturersController.cs:48-50,80-82,109-111`; `EnrollmentsController.cs:60-63,118-121,150-152`; `AccountController.cs` multiple POSTs | Attribute + integration tests | Easy | High | CSRF behavior can regress when moving to new antiforgery defaults/middleware. | Observed |
| T09 | Anti-forgery gap on enrollment AJAX add | `AddStudent` POST lacks `[ValidateAntiForgeryToken]` though form emits token (requires MVC hosting + AJAX endpoint). | `EnrollmentsController.cs:77-79`, `Views/Enrollments/Create.cshtml:107-114` | Security integration test | Moderate | High | JSON/AJAX CSRF protections differ in ASP.NET Core; must document current baseline gap. | Observed |
| T10 | Student search/autocomplete endpoint | `GetStudents` is POST JSON endpoint without anti-forgery/auth; verify payload shape (`Name`, `Id`) and term filtering behavior (requires DB data + MVC hosting). | `EnrollmentsController.cs:160-168`, `Views/Enrollments/Create.cshtml:37-60` | Integration (AJAX/JSON contract) | Moderate | High | Front-end autocomplete contract is fragile during route and JSON serializer migration. | Observed |
| T11 | Duplicate enrollment handling | `AddStudent` blocks duplicates via app-level `Any` check and returns specific JSON message; verify race/duplicate behavior (requires DB setup + concurrent requests). | `EnrollmentsController.cs:82-90` | Integration + concurrency | Hard | High | App-level duplicate checks may fail under concurrency; behavior may change with EF Core/db constraints. | Observed |
| T12 | MVC null-id behavior | `Details/Edit/Delete` GET actions return HTTP 400 for null id and 404 when entity missing (requires DB + MVC runtime). | `CoursesController.cs:25-35`; `StudentsController.cs:28-38`; `LecturersController.cs:25-35`; `EnrollmentsController.cs:34-44,98-108,135-145` | Integration (action result) | Moderate | Medium | Route/model binding differences in ASP.NET Core can alter status code outcomes. | Observed |
| T13 | DeleteConfirmed missing-entity handling | `DeleteConfirmed` actions call `Remove` after `Find`; behavior when entity not found should be captured (requires DB state manipulation + MVC runtime). | `CoursesController.cs:111-116`; `StudentsController.cs:114-119`; `LecturersController.cs:111-116`; `EnrollmentsController.cs:152-157` | Integration (error-path) | Moderate | Medium | Exception behavior and null handling often differ after ORM/controller refactors. | Observed |
| T14 | Metadata validation: Course | Validate `Title` max length 50 and `Credits` range 1-8 as applied to model binding/UI validation (requires MVC model validation runtime). | `Models/MetaClasses/CoursesMetadata.cs:12-19`; `Views/Courses/Create.cshtml:19-31` | Integration (model validation) | Moderate | High | Data annotations and metadata provider behavior can shift during migration/scaffolding. | Observed |
| T15 | Metadata display + validation: Student | Verify display labels and string length constraints from metadata are reflected in views/model state (requires MVC runtime). | `Models/MetaClasses/StudentMetadata.cs:11-31`; `Views/Students/Create.cshtml:19-47`; `Views/Students/Index.cshtml:16-23` | Integration (UI metadata) | Moderate | Medium | Preserves user-facing labels/validation expectations during Razor migration. | Observed |
| T16 | Metadata display naming: Enrollment | Verify display names for enrollment fields (`Course`, `Student`, `Lecturer`) render as expected in views (requires MVC runtime). | `Models/MetaClasses/EnrollmentMetadata.cs:11-28`; `Views/Enrollments/Index.cshtml:16-26`; `Views/Enrollments/Edit.cshtml:29-47` | Integration (UI metadata) | Moderate | Medium | Model metadata mapping can break when moving from EF6 + buddy classes to new patterns. | Observed |
| T17 | Route + action-link compatibility | Conventional route `{controller}/{action}/{id}` and `ActionLink` usage must resolve same URLs after migration (requires hosted app routing). | `App_Start/RouteConfig.cs:16-20`; `Views/Students/Index.cshtml:39-41`; `Views/Enrollments/Index.cshtml:45-47` | End-to-end routing | Moderate | High | Routing compatibility is a major regression source in MVC-to-Core moves. | Observed |
| T18 | Partial view enrollment list behavior | `_enrollmentPartial(courseid)` returns filtered list and “NO ENROLLMENTS…” message when empty (requires DB data + MVC runtime). | `EnrollmentsController.cs:25-31`; `Views/Enrollments/_enrollmentPartial.cshtml:3-6` | Integration (partial rendering) | Moderate | Medium | Partial rendering + AJAX composition often breaks with view/component migration. | Observed |
| T19 | Bind include overposting boundaries | Verify only included properties are bound on Create/Edit actions; extra posted fields are ignored (requires MVC model binding tests). | `CoursesController.cs:50,82`; `StudentsController.cs:53,85`; `LecturersController.cs:50,82`; `EnrollmentsController.cs:62,120,78` | Integration (model binding security) | Moderate | High | Binding behavior changes between ASP.NET MVC and ASP.NET Core can alter security posture. | Observed |
| T20 | Documentation-to-code drift (startup/authorization) | Docs describe some access/startup behavior that may not match code; capture executable truth before migration (requires runtime verification). | `docs/codebase-summary.md:163-166,289-311` vs `Startup.cs:28-47`, `LecturersController.cs:14`, `EnrollmentsController.cs:14` | Documentation validation + smoke tests | Easy | Medium | Prevents migrating based on stale assumptions instead of observed behavior. | Partially observed |

## Reviewed First-Pass Test Ideas

### Implement Now

| ID | Area | Test Idea | Test Type | Why Now |
|---|---|---|---|---|
| TIDEA-001 | Authorization | Verify `CoursesController` has class-level authorization. | Reflection test | Protects security-sensitive baseline behavior without database setup. |
| TIDEA-002 | Authorization | Verify `StudentsController` requires the Teacher role. | Reflection test | Captures current role behavior before authorization migration. |
| TIDEA-003 | Authorization | Verify `StudentsController.Index` allows anonymous access. | Reflection test | Captures unusual baseline behavior that could change accidentally. |
| TIDEA-004 | Authorization Risk | Verify `LecturersController` currently has no class-level authorization attribute. | Reflection/security test | Documents a risky baseline before intentional hardening. |
| TIDEA-005 | Authorization Risk | Verify `EnrollmentsController` currently has no class-level authorization attribute. | Reflection/security test | Documents a risky baseline before intentional hardening. |
| TIDEA-006 | Anti-Forgery | Verify standard CRUD POST actions use anti-forgery validation. | Reflection/security test | Protects form POST security during controller migration. |
| TIDEA-007 | Course Metadata | Verify course title length and credit range metadata. | Metadata validation test | Protects validation behavior likely to be lost during model migration. |
| TIDEA-008 | Student Metadata | Verify student name length and display metadata. | Metadata validation test | Protects Razor form/display behavior during modernization. |
| TIDEA-009 | Enrollment Metadata | Verify enrollment display metadata. | Metadata validation test | Protects form labels and generated UI expectations. |

### Implement After Test Infrastructure Exists

| Area | Test Idea | Why Later |
|---|---|---|
| Course CRUD persistence | Needs EF6 database setup or a test seam. |
| Student CRUD persistence | Needs EF6 database setup or a test seam. |
| Enrollment Index query includes | Needs seeded database data. |
| AddStudent JSON success/duplicate behavior | Valuable, but depends on seeded enrollment data. |
| GetStudents autocomplete JSON behavior | Valuable, but depends on seeded student data. |
| Registration role assignment | Needs Identity test setup. |
| Startup role creation | Needs Identity context setup or a seam around role creation. |

### Defer or Manual Verification

| Area | Reason |
|---|---|
| Full browser login flow | Better as an end-to-end test after test infrastructure is established. |
| External login providers | Providers require external configuration and are not active in the baseline. |
| Password reset email delivery | Email service is incomplete or placeholder-based in the baseline. |
| Full Razor view rendering | Higher setup cost; start with controller and metadata tests first. |
