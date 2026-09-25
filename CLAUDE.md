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

### Workflow: built-ins, no custom skills

Run these without being asked; hand-invoked tools went unused. Keep them
cheap: default effort, no `/effort ultracode`, no workflows unless the
operator asks.

- **Plan** a non-trivial change in plan mode and save it as a file in the
  repo it belongs to, with each step's check command.
- **Execute** a written plan with `/goal <condition provable from output>
  or stop after N turns`, e.g. every step checked and the repo's test
  commands exit 0.
- **Review** before committing a non-trivial code change: `/code-review`
  (medium; `high` for risky or public-facing changes). Verify each finding
  against the code before fixing it, fix the confirmed ones, drop the rest,
  and say which were dropped.
- **See it working** for UI changes: `/run` in the browser pane, at mobile
  and desktop width, before calling it done.

### Harness facts

True for Claude Code, not necessarily for other tools:

- **Skills inside `repos/<name>/.claude/skills/` do not load from here.**
  Claude Code skips skill discovery in gitignored directories. A skill needed
  from the workspace root would go in this repo's `.claude/skills/`, scoped
  with `paths:` when it belongs to one repo.
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
