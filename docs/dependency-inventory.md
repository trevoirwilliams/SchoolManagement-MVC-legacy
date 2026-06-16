# Dependency Inventory

This document identifies the major dependency areas that must be reviewed before modernization.

## Package management model

The application uses `packages.config`. This is part of the legacy baseline and should be reviewed before SDK-style conversion or migration to ASP.NET Core.

## Key backend packages

| Package | Current role | Modernization consideration |
|---|---|---|
| EntityFramework 6.1.3 | EF6 data access and EDMX support | Decide whether to move to EF Core or keep EF6 temporarily |
| Microsoft.AspNet.Mvc 5.2.3 | ASP.NET MVC 5 framework | Migrate controllers and views to ASP.NET Core MVC |
| Microsoft.AspNet.Identity.* 2.2.1 | User, role, and account workflow support | Map to ASP.NET Core Identity or a compatible account strategy |
| Microsoft.Owin.* 3.0.1 | OWIN middleware and cookie flow | Map startup and middleware behavior to ASP.NET Core |
| Newtonsoft.Json 12.0.2 | JSON serialization dependency | Review compatibility with System.Text.Json before replacing |
| Microsoft.ApplicationInsights 2.2.0 packages | Legacy telemetry integration | Replace with current ASP.NET Core telemetry approach if needed |
| Microsoft.CodeDom.Providers.DotNetCompilerPlatform 1.0.8 | Runtime compilation support for ASP.NET Framework | Not required in the same form after ASP.NET Core migration |
| Microsoft.Net.Compilers 2.4.0 | Build/compiler package | Review during .NET Framework 4.8 stabilization and SDK-style migration |

## Key frontend packages

| Package | Current role | Modernization consideration |
|---|---|---|
| bootstrap 3.4.1 | UI layout and styling | Decide whether to preserve Bootstrap 3 initially or upgrade later |
| jQuery 3.4.1 | Client-side DOM and AJAX support | Preserve behavior initially; modernize after migration if required |
| jQuery.UI.Combined 1.12.1 | UI widgets and autocomplete behavior | Identify views that depend on jQuery UI |
| jQuery.Validation 1.17.0 | Client-side validation | Map to ASP.NET Core validation scripts |
| Microsoft.jQuery.Unobtrusive.* | MVC AJAX and validation support | Validate equivalent client behavior after migration |
| Modernizr 2.8.3 | Browser feature detection | Review whether still needed |
| Respond 1.4.2 | Legacy responsive support | Usually not needed for modern browsers |
| WebGrease 1.6.0 and Antlr | Bundling/minification support | Replace with modern static asset strategy |

## Configuration dependencies

Review these before modernization:

- LocalDB connection strings in `Web.config`
- EF provider configuration
- assembly binding redirects
- Application Insights HTTP modules
- CodeDOM compiler configuration
- MVC/WebPages app settings

## Review checklist

| Check | Status |
|---|---|
| Run NuGet restore successfully | Not started |
| Identify packages required only by ASP.NET Framework | Not started |
| Identify packages that map to ASP.NET Core equivalents | Not started |
| Identify packages that can be removed after migration | Not started |
| Review package vulnerabilities with current tooling | Not started |
| Decide whether Newtonsoft.Json should remain temporarily | Not started |
| Decide whether EF6 remains during first migration pass | Not started |
| Document frontend package strategy | Not started |

## Decision log

| Decision | Chosen option | Reason | Date |
|---|---|---|---|
| .NET Framework stabilization target | TBD |  |  |
| ASP.NET Core target | .NET 10 | Current modernization target |  |
| Data access strategy | TBD |  |  |
| Account workflow strategy | TBD |  |  |
| Frontend asset strategy | TBD |  |  |