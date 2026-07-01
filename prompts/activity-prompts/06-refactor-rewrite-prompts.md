## Prompt 1 — Ask for a seam, no code changes

Using the current repository context, review these files:

- README.md
- docs/baseline-assessment.md
- docs/business-rules-and-risks.md
- docs/modernization-path.md
- SchoolManagement/Controllers/EnrollmentsController.cs
- SchoolManagement/Views/Enrollments/Create.cshtml

Find one small refactoring seam in EnrollmentsController.cs that improves readability without changing observable behavior.

Do not rewrite the controller.
Do not change authorization, anti-forgery behavior, routes, EF6 data access strategy, JSON property names, or response message text.
Do not edit generated EF EDMX model files.

Return only:
1. The recommended seam
2. Why it is safe
3. Files affected
4. Risks to watch during review

## Prompt 2 — Apply the narrow change
In EnrollmentsController.cs, apply only this refactor:

Extract the repeated SelectList population for CourseID, StudentID, and LecturerId into a private method named PopulateDropdowns.

Use this method signature:

private void PopulateDropdowns(Enrollment enrollment = null)

Preserve behavior exactly:
- Keep the same ViewBag keys: CourseID, StudentID, LecturerId.
- Keep the same SelectList value and text fields:
  - Courses: "CourseId", "Title"
  - Students: "StudentID", "LastName"
  - Lecturers: "Id", "First_Name"
- Use selected values from enrollment when enrollment is provided.
- Use no selected value when enrollment is null.
- Replace only the duplicated dropdown setup blocks.
- Do not edit generated EDMX model files.

## Prompt 3 - Ask AI to Plan a fix for the Feature First
Review the account registration and role assignment workflow.

Inspect these files:
- SchoolManagement/Controllers/AccountController.cs
- SchoolManagement/Models/AccountViewModels.cs
- SchoolManagement/Views/Account/Register.cshtml
- docs/business-rules-and-risks.md

Do not modify files yet.
Generate a plan to implement a fix for all the issues that have been identified, including a timeline and any dependencies.

Return:
1. Current registration flow
2. Where role selection enters the request
3. Where role assignment happens
4. Why user-selected roles are risky
5. Minimal rewrite options
6. Tests that should exist before or after the rewrite
7. Files likely affected

