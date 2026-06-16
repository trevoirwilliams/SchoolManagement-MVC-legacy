# Prompt 04: EF6 EDMX Assessment

Use this prompt before changing the data access layer.

```text
Assess the EF6 Database First and EDMX data access layer in this ASP.NET Framework MVC application.

Do not modify files yet.

Inspect:
- Models/SchoolManagementDBModel.edmx
- Models/SchoolManagementDBModel.Context.cs
- Models/SchoolManagementDBModel.cs
- generated entity files
- Web.config connection strings
- controllers that use SchoolManagement_DBEntities
- migrations folder

Return:
1. How the current data model is generated
2. Which files appear generated and should not be manually edited
3. Which controllers depend directly on the EF6 context
4. Whether the database schema must be available before migration
5. EF Core migration options
6. Risks of migrating to EF Core too early
7. Risks of keeping EF6 temporarily
8. Recommended first data-access modernization step
9. Validation steps for each data-access change

Do not assume that EDMX and EF Core behave identically. Identify behavior that must be verified.
```

## Expected output

The response should help decide whether the data access layer should be migrated immediately, wrapped first, or handled after the ASP.NET Core shell is established.