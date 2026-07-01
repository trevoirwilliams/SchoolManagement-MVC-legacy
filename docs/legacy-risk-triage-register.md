## Summary

Consolidated legacy risk triage register for incremental modernization to ASP.NET Core MVC on .NET 10, using provided baseline docs plus controller/view code evidence.

## Affected Files

- `docs/baseline-assessment.md`
- `docs/codebase-summary.md`
- `docs/dependency-inventory.md`
- `docs/migration-validation-checklist.md`
- `docs/hidden-business-and-role-rules.md`
- `SchoolManagement/Controllers/StudentsController.cs`
- `SchoolManagement/Controllers/CoursesController.cs`
- `SchoolManagement/Controllers/LecturersController.cs`
- `SchoolManagement/Controllers/EnrollmentsController.cs`
- `SchoolManagement/Controllers/AccountController.cs`
- `SchoolManagement/Views/Account/Register.cshtml`
- `SchoolManagement/Startup.cs`
- `SchoolManagement/Models/AccountViewModels.cs`

## Findings

### 1) Technical Debt

| ID | Category | Affected Area | Finding | Evidence | Business Risk | Modernization Risk | Severity | Decision | Validation Required |
|---|---|---|---|---|---|---|---|---|---|
| TD-01 | Technical Debt | Data access architecture | Controllers directly instantiate EF6 context (`new SchoolManagement_DBEntities()`), creating tight coupling and limited testability. | `StudentsController.cs:17`, `CoursesController.cs:16`, `LecturersController.cs:16`, `EnrollmentsController.cs:16`; `docs/codebase-summary.md` (Data Access Pattern). | Slower change velocity; harder defect isolation. | Increases migration effort to DI-based ASP.NET Core patterns. | High | Validate during migration | Add controller-by-controller smoke tests before/after extracting context usage. |
| TD-02 | Technical Debt | Data model strategy | EDMX database-first generated model is a legacy blocker for Core migration planning. | `docs/baseline-assessment.md` (Data access questions); `docs/dependency-inventory.md` (EF6 consideration); `docs/codebase-summary.md` (EDMX auto-generated). | Schema behavior may be misunderstood during change. | High risk when moving to EF Core scaffolding/reverse-engineering. | High | Validate during migration | Confirm schema reproducibility from `database/create-schoolmanagement-db.sql`; compare generated entities with current runtime behavior. |
| TD-03 | Technical Debt | Documentation accuracy | Auth coverage in summary docs conflicts with current controller code (possible stale baseline assumptions). | `docs/codebase-summary.md` states auth on Lecturers/Enrollments; code shows no `[Authorize]` in `LecturersController.cs` and `EnrollmentsController.cs`. | Incorrect operational/security assumptions in planning. | Can cause wrong migration backlog prioritization. | Medium | Fix now | Reconcile docs with code and re-baseline security/access section. |

### 2) Security and Access Control

| ID | Category | Affected Area | Finding | Evidence | Business Risk | Modernization Risk | Severity | Decision | Validation Required |
|---|---|---|---|---|---|---|---|---|---|
| SEC-01 | Security and Access Control | Authorization coverage | `LecturersController` and `EnrollmentsController` are publicly routable (no `[Authorize]`). | `LecturersController.cs` class declaration; `EnrollmentsController.cs` class declaration; `docs/hidden-business-and-role-rules.md` (Verified role rules). | Unauthorized read/write on academic data. | Existing insecure behavior may be accidentally preserved in Core migration. | High | Fix now | Verify anonymous access behavior for `Lecturers/*`, `Enrollments/*` before and after minimal auth hardening. |
| SEC-02 | Security and Access Control | Role policy consistency | `StudentsController` is teacher-only, but `Index` is `[AllowAnonymous]`, creating inconsistent exposure of student data. | `StudentsController.cs:14` and `:20`; `docs/hidden-business-and-role-rules.md` (Inconsistent rules). | Potential privacy/compliance exposure. | Ambiguous target policy for migration mapping. | High | Validate during migration | Confirm intended anonymous visibility with stakeholders; document target policy matrix. |
| SEC-03 | Security and Access Control | Registration and role assignment | Registration allows user-selected role via posted `UserRole`; UI filters out admin roles but no explicit server-side whitelist enforcement. | `AccountController.cs:144`, `:169`; `Register.cshtml:48`; `AccountViewModels.cs:88-90`; `docs/hidden-business-and-role-rules.md`. | Role escalation risk via payload tampering. | Harder to securely port account flow to ASP.NET Core Identity. | High | Fix now | Attempt role tampering in registration POST; confirm server rejects unauthorized role assignment. |
| SEC-04 | Security and Access Control | CSRF protection | Enrollment AJAX POST endpoints lack `[ValidateAntiForgeryToken]` (`AddStudent`, `GetStudents`). | `EnrollmentsController.cs:77-95`, `:160-168`; `docs/hidden-business-and-role-rules.md` (Known enforcement gaps). | CSRF risk on enrollment changes/search endpoints. | Security gap can be carried forward if not explicitly tracked. | High | Fix now | Add anti-forgery tests for AJAX POSTs; verify expected 400 on invalid token. |
| SEC-05 | Security and Access Control | Identifier consistency in recovery flow | Forgot/reset password actions call `FindByNameAsync(model.Email)` while login uses `Username`; identifier semantics are mixed. | `AccountController.cs:80`, `:211`, `:257`; `AccountViewModels.cs` (separate `Username` and `Email`). | Account recovery confusion/support incidents. | Identity migration mapping risk (username vs email policies). | Medium | Validate during migration | Execute login/forgot/reset scenarios using distinct username/email combinations; document intended rule. |

### 3) Dependency and Modernization Readiness

| ID | Category | Affected Area | Finding | Evidence | Business Risk | Modernization Risk | Severity | Decision | Validation Required |
|---|---|---|---|---|---|---|---|---|---|
| DEP-01 | Dependency and Modernization Readiness | Package management | Project remains on `packages.config` legacy dependency model. | `docs/baseline-assessment.md` (Done); `docs/dependency-inventory.md` (Package management model). | Slower dependency governance and vulnerability response. | Additional conversion step before/with SDK-style modernization phases. | Medium | Validate during migration | Capture restore/build baseline and package inventory diffs per checkpoint. |
| DEP-02 | Dependency and Modernization Readiness | Framework stack compatibility | Core platform dependencies are ASP.NET MVC 5, OWIN/Katana, ASP.NET Identity 2, EF6 EDMX—non-native to ASP.NET Core MVC on .NET 10. | `docs/codebase-summary.md` baseline/dependencies; `docs/dependency-inventory.md` key backend packages. | Legacy stack prolongs unsupported patterns. | High cross-cutting migration complexity. | High | Defer | Stage migration by vertical slices (auth, data, UI), validate each stage with checklist evidence. |
| DEP-03 | Dependency and Modernization Readiness | Frontend/static asset pipeline | Bootstrap 3, jQuery-era libraries, Web Optimization bundling remain baseline dependencies. | `docs/codebase-summary.md` (UI/static assets); `docs/dependency-inventory.md` (frontend packages). | UI regressions if changed too early. | Asset pipeline changes can destabilize migration if bundled with backend porting. | Medium | Accept temporarily | Keep assets stable in first migration pass; validate view rendering and script load parity. |
| DEP-04 | Dependency and Modernization Readiness | Configuration model | `web.config`-centric settings/connection strings and binding redirects still drive runtime config. | `docs/codebase-summary.md` (Web.config section); `docs/dependency-inventory.md` (configuration dependencies). | Environment drift and deployment fragility. | Requires careful mapping to Core configuration system. | High | Validate during migration | Build a setting-by-setting mapping matrix to `appsettings.*` and environment variables before cutover. |

### 4) Validation Gaps

| ID | Category | Affected Area | Finding | Evidence | Business Risk | Modernization Risk | Severity | Decision | Validation Required |
|---|---|---|---|---|---|---|---|---|---|
| VAL-01 | Validation Gaps | Baseline execution evidence | Baseline validation checklist is largely `Not started` (restore, build, run, workflows). | `docs/migration-validation-checklist.md` (Baseline validation). | Unknown current behavior increases release risk. | No trustworthy pre/post comparison for incremental migration. | High | Fix now | Produce baseline evidence: restore/build output, app launch, CRUD workflow notes/screenshots. |
| VAL-02 | Validation Gaps | Dependency readiness evidence | Dependency review checklist remains `Not started`. | `docs/dependency-inventory.md` (Review checklist). | Blind spots on incompatible/vulnerable packages. | Late discovery of blockers during migration. | Medium | Fix now | Complete package restore, compatibility categorization, vulnerability scan, and decision log updates. |
| VAL-03 | Validation Gaps | Security behavior validation | Hidden role/access validation checklist items are unchecked (anonymous behavior, role tampering, anti-forgery on AJAX). | `docs/hidden-business-and-role-rules.md` (Manual Validation Checklist). | Undetected access control issues in production-like flows. | Security defects can be preserved into Core baseline. | High | Fix now | Execute checklist scenarios and record pass/fail evidence per endpoint. |
| VAL-04 | Validation Gaps | Business-rule decisions | Multiple modernization decision points remain unresolved (role matrix, anonymous access intent, duplicate enrollment rules, grade rules). | `docs/hidden-business-and-role-rules.md` (Modernization Decision Points, stakeholder questions). | Business behavior may change unintentionally. | Blocks safe, incremental migration sequencing. | High | Validate during migration | Run stakeholder decision workshop; log approved rules before touching affected areas. |

## Required Decisions

1. Final role-permission matrix for `Admin`, `Teacher`, `Supervisor`.
2. Whether anonymous access to students/lecturers/enrollments is acceptable.
3. Whether user self-selected role assignment remains allowed.
4. Whether duplicate enrollment prevention must be DB-enforced.
5. Username vs email canonical identifier for recovery/login workflows.

## Suggested Next Steps

1. Close **Fix now** items first: `SEC-01`, `SEC-03`, `SEC-04`, `VAL-01`, `VAL-02`, `VAL-03`, `TD-03`.
2. Re-baseline docs after security/auth coverage is verified in code.
3. Use checkpoint-based incremental migration (no rewrite), preserving behavior with explicit validation evidence at each step.

## Validation Plan

- Use `docs/migration-validation-checklist.md` as gate criteria per checkpoint.
- Add targeted security verification for:
  - anonymous endpoint reachability,
  - registration role tampering attempts,
  - anti-forgery on AJAX POST endpoints.
- Record branch, commit SHA, files changed, build result, workflow results, and rollback notes per checkpoint.
