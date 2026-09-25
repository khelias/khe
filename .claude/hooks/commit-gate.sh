#!/usr/bin/env bash
# PreToolUse hook: before Claude runs `git commit` in the workspace root or one
# of the workspace repos, scan what the commit adds for personal-data patterns
# (.claude/hooks/pii-rules.toml, skipped for repos marked `private: true` in
# repos/repos.yaml), then run that repo's `check:` command. Either failing
# blocks the commit (exit 2, output to stderr). Other Bash calls pass through
# untouched, so a passing commit costs no tokens.
set -uo pipefail

input="$(cat)"
cmd="$(jq -r '.tool_input.command // empty' <<<"$input")"
git_re='(^|[;&|[:space:]/])git(([[:space:]]+-[Cc][[:space:]]+[^[:space:]]+)*)[[:space:]]+'
[[ "$cmd" =~ ${git_re}commit([[:space:]]|$) ]] || exit 0

cwd="$(jq -r '.cwd // empty' <<<"$input")"
root="${CLAUDE_PROJECT_DIR:-$cwd}"

unquote() { local v="$1"; v="${v%\"}"; v="${v#\"}"; v="${v%\'}"; v="${v#\'}"; printf '%s' "$v"; }

fail() { echo "commit-gate: $1; commit blocked." >&2; exit 2; }

# The hook runs before the command, so a file force-added in the same call is
# still ignored and invisible to the scan below.
add_re="${git_re}add[[:space:]]([^;&|]*[[:space:]])?(-f|--force|-[A-Za-z]*f[A-Za-z]*)([[:space:]]|\$)"
[[ "$cmd" =~ $add_re ]] &&
    fail "a same-call 'git add --force' cannot be scanned. Run the add as its own command first, then commit"

# Each commit's directory: its `git -C <dir>`, else a leading `cd <dir> &&`,
# else cwd. A command may commit in several repos; each one is gated.
default_dir="$cwd"
[[ "$cmd" =~ ^[[:space:]]*cd[[:space:]]+([^[:space:];&]+) ]] && default_dir="$(unquote "${BASH_REMATCH[1]}")"
dirs=()
rest="$cmd"
while [[ "$rest" =~ ${git_re}commit([[:space:]]|$) ]]; do
    rest="${rest#*"${BASH_REMATCH[0]}"}"
    d="$default_dir"
    [[ "${BASH_REMATCH[2]}" =~ -C[[:space:]]+([^[:space:]]+) ]] && d="$(unquote "${BASH_REMATCH[1]}")"
    [[ "$d" = /* ]] || d="$cwd/$d"
    dirs+=("$d")
done

tmp_root="$(mktemp -d)" && [[ -d "$tmp_root" ]] || fail "no temporary directory for the personal-data scan"
trap 'rm -r -f -- "$tmp_root"' EXIT

gate() {
    local dir="$1"
    # A worktree's common dir is still repos/<name>/.git, which names the repo;
    # the root repo's common dir is the same from any of its worktrees.
    common="$(git -C "$dir" rev-parse --path-format=absolute --git-common-dir 2>/dev/null)" || return 0
    top="$(git -C "$dir" rev-parse --show-toplevel 2>/dev/null)" || return 0
    root_common="$(git -C "$root" rev-parse --path-format=absolute --git-common-dir 2>/dev/null)"
    case "$common" in
        "$root"/repos/*/.git) name="${common#"$root"/repos/}"; name="${name%/.git}"; label="repos/$name" ;;
        "$root_common") name="khe"; label="the workspace root" ;;
        *) return 0 ;;
    esac

    yaml_key() {
        awk -v want="$name" -v key="$1" '
            /^[[:space:]]*- name:/ { sub(/.*name:[[:space:]]*/, ""); cur = $0; next }
            $0 ~ "^[[:space:]]*" key ":" && cur == want { sub(/^[^:]*:[[:space:]]*/, ""); sub(/[[:space:]]+$/, ""); print; exit }
        ' "$root/repos/repos.yaml" 2>/dev/null
    }

    block() {
        {
            echo "commit-gate: personal data in what this commit adds to $label; commit blocked."
            printf '%s\n' "$@"
            echo "Remove it, or if it is a false positive add an allowlist entry with a reason"
            echo "to .claude/hooks/pii-rules.toml. Values are redacted here on purpose."
        } >&2
        exit 2
    }

    # Only added lines are scanned, so removing personal data never blocks. The
    # hook runs before any same-call `git add`, so staged, unstaged and untracked
    # changes are all scanned: any of them may end up in this commit.
    if [[ "$(yaml_key private)" != "true" ]]; then
        rules="$root/.claude/hooks/pii-rules.toml"
        command -v gitleaks >/dev/null ||
            fail "gitleaks is not installed, so the personal-data scan cannot run. Install it with 'brew install gitleaks'"
        [[ -f "$rules" ]] || fail "$rules is missing"

        tmp="$(mktemp -d "$tmp_root/gate.XXXXXX")" || fail "no temporary directory for the personal-data scan"
        g() { git -C "$top" -c core.quotePath=false "$@"; }
        base=HEAD
        g rev-parse -q --verify HEAD >/dev/null || base=4b825dc642cb6eb9a060e54bf8d69288fbee4904

        # File names come from the NUL-separated list in $2, not the diff headers,
        # which quote or mangle unusual paths; both list files in the same order.
        split_diff() {
            awk -v dir="$tmp" -v prefix="$3" '
                /^diff --(git|cc|combined) / {
                    if (n) { close(out); close(map) }
                    n++; ln = 0; out = dir "/" prefix n; map = out ".lines"; printf "" > out; printf "" > map; next
                }
                /^@@ / { split($0, h, " "); sub(/^\+/, "", h[3]); split(h[3], c, ","); ln = c[1]; next }
                n && /^\+\+\+ / && !ln { next }
                n && /^\+/ { print substr($0, 2) > out; print ln > map; ln++ }
            ' "$1"
            local i=0 f
            while IFS= read -r -d '' f; do
                i=$((i + 1))
                printf '%s' "$f" > "$tmp/$3$i.name"
            done < "$2"
        }

        g diff --cached -U0 --no-color --no-ext-diff --no-textconv -M "$base" > "$tmp/staged.diff" &&
            g diff --cached --name-only -z -M "$base" > "$tmp/staged.names" &&
            g diff -U0 --no-color --no-ext-diff --no-textconv > "$tmp/unstaged.diff" &&
            g diff --name-only -z > "$tmp/unstaged.names" &&
            g ls-files -z --others --exclude-standard > "$tmp/untracked.names" ||
            fail "git could not list the changes in $label for the personal-data scan"
        split_diff "$tmp/staged.diff" "$tmp/staged.names" s
        split_diff "$tmp/unstaged.diff" "$tmp/unstaged.names" w

        i=0
        while IFS= read -r -d '' f; do
            [[ -f "$top/$f" && ! -L "$top/$f" ]] || continue
            i=$((i + 1))
            (cd "$top" && git -c core.quotePath=false diff --no-index -U0 --no-color --no-ext-diff --no-textconv -- /dev/null "$f") > "$tmp/u$i.diff"
            [[ $? -le 1 ]] || fail "git could not read the untracked file $f for the personal-data scan"
            printf '%s\0' "$f" > "$tmp/u$i.names"
            split_diff "$tmp/u$i.diff" "$tmp/u$i.names" "u$i-"
        done < "$tmp/untracked.names"

        printf '%s\n' "$cmd" > "$tmp/m1"
        awk '{ print NR }' "$tmp/m1" > "$tmp/m1.lines"
        printf 'the commit command or message' > "$tmp/m1.name"
        if [[ "$cmd" =~ (^|[[:space:]])(-F[[:space:]]*|--file=|--file[[:space:]]+)([^[:space:];&|]+) ]]; then
            msg="$(unquote "${BASH_REMATCH[3]}")"
            [[ "$msg" = /* ]] || msg="$dir/$msg"
            if [[ -f "$msg" ]]; then
                cp -- "$msg" "$tmp/m2"
                awk '{ print NR }' "$tmp/m2" > "$tmp/m2.lines"
                printf 'the commit message file %s' "${BASH_REMATCH[3]}" > "$tmp/m2.name"
            fi
        fi

        # gitleaks runs from $tmp so a .gitleaksignore in the repo cannot silence
        # a finding, and --ignore-gitleaks-allow closes the inline allow comment.
        found=()
        for chunk in "$tmp"/*.lines; do
            chunk="${chunk%.lines}"
            [[ -s "$chunk" ]] || continue
            [[ -f "$chunk.name" ]] || printf 'a changed file' > "$chunk.name"
            (cd "$tmp" && gitleaks stdin --config "$rules" --gitleaks-ignore-path "$tmp" \
                --redact --no-banner --no-color --log-level error --ignore-gitleaks-allow \
                --exit-code 3 --report-format json --report-path "$chunk.json" < "$chunk") 2> "$chunk.err"
            rc=$?
            if [[ $rc -eq 3 ]]; then
                n=${#found[@]}
                while IFS=$'\t' read -r rule idx; do
                    found+=("  $(cat "$chunk.name") line $(sed -n "${idx}p" "$chunk.lines"): $rule")
                done < <(jq -r '.[] | [.RuleID, .StartLine] | @tsv' "$chunk.json" 2>/dev/null)
                [[ ${#found[@]} -gt $n ]] || found+=("  $(cat "$chunk.name"): a finding the report did not name")
            elif [[ $rc -ne 0 ]]; then
                {
                    echo "commit-gate: .claude/hooks/pii-rules.toml failed to load (gitleaks exit $rc); commit blocked."
                    head -n 3 "$chunk.err"
                } >&2
                exit 2
            fi
        done
        [[ ${#found[@]} -eq 0 ]] || block "${found[@]}"
    fi

    check="$(yaml_key check)"
    [[ -n "$check" ]] || return 0

    if ! out="$(cd "$top" && bash -c "$check" 2>&1)"; then
        {
            echo "commit-gate: '$check' failed in $label; commit blocked."
            echo "Fix the failure, then commit again. Last lines of output:"
            tail -n 40 <<<"$out"
        } >&2
        exit 2
    fi
}

for d in "${dirs[@]}"; do gate "$d"; done
exit 0
