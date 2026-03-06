# Dotfiles repo — conventions for Claude

Managed with Dotbot. Config in `install.conf.yaml`. Run `./install` to apply.

For dotfiles structure, personal vs work machine setup, git-crypt, and OS-conditional configs, read `README.md`.

When installing a new CLI tool, read `README.md` for the `install_tools.sh` convention and ask the user if the tool should be added there for cross-platform availability.

"Fish extra" refers to `~/.config/fish/include/ignore/extra.fish` — a git-ignored file containing personal secrets, credentials, and machine-specific config (e.g., NPM API creds, API keys).

`claude/HUMAN.md` contains personal context about the user. Use the `/human` skill for reading, updating, and syncing it.
