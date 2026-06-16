# Copilot Instructions for SchoolManagement Legacy MVC

Use these instructions whenever assessing, documenting, refactoring, or modernizing this repository.

## Primary objective

Modernize the inherited ASP.NET Framework MVC application safely and incrementally. Preserve current business behavior unless a change is explicitly approved and documented.

## Application context

SchoolManagement supports school administration workflows for students, lecturers, courses, enrollments, authentication, and role-based staff access.

## Current baseline

- ASP.NET MVC 5 on .NET Framework 4.6.1
- EF6 Database First with EDMX-generated entities
- ASP.NET Identity 2 with OWIN/Katana authentication
- `web.config`, `Global.asax`, `RouteConfig`, `FilterConfig`, and `BundleConfig`
- `packages.config` dependency management
- LocalDB SQL Server connection strings
- Razor views with Bootstrap 3 and jQuery-era assets

## Target direction

The intended modernization target is ASP.NET Core MVC on .NET 10.

Before proposing changes, assess:

- project format and target framework
- package and dependency compatibility
- System.Web usage
- MVC controllers, filters, routes, and Razor views
- EF6 EDMX and data access risks
- Identity/OWIN authentication migration risks
- authorization and anti-forgery gaps
- configuration and connection string migration
- static asset and bundling migration
- build and validation requirements

## Response rules

When asked to analyze or change code:

1. State the affected files.
2. Explain the risk being addressed.
3. Prefer the smallest safe change.
4. Avoid broad rewrites unless explicitly requested.
5. Do not silently change business behavior.
6. Identify assumptions and missing information.
7. Separate modernization blockers from optional improvements.
8. Include validation steps.
9. Include rollback guidance for risky changes.
10. Flag any security-sensitive workflow that needs human review.

## Modernization safety rules

- Do not remove authentication or authorization checks without replacing them with an equivalent or stronger policy.
- Do not remove anti-forgery validation from form POST actions.
- Do not migrate EF6 EDMX code by hand without documenting data model assumptions.
- Do not replace OWIN/ASP.NET Identity behavior without documenting login, registration, role, password reset, and external provider implications.
- Do not remove `web.config` settings until their ASP.NET Core equivalents are identified.
- Do not convert views blindly. Preserve route names, form posts, validation summaries, and layout behavior.
- Do not assume LocalDB is production-ready.
- Do not assume all users should self-select roles during registration.

## Preferred output format for assessments

Use this structure:

```markdown
## Summary

## Affected Files

## Findings

| Area | Finding | Risk | Recommendation |
|---|---|---|---|

## Required Decisions

## Suggested Next Steps

## Validation Plan
```

## Preferred output format for code changes

Use this structure:

```markdown
## Change Summary

## Files Changed

## Behavior Preserved

## Risks Reduced

## Validation Performed

## Follow-up Work
```