## Prompt 1 — Ask AI to Trace the Enrollment Workflow

You are reviewing the inherited SchoolManagement MVC application.

Do not change any files.

Trace the Enrollment feature as a cross-cutting workflow.

Focus on how the feature spans:

- EnrollmentsController
- Enrollment model
- Course model
- Student model
- Lecturer model
- SchoolManagement_DBEntities
- Enrollments Razor views
- AJAX form submission
- student autocomplete
- partial view refresh
- database relationships

Use these files as primary evidence:

- SchoolManagement/Controllers/EnrollmentsController.cs
- SchoolManagement/Models/Enrollment.cs
- SchoolManagement/Models/Course.cs
- SchoolManagement/Models/Student.cs
- SchoolManagement/Models/Lecturer.cs
- SchoolManagement/Models/SchoolManagementDBModel.Context.cs
- SchoolManagement/Views/Enrollments/Index.cshtml
- SchoolManagement/Views/Enrollments/Create.cshtml
- SchoolManagement/Views/Enrollments/Edit.cshtml
- SchoolManagement/Views/Enrollments/Delete.cshtml
- SchoolManagement/Views/Enrollments/_enrollmentPartial.cshtml
- database/create-schoolmanagement-db.sql
- .github/copilot-instructions.md

Return the trace using this structure:

## Summary
## Why This Is a Cross-Cutting Workflow
## Files Involved
## Main Enrollment List Flow
## Create Page Setup Flow
## Student Autocomplete Flow
## AJAX Add Student Flow
## Partial Enrollment List Refresh Flow
## Edit and Delete Flow
## Data Model and EF6 Relationship Flow
## Database Relationship Flow
## Validation and Anti-Forgery Observations
## Authorization Observations
## Error-Handling Observations
## Modernization-Relevant Observations
## Assumptions and Unknowns
## Manual Validation Steps

Important rules:

- Do not propose code changes.
- Do not modernize the feature.
- Do not infer business rules that are not visible in code.
- Separate verified behavior from assumptions.
- Mark review concerns clearly, but do not fix them yet.


## Prompt 2 — Verify the List Flow

Trace the Enrollment Index flow.

Do not change files.

Explain:

- which controller action handles the main enrollment list
- which related entities are included
- which fields the Index view displays
- which navigation properties are used by the view
- which action links are available from the list
- why this list is cross-cutting instead of a single-table display

Return only verified current behavior and note any assumptions separately.

## Prompt 3 — Trace the Create Page Setup

Trace the Enrollment Create page setup.

Do not change code.

Use EnrollmentsController.cs and Views/Enrollments/Create.cshtml.

Explain:

- which action renders the Create page
- which ViewBag select lists are populated
- which dropdown or input controls the view actually renders
- how CourseID is selected
- how the student is searched and selected
- how StudentID is stored
- which form helper is used
- which action receives the submitted form
- how this differs from a standard full-page MVC Create POST

Separate verified behavior from review concerns.

## Prompt 4 — Trace Student Autocomplete

Trace the student autocomplete workflow in the Enrollment Create screen.

Do not change files.

Use Create.cshtml and EnrollmentsController.cs.

Explain:

- which input has autocomplete behavior
- which URL is called
- which HTTP method is used
- which request value is sent
- how GetStudents queries student data
- what shape of JSON is returned
- how the selected student ID is stored
- what happens if no student is selected
- what security, validation, or performance concerns should be reviewed later

Do not propose fixes yet.

## Prompt 5 — Trace AddStudent End to End

Trace the AJAX AddStudent enrollment workflow end to end.

Do not change code.

Use:

- Views/Enrollments/Create.cshtml
- Controllers/EnrollmentsController.cs
- Models/Enrollment.cs
- Models/SchoolManagementDBModel.Context.cs

Explain:

- which form submits the request
- which action receives the request
- which Enrollment properties are bound
- how duplicate enrollment is checked
- when a new Enrollment is added
- when SaveChangesAsync is called
- what JSON is returned on success
- what JSON is returned when the student is already enrolled
- what JSON is returned on exception
- how the client-side Added, Failed, and Failure functions respond
- how the partial enrollment list is refreshed after success

Do not refactor. Document current behavior only.

## Prompt 6 — Trace Partial View Refresh

Trace the partial enrollment list refresh behavior.

Do not change code.

Use Create.cshtml, EnrollmentsController.cs, and _enrollmentPartial.cshtml.

Explain:

- when LoadEnrollments is called
- which endpoint it calls
- which parameter it sends
- how the controller filters enrollments
- which related entities are included
- what the partial view displays when there are no enrollments
- what the partial view displays when enrollments exist
- how the partial is refreshed after a student is added
- what assumptions or risks should be documented for later review


## Prompt 7 — Trace Data Relationships

Trace the Enrollment data model and database relationship flow.

Do not change files.

Use:

- Models/Enrollment.cs
- Models/Course.cs
- Models/Student.cs
- Models/Lecturer.cs
- Models/SchoolManagementDBModel.Context.cs
- database/create-schoolmanagement-db.sql

Explain:

- Enrollment scalar properties
- Enrollment navigation properties
- which DbSet properties expose the related entities
- which database table stores enrollments
- which foreign keys connect Enrollment to Course, Student, and Lecturer
- whether CourseID, StudentID, and LecturerId are required or nullable in the database
- how cascade delete is configured in the SQL script
- which relationship assumptions should be reviewed before modernization

Return verified facts and assumptions separately.

## Prompt 8 — Trace Edit and Delete

Trace the Enrollment Edit and Delete workflows.

Do not change code.

Use EnrollmentsController.cs, Edit.cshtml, and Delete.cshtml.

Explain:

- how GET Edit loads the enrollment
- which select lists are rebuilt for Edit
- which fields the Edit view posts
- how POST Edit saves changes
- how GET Delete loads the enrollment
- which related fields the Delete view displays
- how POST DeleteConfirmed removes the enrollment
- where anti-forgery protection appears
- what null, relationship, or validation concerns should be documented for later review

Keep this current-state only.

## Prompt 9 — Review Security, Authorization, and Validation Observations

Review the Enrollment workflow trace for security, authorization, validation, and modernization-sensitive concerns.

Do not change code.

Focus on:

- controller authorization coverage
- AJAX POST endpoints
- anti-forgery usage
- model binding includes
- duplicate enrollment checks
- JSON endpoints
- student search behavior
- error handling
- direct DbContext usage
- EF6 generated entities
- cascade delete behavior
- hidden field usage
- business rules that are unclear

Return a table:

| Area | Verified Current Behavior | Review Concern | Evidence File | Later Review Action |

Do not recommend immediate fixes. This is a documentation and review-planning step only.


## Demo Step 10 — Generate the Final Workflow Trace Document

Create a Markdown documentation draft for:

docs/enrollment-feature-trace.md

Document the current Enrollment workflow in the inherited SchoolManagement MVC application.

Use this structure:

# Enrollment Cross-Cutting Workflow Trace

## Scope

## Why This Workflow Is Cross-Cutting

## Files Reviewed

## Main Enrollment List Flow

## Create Page Setup Flow

## Student Autocomplete Flow

## AJAX Add Student Flow

## Partial Enrollment List Refresh Flow

## Edit Flow

## Delete Flow

## EF6 Model and Navigation Properties

## Database Relationship Flow

## Validation and Anti-Forgery Observations

## Authorization Observations

## Error-Handling Observations

## Modernization-Relevant Observations

## Assumptions and Unknowns

## Manual Validation Checklist

Rules:

- Do not propose code changes.
- Do not convert anything to ASP.NET Core.
- Do not infer business rules that are not visible in code.
- Clearly separate verified behavior from assumptions and review concerns.
- Mark AJAX, authorization, anti-forgery, hidden-field, and cascade-delete behavior as areas for later review.
- Keep the tone suitable for an internal engineering review document.
