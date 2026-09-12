# khe-ai-rules

[![CI](https://github.com/khelias/khe-ai-rules/actions/workflows/ci.yml/badge.svg)](https://github.com/khelias/khe-ai-rules/actions/workflows/ci.yml)

Personal AI coding agent configuration for [Claude Code](https://claude.com/claude-code), [OpenAI Codex CLI](https://developers.openai.com/codex/), and any tool that reads `AGENTS.md`.

## What this is

A small, hand-written foundation built directly from canonical sources - not forked from anyone else's framework.

It does four jobs:

1. **Umbrella-scoped config** - `install.{sh,ps1}` symlinks this repo's `AGENTS.md`, `CLAUDE.md`, `settings.json`, `skills/`, `agents/`, and `hooks/` into `<KHE_ROOT>/` and `<KHE_ROOT>/.claude/`. Personal preferences apply when working under the KHE umbrella; other projects on the same machine are unaffected.
2. **Estate index wiring** - when `khe-meta` is cloned alongside this repo, `<KHE_ROOT>/CLAUDE.md` is linked to `CLAUDE-umbrella.md` which `@`-imports both `AGENTS.md` and `khe-meta/ESTATE.md`. AI agents started at the umbrella root get personal prefs and the estate index together. Skipped gracefully if `khe-meta` isn't cloned. See [`docs/resolution.md`](docs/resolution.md) for the layered model.
3. **Curated workflow library** - `skills/` and `agents/` will hold a small, opinionated, every-file-justified set (Phase 1.5).
4. **Snippet library** - `shared/` for per-project AGENTS.md content (Phase 3).

## Why hand-written, not forked

The AI-tooling space is under a year old. No framework is "battle-tested". The best you can do is keep your surface small enough to maintain. Frameworks bring 10× more files than you understand - most of them dead weight for your actual workflow.

This repo bets on the **standard** ([agents.md](https://agents.md/)), not any specific tool. If a tool dies, the standard moves on. If a framework dies, you're stuck.

## Inventory (every file justified)

| Path | Purpose |
|------|---------|
| `AGENTS.md` | Personal prefs, tool-agnostic. → `<KHE_ROOT>/AGENTS.md`. Auto-read by Codex and 20+ other agents.md-aware tools when launched at the KHE root. |
| `CLAUDE.md` | One-line `@AGENTS.md` import + Claude-only extras section. Used by `install` as the fallback `<KHE_ROOT>/CLAUDE.md` target when `khe-meta` is not cloned. |
| `CLAUDE-umbrella.md` | Combines `@AGENTS.md` and `@../khe-meta/ESTATE.md`. Used as the `<KHE_ROOT>/CLAUDE.md` target when `khe-meta` is cloned alongside this repo. |
| `settings.json` | Claude Code settings. Token-optimization defaults (`model: sonnet`, `MAX_THINKING_TOKENS=10000`, `CLAUDE_AUTOCOMPACT_PCT_OVERRIDE=50`) plus deliberate permission rules: read-only `gh pr`/`gh run` inspection and reversible per-PR writes (`create`, `merge`, `update-branch`, `comment`) are allowed; `--no-verify` is denied so the AGENTS.md "never skip git hooks" rule is enforced, not just documented. Destructive commands (`rm`, force-push) stay denied in `~/.claude/settings.json`, and deny always beats allow. → `<KHE_ROOT>/.claude/settings.json`. |
| `codex/config.toml` | OpenAI Codex CLI config, commented placeholder. Not wired by `install` - Codex reads its CLI config from `~/.codex/config.toml` (user-global, no project-scoped equivalent). Copy manually if you need it. |
| `skills/verification.md` | Run build/typecheck/test/lint and report honestly before declaring done. |
| `skills/tdd.md` | RED/GREEN/REFACTOR cycle with git checkpoints, for new features and bug fixes. |
| `skills/commit-style.md` | Conventional Commits format. Body explains WHY, not WHAT. |
| `agents/code-reviewer.md` | Second-pass reviewer with confidence filter (>80%) and severity rubric. |
| `agents/planner.md` | Plan-before-code subagent for non-trivial features and refactors. |
| `shared/` | Tech-stack snippets for per-project AGENTS.md. Empty - Phase 3. |
| `hooks/` | Claude Code hook scripts. Empty - add when you find a real problem to solve. |
| `install.ps1` / `install.sh` | Symlink files into `<KHE_ROOT>/` and `<KHE_ROOT>/.claude/`. Does not touch `~/.claude/` or `~/.codex/`. Falls back to copy on Windows without Developer Mode. |
| `docs/resolution.md` | Reference for how `AGENTS.md` / `CLAUDE.md` are discovered and merged across umbrella and project layers. Cited from canonical Anthropic + agents.md docs. |
| `renovate.json` | Renovate config. The only managed dependencies here are the GitHub Actions in `ci.yml`; non-major bumps automerge, majors wait for dashboard approval. |
| `LAST_REVIEWED.md` | Quarterly review log against upstream sources. |
| `LICENSE` | MIT. |

You should be able to read every file in this repo in 30 minutes. If you can't, something has gone wrong.

## Install

This repo is project-scoped to the KHE umbrella. Clone it (and `khe-meta`, optionally) under a common parent directory - that parent becomes `<KHE_ROOT>`. The install script wires symlinks under `<KHE_ROOT>/` and `<KHE_ROOT>/.claude/` only; it never modifies `~/.claude/` or `~/.codex/`, so other projects on the same machine remain untouched.

Always launch Claude Code and Codex with the cwd at `<KHE_ROOT>`.

### Windows (PowerShell)

```powershell
cd <KHE_ROOT>
git clone https://github.com/khelias/khe-ai-rules
.\khe-ai-rules\install.ps1
```

Symlinks need Developer Mode (`Settings → Privacy & security → For developers → Developer Mode`) or an admin PowerShell. Without either, the script copies files and warns you to re-run after edits.

### Unix

```bash
cd <KHE_ROOT>
git clone https://github.com/khelias/khe-ai-rules
./khe-ai-rules/install.sh
```

## Phase plan

This repo is foundation only. Personal preferences and project-specific patterns layer in later - committed separately so you can see and roll back each layer.

| Phase | Scope |
|-------|-------|
| **1** | Pure scaffolding: structure, install scripts, AGENTS.md/CLAUDE.md/settings.json placeholders. |
| **1.5** (this commit) | Curated `skills/` (3 files) + `agents/` (2 files), reviewed file-by-file from EWC and trimmed/rewritten. Total ~425 lines, every rule justified. |
| **2** | Fill in personal preferences in `AGENTS.md` (Communication, Code style sections). |
| **3** | Extract reusable tech-stack snippets from existing project `CLAUDE.md` / `.cursor/rules/` into `shared/`. |
| **4** | Per-project migration: replace existing CLAUDE.md / .cursor/rules in project repos with thin per-project `AGENTS.md` + imports from `shared/`. |

## Staying current

The AI-tooling space changes monthly. To not fall behind:

- **Watch** the canonical sources for releases (GitHub → Watch → Releases only):
  - [agentsmd/agents.md](https://github.com/agentsmd/agents.md)
  - [anthropics/claude-code](https://github.com/anthropics/claude-code)
  - [openai/codex](https://github.com/openai/codex)
- **Quarterly review** - calendar reminder, follow checklist in [`LAST_REVIEWED.md`](LAST_REVIEWED.md).
- **Don't be early adopter** for everything - let new tools settle 3–6 months before adopting.

## Sources

This repo's structure and content come from canonical references:

- [agents.md spec](https://agents.md/) - the open standard
- [Anthropic Claude Code memory docs](https://code.claude.com/docs/en/memory) - `@import` pattern, hierarchy
- [OpenAI Codex AGENTS.md guide](https://developers.openai.com/codex/guides/agents-md) - Codex behavior
- [GitHub Blog: lessons from 2,500+ AGENTS.md files](https://github.blog/ai-and-ml/github-copilot/how-to-write-a-great-agents-md-lessons-from-over-2500-repositories/) - content guidance

Inspirational reads (consult for patterns; don't fork wholesale):

- [affaan-m/everything-claude-code](https://github.com/affaan-m/everything-claude-code) - large skill/agent library. Star count is suspect; treat content as inspiration, not authority.
- [citypaul/.dotfiles](https://github.com/citypaul/.dotfiles) - solo-dev scale dotfiles with `--claude-only` install option.
- [WE3io/ai-assistant-rules](https://github.com/WE3io/ai-assistant-rules) - single-source-of-truth pattern with parity CI.

## License

MIT - see [LICENSE](LICENSE).
