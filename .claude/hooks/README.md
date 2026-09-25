# .claude/hooks/

Claude Code hooks - scripts that run on events (`PreToolUse`, `PostToolUse`,
`SessionStart`, `Stop`, etc.).

## What's here

Nothing yet. Hooks are powerful but require careful design - a wrong hook =
wrong behavior every session.

## When to add a hook

Add a hook when you find a recurring problem that:

- Happens predictably (every session start, every commit, etc.)
- Has a small, deterministic fix
- Is worth automating

## Patterns to consider (read, don't fork)

- [Anthropic hooks docs](https://code.claude.com/docs/en/hooks) - canonical
- [affaan-m/everything-claude-code/scripts/hooks](https://github.com/affaan-m/everything-claude-code/tree/main/scripts/hooks) - examples of session-end memory extraction, pre-commit checks

## Wiring

Hooks are configured in `settings.json`:

```json
{
  "hooks": {
    "PreToolUse": [
      { "matcher": "Bash", "command": "$CLAUDE_PROJECT_DIR/.claude/hooks/check-bash.sh" }
    ]
  }
}
```
