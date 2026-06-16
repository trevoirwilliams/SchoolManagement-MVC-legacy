# Prompt 01: Baseline Assessment

Use this prompt before making any modernization changes.

```text
Assess this inherited ASP.NET Framework MVC application for modernization to ASP.NET Core MVC on .NET 10.

Do not modify files yet.

Focus on:
- solution and project structure
- target framework and project format
- packages.config dependencies
- System.Web usage
- Global.asax startup behavior
- RouteConfig, FilterConfig, and BundleConfig
- OWIN startup and account workflow behavior
- ASP.NET Identity 2 usage
- EF6 Database First and EDMX-generated code
- Web.config configuration
- controllers, Razor views, and JSON endpoints
- authorization and anti-forgery coverage
- build and validation risks

Return:
1. Executive summary
2. Affected files and folders
3. Modernization blockers
4. Package and dependency risks
5. Data access risks
6. Account and role workflow risks
7. UI and static asset risks
8. Recommended migration sequence
9. Validation plan
10. Questions that require human confirmation
```

## Expected output

The response should separate required migration work from optional refactoring. It should not recommend a full rewrite unless a specific blocker makes incremental migration impractical.