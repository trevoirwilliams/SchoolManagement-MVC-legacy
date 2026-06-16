# Business Rules and Modernization Risks

This document captures the expected business behavior that should be understood before the application is modernized.

## Business context

SchoolManagement supports administrative workflows for a school operations team. The application manages academic records for students, lecturers, courses, enrollments, and staff accounts.

## Current business areas

| Area | Current behavior to verify | Primary files |
|---|---|---|
| Students | Staff can view, create, edit, and delete student records | `StudentsController`, `Views/Students` |
| Courses | Authenticated users can manage course records | `CoursesController`, `Views/Courses` |
| Lecturers | Lecturer records can be viewed and maintained | `LecturersController`, `Views/Lecturers` |
| Enrollments | Students can be assigned to courses and lecturers | `EnrollmentsController`, `Views/Enrollments` |
| Accounts | Users can register, sign in, and be assigned roles | `AccountController`, `ManageController`, Identity models |
| Navigation | Shared layout exposes main application areas | `Views/Shared/_Layout.cshtml` |

## Expected role concepts

The baseline includes these role names:

- Admin
- Teacher
- Supervisor

Before migration, confirm what each role should be allowed to do. Do not infer final access rules from the current attributes alone. Treat the current implementation as inherited behavior that must be reviewed.

## Questions to resolve before modernization

1. Who should create and manage student records?
2. Who should create and manage courses?
3. Who should create and manage lecturer records?
4. Who should create and manage enrollments?
5. Should users select their own roles during registration?
6. Which records should be available anonymously, if any?
7. Should lecturers see only their own course enrollments?
8. Should supervisors have read-only access?
9. Should student search endpoints require authentication?
10. Which workflows require anti-forgery validation?

## Known risk areas in the baseline

| Risk | Why it matters | Suggested handling |
|---|---|---|
| Inconsistent authorization | Some controllers and actions use different access rules | Document expected access before migration |
| Direct data context usage in controllers | Business rules, data access, and UI logic are tightly coupled | Separate behavior gradually after baseline validation |
| EF6 EDMX generated code | Generated files can be overwritten and are difficult to maintain directly | Avoid manual edits to generated entities before migration strategy is chosen |
| User-selected role during registration | Role assignment is a business-sensitive workflow | Review desired registration and approval process |
| JSON endpoints | AJAX endpoints may bypass normal form protections | Review authentication, validation, and anti-forgery requirements |
| Legacy configuration | Important behavior is stored in `web.config` | Map each setting before moving to ASP.NET Core configuration |
| Legacy asset bundling | Scripts and styles are bundled through System.Web optimization | Replace with a modern static asset approach during UI migration |

## Baseline preservation rule

During modernization, preserve observable behavior until a specific change is approved. If a behavior is unsafe, document it as a risk first, then fix it intentionally with validation evidence.