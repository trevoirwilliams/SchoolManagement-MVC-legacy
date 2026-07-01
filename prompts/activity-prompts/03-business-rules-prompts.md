## Prompt 1 - Get Initial Business Rule Inventory
You are reviewing the inherited SchoolManagement MVC application.

Do not change any files.

Identify hidden business rules and role rules in the current application.

Focus especially on:

- Enrollment behavior
- student-course assignment rules
- duplicate enrollment checks
- course, student, lecturer, and enrollment relationships
- user registration and role assignment
- controller authorization attributes
- anonymous access rules
- AJAX and JSON endpoints
- navigation links and visible workflows

Use these files as primary evidence:

- docs/business-rules-and-risks.md
- SchoolManagement/Startup.cs
- SchoolManagement/Controllers/AccountController.cs
- SchoolManagement/Controllers/StudentsController.cs
- SchoolManagement/Controllers/CoursesController.cs
- SchoolManagement/Controllers/LecturersController.cs
- SchoolManagement/Controllers/EnrollmentsController.cs
- SchoolManagement/Views/Account/Register.cshtml
- SchoolManagement/Views/Shared/_Layout.cshtml
- SchoolManagement/Views/Enrollments/Create.cshtml
- SchoolManagement/Views/Enrollments/_enrollmentPartial.cshtml
- SchoolManagement/Models/Enrollment.cs
- SchoolManagement/Models/SchoolManagementDBModel.Context.cs
- database/create-schoolmanagement-db.sql

Return the result using this structure:

## Summary
## Verified Business Rules
## Inferred Business Rules
## Verified Role Rules
## Inconsistent or Unclear Rules
## Security-Sensitive Rules
## Rules Requiring Business Confirmation
## Rules Requiring Security Review
## Manual Validation Steps

Important rules:

- Do not propose fixes.
- Do not modernize the code.
- Do not treat assumptions as facts.
- For each rule, identify the file or behavior that supports it.


## Prompt 2 — Focus on Enrollment Business Rules

Review the Enrollment feature and identify hidden business rules.

Do not change code.

Use:

- EnrollmentsController.cs
- Views/Enrollments/Create.cshtml
- Views/Enrollments/_enrollmentPartial.cshtml
- Models/Enrollment.cs
- Models/SchoolManagementDBModel.Context.cs
- database/create-schoolmanagement-db.sql

Create a table:

| Rule ID | Rule Type | Rule Statement | Verified Evidence | Assumption or Unknown | Review Priority |

Focus on:

- how students are assigned to courses
- whether duplicate enrollments are allowed
- whether a lecturer is required
- whether a grade is required
- how selected course controls the enrollment list
- how selected student is captured
- how related Course, Student, and Lecturer data is displayed
- how database constraints affect the rule
- how cascade delete may affect business behavior

Do not recommend fixes yet.

## Prompt 3 — Identify Role Rules and Authorization Behavior
Identify the current role rules and authorization behavior in the application.

Do not change code.

Use:

- Startup.cs
- AccountController.cs
- StudentsController.cs
- CoursesController.cs
- LecturersController.cs
- EnrollmentsController.cs
- Views/Account/Register.cshtml
- Views/Shared/_Layout.cshtml
- docs/business-rules-and-risks.md

Create a table:

| Area | Current Access Behavior | Role or Attribute Evidence | Business Meaning | Concern or Unknown |

Focus on:

- which role names exist
- where roles are created
- whether users can select roles during registration
- which controllers require authentication
- which controllers require a specific role
- which actions allow anonymous access
- which controllers appear to have no visible authorization attribute
- where navigation exposes application areas
- which access rules need confirmation before modernization

Do not recommend fixes. Document current behavior and questions only.

## Prompt 4 — Separate Verified Rules from Assumptions
Review the business and role rules identified so far.

Separate them into three categories:

1. Verified by code
2. Inferred from code but requiring confirmation
3. Unknown or not supported by current code

Use this table:

| Rule Statement | Category | Evidence | Why It Matters | Question to Resolve |

Rules:

- If the rule is not directly supported by code, do not mark it verified.
- If the rule depends on business intent, mark it as requiring confirmation.
- If the rule affects security, mark it as requiring security review.
- Do not recommend fixes.

## Prompt 5 — Generate a Business and Role Rules Document
Create a Markdown documentation draft for:

docs/hidden-business-and-role-rules.md

Document the hidden business and role rules identified in the current SchoolManagement MVC application.

Use this structure:

# Hidden Business and Role Rules

## Scope

## Review Method

## Files Reviewed

## Rule Classification

## Verified Business Rules

## Inferred Business Rules Requiring Confirmation

## Verified Role and Access Rules

## Inconsistent or Unclear Role Rules

## Enrollment-Specific Rules

## Security-Sensitive Rules

## Modernization Decision Points

## Questions for Business Stakeholders

## Questions for Security Review

## Manual Validation Checklist

Rules:

- Do not propose code changes.
- Do not modernize the implementation.
- Do not treat assumptions as verified facts.
- Clearly separate current behavior, inferred rules, and unknowns.
- Keep the tone suitable for an internal engineering review document.
