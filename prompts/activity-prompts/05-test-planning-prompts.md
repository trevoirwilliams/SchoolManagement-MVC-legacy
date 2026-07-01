## Prompt 1 - Ask AI for Test Ideas

You are helping plan tests for an inherited ASP.NET MVC legacy application.

Repository state:
- Application: SchoolManagement MVC legacy application
- Current platform: ASP.NET MVC on .NET Framework
- Modernization target: ASP.NET Core MVC on .NET 10

Important constraints:
- Do not write test code yet.
- Do not modify files yet.
- Do not refactor production code.
- Do not assume desired future behavior.
- Generate test ideas only.
- Separate observed behavior from assumptions.
- If a test idea depends on database setup, Identity setup, or MVC runtime hosting, say so clearly.

Review these areas:
- CoursesController
- StudentsController
- LecturersController
- EnrollmentsController
- AccountController
- Startup role creation
- Course, Student, Lecturer, and Enrollment models
- metadata classes
- docs/codebase-summary.md
- docs/business-rules-and-risks.md
- docs/baseline-assessment.md
- .github/copilot-instructions.md

Return a table with these columns:
1. Test Idea ID
2. Area
3. Behavior or risk to test
4. Evidence source
5. Suggested test type
6. Feasibility: Easy, Moderate, Hard, or Defer
7. Priority: High, Medium, or Low
8. Why this test matters for modernization
9. Assumption status: Observed, Partially observed, or Assumption to verify

Focus on:
- authorization attributes
- anonymous access
- role behavior
- model metadata validation
- MVC action result behavior
- Create/Edit/Delete POST behavior
- anti-forgery usage
- enrollment AJAX/JSON endpoints
- duplicate enrollment handling
- student search/autocomplete behavior
- EF6/EDMX generated entity risks
- route and view behavior that could change during ASP.NET Core migration

## Prompt 2 - Review the AI Ideas a Second Time

Review your test idea table as a skeptical senior .NET modernization reviewer.

Remove or mark any test idea that is:
- speculative,
- not supported by the current code,
- too broad,
- too coupled to implementation details,
- too expensive for a first test pass,
- better handled as a manual verification item,
- describing desired future behavior instead of current baseline behavior.

Pay special attention to authorization, anti-forgery, Identity, EF6 Database First/EDMX, and MVC runtime dependencies.

Return a revised list grouped into:
1. Implement now
2. Implement after test infrastructure exists
3. Defer or manual verification

# Prompt 3 - Add a Legacy-Compatible MSTest Project

You are helping add the first test baseline to an inherited ASP.NET MVC legacy application.

Repository state:

* Application: SchoolManagement MVC legacy app
* Current platform: ASP.NET MVC 5 on .NET Framework
* Current project: SchoolManagement/SchoolManagement.csproj
* Current solution: SchoolManagement.sln

Goal:
Create a new legacy-compatible MSTest project and implement the “Implement Now” tests from docs/ai-generated-test-ideas.md.

Important constraints:

* Do not modify production code.
* Do not refactor controllers, models, views, or startup code.
* Do not create database-backed tests yet.
* Do not instantiate MVC controllers.
* Do not use ASP.NET Core MVC namespaces.
* Use System.Web.Mvc attributes, not Microsoft.AspNetCore.Mvc.
* Use MSTest.
* Target .NET Framework 4.8 for the test project.
* Test current baseline behavior only.
* Risky inherited behavior must be named with CurrentBaselineRisk.
* The tests should compile and run without requiring LocalDB, EF data seeding, Identity setup, OWIN hosting, browser automation, or MVC runtime hosting.

Create a new and appropriate SchoolManagement.Tests project using a project template that is compatible with the .NET Framework 4.8 legacy project. Add the test project to SchoolManagement.sln.

Create a testing file and folder structure that matches the production code structure for the areas being tested.

Reference the SchoolManagement project from SchoolManagement.Tests.

Add any required test/MVC references needed for:

* MSTest
* System.Web.Mvc
* System.ComponentModel.DataAnnotations
* reflection against the SchoolManagement assembly

Implementation expectations:

* Use clear Arrange / Act / Assert structure.
* Use helper methods to avoid repeated reflection code.
* Add assertion messages that explain baseline-risk tests clearly.
* Do not add tests for CRUD persistence, JSON endpoint behavior, Identity registration, role seeding, route rendering, or browser flows yet.
* Do not introduce mocking frameworks unless strictly necessary. These tests should not need mocks.
* Keep the test project simple and legacy-compatible.

After creating the files:

1. Build the solution.
2. Run the tests if the environment supports it.
3. Report:

   * files created,
   * tests added,
   * commands run,
   * whether build/test passed,
   * any manual steps required if the assistant cannot create or run the legacy .NET Framework test project automatically.


## Prompt 4 - Generate the Infrastructure and Integration Tests

You are continuing the test baseline for the inherited SchoolManagement MVC legacy application.

Repository state:
- Application: SchoolManagement MVC legacy app
- Current platform: ASP.NET MVC 5 on .NET Framework 4.8
- Modernization target direction: ASP.NET Core MVC on .NET 10
- Existing test project: SchoolManagement.Tests
- The tests for the issues categorized as "implement now" from docs/ai-generated-test-ideas.md should already exist and pass.

Goal:
Generate the remaining executable tests from docs/ai-generated-test-ideas.md that were previously deferred until test infrastructure existed.

Important:
- Do not modify production code.
- Do not refactor controllers, models, views, Startup.cs, Web.config, or generated EF files.
- Do not change current application behavior.
- Do not use ASP.NET Core MVC namespaces.
- Use System.Web.Mvc, Entity Framework 6, ASP.NET Identity 2, and MSTest.
- Keep the test project targeting .NET Framework 4.8.
- Use current baseline behavior only.
- Risky inherited behavior must be named with CurrentBaselineRisk.
- Do not create Playwright, Selenium, browser, or full end-to-end tests in this pass.
- Do not implement external login provider tests.
- Do not implement password reset email delivery tests.
- Do not implement full Razor rendering tests unless they can be done safely without browser/runtime hosting.
- Prefer integration-style tests that run against a dedicated LocalDB test database.
- Never run tests against the developer’s normal SchoolManagement_DB database unless explicitly instructed.

Database/testing infrastructure requirements:
1. Configure the test project to use a dedicated LocalDB database named SchoolManagement_Test.
2. Use the same metadata/resource format as the application’s Entity Framework connection string, but point the provider connection string to SchoolManagement_Test.
3. Add a LegacyTestDatabase helper that:
   - verifies LocalDB is available,
   - creates SchoolManagement_Test if missing,
   - executes the database/create-schoolmanagement-db.sql script against the test database,
   - does not permanently alter database/create-schoolmanagement-db.sql,
   - safely replaces the database name from SchoolManagement_DB to SchoolManagement_Test when executing the script,
   - supports GO batch separators,
   - clears only test-created records when needed,
   - provides clear failure messages if SQL Server LocalDB or sqlcmd/database setup is missing.
4. Keep tests deterministic. Do not depend on random existing developer data.
5. Use unique test names or unique test data prefixes such as "AI Test Course", "AI Test Student", and "AI Test Enrollment".
6. Avoid test parallelization for database-backed tests.

Coding standards:
- MSTest only.
- Use clear Arrange / Act / Assert comments.
- Keep helper methods small and explicit.
- Add assertion messages that explain baseline-risk behavior.
- Avoid broad tests that verify too many behaviors at once.
- Avoid Thread.Sleep, real external services, browser automation, or production database dependencies.
- Do not introduce mocking frameworks unless strictly necessary.
- Do not use dynamic if reflection is clearer and safer for JsonResult.Data.
- Use async Task test methods for async controller actions.

After implementation:
1. Build the solution.
2. Run the full test suite.
3. Report:
   - files created,
   - tests added,
   - database setup assumptions,
   - commands run,
   - build result,
   - test result,
   - any tests intentionally deferred and why.

Expected validation commands:

nuget restore .\SchoolManagement.sln
msbuild .\SchoolManagement.sln /p:Configuration=Debug /m
vstest.console.exe .\SchoolManagement.Tests\bin\Debug\SchoolManagement.Tests.dll