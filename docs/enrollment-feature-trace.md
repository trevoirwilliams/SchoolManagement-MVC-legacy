# Enrollment Cross-Cutting Workflow Trace

## Scope

This document traces the current enrollment workflow behavior implemented in the inherited ASP.NET MVC 5 application (`.NET Framework 4.8` workspace baseline), focusing on controller actions, Razor views, AJAX interactions, EF6 model surfaces, and database relationships that affect enrollment behavior.

### Verified in code
- Enrollment workflow endpoints are implemented in `SchoolManagement/Controllers/EnrollmentsController.cs`.
- Primary UI surfaces are in `SchoolManagement/Views/Enrollments/*`.
- Enrollment data uses EF6 Database First entities (`SchoolManagement/Models/*.cs`) via `SchoolManagement_DBEntities`.
- Related scripts/bundles are loaded from shared layout and bundle config.
- Database schema/constraints were reviewed in `database/create-schoolmanagement-db.sql`.

### Out of scope
- No production database inspection was performed.
- No runtime debugging/session trace was performed.
- No behavior assumptions beyond visible code were made.

## Why This Workflow Is Cross-Cutting

Enrollment behavior spans:
- MVC controller actions (`Index`, `Create`, `Edit`, `Delete`, JSON endpoints).
- Server-rendered views plus partial rendering.
- Client-side AJAX and jQuery UI autocomplete.
- EF6 navigation properties (`Enrollment` ↔ `Course`/`Student`/`Lecturer`).
- Database FK and cascade delete behavior.
- Shared app infrastructure (routing, bundling, global filter setup).

This creates cross-cutting coupling across UI rendering, client script behavior, data access, and relational constraints.

## Files Reviewed

- `SchoolManagement/Controllers/EnrollmentsController.cs`
- `SchoolManagement/Views/Enrollments/Index.cshtml`
- `SchoolManagement/Views/Enrollments/Create.cshtml`
- `SchoolManagement/Views/Enrollments/_enrollmentPartial.cshtml`
- `SchoolManagement/Views/Enrollments/Edit.cshtml`
- `SchoolManagement/Views/Enrollments/Delete.cshtml`
- `SchoolManagement/Views/Enrollments/Details.cshtml`
- `SchoolManagement/Models/Enrollment.cs`
- `SchoolManagement/Models/Student.cs`
- `SchoolManagement/Models/Course.cs`
- `SchoolManagement/Models/Lecturer.cs`
- `SchoolManagement/Models/SchoolManagementDBModel.Context.cs`
- `SchoolManagement/Views/Shared/_Layout.cshtml`
- `SchoolManagement/App_Start/BundleConfig.cs`
- `SchoolManagement/App_Start/FilterConfig.cs`
- `SchoolManagement/App_Start/RouteConfig.cs`
- `database/create-schoolmanagement-db.sql`

## Main Enrollment List Flow

### Verified behavior
1. Request to `Enrollments/Index` executes `EnrollmentsController.Index()`.
2. Query includes related entities (`Course`, `Student`, `Lecturer`) using EF `Include(...)`.
3. `Index.cshtml` renders a table with:
   - `Grade`
   - `Course.Title`
   - `Student.LastName`
   - `Lecturer.First_Name`
4. Per-row links route to `Edit`, `Details`, and `Delete`.

### Review concern (later)
- **Authorization area for later review:** no controller-level `[Authorize]` attribute is visible on `EnrollmentsController`; no global `AuthorizeAttribute` is registered in `FilterConfig`.

## Create Page Setup Flow

### Verified behavior
1. GET `Enrollments/Create` populates:
   - `ViewBag.CourseID` from `db.Courses`
   - `ViewBag.StudentID` from `db.Students`
   - `ViewBag.LecturerId` from `db.Lecturers`
2. `Create.cshtml` uses `Ajax.BeginForm("AddStudent", "Enrollments", ...)` (not the standard scaffolded POST `Create` action).
3. Page loads existing enrollments for the selected course by calling `_enrollmentPartial` via AJAX on initial load and on course change.
4. UI message regions:
   - `#success` (“Student Added Successfully”)
   - `#failed` generic failure message

### Review concern (later)
- **AJAX area for later review:** enrollment creation on this page is driven by custom AJAX endpoint (`AddStudent`), not the scaffolded full-form POST `Create`.
- **Hidden-field area for later review:** student selection is stored in hidden field `StudentID`; visible text input is `Student.FirstName` editor.

## Student Autocomplete Flow

### Verified behavior
1. jQuery UI autocomplete is attached to input with id `#Student_FirstName`.
2. Source callback sends POST to `/Enrollments/GetStudents` with `term`.
3. Server action `GetStudents(string term)` returns JSON list:
   - `Name = FirstName + " " + LastName`
   - `Id = StudentID`
   - filtered by `Name.Contains(term)`.
4. On selection, hidden `#StudentID` is assigned selected student id.

### Review concern (later)
- **AJAX area for later review:** autocomplete endpoint is POST JSON without anti-forgery validation.
- **Hidden-field area for later review:** selected ID depends on client-side mapping from text suggestion to hidden field; no additional server-side binding proof beyond posted `StudentID`.

## AJAX Add Student Flow

### Verified behavior
1. Form submit posts to `EnrollmentsController.AddStudent([Bind(Include = "CourseID,StudentID")] Enrollment enrollment)`.
2. Server checks duplicate enrollment using:
   - same `CourseID`
   - same `StudentID`
3. If valid and not duplicate:
   - adds enrollment row
   - saves changes
   - returns JSON `{ IsSuccess = true, Message = "Student Added Successfully" }`
4. Otherwise returns duplicate message JSON.
5. Exceptions return failure JSON with generic system-failure message.

### Review concern (later)
- **Anti-forgery area for later review:** form includes `@Html.AntiForgeryToken()`, but `AddStudent` action does not apply `[ValidateAntiForgeryToken]`.
- **Authorization area for later review:** no explicit authorization attribute on `AddStudent`.
- **Error handling area for later review:** catch block suppresses exception detail and returns generic message only.

## Partial Enrollment List Refresh Flow

### Verified behavior
1. Client function `LoadEnrollments(cid)` requests `Enrollments/_enrollmentPartial?courseid=<id>` (GET).
2. `_enrollmentPartial(int? courseid)` filters enrollments by `CourseID == courseid`, includes `Course` and `Student`, and returns partial view.
3. Partial shows:
   - no-record banner when count `< 1`
   - otherwise table of grade, course title, student full name, delete link.
4. Refresh occurs:
   - on initial page load
   - on course dropdown change
   - after successful `AddStudent`.

### Review concern (later)
- **AJAX area for later review:** partial endpoint is unauthenticated in reviewed code.
- **Authorization area for later review:** delete links are exposed in partial output regardless of role checks in view.

## Edit Flow

### Verified behavior
1. GET `Edit(id)`:
   - returns `400 BadRequest` when `id` missing
   - returns `404` when enrollment not found
   - otherwise loads enrollment and select lists for course/student/lecturer.
2. `Edit.cshtml` posts standard form with anti-forgery token and hidden `EnrollmentID`.
3. POST `Edit(...)`:
   - guarded by `[ValidateAntiForgeryToken]`
   - binds `EnrollmentID,Grade,CourseID,StudentID,LecturerId`
   - sets entity state to `Modified`
   - saves and redirects to `Index` on valid model.

### Review concern (later)
- **Authorization area for later review:** no explicit controller/action-level authorization in reviewed files.

## Delete Flow

### Verified behavior
1. GET `Delete(id)`:
   - `400` if missing id
   - `404` if entity not found
   - otherwise renders confirmation page.
2. POST `DeleteConfirmed(int id)`:
   - `[HttpPost, ActionName("Delete")]`
   - `[ValidateAntiForgeryToken]`
   - removes enrollment entity and saves
   - redirects to `Index`.
3. Delete entry points exist in both `Index.cshtml` and `_enrollmentPartial.cshtml`.

### Review concern (later)
- **Authorization area for later review:** delete endpoint has no visible `[Authorize]`/role constraint in reviewed code.

## EF6 Model and Navigation Properties

### Verified behavior
- `Enrollment` entity contains:
  - `EnrollmentID`
  - `Grade` (`Nullable<decimal>`)
  - required `CourseID`
  - required `StudentID`
  - optional `LecturerId`
  - navigation refs: `Course`, `Student`, `Lecturer`.
- `Course`, `Student`, `Lecturer` each expose `ICollection<Enrollment>`.
- Context class `SchoolManagement_DBEntities` is EF6 `DbContext` with `DbSet`s for all four entities.
- `OnModelCreating` throws `UnintentionalCodeFirstException`, consistent with Database First pattern.

### Review concern (later)
- Entity classes shown are auto-generated; regeneration behavior should be considered during future schema/model changes.

## Database Relationship Flow

### Verified behavior (from reviewed SQL bootstrap script)
- `Enrollment` table has foreign keys:
  - `CourseID -> Course.CourseId ON DELETE CASCADE`
  - `StudentID -> Student.StudentID ON DELETE CASCADE`
  - `LecturerId -> Lecturers.Id ON DELETE CASCADE`
- `LecturerId` is nullable in schema.

### Review concern (later)
- **Cascade-delete area for later review:** enrollment row removal may occur implicitly when parent `Course`, `Student`, or `Lecturer` rows are deleted (script-defined behavior).
- Production DB FK settings were not validated in this trace.

## Validation and Anti-Forgery Observations

### Verified behavior
- `[ValidateAntiForgeryToken]` is present on:
  - scaffolded POST `Create`
  - POST `Edit`
  - POST `Delete`.
- `Create.cshtml` AJAX form includes anti-forgery token helper.
- `AddStudent` endpoint does duplicate check and `ModelState.IsValid` check.

### Review concern (later)
- **Anti-forgery area for later review:** `AddStudent` and `GetStudents` actions do not show `[ValidateAntiForgeryToken]`.
- `AddStudent` binds only `CourseID` and `StudentID`; grade/lecturer are not provided by this flow.

## Authorization Observations

### Verified behavior
- `EnrollmentsController` has no visible `[Authorize]` attribute.
- `FilterConfig` registers only `HandleErrorAttribute`.
- Navigation link to `Enrollments` appears in shared layout menu.

### Review concern (later)
- **Authorization area for later review:** access control may depend on external config/pipeline not reviewed here; endpoint-level enforcement is not explicit in reviewed enrollment files.

## Error-Handling Observations

### Verified behavior
- GET `Details/Edit/Delete` return HTTP status results for missing/invalid ids.
- `AddStudent` wraps operation in `try/catch` and returns JSON success/failure payloads.
- `Index`, `_enrollmentPartial`, and `GetStudents` do not include explicit local exception handling.

### Review concern (later)
- `AddStudent` catch block returns generic message and does not preserve diagnostic context in response.
- No explicit user-visible error contract for partial-load AJAX failures beyond generic client callback behavior.

## Modernization-Relevant Observations

### Verified behavior
- Enrollment workflow depends on:
  - MVC 5 `Controller`/`ActionResult` patterns.
  - `Ajax.BeginForm` + `jquery.unobtrusive-ajax`.
  - jQuery UI autocomplete.
  - EF6 Database First generated entities/context.
  - `System.Web.Optimization` bundles loaded in `_Layout`.

### Review concern (later)
- Cross-cutting coupling (server-rendered partial + AJAX + hidden-field state + EF entities) should be treated as a cohesive unit during any future modernization planning.
- No conversion guidance is provided in this trace by design.

## Assumptions and Unknowns

### Assumptions explicitly made
- SQL script FK/cascade configuration represents intended local schema baseline for this repository.

### Unknowns
- Whether deployed database FK cascade settings exactly match bootstrap script.
- Whether additional authorization is enforced outside reviewed files (e.g., custom filters, middleware, IIS-level policy).
- Whether client-side duplicate prevention or additional validation exists outside this view/controller pair.
- Whether users rely on direct scaffolded POST `Create` action (the UI currently posts to `AddStudent` via AJAX in reviewed create view).

## Manual Validation Checklist

- [ ] Open `Enrollments/Index`; verify list renders grade/course/student/lecturer and action links.
- [ ] Open `Enrollments/Create`; verify course dropdown initializes and partial list loads for default course.
- [ ] Change course in create page; verify partial refresh updates enrollment list.
- [ ] Type 2+ characters in student input; verify autocomplete suggestions appear from `GetStudents`.
- [ ] Select autocomplete item; verify hidden `StudentID` is populated.
- [ ] Submit enroll via AJAX with new student/course pair; verify success alert and partial list refresh.
- [ ] Submit enroll for an existing student/course pair; verify duplicate failure alert.
- [ ] Trigger network/API failure for add flow; verify failure alert behavior.
- [ ] Open `Enrollments/Edit/{id}`; verify existing values load and save redirects to index.
- [ ] Open `Enrollments/Delete/{id}`; verify confirmation and deletion flow.
- [ ] Verify anti-forgery tokens are present in create/edit/delete forms.
- [ ] Mark **AJAX**, **authorization**, **anti-forgery on JSON endpoints**, **hidden-field state reliance**, and **cascade-delete effects** for dedicated follow-up review.