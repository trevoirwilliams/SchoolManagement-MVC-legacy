# Migration Validation Checklist

Use this checklist to verify behavior before and after each modernization stage.

## Baseline validation

| Validation item | Evidence | Status |
|---|---|---|
| NuGet packages restore successfully | Restore output | Not started |
| Solution builds successfully | Build output | Not started |
| Application starts locally | Browser result | Not started |
| LocalDB connection works | App workflow result | Not started |
| Home page loads | Screenshot or notes | Not started |
| Login page loads | Screenshot or notes | Not started |
| Registration page loads | Screenshot or notes | Not started |
| Student list loads | Screenshot or notes | Not started |
| Course list loads | Screenshot or notes | Not started |
| Lecturer list loads | Screenshot or notes | Not started |
| Enrollment list loads | Screenshot or notes | Not started |

## Workflow validation

### Student workflows

- View student list
- View student details
- Create student
- Edit student
- Delete student
- Confirm validation messages still appear
- Confirm redirects after POST actions

### Course workflows

- View course list
- View course details
- Create course
- Edit course
- Delete course
- Confirm validation messages still appear
- Confirm redirects after POST actions

### Lecturer workflows

- View lecturer list
- View lecturer details
- Create lecturer
- Edit lecturer
- Delete lecturer
- Confirm redirects after POST actions

### Enrollment workflows

- View enrollment list
- View enrollment details
- Create enrollment
- Edit enrollment
- Delete enrollment
- Validate course, student, and lecturer dropdown behavior
- Validate AJAX add-student behavior
- Validate student search behavior

### Account workflows

- Login
- Register
- Logout
- Role assignment behavior
- Account management page

## Technical validation

| Area | Validation |
|---|---|
| Routing | Existing URLs continue to resolve or have documented redirects |
| Views | Layout, navigation, forms, partial views, and validation summaries render correctly |
| Forms | POST actions preserve anti-forgery validation where applicable |
| JSON endpoints | Response shape is preserved or documented |
| Data access | Reads and writes preserve existing data behavior |
| Account workflows | Login, registration, logout, and role behavior are validated |
| Configuration | Connection strings and environment settings are mapped |
| Static assets | CSS and JavaScript load without broken references |

## Modernization checkpoint evidence

For each modernization checkpoint, capture:

- branch name
- commit SHA
- files changed
- build result
- validation result
- known issues
- rollback plan

## Pull request validation summary template

```markdown
## Validation Summary

### Build
- Restore:
- Build:

### Workflow Checks
- Home:
- Account:
- Students:
- Courses:
- Lecturers:
- Enrollments:

### Risks Remaining

### Follow-up Work
```

## Stop conditions

Pause modernization if any of the following occurs:

- application no longer builds
- database connection behavior is unclear
- login or role behavior changes unexpectedly
- generated EF model behavior cannot be reproduced
- important routes or views are removed without replacement
- form POST behavior changes without approval
- validation evidence is missing for a completed task