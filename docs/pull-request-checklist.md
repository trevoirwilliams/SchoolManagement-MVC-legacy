# Pull Request Checklist

Use this checklist for any modernization pull request.

## Pull request summary

The pull request description should explain:

- what modernization step was performed
- why the change is needed
- which files changed
- which behavior was preserved
- which risks were reduced
- which risks remain
- how the work was validated

## Required evidence

| Evidence | Required? | Notes |
|---|---:|---|
| Restore result | Yes | Include command and result |
| Build result | Yes | Include command and result |
| Manual workflow validation | Yes | List checked workflows |
| Dependency changes | If applicable | Include package names and reasons |
| Configuration changes | If applicable | Include old and new setting locations |
| Data access changes | If applicable | Include schema/model impact |
| Account or role workflow changes | If applicable | Include behavior impact |
| UI/static asset changes | If applicable | Include pages checked |
| Known issues | Yes | Do not hide incomplete work |
| Rollback notes | Yes | Identify safe rollback point |

## Reviewer focus areas

Reviewers should pay special attention to:

- route changes
- form POST behavior
- anti-forgery behavior
- role and account workflow changes
- EF6 to EF Core assumptions
- generated model changes
- connection string changes
- package replacements
- Razor view rendering
- JSON response shapes
- JavaScript and CSS references

## PR description template

```markdown
## Summary

## Modernization Scope

## Files Changed

## Behavior Preserved

## Validation Evidence

### Restore

### Build

### Workflow Checks

## Risks and Tradeoffs

## Follow-up Work

## Rollback Notes
```

## Reviewer decision guide

Approve only when:

- the modernization scope is clear
- the changed files match the stated scope
- build evidence is included
- key workflows are validated
- risks are documented
- remaining work is intentionally deferred

Request changes when:

- the PR mixes unrelated modernization work
- behavior changes are not explained
- validation evidence is missing
- access-control behavior changes without review
- data access changes are not justified
- generated code is edited without a clear reason
- configuration changes are incomplete