# Codebase Summary

## Purpose

SchoolManagement Legacy MVC is an ASP.NET Framework MVC 5 application that manages school administration workflows. The system supports student record management, lecturer management, course catalogs, enrollment tracking, and role-based user authentication for academic staff workflows.

The application is preserved in its current state as a baseline for planning modernization to ASP.NET Core on .NET 10.

## Business Capabilities

### Core Academic Management

- **Student Management**: Create, read, update, and delete student records with enrollment date and date of birth tracking.
- **Lecturer Management**: Maintain instructor records and course assignments.
- **Course Management**: Catalog courses with credit tracking and course descriptions.
- **Enrollment Management**: Assign students to courses, record lecturer assignments, and track grades.

### User and Access Management

- **User Registration**: Self-service account creation with role-based assignment during signup.
- **Authentication**: Cookie-based login using ASP.NET Identity 2 with OWIN/Katana middleware.
- **Role-Based Authorization**: Admin and staff role classification for controlling access to protected workflows.
- **Account Management**: Users can change passwords and manage their own profile data (birth date).

## Current Technical Baseline

| Component | Detail |
|---|---|
| **Framework** | ASP.NET MVC 5 on .NET Framework 4.8 |
| **Project Format** | Legacy `.csproj` (non-SDK-style) |
| **Package Management** | `packages.config` |
| **Data Access** | Entity Framework 6 (Database First with EDMX) |
| **Authentication** | ASP.NET Identity 2 with OWIN/Katana middleware |
| **Configuration** | `web.config` application settings and connection strings |
| **Routing** | Conventional MVC routing via `RouteConfig.cs` |
| **Bundling** | ASP.NET Web Optimization bundling for scripts and styles |
| **UI Framework** | Bootstrap 3, jQuery 3.4.1, jQuery UI 1.12.1 |
| **Database** | LocalDB SQL Server (connection name: `SchoolManagement_DB`) |

### Key Dependencies

**NuGet packages** (from `packages.config`):
- EntityFramework 6.1.3
- Microsoft.AspNet.Identity.Core 2.2.1
- Microsoft.AspNet.Identity.EntityFramework 2.2.1
- Microsoft.AspNet.Identity.Owin 2.2.1
- Microsoft.AspNet.Mvc 5.2.3
- Microsoft.AspNet.WebPages 3.2.3
- Microsoft.Owin 3.0.1
- Microsoft.Owin.Host.SystemWeb 3.0.1
- Microsoft.Owin.Security.* (Cookies, Facebook, Google, MicrosoftAccount, OAuth, Twitter) 3.0.1
- Microsoft.jQuery.Unobtrusive.Validation 3.2.11
- Microsoft.jQuery.Unobtrusive.Ajax 3.2.6
- Bootstrap 3.4.1
- jQuery 3.4.1
- Newtonsoft.Json 12.0.2
- Microsoft.ApplicationInsights 2.2.0

## Repository Structure
```
SchoolManagement-MVC-legacy/
├── SchoolManagement/                 # Main MVC application
│   ├── App_Start/
│   │   ├── BundleConfig.cs          # Asset bundling configuration
│   │   ├── FilterConfig.cs          # Global MVC filters (HandleErrorAttribute)
│   │   ├── IdentityConfig.cs        # Identity user manager, email, and SMS services
│   │   ├── RouteConfig.cs           # MVC route registration
│   │   └── Startup.Auth.cs          # OWIN authentication configuration
│   ├── Controllers/
│   │   ├── AccountController.cs     # Registration, login, password reset, external login
│   │   ├── CoursesController.cs     # Course CRUD operations
│   │   ├── EnrollmentsController.cs # Enrollment CRUD operations
│   │   ├── HomeController.cs        # Public-facing pages (Index, About, Contact, TestView)
│   │   ├── LecturersController.cs   # Lecturer CRUD operations
│   │   ├── ManageController.cs      # User profile management and two-factor authentication
│   │   └── StudentsController.cs    # Student CRUD operations
│   ├── Models/
│   │   ├── IdentityModels.cs        # ApplicationUser (extends IdentityUser), ApplicationDbContext
│   │   ├── SchoolManagementDBModel.Context.cs   # EF6 EDMX DbContext (auto-generated)
│   │   ├── SchoolManagementDBModel.cs           # EDMX model definitions (auto-generated)
│   │   ├── Student.cs               # Auto-generated entity
│   │   ├── Lecturer.cs              # Auto-generated entity
│   │   ├── Course.cs                # Auto-generated entity
│   │   ├── Enrollment.cs            # Auto-generated entity
│   │   ├── AccountViewModels.cs     # Login, register, and manage views
│   │   └── ViewModels/              # Additional view model classes
│   ├── Views/
│   │   ├── Account/                 # Login, Register, Manage views
│   │   ├── Shared/
│   │   │   ├── _Layout.cshtml       # Master layout with Bootstrap 3 navbar
│   │   │   ├── _LoginPartial.cshtml # Authentication UI (login link or user menu)
│   │   │   └── Error.cshtml         # Global error view
│   │   ├── Courses/                 # Course Index, Create, Edit, Delete, Details views
│   │   ├── Students/                # Student CRUD views
│   │   ├── Lecturers/               # Lecturer CRUD views
│   │   ├── Enrollments/             # Enrollment CRUD views
│   │   └── Home/                    # Public pages (Index, About, Contact, TestView)
│   ├── Scripts/
│   │   ├── jquery-3.4.1.slim.js     # jQuery library
│   │   ├── jquery-ui-*.js           # jQuery UI library
│   │   ├── bootstrap.js             # Bootstrap JavaScript
│   │   ├── jquery.validate*.js      # Client-side validation
│   │   ├── jquery.unobtrusive-*.js  # Unobtrusive AJAX/validation
│   │   └── ... (other JavaScript)
│   ├── Content/
│   │   ├── bootstrap.css            # Bootstrap 3 styles
│   │   ├── site.css                 # Custom application styles
│   │   └── themes/base/             # jQuery UI themes
│   ├── Migrations/                  # EF Code-First migrations (if applicable)
│   ├── Global.asax                  # Application startup file
│   ├── Global.asax.cs               # Application startup code
│   ├── Startup.cs                   # OWIN startup configuration
│   ├── Web.config                   # Application configuration (connection strings, assembly binds, etc.)
│   ├── SchoolManagement.csproj      # Project file (legacy format)
│   └── SchoolManagement_DB.edmx     # Entity Framework EDMX designer file (auto-generated)
├── database/
│   └── create-schoolmanagement-db.sql  # SQL script for database creation
├── docs/
│   ├── baseline-assessment.md       # Existing assessment checklist
│   ├── business-rules-and-risks.md  # Existing business rules and risk analysis
│   └── codebase-summary.md          # This document
├── prompts/
│   ├── 01-baseline-assessment-prompt.md
│   ├── 02-business-rules-prompt.md
│   ├── 03-summarize-codebase-prompt.md
│   ├── ... (other prompt documents)
├── .github/
│   └── copilot-instructions.md      # Modernization guidelines and response rules
├── SchoolManagement.sln             # Visual Studio solution file
└── README.md                        # Project-level documentation
```

## Application Startup

### Global Application Initialization

**File**: `Global.asax.cs`  
**Method**: `Application_Start()`

The startup sequence:

1. **Area Registration**: `AreaRegistration.RegisterAllAreas()` – registers ASP.NET MVC areas (none defined currently).
2. **Filter Registration**: `FilterConfig.RegisterGlobalFilters()` – registers global MVC filters.
3. **Route Registration**: `RouteConfig.RegisterRoutes()` – registers MVC routes.
4. **Bundle Registration**: `BundleConfig.RegisterBundles()` – configures asset bundling.

### OWIN Startup Configuration

**File**: `Startup.cs`  
**OWIN Attribute**: `[assembly: OwinStartupAttribute(typeof(SchoolManagement.Startup))]`

**Method**: `Configuration(IAppBuilder app)`

The OWIN startup sequence:

1. **ConfigureAuth()** – initializes authentication middleware via `Startup.Auth.cs`:
   - Creates per-request OWIN contexts for `ApplicationDbContext`, `ApplicationUserManager`, and `ApplicationSignInManager`.
   - Enables cookie-based authentication with 30-minute security stamp validation.
   - Configures external sign-in cookies for third-party login providers.
   - Enables two-factor authentication cookies.
   - Optionally configures Google, Microsoft Account, Facebook, and Twitter external sign-in (currently commented out).

2. **createRolesandUsers()** – initializes default roles and users:
   - Creates "Admin" and "User" roles if they do not exist.
   - Creates a default admin user if no admin user exists (credentials hardcoded in `Startup.cs`).

### Global Filters

**File**: `App_Start/FilterConfig.cs`

- Registers `HandleErrorAttribute` globally, which catches unhandled exceptions and renders the `Error.cshtml` view.

### Bundling Configuration

**File**: `App_Start/BundleConfig.cs`

Bundles are registered for:
- `~/bundles/jquery` – jQuery library
- `~/bundles/jquery-ajax` – jQuery unobtrusive AJAX
- `~/bundles/jquery-ui` – jQuery UI
- `~/bundles/jqueryval` – jQuery Validation
- `~/bundles/modernizr` – Modernizr feature detection
- `~/bundles/bootstrap` – Bootstrap JavaScript
- `~/Content/css` – Bootstrap CSS and custom site CSS
- `~/Content/jqueryui` – jQuery UI CSS

## Routing

**File**: `App_Start/RouteConfig.cs`

### Default Route

The application uses a single conventional route:
```
url: "{controller}/{action}/{id}"
defaults: controller = "Home", action = "Index", id = UrlParameter.Optional
```

This route matches URLs like:
- `/Home/Index` → HomeController.Index()
- `/Courses/Details/5` → CoursesController.Details(id=5)
- `/` → HomeController.Index() (default)

### Ignored Routes

- `{resource}.axd/{*pathInfo}` – IIS handler requests (e.g., `.axd` files for WebResource.axd)

## MVC Controllers and Workflows

### AccountController

**File**: `Controllers/AccountController.cs`  
**Authorization**: `[Authorize]` class attribute (login and related actions use `[AllowAnonymous]` override)

**Key Workflows**:

| Action | Method | Authorization | Purpose |
|---|---|---|---|
| **Login** | GET | `[AllowAnonymous]` | Display login form |
| **Login** | POST | `[AllowAnonymous]` | Authenticate user and set authentication cookie |
| **Register** | GET | `[AllowAnonymous]` | Display registration form |
| **Register** | POST | `[AllowAnonymous]` | Create new user and assign roles |
| **LogOff** | POST | `[Authorize]` | Clear authentication cookie |
| **ForgotPassword** | GET/POST | `[AllowAnonymous]` | Password reset workflow (email not configured) |
| **ConfirmEmail** | GET | `[AllowAnonymous]` | Email confirmation (not implemented) |
| **ExternalLogin** | POST | `[AllowAnonymous]` | Initiate external provider login |
| **ExternalLoginCallback** | GET | `[AllowAnonymous]` | Handle external provider callback |

**Role Assignment During Registration**: Users self-select roles during signup via checkboxes in the registration form.

### ManageController

**File**: `Controllers/ManageController.cs`  
**Authorization**: `[Authorize]` class attribute

**Key Workflows**:

| Action | Purpose |
|---|---|
| **Index** | Display user profile (currently basic) |
| **ChangePassword** | Allow authenticated user to change password |
| **AddPhoneNumber** | Enable two-factor authentication via SMS |
| **RemovePhoneNumber** | Disable two-factor authentication |
| **EnableTwoFactorAuthentication** | Enable two-factor authentication |
| **DisableTwoFactorAuthentication** | Disable two-factor authentication |

### StudentsController

**File**: `Controllers/StudentsController.cs`  
**Authorization**: `[Authorize]` class attribute

**CRUD Workflows**:

| Action | Method | Purpose |
|---|---|---|
| **Index** | GET | List all students (paginated via LINQ) |
| **Details** | GET | Show student details, enrollment history |
| **Create** | GET | Display student creation form |
| **Create** | POST | Insert new student record |
| **Edit** | GET | Display student edit form |
| **Edit** | POST | Update student record |
| **Delete** | GET | Display delete confirmation |
| **Delete** | POST | Remove student record |

**Data Access**: Direct `SchoolManagement_DBEntities` context instantiation in constructor.

### CoursesController

**File**: `Controllers/CoursesController.cs`  
**Authorization**: `[Authorize]` class attribute

**CRUD Workflows**:

| Action | Method | Purpose |
|---|---|---|
| **Index** | GET | List all courses |
| **Details** | GET | Show course details, enrollment list |
| **Create** | GET | Display course creation form |
| **Create** | POST | Insert new course; anti-forgery validation present |
| **Edit** | GET | Display course edit form |
| **Edit** | POST | Update course record; anti-forgery validation present |
| **Delete** | GET | Display delete confirmation |
| **Delete** | POST | Remove course record; anti-forgery validation present |

**Data Access**: Direct `SchoolManagement_DBEntities` context instantiation in constructor.

### LecturersController

**File**: `Controllers/LecturersController.cs`  
**Authorization**: `[Authorize]` class attribute

**CRUD Workflows**:

| Action | Method | Purpose |
|---|---|---|
| **Index** | GET | List all lecturers |
| **Details** | GET | Show lecturer details, course assignments |
| **Create** | GET | Display lecturer creation form |
| **Create** | POST | Insert new lecturer; anti-forgery validation present |
| **Edit** | GET | Display lecturer edit form |
| **Edit** | POST | Update lecturer record; anti-forgery validation present |
| **Delete** | GET | Display delete confirmation |
| **Delete** | POST | Remove lecturer record; anti-forgery validation present |

**Data Access**: Direct `SchoolManagement_DBEntities` context instantiation in constructor.

### EnrollmentsController

**File**: `Controllers/EnrollmentsController.cs`  
**Authorization**: `[Authorize]` class attribute

**CRUD Workflows**:

| Action | Method | Purpose |
|---|---|---|
| **Index** | GET | List all enrollments (filterable by student) |
| **Details** | GET | Show enrollment details with associated student, course, lecturer |
| **Create** | GET | Display enrollment creation form (dropdowns for student, course, lecturer) |
| **Create** | POST | Insert new enrollment; anti-forgery validation present |
| **Edit** | GET | Display enrollment edit form |
| **Edit** | POST | Update enrollment (grade, lecturer assignment); anti-forgery validation present |
| **Delete** | GET | Display delete confirmation |
| **Delete** | POST | Remove enrollment record; anti-forgery validation present |

**Data Access**: Direct `SchoolManagement_DBEntities` context instantiation in constructor.

### HomeController

**File**: `Controllers/HomeController.cs`  
**Authorization**: No class-level attribute (actions are public by default)

**Actions**:

| Action | Purpose |
|---|---|
| **Index** | Public homepage |
| **About** | Public about page |
| **Contact** | Public contact page |
| **TestView** | Diagnostic test page (should be reviewed for removal) |

## Authentication and Authorization

### Identity Model and User Manager

**Files**: `Models/IdentityModels.cs`, `App_Start/IdentityConfig.cs`

**ApplicationUser**:
- Extends `IdentityUser` (adds email, username, password hash, etc.)
- Custom property: `BirthDate` (DateTime)

**ApplicationDbContext**:
- Inherits `IdentityDbContext<ApplicationUser>`
- Connection string: `DefaultConnection` (LocalDB)
- Contains Identity tables (AspNetUsers, AspNetRoles, AspNetUserRoles, etc.)

**ApplicationUserManager**:
- Extends `UserManager<ApplicationUser>`
- Configures password validators, lockout policy, email/SMS service placeholders

**ApplicationSignInManager**:
- Extends `SignInManager<ApplicationUser>`
- Handles sign-in, two-factor authentication, external login

### Authentication Middleware

**File**: `App_Start/Startup.Auth.cs`

**Cookie Authentication**:
- `AuthenticationType` = `DefaultAuthenticationTypes.ApplicationCookie`
- `LoginPath` = `/Account/Login`
- Security stamp validation every 30 minutes
- Regenerates identity on security stamp change

**External Authentication** (commented out by default):
- Google login (requires client ID and secret)
- Microsoft Account login
- Facebook login
- Twitter login

### Role-Based Authorization

**Default Roles** (created in `Startup.cs`):
- `Admin` – administrative staff
- `User` – regular users/staff

**Authorization Coverage**:
- `[Authorize]` attribute on CoursesController, StudentsController, LecturersController, EnrollmentsController, ManageController
- `[AllowAnonymous]` on HomeController actions
- `[AllowAnonymous]` on AccountController login/register actions

**Current Gap**: No role-based authorization attributes (e.g., `[Authorize(Roles="Admin")]`); all authenticated users can access all academic operations.

### Session and State

- OWIN-based cookie authentication (stateless by default)
- 30-minute security stamp validation interval

## Data Access

### Two Database Contexts

The application uses two separate DbContext instances:

#### 1. ApplicationDbContext (Identity)

**File**: `Models/IdentityModels.cs`  
**Purpose**: User authentication and role management  
**Connection String**: `DefaultConnection`  
**Database**: `SchoolManagement_DB` (LocalDB)

**Tables**:
- AspNetUsers
- AspNetRoles
- AspNetUserRoles
- AspNetUserClaims
- AspNetUserLogins
- etc. (ASP.NET Identity standard tables)

#### 2. SchoolManagement_DBEntities (EDMX)

**File**: `Models/SchoolManagementDBModel.Context.cs` (auto-generated)  
**Purpose**: Academic data (students, courses, lecturers, enrollments)  
**Connection String**: `SchoolManagement_DBEntities`  
**Database**: `SchoolManagement_DB` (LocalDB, same database)

**Entity Model** (Database First / EDMX):
- Auto-generated from database schema
- Not designed for manual editing

**Tables**:
- Students (StudentID, FirstName, MiddleName, LastName, EnrollmentDate, DateOfBirth)
- Courses (CourseId, Title, Credits)
- Lecturers (Id, First_Name, Last_Name)
- Enrollments (EnrollmentID, StudentID, CourseID, LecturerId, Grade)

**Foreign Keys**:
- Enrollments → Students (StudentID)
- Enrollments → Courses (CourseID)
- Enrollments → Lecturers (LecturerId, nullable)

### Data Access Pattern

**Location**: Directly in MVC controllers  
**Pattern**: LINQ to Entities via DbSet

Example (from CoursesController):
```
private SchoolManagement_DBEntities db = new SchoolManagement_DBEntities();

public ActionResult Index()
{
    return View(db.Courses.ToList());
}
```

**Risks**:
- Tight coupling between controllers and EF6 DbContext
- No repository pattern or dependency injection
- DbContext instantiation in constructor (dispose may not be properly handled)
- Potential for N+1 queries; no explicit `.Include()` for navigation properties

### Validation

- Server-side `ModelState.IsValid` validation in POST actions
- Client-side validation via jQuery Validation and unobtrusive attributes
- Anti-forgery token validation via `[ValidateAntiForgeryToken]` on POST actions

### Database Initialization

**File**: `database/create-schoolmanagement-db.sql`  
Provides SQL script for manual database creation. EF6 Migrations folder exists but may not be active.

## Configuration

### Web.config

**File**: `Web.config`

**Connection Strings**:
```
<connectionStrings>
    <add name="DefaultConnection" 
         connectionString="Data Source=(LocalDb)\MSSQLLocalDB;Initial Catalog=SchoolManagement_DB;Integrated Security=True" 
         providerName="System.Data.SqlClient"/>
    <add name="SchoolManagement_DBEntities" 
         connectionString="metadata=res://*/Models.SchoolManagementDBModel.csdl|res://*/Models.SchoolManagementDBModel.ssdl|res://*/Models.SchoolManagementDBModel.msl;provider=System.Data.SqlClient;provider connection string=&quot;data source=(LocalDb)\MSSQLLocalDB;initial catalog=SchoolManagement_DB;integrated security=True;MultipleActiveResultSets=True;App=EntityFramework&quot;" 
         providerName="System.Data.EntityClient"/>
</connectionStrings>
```

**AppSettings**:
```
<appSettings>
    <add key="webpages:Version" value="3.0.0.0"/>
    <add key="webpages:Enabled" value="false"/>
    <add key="ClientValidationEnabled" value="true"/>
    <add key="UnobtrusiveJavaScriptEnabled" value="true"/>
</appSettings>
```

**Authentication**:
```
<authentication mode="None"/>  <!-- OWIN-based, not Forms Auth -->
```

**Compilation**:
```
<compilation debug="true" targetFramework="4.8"/>
<httpRuntime targetFramework="4.8"/>
```

**Modules**:
- FormsAuthentication module removed
- ApplicationInsights module added (v2.2.0)

**Assembly Binding Redirects**: Binding redirects for Microsoft.Owin.Security, Microsoft.Owin, and other assemblies to harmonize dependency versions.

## Dependencies

### NuGet Packages

See **Current Technical Baseline** section above for the complete list.

**Key Dependency Groups**:

| Group | Packages | Version | Purpose |
|---|---|---|---|
| **ASP.NET MVC** | Microsoft.AspNet.Mvc, Microsoft.AspNet.WebPages, Microsoft.AspNet.Razor | 5.2.x / 3.2.x | MVC framework and Razor view engine |
| **Entity Framework** | EntityFramework | 6.1.3 | ORM for database access |
| **ASP.NET Identity** | Microsoft.AspNet.Identity.Core, Microsoft.AspNet.Identity.EntityFramework, Microsoft.AspNet.Identity.Owin | 2.2.1 | User authentication and role management |
| **OWIN** | Microsoft.Owin, Microsoft.Owin.Host.SystemWeb | 3.0.1 | OWIN authentication middleware |
| **OWIN Security** | Microsoft.Owin.Security.Cookies, Microsoft.Owin.Security.Google, Microsoft.Owin.Security.Facebook, Microsoft.Owin.Security.Twitter, Microsoft.Owin.Security.MicrosoftAccount, Microsoft.Owin.Security.OAuth | 3.0.1 | External authentication providers |
| **UI Framework** | Bootstrap, jQuery, jQuery.UI.Combined, jQuery.Validation | 3.4.1, 3.4.1, 1.12.1, 1.17.0 | Client-side UI and validation |
| **Unobtrusive** | Microsoft.jQuery.Unobtrusive.Ajax, Microsoft.jQuery.Unobtrusive.Validation | 3.2.x | Client-side AJAX and validation without inline script |
| **Web Optimization** | Microsoft.AspNet.Web.Optimization | 1.1.3 | Bundling and minification |
| **JSON** | Newtonsoft.Json | 12.0.2 | JSON serialization |
| **Monitoring** | Microsoft.ApplicationInsights.* | 2.2.0 | Application Insights telemetry |

### Package Management

- **Format**: `packages.config` (NuGet v2 / Visual Studio Package Manager)
- **Target Framework** in package metadata: `.net461` (mapped from .NET Framework 4.6.1 baseline)

## UI and Static Assets

### Master Layout

**File**: `Views/Shared/_Layout.cshtml`

**Structure**:
- DOCTYPE HTML5
- Bootstrap 3 navigation bar (fixed-top)
- Navigation links: Home, Courses, Students, Lecturers, Enrollments
- Login partial (`_LoginPartial.cshtml`)
- Main content area with `@RenderBody()`
- Footer with copyright year

**Bundled Assets**:
- `~/bundles/modernizr` – feature detection
- `~/bundles/jquery` – jQuery library
- `~/bundles/jquery-ajax` – unobtrusive AJAX
- `~/bundles/jquery-ui` – jQuery UI
- `~/bundles/bootstrap` – Bootstrap JavaScript and Respond (IE9 support)
- `~/Content/css` – Bootstrap CSS + site.css
- `~/Content/jqueryui` – jQuery UI themes

### Login Partial

**File**: `Views/Shared/_LoginPartial.cshtml`

**Behavior**:
- If authenticated: displays username and "Log Off" link
- If anonymous: displays "Register" and "Log In" links

### View Templates

**Locations**:
- `Views/Account/` – Login, Register, Manage, ForgotPassword, ConfirmEmail, etc.
- `Views/Students/` – Index, Details, Create, Edit, Delete
- `Views/Courses/` – Index, Details, Create, Edit, Delete
- `Views/Lecturers/` – Index, Details, Create, Edit, Delete
- `Views/Enrollments/` – Index, Details, Create, Edit, Delete
- `Views/Home/` – Index, About, Contact, TestView
- `Views/Shared/` – Error.cshtml, _Layout.cshtml, _LoginPartial.cshtml

**CRUD Pattern**:
- Index views: `Html.ActionLink` for Create, and table rows with Edit/Delete buttons
- Details views: Display model properties; link to Edit/Delete/Back
- Create/Edit views: `Html.BeginForm` POST to action, model binding via `@Html.TextBoxFor()`, `@Html.DropDownListFor()`, validation summary
- Delete views: Confirmation message with POST button

**Validation**:
- `@Html.ValidationSummary()`
- `@Html.ValidationMessageFor()` on form fields
- Client-side validation via `jquery.validate` and unobtrusive attributes

### CSS Framework

**Bootstrap 3.4.1**:
- Responsive grid system
- Navbar (fixed-top)
- Form controls and validation
- Tables, buttons, alerts

**Custom CSS**: `Content/site.css` (minimal, application-specific styles)

**jQuery UI Themes**: Located in `Content/themes/base/` for dialog, datepicker, and autocomplete components.

### JavaScript

**jQuery 3.4.1 Slim**: Lightweight version of jQuery
**jQuery UI 1.12.1**: Widget library (datepicker, autocomplete, dialog, tabs, etc.)
**jQuery Validation 1.17.0**: Client-side form validation
**jQuery Unobtrusive AJAX 3.2.6**: AJAX form submission without inline scripts
**Bootstrap 3.4.1 JavaScript**: Modal, dropdown, collapse, carousel plugins
**Modernizr 2.8.3**: HTML5 feature detection

## Existing Review Documents

The repository includes assessment and planning documents created during baseline analysis:

| Document | Purpose |
|---|---|
| `docs/baseline-assessment.md` | Checklist of areas to review before modernization (solution structure, startup, data access, auth, controllers, dependencies, configuration) |
| `docs/business-rules-and-risks.md` | Business rules, workflows, and identified modernization risks |
| `README.md` | Project overview, baseline characteristics, and modernization direction |
| `.github/copilot-instructions.md` | Modernization guidelines and response rules for code review and changes |

## Modernization-Relevant Observations

### Current State Risks

| Area | Observation | Modernization Impact |
|---|---|---|
| **Data Access** | Direct DbContext instantiation in controllers; no repository or dependency injection pattern | Requires refactoring to repository pattern and/or EF Core DbContext injection for ASP.NET Core migration |
| **Two Contexts** | ApplicationDbContext and SchoolManagement_DBEntities are separate; both target the same physical database | Consolidation into single DbContext recommended during migration to EF Core |
| **EDMX Model** | Database First / auto-generated; not suitable for manual editing | Requires reverse-engineering into EF Core model classes or continued use of EDMX (not recommended for Core) |
| **OWIN Authentication** | OWIN/Katana middleware; ASP.NET Identity 2 | Direct replacement with ASP.NET Core Identity middleware; no OWIN in Core |
| **Configuration** | web.config connection strings and app settings | Requires migration to `appsettings.json` and environment variables in ASP.NET Core |
| **Routing** | Conventional MVC routes in RouteConfig.cs | Can be preserved or enhanced with attribute-based routing in Core |
| **Bundling** | ASP.NET Web Optimization (BundleConfig) | Replace with npm/webpack, Vite, or built-in Razor tag helpers in Core |
| **Authorization** | No role-based authorization attributes (e.g., `[Authorize(Roles="Admin")]`) | Recommend adding fine-grained role checks before modernization to clarify intent |
| **External Login** | Google, Facebook, Twitter, Microsoft providers are configured but commented out | Requires re-enabling and configuration in ASP.NET Core Identity |
| **Two-Factor Auth** | Infrastructure exists but not enforced | Can be preserved or enhanced in Core migration |
| **Email/SMS Services** | Placeholders in IdentityConfig.cs; no real implementation | Requires explicit implementation (e.g., SendGrid, Twilio) during migration |
| **JavaScript** | jQuery and Bootstrap 3 (end-of-life); bundled via system | Can be modernized to Bootstrap 5, Webpack/npm, or replaced with framework (React, Angular, Vue) in Core |

### Missing or Incomplete Features

- Email confirmation workflow (EmailConfirmed field present but not used)
- SMS/phone number verification (infrastructure present, not enforced)
- Real email sending (placeholder EmailService)
- Password reset email (placeholder SmsService)
- Granular role-based access control

### Security Observations

- Anti-forgery tokens are present on POST actions in most controllers
- No explicit CORS or API security policies
- LocalDB connection strings are hardcoded (acceptable for dev, not for production)
- No input sanitization or output encoding visible in views (assumed via Razor templating)

## Assumptions and Unknowns

### Assumptions Made

1. The application is currently deployable and running on .NET Framework 4.8.
2. The `SchoolManagement_DB` LocalDB database exists with the schema defined in `create-schoolmanagement-db.sql`.
3. The default admin user credentials hardcoded in `Startup.cs` are for development only.
4. The role assignment during registration (user self-selection) is intentional.
5. AJAX endpoints and unobtrusive validation are working as designed.
6. The TestView action in HomeController is a diagnostic artifact to be reviewed.

### Unknowns

- **Production Deployment**: How is the application currently deployed? (on-premises, IIS, cloud)
- **Database**: What is the actual database state? Are migrations tracked in Migrations folder?
- **External Logins**: Are Google, Facebook, etc., actually used in production?
- **Email Service**: How are password resets and confirmations handled without a real email service?
- **Performance**: Are there known N+1 query issues or slow endpoints?
- **Test Coverage**: What is the existing unit/integration test coverage?
- **Audit Requirements**: Are audit logs or activity tracking required?
- **Multi-Tenancy**: Is the system single-tenant or multi-tenant?
- **API Consumers**: Are there external systems consuming this via API?
- **Scalability**: What are the expected user and data volumes?

## Manual Verification Checklist

Before proceeding with modernization, verify the following:

- [ ] Solution opens successfully in Visual Studio and builds without errors
- [ ] Application runs locally (F5 or Ctrl+F5)
- [ ] Can register a new user account
- [ ] Can log in with registered user
- [ ] Can navigate to all main pages (Courses, Students, Lecturers, Enrollments)
- [ ] Can create a new student record
- [ ] Can create a new course record
- [ ] Can enroll a student in a course
- [ ] Can edit and delete records (student, course, lecturer, enrollment)
- [ ] Anti-forgery validation works (attempt CSRF attack on form)
- [ ] Authentication is enforced (accessing `/Courses` without login redirects to `/Account/Login`)
- [ ] Database connection strings are correct for current environment
- [ ] No compilation warnings related to deprecated APIs
- [ ] Application Insights is connected (if in use)
- [ ] External login providers are disabled or properly configured (no console errors)
- [ ] All views render correctly in modern browsers
- [ ] Form validation works client-side and server-side

---

**Document Status**: Summary of verified current state as of baseline assessment.  
**Last Updated**: June 23, 2026  
**Next Step**: Proceed with detailed modernization planning based on this baseline.