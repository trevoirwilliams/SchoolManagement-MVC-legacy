# Course Management CRUD Workflow Trace

## Scope

This document traces the **current** Course Management CRUD behavior implemented in the inherited ASP.NET MVC application, based on direct review of the files listed below.  
It is intended as a baseline engineering artifact for modernization planning, not a redesign proposal.

## Business Purpose

The Course Management area supports authenticated staff workflows to:

- list existing courses,
- view course details,
- create new courses,
- edit existing courses, and
- delete courses.

This aligns with the repository-level business capability statement for course management in `README.md`.

## Files Reviewed

- `.github/copilot-instructions.md`
- `README.md`
- `SchoolManagement/App_Start/RouteConfig.cs`
- `SchoolManagement/Controllers/CoursesController.cs`
- `SchoolManagement/Models/Course.cs`
- `SchoolManagement/Models/SchoolManagementDBModel.Context.cs`
- `SchoolManagement/Views/Courses/Index.cshtml`
- `SchoolManagement/Views/Courses/Details.cshtml`
- `SchoolManagement/Views/Courses/Create.cshtml`
- `SchoolManagement/Views/Courses/Edit.cshtml`
- `SchoolManagement/Views/Courses/Delete.cshtml`

## Route and Action Map

Verified from `RouteConfig` and `CoursesController`:

- Default route template: `/{controller}/{action}/{id}` with `{id}` optional.
- Controller-level authorization: `[Authorize]` on `CoursesController` (applies to all actions in this controller).

| HTTP | Route Pattern | Action | Input | Output / Behavior |
|---|---|---|---|---|
| GET | `/Courses/Index` | `Index()` | none | Returns `View(db.Courses.ToList())` |
| GET | `/Courses/Details/{id}` | `Details(int? id)` | nullable id | `400 BadRequest` if null; `404` if not found; else details view |
| GET | `/Courses/Create` | `Create()` | none | Returns create form |
| POST | `/Courses/Create` | `Create([Bind(...)] Course course)` | `CourseId, Title, Credits` | Anti-forgery + model validation; insert then redirect to Index |
| GET | `/Courses/Edit/{id}` | `Edit(int? id)` | nullable id | `400` if null; `404` if not found; else edit form |
| POST | `/Courses/Edit` | `Edit([Bind(...)] Course course)` | `CourseId, Title, Credits` | Anti-forgery + model validation; mark modified + save; redirect to Index |
| GET | `/Courses/Delete/{id}` | `Delete(int? id)` | nullable id | `400` if null; `404` if not found; else delete confirmation view |
| POST | `/Courses/Delete/{id}` (action name `Delete`) | `DeleteConfirmed(int id)` | id | Anti-forgery; find + remove + save; redirect to Index |

## List Courses

Verified behavior:

1. Request reaches `CoursesController.Index()`.
2. Controller loads all courses via `db.Courses.ToList()`.
3. `Views/Courses/Index.cshtml` renders a table with:
   - `Title`
   - `Credits`
   - action links per row (`Edit`, `Details`, `Delete`).
4. View also provides `Create New` link to `Create`.

No paging, filtering, or sorting behavior is present in reviewed files.

## View Course Details

Verified behavior:

1. `Details(int? id)` checks `id`:
   - null => `HttpStatusCode.BadRequest` (400).
2. Loads entity via `db.Courses.Find(id)`.
3. If null => `HttpNotFound()` (404).
4. If found => `Views/Courses/Details.cshtml` displays `Title` and `Credits`.
5. View contains links to `Edit` (current item) and `Back to List`.

## Create Course

Verified behavior:

1. GET `Create()` returns `Views/Courses/Create.cshtml`.
2. Form is posted back with default `Html.BeginForm()` target (same controller/action).
3. View emits anti-forgery token via `@Html.AntiForgeryToken()`.
4. POST `Create(...)` is protected by `[HttpPost]` + `[ValidateAntiForgeryToken]`.
5. Binding is limited via `[Bind(Include = "CourseId,Title,Credits")]`.
6. If `ModelState.IsValid`:
   - `db.Courses.Add(course)`
   - `db.SaveChanges()`
   - redirect to `Index`
7. If invalid:
   - same view is returned with validation summary/messages.

## Edit Course

Verified behavior:

1. GET `Edit(int? id)` validates id and loads course using `Find`.
2. Null id => 400; missing course => 404.
3. View includes:
   - hidden `CourseId`
   - editable `Title` and `Credits`
   - anti-forgery token.
4. POST `Edit(...)` uses `[HttpPost]` + `[ValidateAntiForgeryToken]` and same `[Bind(...)]`.
5. If valid:
   - `db.Entry(course).State = EntityState.Modified`
   - `db.SaveChanges()`
   - redirect to `Index`
6. If invalid:
   - returns edit view with model + validation UI.

## Delete Course

Verified behavior:

1. GET `Delete(int? id)` validates id and loads course.
2. Null id => 400; missing course => 404.
3. `Delete.cshtml` shows a confirmation screen with `Title` and `Credits`.
4. Confirmation form posts back with anti-forgery token.
5. POST action (`DeleteConfirmed`, mapped as action name `"Delete"`) executes:
   - `Course course = db.Courses.Find(id);`
   - `db.Courses.Remove(course);`
   - `db.SaveChanges();`
   - redirect to `Index`.

Notable verified implementation detail: `DeleteConfirmed` does **not** perform an explicit null check after `Find(id)`.

## Data Model and Database Mapping

Verified from reviewed files:

- `Course` entity (`Models/Course.cs`) contains:
  - `int CourseId`
  - `string Title`
  - `int Credits`
  - navigation property `ICollection<Enrollment> Enrollments`.
- Context (`SchoolManagement_DBEntities`) is EF6 `DbContext` using connection string name `"SchoolManagement_DBEntities"`.
- `OnModelCreating` throws `UnintentionalCodeFirstException`, indicating Database-First generated model usage.
- `DbSet<Course> Courses` is present.

Assumption (not directly verified in reviewed files): exact SQL table/column names and DB constraints depend on EDMX metadata / database schema not included in this review set.

## Validation and Anti-Forgery Behavior

Verified:

- Anti-forgery token is emitted in `Create`, `Edit`, and `Delete` forms.
- `[ValidateAntiForgeryToken]` is present on all corresponding POST actions.
- `ModelState.IsValid` gates create/update persistence.
- Overposting mitigation is attempted via `[Bind(Include = "CourseId,Title,Credits")]`.

Unknowns from reviewed files:

- No explicit data annotation attributes are visible on `Course` properties in the generated partial class.  
  Effective required/range/string constraints may come from metadata classes, EF model configuration, or DB constraints not reviewed here.

## Authorization Behavior

Verified:

- `[Authorize]` is applied at `CoursesController` class level.
- All reviewed course CRUD actions require an authenticated user.
- No role-specific restriction attributes (e.g., admin-only) are present on these actions.

## Current-State Review Concerns

Verified concern:

1. `DeleteConfirmed(int id)` does not null-check the result of `db.Courses.Find(id)` before `Remove(course)`.  
   Potential outcome: runtime exception if record is already removed or id is invalid at POST time.

Contextual concern (requires broader repo confirmation):

2. Course controller enforces authentication, but role-based authorization granularity is not visible in this controller.
3. Controller directly constructs and owns EF context (`new SchoolManagement_DBEntities()`), which is common legacy MVC practice but reduces testability.

## Modernization Notes for Later

These are incremental observations for future planning (not rewrite recommendations):

- Preserve current route shapes and status code behaviors (400/404 patterns) during migration.
- Preserve anti-forgery coverage on all mutating course actions.
- Preserve `[Authorize]` protection baseline and review whether role policies are needed.
- Preserve overposting protections when moving model binding patterns.
- Account for EF6 Database-First dependencies (`UnintentionalCodeFirstException` pattern) in data-layer migration planning.

## Assumptions and Unknowns

### Verified
- CRUD flow and action/view wiring described above are present in reviewed files.
- Anti-forgery and authentication behavior described above is explicitly implemented.

### Assumptions / Unknowns
- Exact database schema constraints (e.g., `Title` nullability, length limits) are not verified from reviewed files.
- No direct evidence in reviewed files for additional client-side validation rules beyond Razor helpers.
- No evidence in reviewed files for course-specific business rules beyond field capture and persistence.
- No evidence in reviewed files for concurrency handling (e.g., row version checks).

## Manual Validation Checklist

1. Authenticate as a valid user and navigate to `/Courses`.
2. Verify list page renders existing courses with `Title` and `Credits`.
3. Open a valid details URL and confirm fields render correctly.
4. Request details/edit/delete with missing `id` and verify HTTP 400 behavior.
5. Request details/edit/delete with non-existent `id` and verify HTTP 404 behavior.
6. Create a course with valid values; verify redirect to list and persisted row appears.
7. Submit create form with anti-forgery token removed/invalid; verify request is rejected.
8. Edit an existing course; verify updated values persist after redirect.
9. Delete an existing course via confirmation form; verify row is removed from list.
10. Attempt delete POST for already-removed/non-existent id to observe current error handling behavior.
11. Verify unauthenticated access to `/Courses/*` routes is blocked by authorization.