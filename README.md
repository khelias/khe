# khe

[![CI](https://github.com/khelias/khe/actions/workflows/ci.yml/badge.svg)](https://github.com/khelias/khe/actions/workflows/ci.yml)

Workspace repo for the KHE estate: open this folder in [Claude Code](https://claude.com/claude-code), [OpenAI Codex CLI](https://developers.openai.com/codex/) or any tool that reads `AGENTS.md`, and every KHE repo is reachable under `repos/` with shared AI-agent configuration at the root. Formerly `khe-ai-rules`.

## What this is

A small, hand-written foundation built directly from canonical sources - not forked from anyone else's framework. It follows the multi-repo workspace layout that became the common pattern for AI coding agents in 2026 (meta-repo, repo-of-repos, virtual monorepo):

```text
khe/                         this repo, the workspace root
  AGENTS.md                  personal preferences, tool-agnostic
  CLAUDE.md                  imports AGENTS.md and the estate index
  .claude/                   settings, skills, agents, hooks for Claude Code
  repos/
    repos.yaml               which repos the workspace clones (tracked)
    khe-meta/                independent clones, gitignored here
    khe-homelab/
    ...
  scripts/workspace.sh       clone | pull | status
```

It does three jobs:

1. **Workspace root** - one folder to open. Each repo keeps its own history, CI and `AGENTS.md`; nothing is symlinked and there is no install step. See [`docs/resolution.md`](docs/resolution.md) for how each tool finds each file.
2. **Estate index wiring** - `CLAUDE.md` `@`-imports `AGENTS.md` and `repos/khe-meta/ESTATE.md`, so a session at the root gets personal prefs and the estate index together.
3. **Curated workflow library** - `.claude/skills/` and `.claude/agents/` hold a small, opinionated, every-file-justified set.

## Why hand-written, not forked

The AI-tooling space is young and changes monthly. No framework is "battle-tested". The best you can do is keep your surface small enough to maintain. Frameworks bring 10× more files than you understand - most of them dead weight for your actual workflow.

This repo bets on the **standards** ([agents.md](https://agents.md/), [Agent Skills](https://agentskills.io/)), not any specific tool. If a tool dies, the standard moves on. If a framework dies, you're stuck.

## Inventory (every file justified)

| Path | Purpose |
|------|---------|
| `AGENTS.md` | Personal prefs, tool-agnostic. Auto-read by Codex and 20+ other agents.md-aware tools when launched at the root. |
| `CLAUDE.md` | `@AGENTS.md` + `@repos/khe-meta/ESTATE.md`, plus Claude-only harness facts. |
| `.claude/settings.json` | Claude Code settings. No model pin (the Claude Code default applies), `CLAUDE_AUTOCOMPACT_PCT_OVERRIDE=50`, and `attribution` emptied so the AGENTS.md "no agent attribution" rule is enforced by the harness. The object form is used because `attribution: false` needs v2.1.281+ and older versions skip the whole file on it. Also deliberate permission rules: read-only `gh pr`/`gh run` inspection and reversible per-PR writes (`create`, `merge`, `update-branch`, `comment`) are allowed; `--no-verify` is denied so the AGENTS.md "never skip git hooks" rule is enforced, not just documented. Destructive commands (`rm`, force-push) stay denied in `~/.claude/settings.json`, and deny always beats allow. |
| `.claude/skills/verification/SKILL.md` | Run build/typecheck/test/lint and report honestly before declaring done. |
| `.claude/skills/tdd/SKILL.md` | RED/GREEN/REFACTOR cycle with git checkpoints, for new features and bug fixes. |
| `.claude/skills/commit-style/SKILL.md` | Conventional Commits format. Body explains WHY, not WHAT. |
| `.claude/skills/audit-agents-md/SKILL.md` | Check a repo's AGENTS.md against its actual state; reports drift, does not edit. |
| `.claude/agents/code-reviewer.md` | Second-pass reviewer with confidence filter (>80%) and severity rubric. |
| `.claude/agents/planner.md` | Plan-before-code subagent for non-trivial features and refactors. |
| `.claude/hooks/` | Claude Code hook scripts. Empty - add when you find a real problem to solve. |
| `repos/repos.yaml` | The repos this workspace clones: name, URL, optional `upstream`, description. |
| `repos/README.md` | What lives in `repos/` and why plain nested clones rather than submodules. |
| `scripts/workspace.sh` | `clone` missing repos, `pull` (fast-forward clean repos), `status` (branch, dirty, ahead/behind). |
| `.gitignore` | Ignores `repos/*` except the manifest and README, plus per-machine files. |
| `.rgignore` | Puts `repos/` back into Claude Code's Grep, which otherwise honours `.gitignore`. |
| `shared/` | Tech-stack snippets for per-repo AGENTS.md. Empty - Phase 3. |
| `codex/config.toml` | OpenAI Codex CLI config, commented placeholder. Codex reads its CLI config from `~/.codex/config.toml`; copy manually if you need it. |
| `docs/resolution.md` | How `AGENTS.md`, `CLAUDE.md`, skills and settings are discovered across the root and repo layers, including the gitignore effects. |
| `scripts/validate_frontmatter.py` | CI check: agent and skill frontmatter, skill folder layout. |
| `scripts/check_freshness.py` | CI warning when `LAST_REVIEWED.md` is older than 90 days. |
| `renovate.json` | Renovate config. The only managed dependencies here are the GitHub Actions in `ci.yml`; non-major bumps automerge, majors wait for dashboard approval. |
| `LAST_REVIEWED.md` | Quarterly review log against upstream sources. |
| `ROADMAP.md` | Open work from the latest review, ordered by payoff against effort. |
| `LICENSE` | MIT. |

You should be able to read every file in this repo in 30 minutes. If you can't, something has gone wrong.

## Setup

```bash
git clone https://github.com/khelias/khe.git
cd khe
scripts/workspace.sh clone
```

Launch Claude Code and Codex from this folder. Nothing outside it is touched: `~/.claude/` and `~/.codex/` keep serving other projects on the same machine.

Day to day:

```bash
scripts/workspace.sh status
scripts/workspace.sh pull
```

## Phase plan

| Phase | Scope |
|-------|-------|
| **1** | Scaffolding: structure, AGENTS.md/CLAUDE.md/settings.json placeholders. |
| **1.5** | Curated skills (3 files) + agents (2 files), reviewed file-by-file from EWC and trimmed/rewritten. Total ~425 lines, every rule justified. |
| **2** | Personal preferences in `AGENTS.md` (Communication, Code style sections). |
| **2.5** | 2026-09: became the workspace root; symlinks and install scripts removed. |
| **3** | Extract reusable tech-stack snippets from existing repo `CLAUDE.md` / `.cursor/rules/` into `shared/`. |
| **4** | Per-repo migration: thin per-repo `AGENTS.md` + snippets from `shared/`. |

Work found by the 2026-09 review against the current tooling lives in [`ROADMAP.md`](ROADMAP.md).

## Staying current

The AI-tooling space changes monthly. To not fall behind:

- **Watch** the canonical sources for releases (GitHub → Watch → Releases only):
  - [agentsmd/agents.md](https://github.com/agentsmd/agents.md)
  - [anthropics/claude-code](https://github.com/anthropics/claude-code)
  - [openai/codex](https://github.com/openai/codex)
- **Quarterly review** - follow the checklist in [`LAST_REVIEWED.md`](LAST_REVIEWED.md). A calendar reminder did not hold; [`ROADMAP.md`](ROADMAP.md) plans a scheduled routine instead.
- **Don't be early adopter** for everything - let new tools settle 3–6 months before adopting.

## Sources

This repo's structure and content come from canonical references:

- [agents.md spec](https://agents.md/) - the open standard
- [Agent Skills spec](https://agentskills.io/specification) - `SKILL.md` format
- [Anthropic Claude Code memory docs](https://code.claude.com/docs/en/memory) - `@import` pattern, hierarchy
- [OpenAI Codex AGENTS.md guide](https://developers.openai.com/codex/guides/agents-md) - Codex behavior
- [GitHub Blog: lessons from 2,500+ AGENTS.md files](https://github.blog/ai-and-ml/github-copilot/how-to-write-a-great-agents-md-lessons-from-over-2500-repositories/) - content guidance
- Workspace layout: [Repo-of-Repos](https://raffertyuy.com/raztype/repo-of-repos-pattern/), [Structuring Claude Code for multi-repo workspaces](https://karun.me/blog/2026/03/26/structuring-claude-code-for-multi-repo-workspaces/)

Inspirational reads (consult for patterns; don't fork wholesale):

- [affaan-m/everything-claude-code](https://github.com/affaan-m/everything-claude-code) - large skill/agent library. Treat content as inspiration, not authority.
- [obra/superpowers](https://github.com/obra/superpowers) - mature skills workflow (plan, subagent execution, TDD, verification).
- [citypaul/.dotfiles](https://github.com/citypaul/.dotfiles) - solo-dev scale dotfiles with `--claude-only` install option.
- [WE3io/ai-assistant-rules](https://github.com/WE3io/ai-assistant-rules) - single-source-of-truth pattern with parity CI.

## License

MIT - see [LICENSE](LICENSE).
