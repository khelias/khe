# How AI agents find these files

Reference for how `AGENTS.md` and `CLAUDE.md` files are discovered and merged
across the layers used in the KHE estate. Verified against canonical docs
(sources at the bottom).

## The two layers wired by this repo

| Layer | Where | Loaded as | Set up by |
|-------|-------|-----------|-----------|
| **Umbrella** | `<KHE_ROOT>/AGENTS.md`, `<KHE_ROOT>/CLAUDE.md`, `<KHE_ROOT>/.claude/{skills,agents,hooks,settings.json}` | Loaded when CWD is `<KHE_ROOT>` (the assumed launch directory). Personal preferences, estate index, curated skills/agents/hooks, settings defaults. | `khe-ai-rules/install.{sh,ps1}` symlinks each path to a file or directory in this repo. |
| **Project** | `<KHE_ROOT>/khe-*/AGENTS.md`, `<KHE_ROOT>/khe-*/CLAUDE.md` | Loaded lazily when Claude reads or edits a file in that subtree. Project-specific commands, architecture, invariants. | Tracked in each project's git repo. |

The two layers compose: project-level adds to (and can override) umbrella.

`khe-ai-rules` does **not** write to `~/.claude/` or `~/.codex/`. Those
user-global directories are reserved for prefs from other projects on the
same machine and are intentionally left untouched.

## Claude Code (`CLAUDE.md`)

[Source: code.claude.com/docs/en/memory](https://code.claude.com/docs/en/memory)

- **Walks UP the directory tree from CWD**, reading every `CLAUDE.md` it
  finds. All files concatenated; closer files load last (so they win
  conflicts).
- `~/.claude/CLAUDE.md` is the user-level scope, always loaded - this repo
  does not populate it, but if other tools or other projects place a file
  there, Claude will still read it.
- **Sub-directory CLAUDE.md files load lazily** - only when Claude reads or
  edits a file in that subtree.
- `@path` imports are resolved relative to the file containing the import.
  Max import depth: four hops.
- **Claude Code reads `AGENTS.md` natively only when there is no
  `CLAUDE.md`** (from v2.1.277). The default mode, `claude-md-or-agents-md`,
  skips every `AGENTS.md` once a `CLAUDE.md`, `.claude/CLAUDE.md` or
  `CLAUDE.local.md` exists in the cwd or any parent. The umbrella
  `<KHE_ROOT>/CLAUDE.md` is such a parent for every KHE repo, so each
  CLAUDE.md here still `@`-imports its AGENTS.md (the pattern this repo
  uses). The alternative, `claude-md-and-agents-md`, is a user-level
  setting and would change every project on the machine, not just KHE.
- **Skills are discovered only as `skills/<name>/SKILL.md`.** A flat
  `skills/*.md` file is silently ignored. `scripts/validate_frontmatter.py`
  fails CI on one.

What this means for KHE: when you start Claude in `<KHE_ROOT>/`, the
umbrella layer loads up front (personal prefs via `@AGENTS.md`, estate
index via `@../khe-meta/ESTATE.md`, plus skills/agents/hooks/settings from
`<KHE_ROOT>/.claude/`). Per-project layers come in the moment Claude
touches a file in that project.

## Codex / Cursor / Aider / others (`AGENTS.md`)

[Source: agents.md spec](https://agents.md/)

- "Place another `AGENTS.md` inside each package. Agents automatically read
  the **nearest file in the directory tree**, so the closest one takes
  precedence."
- The spec defines monorepo discovery; non-git umbrella folders are
  unspecified, but in practice tools walk up the same way Claude Code does.

What this means for KHE: tools find the closest `AGENTS.md` to the file
being edited. Working inside `khe-homelab/`, they get
`khe-homelab/AGENTS.md`. Working at the umbrella root, they get
`<KHE_ROOT>/AGENTS.md` (the symlink to `khe-ai-rules/AGENTS.md`).

Note: agents.md does not support `@`-imports, so `<KHE_ROOT>/AGENTS.md`
contains personal prefs only - it does not include `khe-meta/ESTATE.md`
content. If you need the estate index in Codex too, navigate into the
relevant sub-repo (its `AGENTS.md` references estate-level info as needed)
or generate a composite manually.

## CLAUDE.md composition at the umbrella

`<KHE_ROOT>/CLAUDE.md` symlinks to one of two files in this repo,
depending on whether `khe-meta` is cloned alongside it:

- If `<KHE_ROOT>/khe-meta/ESTATE.md` exists: symlink to
  `khe-ai-rules/CLAUDE-umbrella.md`, which `@`-imports both
  `AGENTS.md` and `../khe-meta/ESTATE.md`.
- Otherwise: symlink to `khe-ai-rules/CLAUDE.md`, which only imports
  `AGENTS.md`. The install script logs a note suggesting you clone
  `khe-meta` and re-run for full umbrella context.

`@`-paths in both variants are resolved relative to the file's actual
location in `khe-ai-rules/`, not the symlink path - so the imports work
regardless of where the symlink lives.

## Per-machine setup

Clone `khe-ai-rules` and `khe-meta` under the same parent directory on
each machine, then run `khe-ai-rules/install.{sh,ps1}`. The script
infers `<KHE_ROOT>` as its own parent and creates:

- `<KHE_ROOT>/AGENTS.md` and `<KHE_ROOT>/CLAUDE.md` (linked to this repo).
- `<KHE_ROOT>/.claude/{settings.json,skills,agents,hooks}` (linked to this repo).
- `<KHE_ROOT>/.claude/settings.local.json` and any other local files there
  are preserved untouched.

If `khe-meta/` is not cloned, the umbrella `CLAUDE.md` falls back to the
non-estate variant with a note. Re-run the script after cloning `khe-meta`
to pick up the full umbrella.

## Sources

- [Anthropic Claude Code memory docs](https://code.claude.com/docs/en/memory) - resolution rules, `@import`, lazy sub-dir loading.
- [agents.md spec](https://agents.md/) - nearest-file discovery, monorepo guidance.
- Published patterns aligned with this layout: [Spine pattern](https://tsoporan.com/blog/spine-pattern-multi-repo-ai-development/), [Virtual Monorepo pattern](https://medium.com/devops-ai/the-virtual-monorepo-pattern-how-i-gave-claude-code-full-system-context-across-35-repos-43b310c97db8).
