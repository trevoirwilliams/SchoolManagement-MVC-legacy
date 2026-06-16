# Prompt 03: Modernization Plan

Use this prompt after the baseline assessment and dependency inventory are complete.

```text
Create an incremental modernization plan for this ASP.NET Framework MVC 5 application.

Target state: ASP.NET Core MVC on .NET 10.

Do not modify files yet.

Use the existing repository structure and current application behavior as the baseline.

Plan the migration in phases:
1. Baseline verification
2. .NET Framework 4.8 stabilization
3. SDK-style and dependency planning
4. ASP.NET Core MVC application shell
5. Routing, filters, layout, and static assets
6. Controller and Razor view migration by vertical slice
7. EF6 EDMX data access strategy
8. Account and role workflow strategy
9. Validation and pull request preparation

For each phase, include:
- goal
- affected files
- expected changes
- risks
- validation steps
- stop conditions
- rollback notes

Separate required migration tasks from optional cleanup tasks.
```

## Expected output

The response should create a practical migration sequence that can be reviewed before execution. It should not combine unrelated changes into one large rewrite.