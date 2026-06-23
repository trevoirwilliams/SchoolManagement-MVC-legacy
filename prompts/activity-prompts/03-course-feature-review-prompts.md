# Prompt 1 — Ask AI to Identify the CRUD Workflow
You are reviewing the inherited SchoolManagement MVC application on branch 02-ai-review-setup.

Do not change any files.

Trace the Course Management CRUD workflow as it currently exists.

Use the attached repository context, especially:

- .github/copilot-instructions.md
- README.md
- SchoolManagement/App_Start/RouteConfig.cs
- SchoolManagement/Controllers/CoursesController.cs
- SchoolManagement/Models/Course.cs
- SchoolManagement/Models/SchoolManagementDBModel.Context.cs
- SchoolManagement/Views/Courses/*.cshtml

Produce a current-state workflow trace only. Do not recommend refactoring yet.

Output the result using this structure:

## Summary
## Affected Files
## Route and Action Map
## Read/List Flow
## Details Flow
## Create Flow
## Edit Flow
## Delete Flow
## Data Model and Persistence Flow
## Validation and Anti-Forgery Observations
## Authorization Observations
## Modernization Risks to Review Later
## Assumptions and Unknowns
## Manual Validation Steps


## Prompt 2 — Force Evidence-Based Verification
Review your workflow trace against the actual CoursesController and Courses views.

For each statement, identify the exact file that supports it.

Do not infer behavior that is not visible in the code.

Specifically verify:

- how the course list is loaded
- which fields are displayed on the Index view
- how Details handles a missing id
- how Details handles a missing course record
- which fields are displayed on the Details view

Return only verified findings and a short list of unknowns.

## Prompt 3 — Trace Create Request and Data Flow
Trace the Course create workflow from the Create Razor view to the database save.

Use only the current files. Do not suggest code changes.

Explain:

1. Which GET action renders the form.
2. Which POST action receives the form.
3. Which fields are rendered by the view.
4. Which fields are accepted by model binding.
5. Where anti-forgery protection appears.
6. Where ModelState is checked.
7. How the Course entity is added and persisted.
8. What the user sees after a successful create.
9. Any assumptions or concerns that should be reviewed later.

Keep the answer factual and evidence-based.

## Prompt 4 — Trace Edit Behavior and State Change

Trace the Course edit workflow.

Do not change code.

Explain the current behavior for:

- GET /Courses/Edit/{id}
- the Edit Razor form
- POST /Courses/Edit
- the role of the hidden CourseId field
- the bound fields
- anti-forgery validation
- ModelState validation
- EntityState.Modified
- SaveChanges
- redirect behavior

Also identify current-state review concerns, but do not propose a refactor yet.

## Prompt 5 — Trace Delete Confirmation and POST
Trace the Course delete workflow exactly as implemented.

Do not change code.

Explain:

1. Why there is a GET Delete action.
2. What the Delete view displays.
3. How the POST delete action is mapped with ActionName("Delete").
4. Where anti-forgery protection appears.
5. How the Course record is found and removed.
6. What happens after SaveChanges.
7. What risks or edge cases should be documented for later review.

Do not modernize or rewrite the workflow.

## Prompt 6 — Generate the Documentation Artifact

Create a Markdown documentation draft for:

docs/course-management-crud-trace.md

Document the current Course Management CRUD workflow in the inherited SchoolManagement MVC application.

Use this structure:

# Course Management CRUD Workflow Trace

## Scope

## Business Purpose

## Files Reviewed

## Route and Action Map

## List Courses

## View Course Details

## Create Course

## Edit Course

## Delete Course

## Data Model and Database Mapping

## Validation and Anti-Forgery Behavior

## Authorization Behavior

## Current-State Review Concerns

## Modernization Notes for Later

## Assumptions and Unknowns

## Manual Validation Checklist

Rules:

- Do not recommend rewriting the application.
- Do not claim behavior unless it is supported by the attached files.
- Clearly separate verified behavior from assumptions.
- Keep the tone professional and suitable for an engineering review package.
