---
name: tdd
description: Use when adding features or fixing bugs that lack test coverage - RED/GREEN/REFACTOR with git checkpoints.
---

# TDD workflow

Write the test first. Make it fail. Make it pass. Refactor.

## When to use

- Adding a new feature
- Fixing a bug (write a test that reproduces the bug, then fix)
- Before any non-trivial refactor

## When NOT to use

- One-off scripts or experiments
- Pure UI tweaks (use visual verification instead)
- Code being deleted

## Cycle

### 1. RED - write a failing test

- Write a test that captures the new behaviour.
- Run it. Confirm it fails for the **intended** reason - not a syntax error, not a missing import, not unrelated breakage.
- A test that compiles but isn't executed does NOT count as RED.

If under git: commit the failing test before continuing.
```
test: reproduce <bug or behaviour>
```

### 2. GREEN - minimum code to pass

- Implement the smallest change that makes the failing test pass.
- Don't add extra features. Don't refactor yet.
- Re-run the test. Confirm it now passes for the right reason.

If under git: commit the fix.
```
fix: <bug>            (for bug fixes)
feat: <behaviour>     (for new features)
```

### 3. REFACTOR - clean up

- Improve naming, extract helpers, remove duplication.
- Re-run tests after each change. They stay green.

If under git, optionally:
```
refactor: clean up <area>
```

## Why git checkpoints

Splitting RED/GREEN/REFACTOR into separate commits gives a reviewer (and future-you) clear evidence the test-first cycle was followed, not retrofitted. The diff for each commit also makes it obvious whether the test actually exercises the changed code path.

## Source

Adapted from [affaan-m/everything-claude-code/skills/tdd-workflow](https://github.com/affaan-m/everything-claude-code/blob/main/skills/tdd-workflow/SKILL.md) (463 lines). Kept: RED/GREEN/REFACTOR cycle, git-checkpoint discipline. Stripped: framework-specific examples (Jest/Vitest/Playwright), 80% coverage dogma, project-specific mocks (Supabase/Redis/OpenAI), test-organization layout.
