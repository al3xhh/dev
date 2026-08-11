# dev

[![License: GPL v3](https://img.shields.io/badge/License-GPLv3-blue.svg)](LICENSE)

Personal development environment: editor, shell, terminal, window
management, and automation configuration, kept in one place and
symlinked into `$HOME`.

```
       .__  ________              .__    .__          .___
_____  |  | \_____  \___  ___     |  |__ |  |__     __| _/_______  __
\__  \ |  |   _(__  <\  \/  /     |  |  \|  |  \   / __ |/ __ \  \/ /
 / __ \|  |__/       \>    <      |   Y  \   Y  \ / /_/ \  ___/\   /
(____  /____/______  /__/\_ \_____|___|  /___|  / \____ |\___  >\_/
     \/            \/      \/_____/    \/     \/       \/    \/
```

## Layout

Each top-level directory holds the config for one tool, mirroring the
path it's symlinked to under `$HOME` — e.g. `tmux/.tmux.conf` symlinks
to `~/.tmux.conf`, `zsh/.zshrc` to `~/.zshrc`. Third-party plugins are
tracked as git submodules (see `.gitmodules`) rather than vendored.

| Category | Tool | Directory |
|---|---|---|
| Editor | [Vim](https://github.com/vim/vim) | `vim/` |
| Terminal | [Oh My Zsh](https://ohmyz.sh) | `zsh/` |
| Terminal | [Terminator](https://terminator-gtk3.readthedocs.io/en/latest) | `terminator/` |
| Version control | [Git](https://github.com/git/git) | `git/` |
| Window management | [i3](https://i3wm.org/docs/userguide.html) | `i3/` |
| Window management | [i3status](https://i3wm.org/docs/i3status.html) *(deprecated)* | `i3status/` |
| Window management | [i3status-rust](https://github.com/greshake/i3status-rust) | `i3status-rust/` |
| Window management | [tmux](https://github.com/tmux/tmux) | `tmux/` |
| AI tools | [Claude Code](https://claude.com/product/claude-code) | `claude/` |
| Automation | Startup/shutdown helper scripts | `scripts/` (see [scripts/README.md](scripts/README.md)) |

## Installation

Clone the repo with submodules, then symlink whichever configs you
want into `$HOME`, following the same directory-mirrors-target
pattern as the existing entries:

```sh
git clone --recurse-submodules git@github.com:al3xhh/dev.git ~/Documents/dev
ln -s ~/Documents/dev/tmux/.tmux.conf ~/.tmux.conf
ln -s ~/Documents/dev/zsh/.zshrc ~/.zshrc
ln -s ~/Documents/dev/claude/CLAUDE.md ~/.claude/CLAUDE.md
# ...repeat per tool
```

Machine-local or employer-specific overrides (secrets, internal
aliases, anything that shouldn't be public) are kept in untracked
files outside this repo and sourced conditionally where the tracked
config supports it, rather than committed here.

## License

[GPLv3](LICENSE)
