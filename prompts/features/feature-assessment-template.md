Review the [FEATURE NAME] workflow in the SchoolManagement Legacy MVC application.

The application is an inherited ASP.NET MVC 5 application stabilized on .NET Framework 4.8. 

It uses EF6 Database First with an EDMX model, ASP.NET Identity 2, OWIN/Katana authentication, Web.config configuration, packages.config dependency management, IIS Express, and SQL Server LocalDB.

Do not modify files. Do not generate code changes. Do not recommend a full rewrite unless a specific blocker is identified. Do not silently change business behavior. Separate required migration work from optional refactoring. Identify assumptions instead of presenting them as facts. Flag security-sensitive behavior that requires human review.

Review these files and folders:

- [file or folder 1]
- [file or folder 2]
- [file or folder 3]
- [file or folder 4]

Focus on:

- current feature behavior
- controller actions
- Razor views
- model binding and validation
- EF6 data access
- authorization behavior
- anti-forgery behavior
- JSON or AJAX behavior, if present
- Web.config or database assumptions, if relevant
- behavior-preservation requirements

For each finding, include:

- affected file or folder
- affected controller/action/view/model where applicable
- observed behavior or code evidence
- risk level
- why the risk matters
- recommendation
- validation step
- whether human confirmation is required

Return the result using this structure:

## Summary

## Feature Scope

## Affected Files

## Findings

| Area | Finding | Evidence | Risk | Recommendation | Validation |
|---|---|---|---|---|---|

## Required Human Decisions

## Suggested Next Steps

## Validation Checklist

If a finding is uncertain, mark it as Assumption or Needs Review.