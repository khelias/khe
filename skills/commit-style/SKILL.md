---
name: commit-style
description: Use when crafting any git commit message - Conventional Commits format, body explains WHY.
---

# Commit style

Conventional Commits. Body explains the **why** - the diff already shows what.

## Format

```
<type>(<scope>): <subject>

<body - motivation, context, why now>
```

## Types

| Type | Use for |
|---|---|
| `feat` | new feature |
| `fix` | bug fix |
| `refactor` | restructuring without behaviour change |
| `docs` | documentation only |
| `test` | adding or fixing tests |
| `chore` | tooling, deps, config - no production code change |
| `perf` | performance improvement |
| `ci` | CI/CD pipeline change |
| `revert` | revert a previous commit |

## Rules

- Subject in imperative mood ("add X", not "added X" or "adds X")
- Subject under 70 characters, no trailing period
- Body wrap at 72 characters
- Body explains motivation/context - not the diff
- One commit per logical change

## Examples

```
fix(parser): handle BOM in UTF-8 input

Files exported from Excel include a BOM byte that broke the CSV
header detection. Strip it before column mapping.
```

```
feat(auth): rate-limit login attempts

Brute-force attempts spiked last week. 5/min cap matches industry
norm and aligns with the security review requirement.
```

## Source

Conventional Commits standard: <https://www.conventionalcommits.org/>. EWC's [git-workflow](https://github.com/affaan-m/everything-claude-code/blob/main/skills/git-workflow/SKILL.md) skill was 716 lines of Git tutorial - only the conventional-commits format made it here. Branching strategy, merge-vs-rebase, and Git basics belong in project docs (or the agent already knows Git), not in every-session context.
