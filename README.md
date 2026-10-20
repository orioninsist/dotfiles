# Fedora Dotfiles — Chezmoi + Git

Fedora user configuration is managed with **chezmoi**, versioned on **GitHub**, and tracked in [Google Sheets](https://docs.google.com/spreadsheets/d/1sutPQH5P0kotlz__uTs7v_PY3LeRZcvSjgDekgImyRg/edit).

## Documentation

**[Chezmoi, Git & GitHub — Fedora Command Manual](docs/chezmoi.md)** is the **single English documentation page**. It contains the full step-by-step workflow from inspecting a file through `chezmoi add`, reviewing diffs, committing, pushing, and verifying GitHub, plus parameter explanations, safety checks, real examples, and troubleshooting.

## Quick terminal check

```bash
chezmoi managed
chezmoi status
chezmoi diff
git -C "$(chezmoi source-path)" status --short
```

Read the [command manual](docs/chezmoi.md) before adding, editing, or publishing configurations. Do not push passwords, private keys, tokens, caches, histories, or nested Git repositories.

## Verified setup snapshot (October 20, 2026)

Fedora Linux 44 (x86_64); chezmoi 2.73.0 via Fedora RPM; source directory `~/.local/share/chezmoi`; `main` branch on [orioninsist/dotfiles](https://github.com/orioninsist/dotfiles). Managed configurations included Bash, Kitty, Atuin and Espanso. These details are historical; inspect the current machine before making changes.

Official resources: [chezmoi](https://www.chezmoi.io/) · [Git](https://git-scm.com/docs)
