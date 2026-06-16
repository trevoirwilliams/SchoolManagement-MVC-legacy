# Prompt 07: Pull Request Summary

Use this prompt after a modernization checkpoint is complete.

```text
Create a professional pull request summary for the current modernization checkpoint.

Use the current git diff and repository context.

Return:
1. Summary of the change
2. Business reason for the change
3. Files changed
4. Modernization scope
5. Behavior intentionally preserved
6. Behavior intentionally changed
7. Build and validation evidence to include
8. Risks remaining
9. Follow-up work
10. Reviewer checklist
11. Rollback notes

Use this Markdown structure:

## Summary

## Why This Change Is Needed

## Files Changed

## Modernization Scope

## Behavior Preserved

## Behavior Changed

## Validation Evidence

## Risks and Tradeoffs

## Follow-up Work

## Reviewer Checklist

## Rollback Notes
```

## Expected output

The response should be specific to the changed files and should not claim validation that has not actually been performed.