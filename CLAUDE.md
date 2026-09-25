# CLAUDE.md

@AGENTS.md
@repos/khe-meta/ESTATE.md

## Workflow

Built-ins, no custom skills. Run these without being asked, at default
effort; no `/effort ultracode` or workflows unless the operator asks.

- **Plan** a non-trivial change in plan mode, with each step's check
  command. Plan files land in `repos/khe-meta/plans/` (`plansDirectory`).
  The operator does not switch modes: when a task needs a plan, enter plan
  mode yourself with the `EnterPlanMode` tool rather than planning in chat.
  After writing the plan file and before handing over the `/goal` line,
  have a subagent without this conversation review it: what does the plan
  get wrong or leave out that would break the goal or correctness? Gaps,
  not style. Verify each finding, fix the plan for the real ones, say which
  were dropped.
- **Execute** a written plan through `/goal`, which only the operator can
  type: end the planning turn with the exact line to paste, a condition
  provable from output plus a turn cap, e.g. `/goal every step in
  repos/khe-meta/plans/x.md is checked and npm test exits 0 in the output,
  or stop after 20 turns`.
- **Review** every code change (not docs-only) before committing:
  `/code-review` (medium; `high` for risky or public-facing changes).
  Verify each finding against the code, fix the confirmed ones, and say
  which were dropped. If you skip the review, say so and why.
- **See it working** for UI changes: `/run` in the browser pane.

## Harness facts

- **`git commit` in a repo is gated.** `.claude/hooks/commit-gate.sh` runs
  that repo's `check:` first and blocks the commit on failure. Fix the
  cause; never work around the gate. Do not run `check:` yourself right
  before committing; the gate already does.
- **The gate also scans for personal data** in every repo, the root
  included, unless `repos/repos.yaml` marks it `private: true`: lines the
  commit adds (staged, unstaged, untracked) and the message, against the
  gitleaks patterns in `.claude/hooks/pii-rules.toml` (MAC, isikukood,
  phone, Estonian coordinates, e-mail, LAN address). Pattern-only: names
  and street addresses are not caught and stay a judgement call. Commits
  made by merge, cherry-pick, revert or rebase are not scanned, and a
  same-call `git add -f` is refused: force-add first, then commit. A false
  positive gets an allowlist entry with a reason in `pii-rules.toml`.
- **Parallel sessions:** for a second session in the same repo, use a
  worktree of `repos/<name>`, not a desktop worktree of the workspace root,
  which has no `repos/`. Install dependencies there before committing.
- **Skills in `repos/<name>/.claude/skills/` do not load from here**
  (gitignored directories are skipped). A needed skill goes in this repo's
  `.claude/skills/`, scoped with `paths:`.
- **Grep reaches `repos/` only through `.rgignore`**, which negates the
  `.gitignore` entry.
- **The browser pane reads only this root's `.claude/launch.json`**
  (gitignored, per machine), not a repo's own. Commands run from the root,
  so paths start with `repos/<name>/`. Serve a static build with
  `python3 -m http.server <port> --directory <path>`.
- **The Bash sandbox blocks raw TCP.** WebSocket scripts need
  `dangerouslyDisableSandbox: true`; `curl` and REST do not.
- **The pretooluse guard fails the whole command** if it contains a recursive
  `rm`, a `git checkout --` on a repo file, or a read of any `.env*` file,
  including `.example`. Revert with an edit instead, and ask the operator to
  run anything the guard refuses. Deleting config entries and bulk
  enable/disable scripts also get blocked; inline Python on named entities
  passes.
