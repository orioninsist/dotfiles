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


## 14. SOPS + age — encryption and secret handling (verified October 20, 2026)

### Verified Fedora environment

| Component | Observed version | Verification |
|---|---|---|
| Fedora | 44 x86_64 | User terminal output |
| chezmoi | 2.73.0 (Fedora RPM) | `chezmoi doctor` |
| SOPS | 3.13.3 | `sops --version` |
| age | 1.3.1 | `age --version` and `age-keygen --version` |
| gopass | 1.16.1 (Fedora RPM) | `gopass version`, `rpm -q gopass` |

**Tested:** age password-based encryption/decryption produced matching plaintext files. A temporary age identity and recipient were generated; SOPS encrypted a two-field YAML file and successfully decrypted it with `SOPS_AGE_KEY_FILE`. The decrypted YAML had the same values but omitted optional quotation marks, so a byte-for-byte `diff` reported a formatting difference; explicit value checks passed. The user then removed the temporary test directory and test files. This demonstrates a successful **test only**, not a deployed permanent key or encrypted dotfile.

### Security and ownership boundaries

- Keep age **private identity files** outside the public Git repository, Google Sheets, and chezmoi-managed source files. A public age recipient (`age1...`) is not a secret, but never confuse it with the private identity.
- Do not commit decrypted files, SOPS test plaintext, temporary identities, password databases, browser vault data, tokens, or recovery codes. Review staged contents before every push.
- If permanent encrypted dotfiles are needed later, first choose an identity storage location with restrictive permissions and a tested, separate backup/recovery method. Do not assume encryption substitutes for backups.
- SOPS and chezmoi's native age encryption are **distinct integration approaches**. Choose one for a concrete file only after examining official documentation and the target's lifecycle; do not automatically enable both.
- gopass is installed but no password store or GPG key setup has been verified. Do not document it as operational secret storage yet.
- Google Password Manager remains the user's primary password manager. Bitwarden Desktop is installed as an unused alternative; no password migration is planned.

### Read-only checks before adopting encrypted files

```bash
age --version
sops --version
chezmoi doctor
chezmoi status
chezmoi diff
git -C "$(chezmoi source-path)" status --short
```

At the time of the temporary tests described above, no permanent age identity or chezmoi encryption configuration had been created. The subsequent permanent age setup is documented below.

### Historical rollout checklist (subsequently completed for age)

1. Identify an actual configuration file that needs encryption and inspect its contents locally.
2. Decide whether SOPS or chezmoi's native age support is appropriate; consult the official guides.
3. Generate and back up a permanent identity **locally**; verify recovery before encrypting irreplaceable data.
4. Encrypt a disposable test copy first, then test decryption on Fedora.
5. Preview chezmoi changes with `chezmoi status`, `chezmoi diff`, and `chezmoi apply --dry-run --verbose`.
6. Stage only approved encrypted source files; review the full `git diff --cached` and scan for secrets.
7. Commit and push only after approval; verify the remote commit and record the result in Google Sheets.

**Official sources:** [SOPS](https://github.com/getsops/sops) · [age](https://github.com/FiloSottile/age) · [chezmoi encryption](https://www.chezmoi.io/user-guide/encryption/) · [gopass](https://github.com/gopasspw/gopass).

## Official references

- [Chezmoi documentation](https://www.chezmoi.io/)
- [Chezmoi daily operations](https://www.chezmoi.io/user-guide/daily-operations/)
- [Chezmoi command reference](https://www.chezmoi.io/reference/commands/)
- [Git reference](https://git-scm.com/docs)

### Permanent age encryption and rclone recovery (October 20, 2026)

The earlier SOPS + age experiments described above were temporary tests.
A permanent age identity and chezmoi age configuration have since been
established and verified on Fedora.

**Current configuration**

- Age private identity: `~/.config/age/keys.txt` (mode `600`).
- Age identity directory: `~/.config/age` (mode `700`).
- Chezmoi encryption: `age`, configured in `.chezmoi.toml.tmpl`.
- The age public recipient is stored in `.chezmoi.toml.tmpl`.
- The private identity is **not** managed by chezmoi or stored in GitHub.
- Password-encrypted recovery copy: `~/age-recovery.age`.
- The recovery copy was locally decrypted and compared with the original.
  Uploading it to Google Drive and keeping an offline copy remain separate
  manual recovery steps until explicitly verified.

**Rclone files**

- `~/.config/rclone/backup.conf` is documented as managed by chezmoi at
  `dot_config/private_rclone/backup.conf` (historical Fedora observation; verify locally).
- `~/.config/rclone/rclone.conf` contains OAuth credentials and refreshed
  tokens. It must not be committed in plaintext.
- Its encrypted snapshot is stored at
  `.chezmoitemplates/rclone/rclone.conf.age`.
- The encrypted snapshot is not a managed target file.
- `.chezmoiscripts/run_once_after_restore-rclone.sh.tmpl` restores the snapshot
  only when the target `rclone.conf` does not already exist.
- The restore script was tested with an isolated HOME: restoration succeeded,
  permissions were `600`, and an existing file was preserved.

**Restore on a new Fedora installation**

1. Install chezmoi and age.
2. Clone or initialize the dotfiles repository.
3. Restore `~/.config/age/keys.txt` from the separately protected recovery
   backup; set its directory permissions to `700` and file permissions to `600`.
4. Run `chezmoi init` to generate the age configuration.
5. Review `chezmoi apply --dry-run --verbose`.
6. Run `chezmoi apply` only after reviewing the planned changes.
7. Verify rclone configuration locally without displaying OAuth tokens.

**Refreshing the encrypted snapshot**

Rclone may refresh OAuth tokens in the live `rclone.conf`.
The encrypted snapshot is not automatically synchronized with these changes.

After reviewing the current live file locally, regenerate the encrypted
snapshot using a temporary file and replace the existing encrypted snapshot
only after verifying that it decrypts to the current live configuration.
Review the Git diff before committing the encrypted snapshot.

Never commit the age private identity, plaintext `rclone.conf`, OAuth tokens,
recovery passwords, or decrypted temporary files.

**Security limitation:** The encrypted snapshot can become outdated.
Restoring an old snapshot may require reconnecting the Google Drive remote
if its OAuth credentials have expired or been revoked.


### Restore implementation: repository-verified notes (October 21, 2026)

These points were checked against the repository's actual tracked files, not a live Fedora machine:

- The script is **`.chezmoiscripts/run_once_after_restore-rclone.sh.tmpl`**, not `run_after_restore-rclone.sh.tmpl`. The `run_once_` prefix matters: chezmoi tracks one-time script execution by its generated contents. Do **not** assume an unchanged script automatically retries on the next `chezmoi apply` just because the age identity was missing during the first run.
- The script skips restoration when `~/.config/rclone/rclone.conf` already exists **or is a symlink**, and skips with a message if the age identity or encrypted snapshot is unreadable. It decrypts into a private temporary file, uses a hard link to create the target without overwriting an existing path, and removes the temporary path on exit. This explains the implementation, **not** a new end-to-end Fedora test.
- The encrypted source is `.chezmoitemplates/rclone/rclone.conf.age`. Template files are inputs, not automatically applied target files. The secret age identity remains outside Git and must be recovered separately.
- Restore the age identity **before** the first applicable chezmoi script run; confirm that `age` is installed and that the identity matches the public recipient. If the one-time script ran without its identity, inspect `chezmoi state` and the installed chezmoi help before choosing a controlled retry; never delete all chezmoi state blindly.
- An encrypted rclone snapshot is a point-in-time backup. A successful decrypt does not confirm that OAuth access still works, and updating live rclone tokens does **not** update the committed snapshot.

Read-only checks on the actual Fedora machine:

```bash
chezmoi --version
chezmoi source-path
chezmoi doctor
chezmoi status
chezmoi diff
chezmoi state --help
ls -ld "$HOME/.config/age" "$HOME/.config/rclone" 2>/dev/null
ls -l "$HOME/.config/age/keys.txt" "$HOME/.config/rclone/rclone.conf" 2>/dev/null
git -C "$(chezmoi source-path)" status --short
```

**Security caution:** `chezmoi apply --dry-run --verbose` is an application preview, not a guarantee that a future script will never expose sensitive data. Avoid posting decrypted configuration, key material, and OAuth tokens in logs or chat. Do not execute restoration on a working machine just to test the guide.
