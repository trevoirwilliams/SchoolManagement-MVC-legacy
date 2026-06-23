# Hidden Business and Role Rules

## Scope

This document captures currently observed business behavior and role/access behavior in the inherited SchoolManagement MVC application, based on controller logic, model metadata, startup configuration, identity settings, views, and database schema script.

It separates:
- **Verified current behavior** (direct code/schema evidence)
- **Inferred rules** (likely intent, not explicitly enforced end-to-end)
- **Unknowns** (requires business/security confirmation)

## Review Method

- Static review of MVC controllers, Razor views, identity configuration, startup, and SQL schema/seed script.
- Classified each item as:
  - **Verified**: directly enforced by code/config/schema
  - **Inferred**: implied by naming/UI/data but not fully enforced
  - **Unknown**: insufficient evidence or conflicting evidence
- Focused on business rules, enrollment workflow, and role/access controls.

## Files Reviewed

- `SchoolManagement/Controllers/StudentsController.cs`
- `SchoolManagement/Controllers/CoursesController.cs`
- `SchoolManagement/Controllers/LecturersController.cs`
- `SchoolManagement/Controllers/EnrollmentsController.cs`
- `SchoolManagement/Controllers/AccountController.cs`
- `SchoolManagement/Controllers/ManageController.cs`
- `SchoolManagement/Controllers/HomeController.cs`
- `SchoolManagement/Views/Enrollments/Create.cshtml`
- `SchoolManagement/Views/Enrollments/Index.cshtml`
- `SchoolManagement/Views/Enrollments/_enrollmentPartial.cshtml`
- `SchoolManagement/Views/Account/Register.cshtml`
- `SchoolManagement/Views/Shared/_Layout.cshtml`
- `SchoolManagement/Views/Shared/_LoginPartial.cshtml`
- `SchoolManagement/Startup.cs`
- `SchoolManagement/App_Start/Startup.Auth.cs`
- `SchoolManagement/App_Start/IdentityConfig.cs`
- `SchoolManagement/App_Start/FilterConfig.cs`
- `SchoolManagement/Models/AccountViewModels.cs`
- `SchoolManagement/Models/IdentityModels.cs`
- `SchoolManagement/Models/MetaClasses/CoursesMetadata.cs`
- `SchoolManagement/Models/MetaClasses/StudentMetadata.cs`
- `database/create-schoolmanagement-db.sql`
- `SchoolManagement/Web.config`

## Rule Classification

- **Verified**: Controller attributes/actions, model validation attributes, identity settings, SQL constraints/indexes/FKs.
- **Inferred**: Workflow intent from UI labels, seed data patterns, and partial enforcement paths.
- **Unknown**: Business ownership/approval requirements, final role matrix, and security expectations not encoded in current implementation.

## Verified Business Rules

1. Course credits are constrained to `1..8` by model metadata (`CoursesMetadata`).
2. Course title maximum length is `50` characters (`CoursesMetadata` + DB schema `NVARCHAR(50)`).
3. Student first/last/middle names are max length `50` (`StudentMetadata` + DB schema).
4. Student enrollment date and date of birth are optional in schema/model.
5. Enrollment allows optional grade and optional lecturer (`Enrollment` model + DB schema).
6. Enrollment create/edit POST actions use model binding with explicit include lists.
7. Enrollment duplicate check exists only in AJAX path (`AddStudent`) using `(CourseID, StudentID)` existence check.
8. Enrollment records are cascade-deleted when related course, student, or lecturer is deleted (DB foreign keys with `ON DELETE CASCADE`).
9. Password policy is enforced by Identity:
   - min length 6
   - requires non-alphanumeric, digit, lowercase, uppercase
10. User email uniqueness is enforced by Identity (`RequireUniqueEmail = true`).
11. Account lockout is enabled by default (5 failed attempts, 5-minute lockout).

## Inferred Business Rules Requiring Confirmation

1. **Self-service registration is intended for non-admin users** (role dropdown excludes roles containing `Admin`).
2. **Teacher appears to be treated as primary staff role for student management** (only `StudentsController` has `[Authorize(Roles = "Teacher")]`).
3. **Supervisor role exists but has no explicit access rules in reviewed controllers**.
4. **Grade scale appears GPA-like (seeded decimal values around 2.0–4.0)**, but no explicit validation range is enforced in app code.
5. **Enrollment may support two modes**:
   - full CRUD with grade/lecturer
   - quick add student-to-course (AJAX) without grade/lecturer
6. **Role names are operationally fixed to `Admin`, `Teacher`, `Supervisor`** due to startup role creation.

## Verified Role and Access Rules

1. `StudentsController`:
   - Controller-level: `Teacher` role required.
   - Exception: `Index` action is explicitly `[AllowAnonymous]`.
2. `CoursesController`:
   - Controller-level `[Authorize]` (any authenticated user).
3. `AccountController` and `ManageController`:
   - Controller-level `[Authorize]` with specific anonymous actions in `AccountController` (login/register/password reset/external flows).
4. `LecturersController` and `EnrollmentsController`:
   - No `[Authorize]` at controller/action level (publicly reachable by default MVC behavior).
5. Registration assigns user to the selected role via `AddToRoleAsync(user.Id, model.UserRole)`.
6. Baseline roles are created at startup if missing (`Admin`, `Teacher`, `Supervisor`).

## Inconsistent or Unclear Role Rules

1. Anonymous access is inconsistent across domains:
   - Students list is anonymous, but other student actions are teacher-only.
   - Lecturers and enrollments appear broadly open, including mutating actions.
2. `Supervisor` role is seeded but not visibly mapped to protected domain actions.
3. Courses require authentication, but lecturers/enrollments do not.
4. Registration allows user-selected role assignment without a visible server-side whitelist check beyond UI filtering.
5. Navigation shows links for all domains to all visitors, regardless of role/access outcome.

## Enrollment-Specific Rules

### Verified current behavior

1. `AddStudent` enforces no duplicate `(CourseID, StudentID)` for that specific endpoint.
2. `AddStudent` does not require lecturer or grade; resulting enrollment can persist with null grade/lecturer.
3. Standard enrollment create/edit supports setting `Grade`, `CourseID`, `StudentID`, `LecturerId`.
4. Student lookup endpoint (`GetStudents`) returns student name/id JSON filtered by name contains search term.
5. Enrollment partial view filters rows by selected course and displays deletion link per enrollment row.

### Known enforcement gaps (verified technical behavior)

1. No database unique constraint on `(CourseID, StudentID)`; duplicate prevention depends on application path.
2. `AddStudent` and `GetStudents` POST endpoints do not enforce anti-forgery validation attributes.
3. No explicit authorization restriction on enrollment endpoints.

## Security-Sensitive Rules

1. **Role assignment at registration is user-driven** (security-sensitive business workflow).
2. **Anonymous or broadly accessible data endpoints**:
   - Student index (`AllowAnonymous`)
   - Enrollment JSON/partial endpoints (no authorization attributes)
   - Lecturer/enrollment CRUD appears publicly routable
3. **Anti-forgery enforcement is inconsistent**:
   - Present on many form POST actions
   - Not enforced on selected AJAX/JSON POST endpoints
4. **Cascade delete behavior** can remove enrollment history automatically when student/course/lecturer is deleted.
5. **Login uses username**, while some password reset actions use view model `Email` values with `FindByName`, requiring confirmation of intended identifier rules.

## Modernization Decision Points

1. Final role-permission matrix for `Admin`, `Teacher`, `Supervisor`.
2. Whether anonymous access to student, lecturer, and enrollment data is intentional.
3. Whether self-selected role registration remains acceptable.
4. Whether duplicate enrollment prevention must be guaranteed at database level or only application level.
5. Expected rule for lecturer assignment during enrollment creation.
6. Expected grade validation range and whether null grade is valid at creation time.
7. Expected delete semantics for enrollment records when parent entities are removed.

## Questions for Business Stakeholders

1. Which roles may create/edit/delete students, lecturers, courses, and enrollments?
2. Should `Supervisor` be read-only, limited-write, or full-write?
3. Should users be allowed to choose their own role during registration?
4. Is anonymous visibility of student/lecturer/enrollment information acceptable?
5. Can a student be enrolled in the same course more than once?
6. Is lecturer assignment mandatory at enrollment time?
7. Is grade entry mandatory at enrollment time?
8. What is the approved grading scale and validation boundaries?
9. Should deleting a course/student/lecturer remove related enrollments automatically?

## Questions for Security Review

1. Is self-service role assignment compliant with policy?
2. Are current anonymous endpoints acceptable for FERPA/privacy expectations?
3. Should all enrollment and student search endpoints require authenticated access and anti-forgery enforcement?
4. Is current role filtering logic (`!Name.Contains("Admin")`) sufficient against role-escalation attempts?
5. Are identity flows aligned on username vs email usage for account recovery?
6. Is exposed enrollment deletion via partial-view links acceptable without explicit role checks?

## Manual Validation Checklist

- [ ] Verify anonymous user behavior for `Students/Index`, `Lecturers/*`, `Enrollments/*`.
- [ ] Verify authenticated non-teacher behavior for student create/edit/delete.
- [ ] Verify `Teacher` role behavior across all student actions.
- [ ] Verify `Supervisor` role behavior across all controllers.
- [ ] Register a new account and confirm selectable roles and resulting assigned role.
- [ ] Attempt role tampering in registration request payload and record result.
- [ ] Validate duplicate enrollment prevention through AJAX (`AddStudent`) and non-AJAX create paths.
- [ ] Validate whether enrollments can be created with null `Grade` and null `LecturerId`.
- [ ] Validate anti-forgery behavior on AJAX enrollment endpoints.
- [ ] Validate cascade delete outcomes when deleting course/student/lecturer records.
- [ ] Validate password policy, lockout, and login/forgot/reset identifier behavior.