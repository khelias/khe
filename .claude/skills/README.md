# .claude/skills/

Reusable workflow guides the agent invokes when relevant. Each skill is a
folder `<name>/SKILL.md` with YAML frontmatter; `name` must match the
folder. A flat `<name>.md` here is never discovered by Claude Code (the
four skills here sat unloaded from May to September 2026 for that reason),
and CI now rejects one.

```yaml
---
name: skill-name
description: When to use this skill (one sentence - the agent matches against this)
---

[markdown body - instructions, examples, checklists]
```

## What's here

- [`verification`](verification/SKILL.md) - run build/typecheck/test/lint and report honestly. Adapted from EWC's verification-loop, stripped of hardcoded `npm` commands and coverage dogma.
- [`tdd`](tdd/SKILL.md) - RED/GREEN/REFACTOR cycle with git checkpoints. Adapted from EWC's tdd-workflow, stripped of framework-specific examples (was 463 lines, now 63).
- [`commit-style`](commit-style/SKILL.md) - Conventional Commits format. The 30 useful lines extracted from EWC's 716-line git-workflow tutorial.
- [`audit-agents-md`](audit-agents-md/SKILL.md) - compare a project's AGENTS.md with the repo's actual state and report drift.

Each file ends with a "Source" section attributing the EWC original and noting what was kept vs trimmed.

## Inspiration sources (read, don't fork)

- [agents.md spec](https://agents.md/) - canonical
- [affaan-m/everything-claude-code/skills](https://github.com/affaan-m/everything-claude-code/tree/main/skills) - 182 skills as patterns library (treat as inspiration; verify quality file by file)
- [citypaul/.dotfiles](https://github.com/citypaul/.dotfiles) - solo-dev scale

## Adding a skill

1. Identify a workflow you keep correcting the agent on
2. Create `<name>/SKILL.md` with frontmatter and concrete steps - keep under 50 lines
3. Test by invoking it; refine based on what the agent gets wrong
