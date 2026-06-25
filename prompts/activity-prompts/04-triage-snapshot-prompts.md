## Prompt 1 - Technical Debt Snapshot

Review the known technical debt concerns for this inherited ASP.NET MVC 5 application.

Use the existing baseline documents and the selected controller examples as context.

Focus on technical debt that affects modernization readiness:
- direct DbContext usage in controllers
- mixed controller responsibilities
- EF6 EDMX/generated model constraints
- repeated CRUD patterns
- System.Web MVC dependencies
- testability concerns

Do not propose a rewrite. Produce a concise triage table with:
1. finding
2. evidence
3. modernization impact
4. fix now, defer, or validate during migration
5. validation required

## Prompt 2 - Security, Privacy, and Access Control Snapshot
Review the documented access-control and security concerns for this inherited ASP.NET MVC 5 application.

Use the selected controller examples and business-rules document as context.

Focus on:
- inconsistent authorization
- anonymous access decisions
- AJAX POST actions
- anti-forgery coverage
- user-selected role registration
- JSON search endpoint exposure

Do not assume the current behavior is correct or incorrect. Classify each item as:
- preserve temporarily
- fix before migration
- validate during migration
- requires business decision

Return a concise security triage table with evidence and required validation.

## Prompt 3 - Dependency and Modernization Readiness Snapshot
Review the dependency inventory for this inherited ASP.NET MVC 5 application.

Create a modernization readiness matrix for migration toward ASP.NET Core MVC on .NET 10.

Classify each dependency or technology area as:
- keep temporarily
- replace during migration
- remove after migration
- requires security/package review
- requires behavior validation

Focus on:
- ASP.NET MVC 5 / System.Web
- EF6 EDMX
- ASP.NET Identity 2
- OWIN/Katana
- packages.config
- web.config
- legacy frontend packages
- bundling/minification
- Newtonsoft.Json

Do not recommend changing everything at once. Prioritize incremental migration safety.

## Prompt 5 - Build the Consolidated Risk Register
Create a consolidated legacy risk triage register for the SchoolManagement Legacy MVC application.

Use the existing baseline documents and selected code evidence.

Group findings into:
1. Technical Debt
2. Security and Access Control
3. Dependency and Modernization Readiness
4. Validation Gaps

For each finding, include:
- ID
- category
- affected area
- finding
- evidence
- business risk
- modernization risk
- severity
- decision: fix now, defer, accept temporarily, or validate during migration
- validation required

Do not invent findings that are not supported by the provided documents or code evidence.
Do not propose a rewrite.
Prioritize incremental modernization toward ASP.NET Core MVC on .NET 10.