# Last Reviewed

Track when this repo was last reviewed against upstream best practices.

| Date       | Notes |
|------------|-------|
| 2026-09-25 | Became the workspace root (`khe`): config under `.claude/`, repos cloned into gitignored `repos/` from `repos/repos.yaml`, `.rgignore` for Grep, install scripts and symlinks removed. Layout choices tested with headless Claude Code 2.1.274; results in `ROADMAP.md`. |
| 2026-09-25 | Review against Claude Code 2.1.282, Codex, Agent Skills spec. Found the four skills had never loaded (flat `*.md`; discovery needs `<name>/SKILL.md`): moved them, CI now rejects flat files. `settings.json`: dropped `model: sonnet` pin and `MAX_THINKING_TOKENS` (ignored on adaptive models), emptied `attribution`. `docs/resolution.md` updated for native AGENTS.md reading (v2.1.277, only without CLAUDE.md). Open work in `ROADMAP.md`. |
| 2026-05-03 | Phase 1.5: skills/ (verification, tdd, commit-style) + agents/ (code-reviewer, planner) added. Reviewed 5 EWC source files (1750 lines combined), kept ~25% as adapted, wrote rest from scratch. Each file attributes source and notes what was stripped. |
| 2026-05-03 | Phase 1: frame committed. Foundation built from agents.md spec + Anthropic memory docs + OpenAI Codex AGENTS.md guide + GitHub Blog 2500-repo analysis. |

## Quarterly review checklist

When the calendar reminder fires (every 3 months):

1. Check [agents.md spec](https://agents.md/) - any spec changes?
2. Check [Anthropic Claude Code memory docs](https://code.claude.com/docs/en/memory) - new patterns?
3. Check [OpenAI Codex AGENTS.md guide](https://developers.openai.com/codex/guides/agents-md) - Codex behavior changes?
4. Skim 2–3 top-trending repos at [GitHub search: agents.md](https://github.com/search?q=agents.md&type=repositories&s=stars&o=desc) - any new patterns worth adopting?
5. Add a row above with date and a one-line summary of changes (or "no changes").

## Watch list (GitHub → Watch → Releases only)

- [agentsmd/agents.md](https://github.com/agentsmd/agents.md)
- [anthropics/claude-code](https://github.com/anthropics/claude-code)
- [openai/codex](https://github.com/openai/codex)
