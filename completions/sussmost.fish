# Fish completion for sussmost
# Install to ~/.config/fish/completions/sussmost.fish

set -l sussmost_config_dir (set -q SUSSMOST_CONFIG_DIR; and echo $SUSSMOST_CONFIG_DIR; or echo $HOME/.config/sussmost)
set -l sussmost_sessions_dir "$sussmost_config_dir/sessions"
set -l sussmost_repos_file "$sussmost_config_dir/repos"

# Helper: list registered repo names
function __sussmost_repos
    set -l repos_file (set -q SUSSMOST_CONFIG_DIR; and echo $SUSSMOST_CONFIG_DIR; or echo $HOME/.config/sussmost)/repos
    test -f "$repos_file"; or return
    cut -d= -f1 "$repos_file" 2>/dev/null
end

# Helper: list session names
function __sussmost_sessions
    set -l sessions_dir (set -q SUSSMOST_CONFIG_DIR; and echo $SUSSMOST_CONFIG_DIR; or echo $HOME/.config/sussmost)/sessions
    test -d "$sessions_dir"; or return
    ls "$sessions_dir" 2>/dev/null
end

# Helper: list worktree windows for a session
function __sussmost_windows
    set -l session $argv[1]
    set -l sf (set -q SUSSMOST_CONFIG_DIR; and echo $SUSSMOST_CONFIG_DIR; or echo $HOME/.config/sussmost)/sessions/$session
    test -f "$sf"; or return
    grep '^window:' "$sf" 2>/dev/null | sed 's/^window:[0-9]*=//'
end

# Disable file completions by default
complete -c sussmost -f

# Top-level commands
complete -c sussmost -n "__fish_use_subcommand" -a hub -d "Manage the hub session"
complete -c sussmost -n "__fish_use_subcommand" -a repo -d "Manage registered repositories"
complete -c sussmost -n "__fish_use_subcommand" -a start -d "Start a tmux session for a repo"
complete -c sussmost -n "__fish_use_subcommand" -a add -d "Add a Claude worktree window"
complete -c sussmost -n "__fish_use_subcommand" -a list -d "List all sessions and windows"
complete -c sussmost -n "__fish_use_subcommand" -a attach -d "Attach to a session or worktree window"
complete -c sussmost -n "__fish_use_subcommand" -a stop -d "Stop a worktree window or session"
complete -c sussmost -n "__fish_use_subcommand" -a status -d "Show live status"
complete -c sussmost -n "__fish_use_subcommand" -a recover -d "Recover sessions after reboot/crash"
complete -c sussmost -n "__fish_use_subcommand" -a help -d "Show help"
complete -c sussmost -n "__fish_use_subcommand" -a version -d "Show version"

# hub subcommands
complete -c sussmost -n "__fish_seen_subcommand_from hub; and not __fish_seen_subcommand_from start stop" -a start -d "Start the hub"
complete -c sussmost -n "__fish_seen_subcommand_from hub; and not __fish_seen_subcommand_from start stop" -a stop -d "Stop the hub"

# repo subcommands
complete -c sussmost -n "__fish_seen_subcommand_from repo; and not __fish_seen_subcommand_from add clone list remove" -a add -d "Register an existing repo"
complete -c sussmost -n "__fish_seen_subcommand_from repo; and not __fish_seen_subcommand_from add clone list remove" -a clone -d "Clone and register a repo"
complete -c sussmost -n "__fish_seen_subcommand_from repo; and not __fish_seen_subcommand_from add clone list remove" -a list -d "List registered repos"
complete -c sussmost -n "__fish_seen_subcommand_from repo; and not __fish_seen_subcommand_from add clone list remove" -a remove -d "Unregister a repo"

# repo remove: complete with repo names
complete -c sussmost -n "__fish_seen_subcommand_from repo; and __fish_seen_subcommand_from remove" -a "(__sussmost_repos)" -d "Registered repo"

# start: complete with repo names
complete -c sussmost -n "__fish_seen_subcommand_from start" -a "(__sussmost_repos)" -d "Registered repo"
complete -c sussmost -n "__fish_seen_subcommand_from start" -l worktree -s w -d "Initial worktree name" -r

# add: complete with session names
complete -c sussmost -n "__fish_seen_subcommand_from add" -a "(__sussmost_sessions)" -d "Session"

# attach: complete with session names, then worktree names
complete -c sussmost -n "__fish_seen_subcommand_from attach; and test (count (commandline -opc)) -eq 2" -a "(__sussmost_sessions)" -d "Session"
complete -c sussmost -n "__fish_seen_subcommand_from attach; and test (count (commandline -opc)) -eq 3" -a "(__sussmost_windows (commandline -opc)[3])" -d "Worktree"

# stop: complete with session names, then worktree names
complete -c sussmost -n "__fish_seen_subcommand_from stop; and test (count (commandline -opc)) -eq 2" -a "(__sussmost_sessions)" -d "Session"
complete -c sussmost -n "__fish_seen_subcommand_from stop; and test (count (commandline -opc)) -eq 3" -a "(__sussmost_windows (commandline -opc)[3])" -d "Worktree"

# recover subcommands
complete -c sussmost -n "__fish_seen_subcommand_from recover; and not __fish_seen_subcommand_from enable disable" -a enable -d "Enable auto-recovery via systemd timer"
complete -c sussmost -n "__fish_seen_subcommand_from recover; and not __fish_seen_subcommand_from enable disable" -a disable -d "Disable auto-recovery"
