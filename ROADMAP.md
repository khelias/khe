# Roadmap

Open work from the 2026-09-25 review against Claude Code 2.1.282, Codex and
the Agent Skills spec. Done items from that review are logged in
[`LAST_REVIEWED.md`](LAST_REVIEWED.md). Order is by payoff against effort.

## Next

1. **Prune `<KHE_ROOT>/.claude/settings.local.json`.** About 540 allow
   rules, most of them one-off `python3`/`grep`/`sed` invocations and
   session-scratchpad paths from past sessions. Empty it and let
   `/fewer-permission-prompts` propose a short allowlist for the tracked
   `settings.json`; auto mode covers the rest.
2. **Share skills with Codex.** `.agents/skills/` is the cross-tool path
   (Codex, Copilot, Cursor, Antigravity read it; Claude Code does not).
   Have `install.{sh,ps1}` also link `<KHE_ROOT>/.agents/skills` to
   `skills/`.
3. **Per-repo `/verify` recipes.** The bundled `/verify` records a repo's
   exact build/test commands in `.claude/skills/verify/SKILL.md`. Once each
   KHE repo has one, the generic `verification` skill is redundant.
4. **Decide the skill set on data.** The four skills never loaded before
   2026-09-25, so "not used" was not a signal. Around 2026-10-25 run
   `/skill-doctor`; drop what was never invoked. Candidates: `verification`
   (overlaps `/verify`), `code-reviewer` agent (overlaps `/code-review`).

## Then

5. **Quarterly review as a routine, not a calendar reminder.** The CI
   freshness check only warns, and the May to September gap shows nobody
   sees it. A `/schedule` routine that reads the Claude Code changelog and
   the checklist in `LAST_REVIEWED.md` and opens a PR would close the loop.
6. **Procedures out of auto memory into skills.** Some auto-memory entries
   are step-by-step workflows (Home Assistant API loop, deploy flow). Those
   belong as skills in the repo that owns them, e.g. `khe-homelab`, where
   they load on demand and are versioned. Then consolidate memory entries
   that now duplicate the AGENTS.md "Judgement" section.
7. **SessionStart hook for estate state.** Many sessions start by listing
   repos and running `git status` in each. A hook printing branch and
   dirty/ahead state per repo saves that round trip.

## Try and measure

8. **obra/superpowers** in one repo for a week. Same shape as `tdd` +
   `planner` + `verification` (brainstorm, plan, subagent execution, TDD,
   verify) and far more mature. Compare with `/skill-doctor` before
   replacing anything here.

## Later, when a need shows up

9. **`khe-trips/AGENTS.md` is 432 lines** against a 200-line guideline.
   Split into `.claude/rules/*.md` with `paths:` or into skills.
10. **Privacy guard for public repos.** The AGENTS.md rule that device ids
    and LAN addresses stay out of public repos is prose only. A git
    pre-commit check (gitleaks with custom rules) enforces it for every tool,
    not just Claude.
11. **`attribution: false`** once v2.1.281+ reaches the stable channel;
    the object form in `settings.json` works until then.
12. **Package as a plugin** only if a second machine or a non-KHE context
    needs the same set. Symlinks are enough for one person on one machine.

## Considered and not planned

- **spec-kit, BMAD:** spec-driven ceremony, too heavy for a solo hobby estate.
- **claude-mem and similar:** built-in auto memory covers the use.
- **Gemini CLI config:** the consumer tier shut down on 2026-06-18
  (successor: Antigravity CLI). Revisit only if a tool from that line is used.
- **`claude-md-and-agents-md` mode:** a user-level setting that would change
  every project on the machine; the `@AGENTS.md` imports already work.

## Sources

- [Claude Code changelog](https://code.claude.com/docs/en/changelog)
- [Skills](https://code.claude.com/docs/en/skills), [memory and AGENTS.md](https://code.claude.com/docs/en/memory), [settings](https://code.claude.com/docs/en/settings-reference)
- [Agent Skills cross-client paths](https://agentskills.io/client-implementation/adding-skills-support), [Codex skills](https://learn.chatgpt.com/docs/build-skills)
- [Gemini CLI to Antigravity CLI](https://developers.googleblog.com/an-important-update-transitioning-gemini-cli-to-antigravity-cli/)
- [Context engineering for Claude 5 models](https://claude.dev/blog/the-new-rules-of-context-engineering-for-claude-5-generation-models/), [ETH study on context files](https://arxiv.org/abs/2602.11988)
