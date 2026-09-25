# .claude/agents/

Specialized subagents for delegated tasks. Each agent is a markdown file with
YAML frontmatter that the main agent dispatches to.

## What's here

- [`code-reviewer.md`](code-reviewer.md) - second-pass reviewer with confidence filter (>80%) and severity rubric (CRITICAL/HIGH/MEDIUM/LOW). Adapted from EWC's code-reviewer, trimmed of framework-specific deep-dives.
- [`planner.md`](planner.md) - plan-before-code for non-trivial features and refactors. Adapted from EWC's planner, replaced 70-line Stripe example with shorter rate-limit example. Changed `model: opus` → `model: sonnet`.

Each file ends with a "Source" section attributing the EWC original.

## When to add an agent

Only when you find yourself doing the same kind of delegation repeatedly.
Subagents aren't free - each one is more context to maintain and another
prompt to keep in sync with your main rules.

## Inspiration

- [affaan-m/everything-claude-code/agents](https://github.com/affaan-m/everything-claude-code/tree/main/agents) - 48 agents as patterns library
- [Anthropic subagent docs](https://code.claude.com/docs/en/sub-agents)
