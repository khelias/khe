# KHE umbrella CLAUDE.md

Loaded when Claude Code starts in `<KHE_ROOT>/`. This file is the
symlink target of `<KHE_ROOT>/CLAUDE.md`, created by
`khe-ai-rules/install.{sh,ps1}` when both `khe-ai-rules` and `khe-meta`
are cloned under the same parent.

It composes two umbrella-layer sources via `@`-imports:

- `AGENTS.md` (this repo) - personal preferences for AI agents.
- `../khe-meta/ESTATE.md` - canonical KHE estate index.

`@`-paths resolve relative to this file's location (per Anthropic's
Claude Code memory docs), so the imports work regardless of where the
symlink lives.

@AGENTS.md
@../khe-meta/ESTATE.md

## Claude Code only

Tool-agnostic instructions belong in `AGENTS.md`. This section is for
Claude-specific extensions: plan-mode hints, hook references, subagent
dispatch preferences, slash command notes, etc.

Harness facts that are true for Claude Code and not necessarily for other
tools:

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
