# Modernization Path

This document defines the recommended modernization path for SchoolManagement Legacy MVC.

## Target state

The target state is ASP.NET Core MVC on .NET 10 with a reviewed and validated migration of the inherited ASP.NET MVC 5 application.

## Guiding principles

1. Assess before changing code.
2. Preserve current business behavior until a change is approved.
3. Prefer incremental, reviewable changes.
4. Separate required migration work from optional cleanup.
5. Capture build and validation evidence at every checkpoint.
6. Keep access control, data access, and configuration decisions explicit.

## Recommended phases

### Phase 1: Baseline verification

- Restore packages.
- Build the current solution.
- Run the application locally.
- Verify LocalDB connection strings.
- Walk through core workflows.
- Capture baseline notes.
- Document known build or runtime issues.

### Phase 2: Legacy baseline stabilization

- Review the current .NET Framework 4.6.1 target.
- Move to .NET Framework 4.8 where practical before the ASP.NET Core migration.
- Keep MVC 5, EF6, OWIN, and `packages.config` in place during this step.
- Validate that the application still builds and runs.

### Phase 3: AI-assisted assessment

Use GitHub Copilot modernization to assess the solution. Review the generated assessment before accepting a plan.

Assessment should cover:

- project format
- target framework
- package compatibility
- System.Web dependencies
- MVC controllers and views
- EF6 EDMX data access
- OWIN startup configuration
- routing and filters
- bundling and static assets
- configuration migration
- testing and validation gaps

### Phase 4: Migration planning

Review and edit the generated modernization artifacts before execution.

Expected artifacts may include:

- `.github/upgrades/{scenarioId}/assessment.md`
- `.github/upgrades/{scenarioId}/upgrade-options.md`
- `.github/upgrades/{scenarioId}/plan.md`
- `.github/upgrades/{scenarioId}/tasks.md`

Decide whether the migration is handled all at once or staged by concern.

### Phase 5: ASP.NET Core application shell

Create the ASP.NET Core MVC target project and migrate the application shell:

- Program startup
- appsettings configuration
- routing
- static files
- layout
- shared views
- dependency registration

### Phase 6: Controller and view migration

Migrate vertical slices in a controlled order:

1. Home and shared layout
2. Courses
3. Students
4. Lecturers
5. Enrollments
6. Account and management workflows

For each slice, validate routes, forms, view models, validation messages, redirects, and JSON behavior.

### Phase 7: Data access migration

Decide whether to:

- temporarily keep EF6 where possible,
- scaffold EF Core entities from the existing database,
- rebuild selected models manually,
- or split account data access from school-management data access.

Document the chosen approach before making data access changes.

### Phase 8: Account and role workflow migration

Map OWIN and ASP.NET Identity 2 behavior to ASP.NET Core equivalents.

Review:

- login
- registration
- roles
- account management
- external login placeholders
- authorization attributes
- anti-forgery behavior

### Phase 9: Validation and pull request preparation

Before merging modernization work, provide:

- build evidence
- restored package evidence
- manual workflow validation notes
- known limitations
- review notes
- data migration notes
- rollback guidance
- reviewer checklist

## Out of scope for the first modernization pass

Unless explicitly approved, do not include these in the first pass:

- complete UI redesign
- replacing MVC with Blazor
- replacing SQL Server with another database
- introducing microservices
- introducing cloud deployment automation
- changing domain behavior without a documented business decision