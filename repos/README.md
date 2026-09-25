# repos/

The KHE repos, each an independent clone with its own `.git`, history, CI
and `AGENTS.md`. Only this README and [`repos.yaml`](repos.yaml) are
tracked by the workspace repo; everything else here is gitignored.

```bash
scripts/workspace.sh clone    # clone every repo listed in repos.yaml
scripts/workspace.sh pull     # fast-forward each clean repo on its current branch
scripts/workspace.sh status   # branch, dirty files, ahead/behind
```

Add a repo by appending an entry to `repos.yaml`. `upstream:` is optional
and adds an `upstream` remote on clone (used for forks).

Why plain nested clones and not submodules: every repo is worked on at its
latest `main` and deploys on its own. Submodules pin commits, which would
add a bump commit here for every change elsewhere and buy nothing.

Two consequences of the gitignore, both handled at the workspace root:

- Claude Code's Grep would skip `repos/`; [`.rgignore`](../.rgignore) puts
  it back.
- Skills in `repos/<name>/.claude/skills/` load only when a session starts
  inside that repo. Skills needed from the root live in the root
  `.claude/skills/`.
