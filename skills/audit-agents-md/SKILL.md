---
name: audit-agents-md
description: Use to check whether a project's AGENTS.md is in sync with current reality (tech stack, file structure, commands, doc references). Invoke before declaring AGENTS.md "current", when working in a project after a long gap, or after a refactor that touched structure.
---

# Audit AGENTS.md

Compare the project's `AGENTS.md` against the actual repo state. Report
drift. Do NOT auto-edit; the user reviews findings and decides what to
update.

## Steps

1. **Read `AGENTS.md`** at the project root.
2. **Cross-check each claim** against reality:

   | Claim in AGENTS.md | Source of truth |
   |---|---|
   | Tech stack (deps, versions) | `package.json` (or equivalent: pyproject.toml, Cargo.toml, go.mod, etc.) |
   | Build / test / lint commands | `package.json` scripts (or Makefile, taskfile, etc.) |
   | Layout (directories, key files) | actual filesystem (`find`, `ls`) |
   | Doc references (links to other files) | files exist at the linked paths |
   | Deployment paths | CI workflow files (`.github/workflows/*`) and deploy scripts |
   | HARD invariants tied to specific code | grep that the code still exists (function name, env var, schema) |

3. **Categorize findings**:

   - **Stale**: AGENTS.md claims X, reality is Y. (e.g., "React 18" but
     package.json shows 19; "Vite 7" but it's 8.)
   - **Missing**: Reality has X, AGENTS.md doesn't mention it. (e.g., a
     new top-level directory, a new deploy step, a new key in scripts.)
   - **Phantom**: AGENTS.md mentions X, reality no longer has it. (e.g.,
     a removed dep, a renamed file, a deprecated command.)
   - **Locked**: AGENTS.md uses prohibition wording that pins a specific
     version. (e.g., "DO NOT use v4" - flag for softening.)

4. **Report** in this format:

   ```
   AGENTS.md audit: <project name>

   Stale (n):
   - <line ref>: <claim> -> reality is <observation>

   Missing (n):
   - <observation>: not mentioned in AGENTS.md

   Phantom (n):
   - <line ref>: <claim> but no longer in repo

   Locked (n):
   - <line ref>: <prohibition wording> - consider softening

   Verdict: clean | drift | rewrite-needed
   ```

5. **Do not edit**. The user decides what to update. The skill is
   diagnostic, not corrective.

## When to invoke

- Before claiming "AGENTS.md is current" after a structural change
- When picking up a project after a long gap (months)
- After a refactor that touched directories, deps, or commands
- When the user asks "is AGENTS.md still accurate?"
- During the quarterly review (see `LAST_REVIEWED.md` pattern)

## What this skill does NOT do

- Does not check umbrella-level rules (`<KHE_ROOT>/AGENTS.md`,
  `<KHE_ROOT>/CLAUDE.md`). Those are managed via the `khe-ai-rules`
  repo and reviewed quarterly.
- Does not validate prose quality, grammar, or em-dashes (handled by
  umbrella-level rules).
- Does not edit files. Diagnostic only.
