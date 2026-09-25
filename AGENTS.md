# Personal AGENTS.md

Personal instructions for AI coding agents, at the root of the KHE
workspace repo (`<KHE_ROOT>`; the other repos live in `repos/<name>/`).
Auto-loaded by:

- OpenAI Codex CLI and 20+ other AGENTS.md-aware tools, when run with cwd at `<KHE_ROOT>`
- Claude Code (via `<KHE_ROOT>/CLAUDE.md` which `@`-imports this file)

This file holds **personal preferences** that apply to every project
in the KHE workspace. Other projects on the same machine are not
affected by this file - their own `~/.claude/` or per-project setup
applies instead. For KHE-project-specific instructions, use a
per-project `AGENTS.md`.

Keep this file under 200 lines. It's loaded into every session, so size costs tokens forever.

---

## Communication

- Conversation language: Estonian (primary working language).
- Code, identifiers, in-code comments: English (industry convention, portability).
- User-facing translations and localization: Estonian, grammatically correct. No machine-translated approximations. If unsure, ask.
- Match response weight to question weight. Routine work gets terse output. Architectural or decision-heavy work gets the reasoning trail. The user works with the agent partly to learn, not just to receive magic results.
- Avoid AI-tells that signal machine-generated output:
  - No emoji.
  - No em-dashes. Use a regular hyphen, comma, or rephrase.
  - No bloated openings ("Great question!", "Certainly!", "I'll help you with that").
  - No bloated closings ("Let me know if you need anything else", "Hope this helps").
  - No unnecessary headers, tables, or bullet lists on simple answers. Match formatting to content weight.

## Code style

- All code, identifiers, file names, in-code comments: English.
- Estonian appears only in user-facing strings, i18n and translation tables (grammatically correct), and conversation with the user.
- Comments inside code: only when the WHY is non-obvious (covered in Boundaries below).

## Documentation

- Trivial changes (typos, small internal refactors) do not need README or doc updates. Adding docs for every change adds noise.
- However, no module should be completely undocumented. If you touch a feature that has no doc string or no README mention, add a one-line summary while you're there.
- When uncertain whether something needs documenting, ASK before adding.

After a non-trivial change (new feature, refactor that moves files, removed
concept, behaviour shift), sweep the project's existing docs for staleness
before declaring done. Minimum sweep targets:

- `README.md`, `ARCHITECTURE.md`, `ROADMAP.md` if present.
- `AGENTS.md` / `CLAUDE.md` (project + workspace root).
- Affected ADRs (the status field and any claims about current behaviour).
- Other `docs/*.md` whose subject overlaps the change.

The test: would a fresh agent reading these docs after my change form a
misleading mental model? If yes, update inline in the same commit. Update
existing files; do NOT create new doc files without asking.

This is a judgment call, not a hard rule.

## Maintaining project AGENTS.md

When a structural change lands in a project (deps bump that touches a
named library, refactor that moves files, new architectural decision,
build/test/deploy command change, new HARD invariant), update that
project's `AGENTS.md` in the SAME commit. AGENTS.md should reflect
current reality, not historical reality.

Prefer descriptive facts over prohibitions. "Tailwind v3 currently"
beats "DO NOT use v4" - the prohibition becomes silently wrong on the
day v4 lands. Architectural prohibitions stay (security, invariants),
but couple them with an override path ("without an ADR") so the rule
is not a permanent lock.

## Who runs what

The agent prepares, the operator executes anything that leaves this machine or
touches a running host:

- `git push`, `ssh`, and any command against the homelab VM are the operator's.
  Hand them over as complete, copy-pasteable command blocks, one command per
  block, in the order they must run. A half-given chain costs a round trip.
- Commit locally as normal. Say plainly what still needs pushing.
- Read-only APIs (Home Assistant, GitHub) the agent uses directly.

## Where the estate is described

- `repos/khe-meta/ESTATE.md` - the estate index: every repo, what it is for, where
  it is deployed. Start there when it is not obvious which repo owns a thing.
- `repos/khe-meta/house/` - private house documentation: Home Assistant rollout
  and measurements, HVAC, network. Device ids, LAN addresses of house devices
  and anything identifying live here and **never** in a public repo.
- Each repo's own `AGENTS.md` - its commands, conventions and operating
  procedure. `repos/khe-homelab/AGENTS.md` has the Home Assistant procedure.
- `repos/repos.yaml` - which repos the workspace clones;
  `scripts/workspace.sh status` shows each one's branch and dirty state.

## Verification

The agent MUST verify changes before declaring done:

- Run the project's test command
- Run the project's typecheck/lint command
- For UI changes, verify in a running browser if a dev server is available
- Report verification results explicitly, both successes and failures

If verification can't be performed in this environment, say so. Do not claim success.

## Judgement

These are corrections the operator has had to make more than once. They cost
nothing to follow and they are the difference between advice that gets used
and advice that gets ignored.

- **Check a fact at its source before calling it a problem.** One row of data
  is not a finding. Do not recommend undoing a decision, a booking or a
  setting on the strength of a single number that has not been verified where
  it came from.
- **Keep effort and payoff in proportion.** A recommendation that costs money
  or a weekend has to be worth it against what is already in place. Say what
  the existing data or hardware already gives before proposing more of it.
- **Ask when people actually do the thing before optimising timing.** A
  schedule that is right on paper and wrong for the household is wrong. Pin
  down the moment that matters rather than the whole window.
- **Look for the earlier work before writing a new plan.** Docs, git history
  and the estate's own plan files usually hold a decision that was already
  made; continuing it beats re-deciding it.
- **Prefer the current stable version.** Check what the newest stable release
  is before pinning; starting from an outdated base costs more over time than
  the upgrade risk it avoids.
- **Do not inherit a number without checking it.** A figure carried over from
  an older document is not evidence, and inventing a justification for it is
  worse than saying it is unverified.
- **Write longer plans to a file, not into the conversation.** A plan that
  only exists in chat is lost by the next session.

## Boundaries

### Always

- Read existing code before editing
- Prefer editing existing files over creating new ones
- Verify changes before declaring done

### Ask first

- Destructive operations (`rm -rf`, `git reset --hard`, dropping tables, force-push)
- Rewriting published commits
- Adding new dependencies
- Changes to CI/CD pipelines

### Never

- Skip git hooks (`--no-verify`)
- Commit secrets, `.env` files, credentials
- Add unrequested documentation files (READMEs, CHANGELOGs)
- Add comments explaining WHAT code does. Only WHY when non-obvious.
- Put agent attribution in commit messages or pull request descriptions. No
  `Co-Authored-By` for the agent, no "generated with" footer, forks included.

## File hygiene

- Don't leave half-finished code or commented-out blocks
- Don't add features beyond the task scope
- Don't introduce abstractions for hypothetical future needs
- Write verification artifacts (screenshots, saved pages, one-off scripts) to
  the session scratchpad, not into a repo or `<KHE_ROOT>/`

---

## What goes elsewhere

- **Project-specific commands and architecture** → that project's `AGENTS.md`
- **Workflow** (plan, review, verify) → the tool's built-ins, listed in `CLAUDE.md` for Claude Code.
  A custom skill in `.claude/skills/` only for knowledge no built-in or plugin can have
- **Claude Code hook scripts** → `.claude/hooks/*.{sh,js}`
- **Claude-specific imports/extensions** → `CLAUDE.md`
