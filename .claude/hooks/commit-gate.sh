#!/usr/bin/env bash
# PreToolUse hook: before Claude runs `git commit` in one of the workspace
# repos, run that repo's `check:` command from repos/repos.yaml and block the
# commit (exit 2, output to stderr) when it fails. Other Bash calls pass
# through untouched, so a passing check costs no tokens.
set -uo pipefail

input="$(cat)"
cmd="$(jq -r '.tool_input.command // empty' <<<"$input")"
[[ "$cmd" =~ (^|[;&|[:space:]])git([[:space:]]+-C[[:space:]]+[^[:space:]]+)?[[:space:]]+commit([[:space:]]|$) ]] || exit 0

cwd="$(jq -r '.cwd // empty' <<<"$input")"
root="${CLAUDE_PROJECT_DIR:-$cwd}"

# The commit's directory: `git -C <dir>`, else a leading `cd <dir> &&`, else cwd.
dir="$cwd"
if [[ "$cmd" =~ git[[:space:]]+-C[[:space:]]+([^[:space:]]+) ]]; then
    dir="${BASH_REMATCH[1]}"
elif [[ "$cmd" =~ ^[[:space:]]*cd[[:space:]]+([^[:space:];&]+) ]]; then
    dir="${BASH_REMATCH[1]}"
fi
dir="${dir%\"}"; dir="${dir#\"}"; dir="${dir%\'}"; dir="${dir#\'}"
[[ "$dir" = /* ]] || dir="$cwd/$dir"

# A worktree's common dir is still repos/<name>/.git, which names the repo.
common="$(git -C "$dir" rev-parse --path-format=absolute --git-common-dir 2>/dev/null)" || exit 0
top="$(git -C "$dir" rev-parse --show-toplevel 2>/dev/null)" || exit 0
case "$common" in
    "$root"/repos/*/.git) name="${common#"$root"/repos/}"; name="${name%/.git}" ;;
    *) exit 0 ;;
esac

check="$(awk -v want="$name" '
    /^[[:space:]]*- name:/ { sub(/.*name:[[:space:]]*/, ""); cur = $0; next }
    /^[[:space:]]*check:/ && cur == want { sub(/.*check:[[:space:]]*/, ""); print; exit }
' "$root/repos/repos.yaml")"
[[ -n "$check" ]] || exit 0

if ! out="$(cd "$top" && bash -c "$check" 2>&1)"; then
    {
        echo "commit-gate: '$check' failed in repos/$name; commit blocked."
        echo "Fix the failure, then commit again. Last lines of output:"
        tail -n 40 <<<"$out"
    } >&2
    exit 2
fi
exit 0
