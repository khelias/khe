# How AI agents find these files

Reference for how `AGENTS.md`, `CLAUDE.md`, skills and settings are
discovered across the layers of the KHE workspace. Verified against
canonical docs and a headless Claude Code 2.1.274 test (sources at the
bottom).

## The two layers

| Layer | Where | Loaded as | Tracked in |
|-------|-------|-----------|------------|
| **Workspace root** | `<KHE_ROOT>/AGENTS.md`, `<KHE_ROOT>/CLAUDE.md`, `<KHE_ROOT>/.claude/{settings.json,skills,agents,hooks}` | Loaded when the session starts at `<KHE_ROOT>`. Personal preferences, estate index, curated skills/agents, settings. | This repo, which is `<KHE_ROOT>` itself. |
| **Repo** | `<KHE_ROOT>/repos/<name>/AGENTS.md`, `.../CLAUDE.md` | Loaded lazily when Claude reads or edits a file in that repo. Repo-specific commands, architecture, invariants. | Each repo's own git history. `repos/` is gitignored here. |

The layers compose: repo-level adds to (and can override) the root.

Nothing here writes to `~/.claude/` or `~/.codex/`. Those user-global
directories also serve projects outside KHE and are left alone.

## Claude Code

[Source: code.claude.com/docs/en/memory](https://code.claude.com/docs/en/memory)

- **Walks UP the directory tree from CWD**, reading every `CLAUDE.md` it
  finds. All files concatenated; closer files load last (so they win
  conflicts).
- `~/.claude/CLAUDE.md` is the user-level scope, always loaded - this repo
  does not populate it, but if other tools or other projects place a file
  there, Claude will still read it.
- **Sub-directory CLAUDE.md files load lazily** - only when Claude reads or
  edits a file in that subtree. This works inside gitignored `repos/` too.
- `@path` imports are resolved relative to the file containing the import.
  Max import depth: four hops.
- **Claude Code reads `AGENTS.md` natively only when there is no
  `CLAUDE.md`** (from v2.1.277). The default mode, `claude-md-or-agents-md`,
  skips every `AGENTS.md` once a `CLAUDE.md`, `.claude/CLAUDE.md` or
  `CLAUDE.local.md` exists in the cwd or any parent. The root
  `<KHE_ROOT>/CLAUDE.md` is such a parent for every KHE repo, so each
  CLAUDE.md here still `@`-imports its AGENTS.md. The alternative,
  `claude-md-and-agents-md`, is a user-level setting and would change every
  project on the machine, not just KHE.
- **Skills are discovered only as `.claude/skills/<name>/SKILL.md`.** A flat
  `*.md` file there is silently ignored. `scripts/validate_frontmatter.py`
  fails CI on one.
- **Skills in gitignored directories are not discovered.** Skills under
  `repos/<name>/.claude/skills/` therefore load only in a session started
  inside that repo. Skills needed from the root go in the root
  `.claude/skills/`, scoped with `paths:` if they belong to one repo.
- **Grep respects `.gitignore` and ignores `.ignore`, but honours
  `.rgignore`.** The root `.rgignore` negates `/repos/*` so root-level
  searches reach the repos; each repo's own `.gitignore` still applies
  inside it.
- **Project settings are not inherited.** `repos/<name>/.claude/settings.json`
  applies only to a session started in that repo.
- **Auto memory is keyed by git root.** Sessions at `<KHE_ROOT>` share one
  memory directory; a session started inside a repo gets that repo's own.

## Codex / Cursor / Aider / others (`AGENTS.md`)

[Source: agents.md spec](https://agents.md/)

- "Place another `AGENTS.md` inside each package. Agents automatically read
  the **nearest file in the directory tree**, so the closest one takes
  precedence."
- Codex reads `AGENTS.md` files from the git root down to the cwd. At
  `<KHE_ROOT>` that is this repo's `AGENTS.md`; inside `repos/<name>/` the
  repo is its own git root, so Codex sees only that repo's file (plus
  `~/.codex/AGENTS.md`).

agents.md has no `@`-imports, so for Codex the root `AGENTS.md` carries the
personal prefs only, not the estate index. `AGENTS.md` points at
`repos/khe-meta/ESTATE.md` by path instead.

## Per-machine setup

```bash
git clone https://github.com/khelias/khe.git
cd khe
scripts/workspace.sh clone
```

The repos land in `repos/<name>/` from `repos/repos.yaml`. Local files such
as `.claude/settings.local.json` and `.claude/launch.json` are gitignored and
stay per machine.

## Sources

- [Anthropic Claude Code memory docs](https://code.claude.com/docs/en/memory) - resolution rules, `@import`, lazy sub-dir loading, auto memory location.
- [Claude Code tools reference](https://code.claude.com/docs/en/tools-reference) - Grep respects `.gitignore`.
- [Set up Claude Code in a large codebase](https://code.claude.com/docs/en/large-codebases) - settings not inherited, per-directory skills.
- [agents.md spec](https://agents.md/) - nearest-file discovery, monorepo guidance.
- Published workspace patterns this layout follows: [Repo-of-Repos](https://raffertyuy.com/raztype/repo-of-repos-pattern/), [Structuring Claude Code for multi-repo workspaces](https://karun.me/blog/2026/03/26/structuring-claude-code-for-multi-repo-workspaces/), [Virtual Monorepo pattern](https://medium.com/devops-ai/the-virtual-monorepo-pattern-how-i-gave-claude-code-full-system-context-across-35-repos-43b310c97db8).
