# ast-grep

Personal shell integration for ast-grep.

## Completion

`ast-grep.bash` is generated from the installed ast-grep CLI:

    ast-grep completions bash > .config/ast-grep/ast-grep.bash

The active configuration directory is symlinked from:

    ~/.config/ast-grep

to the `.config/ast-grep` directory of the active dotfiles checkout.
You can inspect its current location with `readlink -f ~/.config/ast-grep`.

## Project configuration

ast-grep root configuration is project-specific.

Projects should keep their own `sgconfig.yml` at the project root rather
than using a global configuration.

Example:

    ruleDirs:
      - ast-grep/rules
    utilDirs:
      - ast-grep/utils
    testConfigs:
      - testDir: ast-grep/tests

Do not add a global `sgconfig.yml` here unless global configuration is
explicitly required.
