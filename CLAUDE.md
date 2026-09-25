# KHE workspace CLAUDE.md

Loaded when Claude Code starts at the workspace root. This repo is the
root: the other KHE repos are cloned into `repos/<name>/` by
`scripts/workspace.sh clone` and are gitignored here.

It composes two sources via `@`-imports:

- `AGENTS.md` (this repo) - personal preferences for AI agents.
- `repos/khe-meta/ESTATE.md` - canonical KHE estate index. Present once
  `khe-meta` is cloned.

@AGENTS.md
@repos/khe-meta/ESTATE.md

## Claude Code only

Tool-agnostic instructions belong in `AGENTS.md`. This section is for
Claude-specific extensions: plan-mode hints, hook references, subagent
dispatch preferences, slash command notes, etc.

Harness facts that are true for Claude Code and not necessarily for other
tools:

- **Skills inside `repos/<name>/.claude/skills/` do not load from here.**
  Claude Code skips skill discovery in gitignored directories. A skill needed
  from the workspace root goes in this repo's `.claude/skills/`, scoped with
  `paths:` when it belongs to one repo. A repo's own skills load when a
  session starts inside that repo.
- **Grep reaches `repos/` only through `.rgignore`.** Grep respects
  `.gitignore` and ignores `.ignore`; the `.rgignore` negation puts the repos
  back into root-level searches.
- **The Bash sandbox blocks raw TCP.** A `websockets` client fails with
  `No route to host` while `curl` to the same host and port works. Run
  WebSocket scripts with `dangerouslyDisableSandbox: true`; REST needs no
  exception.
- **The pretooluse guard fails the whole command** if it contains a recursive
  `rm`, a `git checkout --` on a repo file, or a read of any `.env*` file,
  including `.example`. Revert with an edit instead, and ask the operator to
  run anything the guard refuses.
- Deleting config entries and bulk enable/disable scripts get blocked;
  inline Python acting on named entities passes.
