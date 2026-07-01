# Prompt 08: High-Quality Review Prompt

Use this prompt when you need an evidence-backed review of the SchoolManagement Legacy MVC application before code changes are made.

```text
Assess this inherited ASP.NET Framework MVC application for modernization readiness.

The modernization target is ASP.NET Core MVC on .NET 10.

Do not modify files. Do not generate code changes. Do not recommend a full rewrite unless you identify a specific blocker. Do not silently change business behavior. Separate required migration work from optional refactoring. Flag security-sensitive workflows that require human review.

Focus on:

- solution and project structure
- Web.config
- packages.config
- Startup.cs
- App_Start/Startup.Auth.cs
- App_Start/IdentityConfig.cs
- App_Start/RouteConfig.cs
- App_Start/BundleConfig.cs
- App_Start/FilterConfig.cs
- EF6 EDMX files and generated model classes
- MVC controllers
- Razor views
- JSON endpoints
- authorization attributes
- anti-forgery validation
- database assumptions
- build and runtime validation evidence

Return the result using this structure:

## Summary

## Affected Files and Folders

## Findings

Use this table:

| Area | Finding | Evidence | Risk | Recommendation | Validation |
|---|---|---|---|---|---|

## Modernization Blockers

## Required Business Decisions

## Suggested Next Steps

## Validation Plan

For every finding, name the affected file or folder. If you are uncertain, state the assumption instead of presenting it as fact.
````

## Expected Output

The response should be evidence-backed, file-specific, and suitable for use as a baseline review artifact. It should not include code changes.

````
