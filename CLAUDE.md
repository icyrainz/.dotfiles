# Dotfiles repo — conventions for Claude

Managed with Dotbot. Config in `install.conf.yaml`. Run `./install` to apply.

For dotfiles structure, personal vs work machine setup, git-crypt, and OS-conditional configs, read `README.md`.

When installing a new CLI tool, read `README.md` for the `install_tools.sh` convention and ask the user if the tool should be added there for cross-platform availability.

"Fish extra" refers to `~/.config/fish/include/ignore/extra.fish` — a git-ignored file containing personal secrets, credentials, and machine-specific config (e.g., NPM API creds, API keys).

When deep-researching a GitHub repo (reading multiple files, tracing code paths, understanding architecture), clone it to `/tmp` and explore locally instead of making repeated `gh api` calls. Local reads are faster, cheaper on tokens, and don't risk rate limits.
