# Chezmoi, Git & GitHub — Fedora Command Manual

**One English reference. Commands first. Real use cases, parameters, safety checks, and a complete path from local files to verified GitHub commits.**

> Environment verified from Fedora terminal output on October 20, 2026: Fedora 44 x86_64; chezmoi 2.73.0 (Fedora RPM); source directory `~/.local/share/chezmoi`; remote `https://github.com/orioninsist/dotfiles.git`; branch `main`. These are historical observations, **not** a claim that your machine has been checked right now.

## 0. Start here: what to run, in what order

| Step | Terminal command | Purpose |
|---|---|---|
| 1 | `ls -l PATH` / `find DIR -type f` | Confirm the real configuration files |
| 2 | `chezmoi add PATH` | Copy the chosen target file into chezmoi's source state |
| 3 | `chezmoi source-path PATH` | Find its actual source filename (`dot_`, `private_`, etc.) |
| 4 | `chezmoi managed` | Confirm chezmoi manages the target |
| 5 | `chezmoi status` and `chezmoi diff` | Inspect target/source differences |
| 6 | `chezmoi apply --dry-run --verbose` | Preview without changing target files |
| 7 | `git status --short` | See new/modified source files |
| 8 | `git add -- EXACT_SOURCE_PATH` | Stage *only* approved paths |
| 9 | `git diff --cached --check` and `git diff --cached` | Check errors, secrets, personal content, and all staged changes |
| 10 | `git commit -m "MESSAGE"` | Create a local Git commit |
| 11 | `git push origin main` | Publish the commit to GitHub |
| 12 | `git rev-parse HEAD` and `git ls-remote --heads origin main` | Check that local and remote commit IDs match |

**Stop if any command fails.** Never publish passwords, tokens, private keys, command histories, databases, nested Git repositories, or personal snippets to a public repository. Review full content, not merely filenames or keyword matches.

## 1. Copy/paste: check your current setup (read-only)

```bash
pwd
chezmoi --version
chezmoi source-path
chezmoi doctor
chezmoi managed
chezmoi status
chezmoi diff
chezmoi apply --dry-run --verbose
git -C "$(chezmoi source-path)" status --short
git -C "$(chezmoi source-path)" remote -v
```

`status` and `diff` may both be empty when source and target agree. That **does not** prove that files were committed or pushed.

## 2. Scenario A — Add one configuration file

**Example:** `~/.config/kitty/kitty.conf`. Replace `TARGET` with the real file you wish to add. Kitty is already tracked in the recorded setup: this is an example, not an instruction to re-add it.

### Inspect → add → preview

```bash
TARGET="$HOME/.config/kitty/kitty.conf"
test -f "$TARGET" || { echo "Missing: $TARGET"; false; }
ls -l "$TARGET"
chezmoi add "$TARGET"
chezmoi source-path "$TARGET"
chezmoi managed
chezmoi status
chezmoi diff
chezmoi apply --dry-run --verbose
```

Run each command only if the preceding checks succeeded. Inspect the file's contents privately for secrets before adding it.

### Stage → review → commit → push

```bash
cd "$(chezmoi source-path)"
git status --short
# This path is an EXAMPLE; confirm it matches the earlier source-path output:
git add -- dot_config/kitty/kitty.conf
git diff --cached --name-only
git diff --cached --check
git diff --cached
```

**Stop here and inspect the complete staged diff.** Once all staged content is approved:

```bash
git commit -m "feat(chezmoi): manage kitty configuration"
git push origin main
```

### Verify the outcome

```bash
git status --short
git log -1 --oneline
git rev-parse HEAD
git ls-remote --heads origin main
chezmoi status
chezmoi diff
```

The last two SHA values must match. `git status --short` should have no unexpected changes.

## 3. Scenario B — Add a directory (Atuin example)

### Inspect files first

```bash
find "$HOME/.config/atuin" -type f -print
du -ah "$HOME/.config/atuin" | sort -h | tail -20
```

If there are histories, databases, caches, API keys, or private information, do **not** add the entire directory. Add selected files individually instead, e.g.:

```bash
chezmoi add "$HOME/.config/atuin/config.toml"
```

Only when **every file** is safe to track:

```bash
chezmoi add --recursive "$HOME/.config/atuin"
chezmoi managed | grep '/atuin/'
chezmoi status
chezmoi diff
git -C "$(chezmoi source-path)" status --short
```

Then (only after reviewing the staged contents):

```bash
cd "$(chezmoi source-path)"
git add -- dot_config/atuin
git diff --cached --name-only
git diff --cached --check
git diff --cached
# After manual approval:
git commit -m "feat(chezmoi): manage atuin configuration"
git push origin main
```

## 4. Scenario C — Nested .git directories (Espanso example)

In the recorded Fedora setup, `~/.config/espanso/match/.git` was a **separate Git repository**. Recursive add initially picked it up; this is *not* a config directory to publish.

```bash
find "$HOME/.config/espanso" -name .git -print
chezmoi managed | grep '/espanso/'
chezmoi source-path "$HOME/.config/espanso/match/.git"
```

If chezmoi currently manages the nested `.git`, use `forget`. Review its interactive prompt: a real `.git` may appear as `dot_git` in chezmoi's source tree.

```bash
chezmoi forget "$HOME/.config/espanso/match/.git"
test -d "$HOME/.config/espanso/match/.git" && echo "Nested Git repository preserved"
chezmoi managed | grep '/espanso/match/.git' || echo "No longer managed"
```

In the observed operation, the real nested Git directory was preserved. Never run `rm -rf` on it.

To stage only approved Espanso configuration files:

```bash
cd "$(chezmoi source-path)"
git add -- dot_config/espanso
git diff --cached --name-only
git diff --cached --check
git diff --cached
```

If the list includes `dot_git`, unexpected files, or private snippets: **stop, unstage them, and fix the source first**.

## 5. Scenario D — Edit an already-managed file

```bash
TARGET="$HOME/.config/atuin/config.toml"
chezmoi source-path "$TARGET"
chezmoi edit "$TARGET"
chezmoi status
chezmoi diff
chezmoi apply --dry-run --verbose
```

`edit` changes the chezmoi *source*. `apply` changes the *actual target file*, so run it only after inspecting the preview.

```bash
# Only after approving the preview:
chezmoi apply "$TARGET"
chezmoi status
```

Then enter the source directory and follow the exact-path `git add`, staged diff, commit, push, and SHA verification steps in Scenario A.

## 6. Scenario E — The target was edited outside chezmoi

```bash
TARGET="$HOME/.config/atuin/config.toml"
chezmoi diff "$TARGET"
chezmoi status
chezmoi source-path "$TARGET"
```

If you deliberately want the target version copied back into chezmoi source:

```bash
chezmoi re-add "$TARGET"
chezmoi diff "$TARGET"
git -C "$(chezmoi source-path)" status --short
```

`re-add` overwrites the source version based on the target. Review both versions before proceeding to Git staging.

## 7. Scenario F — Undo an accidental Git stage (without deleting files)

```bash
cd "$(chezmoi source-path)"
git status --short
git restore --staged -- dot_config/atuin dot_config/espanso
git status --short
```

`restore --staged` removes paths from the staging area; it does not delete local source files. A subsequent `git commit` may correctly report **nothing added to commit**. Stage the intended paths again after reviewing them.

## 8. Scenario G — Push rejected because GitHub is ahead

This happened in the real Atuin/Espanso workflow: a documentation commit had been added to GitHub before the Fedora copy was refreshed.

```bash
cd "$(chezmoi source-path)"
git fetch origin
git status
git log --oneline --graph --decorate --all -n 12
git pull --ff-only origin main
```

`pull --ff-only` is appropriate when the local branch is behind and can fast-forward. If it fails, **stop** and inspect divergent commits. Do not blindly use `--force`, `reset --hard`, or `pull --rebase`. If you have a reviewed local commit and the branch is now up to date:

```bash
git push origin main
```

## 9. Scenario H — Only documentation changed on GitHub

`README.md` and `docs/` are intentionally excluded from chezmoi target application by `.chezmoiignore`. To download changes to the local *Git source repository*:

```bash
cd "$(chezmoi source-path)"
git status --short
git fetch origin
git pull --ff-only origin main
git log -1 --oneline
```

No `chezmoi apply` is necessary for documentation-only changes.

## 10. Command reference — chezmoi

| Command | What it does / key parameters |
|---|---|
| `chezmoi init REPO` | Initialize from a repository (new setups only); inspect before applying |
| `chezmoi add FILE` | Add one target file to source state |
| `chezmoi add --recursive DIR` | Add directory contents recursively; inspect nested `.git` and secrets |
| `chezmoi source-path [TARGET]` | Show source directory or target's corresponding source path |
| `chezmoi managed` | List target paths under chezmoi control |
| `chezmoi status` | Show differences between source state and real target files |
| `chezmoi diff [TARGET]` | Show the content changes an application would make |
| `chezmoi edit TARGET` | Edit source-managed representation |
| `chezmoi re-add TARGET` | Re-import a locally changed target into source |
| `chezmoi forget TARGET` | Stop managing target by removing source representation (not the target) |
| `chezmoi apply --dry-run --verbose` | Preview intended changes without applying them |
| `chezmoi apply TARGET` | Apply the source version to target; can overwrite local changes |
| `chezmoi update` | Pull source updates and apply; not a substitute for a Git diff review |
| `chezmoi doctor` | Diagnose setup and environment |
| `chezmoi help COMMAND` | Show all installed options and flags for a specific command |

Examples of built-in help:

```bash
chezmoi help add
chezmoi help diff
chezmoi help apply
chezmoi help forget
chezmoi help update
```

## 11. Command reference — Git

| Command | What it does / practical detail |
|---|---|
| `git status --short` | `??` untracked, `A` added, `M` modified |
| `git diff` | Unstaged changes to **already tracked** files; excludes new untracked content |
| `git diff --cached` | All staged changes, including the content of new files |
| `git diff --cached --check` | Detect whitespace errors in staged changes |
| `git diff --cached --name-only` | List exactly which staged files the next commit will contain |
| `git add -- PATH` | Stage one checked path; avoid indiscriminate `git add .` |
| `git restore --staged -- PATH` | Unstage without deleting local files |
| `git commit -m "MESSAGE"` | Save staged changes as a local commit |
| `git push origin main` | Publish commits to GitHub |
| `git fetch origin` | Fetch remote references; do not update working tree |
| `git pull --ff-only origin main` | Fast-forward only, no automatic merge commit |
| `git log -1 --oneline` | Print latest local commit |
| `git rev-parse HEAD` | Print the full local commit hash |
| `git ls-remote --heads origin main` | Print the actual remote main hash |

## 12. Real verified example — Fedora → GitHub

On **October 20, 2026**, the user supplied Fedora terminal output showing:

```bash
chezmoi add --recursive ~/.config/atuin
chezmoi add --recursive ~/.config/espanso
chezmoi forget ~/.config/espanso/match/.git
git fetch origin
git pull --ff-only origin main
git add -- dot_config/atuin dot_config/espanso
git diff --cached --check
git diff --cached --stat
git commit -m "feat(chezmoi): manage atuin and espanso configurations"
git push origin main
git status --short
git rev-parse HEAD
git ls-remote --heads origin main
chezmoi status
```

**Verified outcome:** commit [`8b1e6c0`](https://github.com/orioninsist/dotfiles/commit/8b1e6c0b92f47441ca0af4b7423e954ad4d24f64) contained **40 new files**, with the nested Espanso Git repository excluded. Local and remote main hashes matched. Git status and chezmoi status were empty. However, a *complete* sensitive-content audit of all YAML files was **not** verified.

Earlier verified changes:

| Configuration | Commit | Note |
|---|---|---|
| `~/.bashrc` | [`49b9b24`](https://github.com/orioninsist/dotfiles/commit/49b9b24) | Initial Bash configuration |
| `~/.config/kitty/kitty.conf` | [`23d7013`](https://github.com/orioninsist/dotfiles/commit/23d7013) | Kitty configuration; external copy-scrollback script still unverified |
| Atuin + Espanso | [`8b1e6c0`](https://github.com/orioninsist/dotfiles/commit/8b1e6c0b92f47441ca0af4b7423e954ad4d24f64) | Configurations added; 40 files |

**Troubleshooting notes:** a past `chezmoi doctor` cross-device hardlink warning arose because the source was on `ext4` while `/tmp` was `tmpfs`. This alone is not proof of a broken setup. Fedora RPM chezmoi 2.73.0 was behind 2.73.2 at that time. A missing `~/.config/chezmoi/chezmoi.toml` did not prevent default configuration from working.

## 13. Final checklist

- [ ] Target file/directory and all contents inspected
- [ ] No credentials, personal snippets, caches, histories, database files, or nested Git objects staged
- [ ] Actual chezmoi source path confirmed
- [ ] `chezmoi managed`, `status`, `diff`, and dry-run checked
- [ ] Only intended paths staged and **full** `git diff --cached` reviewed
- [ ] Commit succeeded and `git push origin main` succeeded
- [ ] Local HEAD equals remote main; working tree and chezmoi state checked
- [ ] Verified results logged in [Google Sheets](https://docs.google.com/spreadsheets/d/1sutPQH5P0kotlz__uTs7v_PY3LeRZcvSjgDekgImyRg/edit)

## Official references

- [Chezmoi documentation](https://www.chezmoi.io/)
- [Chezmoi daily operations](https://www.chezmoi.io/user-guide/daily-operations/)
- [Chezmoi command reference](https://www.chezmoi.io/reference/commands/)
- [Git reference](https://git-scm.com/docs)
