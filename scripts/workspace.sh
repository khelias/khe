#!/usr/bin/env bash
# Clone, update or inspect the KHE repos listed in repos/repos.yaml.
#
#   scripts/workspace.sh clone    clone every missing repo into repos/<name>/
#   scripts/workspace.sh pull     fast-forward each clean repo on its current branch
#   scripts/workspace.sh status   branch, dirty files and ahead/behind per repo
set -euo pipefail

root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
manifest="$root/repos/repos.yaml"

# Emits "name<TAB>url<TAB>upstream" per entry. A line parser keeps the script
# dependency-free; repos.yaml documents the flat shape it expects.
entries() {
    awk '
        function flush() { if (name != "") print name "\t" url "\t" upstream; name = url = upstream = "" }
        /^[[:space:]]*- name:/ { flush(); sub(/.*name:[[:space:]]*/, ""); name = $0; next }
        /^[[:space:]]*url:/      { sub(/.*url:[[:space:]]*/, ""); url = $0; next }
        /^[[:space:]]*upstream:/ { sub(/.*upstream:[[:space:]]*/, ""); upstream = $0; next }
        END { flush() }
    ' "$manifest"
}

cmd_clone() {
    mkdir -p "$root/repos"
    while IFS=$'\t' read -r name url upstream; do
        target="$root/repos/$name"
        if [[ -d "$target/.git" ]]; then
            echo "  skip    $name"
            continue
        fi
        echo "  clone   $name"
        git clone --quiet "$url" "$target"
        if [[ -n "$upstream" ]]; then
            git -C "$target" remote add upstream "$upstream"
        fi
    done < <(entries)
}

cmd_pull() {
    while IFS=$'\t' read -r name _ _; do
        target="$root/repos/$name"
        if [[ ! -d "$target/.git" ]]; then
            echo "  missing $name (run clone)"
        elif [[ -n "$(git -C "$target" status --porcelain)" ]]; then
            echo "  dirty   $name (not pulled)"
        elif git -C "$target" pull --quiet --ff-only 2>/dev/null; then
            echo "  pulled  $name ($(git -C "$target" branch --show-current))"
        else
            echo "  failed  $name (no upstream branch or not a fast-forward)"
        fi
    done < <(entries)
}

cmd_status() {
    printf '  %-18s %-32s %6s %s\n' repo branch dirty ahead/behind
    while IFS=$'\t' read -r name _ _; do
        target="$root/repos/$name"
        if [[ ! -d "$target/.git" ]]; then
            printf '  %-18s %s\n' "$name" "(not cloned)"
            continue
        fi
        branch="$(git -C "$target" branch --show-current)"
        dirty="$(git -C "$target" status --porcelain | wc -l | tr -d ' ')"
        counts="$(git -C "$target" rev-list --left-right --count '@{upstream}...HEAD' 2>/dev/null \
            | awk '{print "+" $2 "/-" $1}')"
        printf '  %-18s %-32s %6s %s\n' "$name" "$branch" "$dirty" "${counts:-no upstream}"
    done < <(entries)
}

case "${1:-}" in
    clone)  cmd_clone ;;
    pull)   cmd_pull ;;
    status) cmd_status ;;
    *) echo "usage: $0 clone|pull|status" >&2; exit 2 ;;
esac
