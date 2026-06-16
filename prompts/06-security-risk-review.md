# Prompt 06: Security and Risk Review

Use this prompt to review inherited risk areas before and after modernization.

```text
Review this inherited ASP.NET Framework MVC application for modernization-related security and business risk.

Do not modify files yet.

Focus on:
- authorization attributes on controllers and actions
- anonymous access decisions
- role-based access behavior
- anti-forgery validation on POST actions
- JSON endpoints
- AJAX workflows
- registration and role assignment behavior
- direct data access in controllers
- validation and model binding behavior
- Web.config connection strings and configuration
- error handling and user-facing messages

Return:
1. Risk summary
2. Affected files and actions
3. Risk rating for each finding
4. Evidence from code
5. Recommended remediation
6. Whether remediation should happen before, during, or after migration
7. Validation steps
8. Questions requiring business confirmation

Do not rewrite the application. Produce an evidence-backed risk review that can be used to scope modernization work.
```

## Expected output

The response should identify risks without assuming every inherited behavior is wrong. Some risks may require business confirmation before remediation.