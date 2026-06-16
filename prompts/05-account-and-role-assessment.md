# Prompt 05: Account and Role Workflow Assessment

Use this prompt before changing account, login, registration, or role-related code.

```text
Assess the account and role workflow in this inherited ASP.NET Framework MVC application.

Do not modify files yet.

Inspect:
- Controllers/AccountController.cs
- Controllers/ManageController.cs
- Models/IdentityModels.cs
- Models/AccountViewModels.cs
- Models/ManageViewModels.cs
- App_Start/IdentityConfig.cs
- App_Start/Startup.Auth.cs
- Startup.cs
- Web.config
- account-related Razor views

Return:
1. Current account workflow summary
2. Current role workflow summary
3. OWIN and ASP.NET Identity 2 dependencies
4. Actions that allow anonymous access
5. Actions that require authentication
6. Role assignment behavior that requires review
7. ASP.NET Core Identity migration considerations
8. Behavior that must be preserved during migration
9. Behavior that should be reviewed before preservation
10. Validation checklist for account workflows

Do not replace the account system yet. First document the existing behavior, risks, and migration decisions required.
```

## Expected output

The response should distinguish between preserving inherited behavior and improving account workflow design. Any behavior change should be called out as a decision, not treated as an automatic migration detail.