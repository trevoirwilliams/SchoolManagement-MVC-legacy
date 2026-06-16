# Prompt 02: Dependency Inventory

Use this prompt to review NuGet and frontend dependencies before modernization.

```text
Review the dependency inventory for this ASP.NET Framework MVC application.

Do not modify files yet.

Inspect:
- SchoolManagement/packages.config
- SchoolManagement/SchoolManagement.csproj
- SchoolManagement/Web.config
- App_Start/BundleConfig.cs
- Razor layout and script references

For each dependency, classify it as:
- required for the current legacy application
- ASP.NET Framework-specific
- likely replaceable during ASP.NET Core migration
- frontend/static asset dependency
- data access dependency
- account workflow dependency
- telemetry/diagnostics dependency
- obsolete or high-risk dependency requiring further review

Return a table with:
- package name
- current version
- current purpose
- migration concern
- recommended action
- validation needed

Also identify which dependencies are tied to System.Web, MVC 5, EF6 EDMX, OWIN, ASP.NET Identity 2, bundling, and Web.config.
```

## Expected output

The response should not simply upgrade packages. It should first explain which dependencies are part of the current runtime behavior and which are migration targets.