# Fish shell completions for opencode
# Save to ~/.config/fish/completions/opencode.fish

# Disable default file completions for most commands
complete -c opencode -f

# Global flags
complete -c opencode -l help -s h -d "Display help"
complete -c opencode -l version -s v -d "Print version number"
complete -c opencode -l print-logs -d "Print logs to stderr"
complete -c opencode -l log-level -d "Log level (DEBUG, INFO, WARN, ERROR)" -a "DEBUG INFO WARN ERROR"

# Main subcommands
complete -c opencode -n "__fish_use_subcommand" -a "agent" -d "Manage agents"
complete -c opencode -n "__fish_use_subcommand" -a "attach" -d "Attach to a running OpenCode server"
complete -c opencode -n "__fish_use_subcommand" -a "auth" -d "Manage credentials and login"
complete -c opencode -n "__fish_use_subcommand" -a "github" -d "Manage the GitHub agent"
complete -c opencode -n "__fish_use_subcommand" -a "mcp" -d "Manage MCP servers"
complete -c opencode -n "__fish_use_subcommand" -a "models" -d "List available models"
complete -c opencode -n "__fish_use_subcommand" -a "run" -d "Run in non-interactive mode"
complete -c opencode -n "__fish_use_subcommand" -a "serve" -d "Start a headless OpenCode server"
complete -c opencode -n "__fish_use_subcommand" -a "session" -d "Manage sessions"
complete -c opencode -n "__fish_use_subcommand" -a "stats" -d "Show token usage and cost statistics"
complete -c opencode -n "__fish_use_subcommand" -a "export" -d "Export session data as JSON"
complete -c opencode -n "__fish_use_subcommand" -a "import" -d "Import session data"
complete -c opencode -n "__fish_use_subcommand" -a "web" -d "Start web interface server"
complete -c opencode -n "__fish_use_subcommand" -a "acp" -d "Start ACP server"
complete -c opencode -n "__fish_use_subcommand" -a "uninstall" -d "Uninstall OpenCode"
complete -c opencode -n "__fish_use_subcommand" -a "upgrade" -d "Update to latest version"

# Default TUI flags (when no subcommand)
complete -c opencode -n "__fish_use_subcommand" -l continue -s c -d "Continue the last session"
complete -c opencode -n "__fish_use_subcommand" -l session -s s -d "Session ID to continue"
complete -c opencode -n "__fish_use_subcommand" -l fork -d "Fork the session when continuing"
complete -c opencode -n "__fish_use_subcommand" -l prompt -d "Prompt to use"
complete -c opencode -n "__fish_use_subcommand" -l model -s m -d "Model to use (provider/model)"
complete -c opencode -n "__fish_use_subcommand" -l agent -d "Agent to use"
complete -c opencode -n "__fish_use_subcommand" -l port -d "Port to listen on"
complete -c opencode -n "__fish_use_subcommand" -l hostname -d "Hostname to listen on"

# Agent subcommand
complete -c opencode -n "__fish_seen_subcommand_from agent; and not __fish_seen_subcommand_from create list" -a "create" -d "Create a new agent"
complete -c opencode -n "__fish_seen_subcommand_from agent; and not __fish_seen_subcommand_from create list" -a "list" -d "List all available agents"

# Attach subcommand flags
complete -c opencode -n "__fish_seen_subcommand_from attach" -l dir -d "Working directory to start TUI in"
complete -c opencode -n "__fish_seen_subcommand_from attach" -l session -s s -d "Session ID to continue"

# Auth subcommand
complete -c opencode -n "__fish_seen_subcommand_from auth; and not __fish_seen_subcommand_from login list logout" -a "login" -d "Configure API keys for providers"
complete -c opencode -n "__fish_seen_subcommand_from auth; and not __fish_seen_subcommand_from login list logout" -a "list" -d "List authenticated providers"
complete -c opencode -n "__fish_seen_subcommand_from auth; and not __fish_seen_subcommand_from login list logout" -a "logout" -d "Logout from a provider"
complete -c opencode -n "__fish_seen_subcommand_from auth" -a "ls" -d "List authenticated providers (alias)"

# GitHub subcommand
complete -c opencode -n "__fish_seen_subcommand_from github; and not __fish_seen_subcommand_from install run" -a "install" -d "Install the GitHub agent"
complete -c opencode -n "__fish_seen_subcommand_from github; and not __fish_seen_subcommand_from install run" -a "run" -d "Run the GitHub agent"
complete -c opencode -n "__fish_seen_subcommand_from github; and __fish_seen_subcommand_from run" -l event -d "GitHub mock event"
complete -c opencode -n "__fish_seen_subcommand_from github; and __fish_seen_subcommand_from run" -l token -d "GitHub personal access token"

# MCP subcommand
complete -c opencode -n "__fish_seen_subcommand_from mcp; and not __fish_seen_subcommand_from add list auth logout debug" -a "add" -d "Add an MCP server"
complete -c opencode -n "__fish_seen_subcommand_from mcp; and not __fish_seen_subcommand_from add list auth logout debug" -a "list" -d "List configured MCP servers"
complete -c opencode -n "__fish_seen_subcommand_from mcp; and not __fish_seen_subcommand_from add list auth logout debug" -a "auth" -d "Authenticate with OAuth-enabled MCP server"
complete -c opencode -n "__fish_seen_subcommand_from mcp; and not __fish_seen_subcommand_from add list auth logout debug" -a "logout" -d "Remove OAuth credentials"
complete -c opencode -n "__fish_seen_subcommand_from mcp; and not __fish_seen_subcommand_from add list auth logout debug" -a "debug" -d "Debug OAuth connection issues"
complete -c opencode -n "__fish_seen_subcommand_from mcp" -a "ls" -d "List configured MCP servers (alias)"

# Models subcommand flags
complete -c opencode -n "__fish_seen_subcommand_from models" -l refresh -d "Refresh models cache from models.dev"
complete -c opencode -n "__fish_seen_subcommand_from models" -l verbose -d "Verbose output with metadata"

# Run subcommand flags
complete -c opencode -n "__fish_seen_subcommand_from run" -l command -d "The command to run"
complete -c opencode -n "__fish_seen_subcommand_from run" -l continue -s c -d "Continue the last session"
complete -c opencode -n "__fish_seen_subcommand_from run" -l session -s s -d "Session ID to continue"
complete -c opencode -n "__fish_seen_subcommand_from run" -l fork -d "Fork the session when continuing"
complete -c opencode -n "__fish_seen_subcommand_from run" -l share -d "Share the session"
complete -c opencode -n "__fish_seen_subcommand_from run" -l model -s m -d "Model to use (provider/model)"
complete -c opencode -n "__fish_seen_subcommand_from run" -l agent -d "Agent to use"
complete -c opencode -n "__fish_seen_subcommand_from run" -l file -s f -d "File(s) to attach" -F
complete -c opencode -n "__fish_seen_subcommand_from run" -l format -d "Output format" -a "default json"
complete -c opencode -n "__fish_seen_subcommand_from run" -l title -d "Title for the session"
complete -c opencode -n "__fish_seen_subcommand_from run" -l attach -d "Attach to a running opencode server"
complete -c opencode -n "__fish_seen_subcommand_from run" -l port -d "Port for local server"

# Serve subcommand flags
complete -c opencode -n "__fish_seen_subcommand_from serve" -l port -d "Port to listen on"
complete -c opencode -n "__fish_seen_subcommand_from serve" -l hostname -d "Hostname to listen on"
complete -c opencode -n "__fish_seen_subcommand_from serve" -l mdns -d "Enable mDNS discovery"
complete -c opencode -n "__fish_seen_subcommand_from serve" -l cors -d "Additional browser origins for CORS"

# Session subcommand
complete -c opencode -n "__fish_seen_subcommand_from session; and not __fish_seen_subcommand_from list" -a "list" -d "List all sessions"
complete -c opencode -n "__fish_seen_subcommand_from session" -a "ls" -d "List all sessions (alias)"
complete -c opencode -n "__fish_seen_subcommand_from session" -l max-count -s n -d "Limit to N most recent sessions"
complete -c opencode -n "__fish_seen_subcommand_from session" -l format -d "Output format" -a "table json"

# Stats subcommand flags
complete -c opencode -n "__fish_seen_subcommand_from stats" -l days -d "Show stats for last N days"
complete -c opencode -n "__fish_seen_subcommand_from stats" -l tools -d "Number of tools to show"
complete -c opencode -n "__fish_seen_subcommand_from stats" -l models -d "Show model usage breakdown"
complete -c opencode -n "__fish_seen_subcommand_from stats" -l project -d "Filter by project"

# Web subcommand flags
complete -c opencode -n "__fish_seen_subcommand_from web" -l port -d "Port to listen on"
complete -c opencode -n "__fish_seen_subcommand_from web" -l hostname -d "Hostname to listen on"
complete -c opencode -n "__fish_seen_subcommand_from web" -l mdns -d "Enable mDNS discovery"
complete -c opencode -n "__fish_seen_subcommand_from web" -l cors -d "Additional browser origins for CORS"

# ACP subcommand flags
complete -c opencode -n "__fish_seen_subcommand_from acp" -l cwd -d "Working directory"
complete -c opencode -n "__fish_seen_subcommand_from acp" -l port -d "Port to listen on"
complete -c opencode -n "__fish_seen_subcommand_from acp" -l hostname -d "Hostname to listen on"

# Uninstall subcommand flags
complete -c opencode -n "__fish_seen_subcommand_from uninstall" -l keep-config -s c -d "Keep configuration files"
complete -c opencode -n "__fish_seen_subcommand_from uninstall" -l keep-data -s d -d "Keep session data and snapshots"
complete -c opencode -n "__fish_seen_subcommand_from uninstall" -l dry-run -d "Show what would be removed"
complete -c opencode -n "__fish_seen_subcommand_from uninstall" -l force -s f -d "Skip confirmation prompts"

# Upgrade subcommand flags
complete -c opencode -n "__fish_seen_subcommand_from upgrade" -l method -s m -d "Installation method" -a "curl npm pnpm bun brew"
