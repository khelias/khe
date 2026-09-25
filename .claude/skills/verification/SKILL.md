---
name: verification
description: Use whenever a code change needs to be declared "done" - runs build/typecheck/test/lint and reports honestly.
---

# Verification

Before reporting any code change as complete, run the verification phases.

## Phases

1. **Build** - run the project's build command. If it fails, stop and fix.
2. **Type check** - run the project's typecheck. Report errors.
3. **Lint** - run the project's lint. Report warnings/errors.
4. **Tests** - run the project's test suite.
5. **Diff review** - `git diff --stat` and `git diff` to spot unintended changes, missing error handling, or scope creep.

The exact commands live in the project's `AGENTS.md`. Do not assume `npm`/`pnpm`/`pytest`/etc.

## Output

```
Build:   PASS / FAIL (n errors)
Types:   PASS / FAIL (n errors)
Lint:    PASS / FAIL (n issues)
Tests:   n/m passed
Diff:    n files changed

Verdict: ready / fix-then-ready / blocked
```

## Honesty

- If a phase fails, say so. Don't paper over it.
- If a phase can't be run in this environment (no binary, no network, no test target), say so explicitly.
- Type-check and tests verify CORRECTNESS, not COMPLETENESS - for new features, also describe what was tested by hand.

## Source

Adapted from [affaan-m/everything-claude-code/skills/verification-loop](https://github.com/affaan-m/everything-claude-code/blob/main/skills/verification-loop/SKILL.md) (127 lines). Kept: phase structure, output format. Stripped: hardcoded `npm` commands, 80% coverage threshold, "every 15 minutes" advice, naive `grep "sk-"` security scan.
