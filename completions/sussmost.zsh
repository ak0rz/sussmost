#compdef sussmost
# Zsh completion for sussmost
# Install to a directory in your $fpath, e.g.:
#   cp sussmost.zsh ~/.local/share/zsh/site-functions/_sussmost

__sussmost_config_dir="${SUSSMOST_CONFIG_DIR:-$HOME/.config/sussmost}"
__sussmost_sessions_dir="$__sussmost_config_dir/sessions"
__sussmost_repos_file="$__sussmost_config_dir/repos"

_sussmost_repos() {
    local -a repos
    [[ -f "$__sussmost_repos_file" ]] || return
    repos=(${(f)"$(cut -d= -f1 "$__sussmost_repos_file" 2>/dev/null)"})
    _describe 'repo' repos
}

_sussmost_sessions() {
    local -a sessions
    [[ -d "$__sussmost_sessions_dir" ]] || return
    sessions=(${(f)"$(ls "$__sussmost_sessions_dir" 2>/dev/null)"})
    _describe 'session' sessions
}

_sussmost_windows() {
    local session="$1"
    local sf="$__sussmost_sessions_dir/$session"
    local -a windows
    [[ -f "$sf" ]] || return
    windows=(${(f)"$(grep '^window:' "$sf" 2>/dev/null | sed 's/^window:[0-9]*=//')"})
    _describe 'worktree' windows
}

_sussmost_hub() {
    local -a subcmds=(
        'start:Start the hub session with Claude remote-control'
        'stop:Stop the hub session'
    )
    _describe 'hub command' subcmds
}

_sussmost_repo() {
    local -a subcmds=(
        'add:Register an existing git repo'
        'clone:Clone a repo and register it'
        'list:List all registered repos'
        'remove:Unregister a repo'
    )

    case "$words[3]" in
        add)
            case $CURRENT in
                4) _sussmost_repos ;;
                5) _directories ;;
            esac
            ;;
        clone)
            # No completion for URL
            ;;
        remove)
            _sussmost_repos
            ;;
        *)
            _describe 'repo command' subcmds
            ;;
    esac
}

_sussmost() {
    local -a commands=(
        'hub:Manage the hub session'
        'repo:Manage registered repositories'
        'start:Start a tmux session for a repo'
        'add:Add a Claude worktree window to a session'
        'list:List all sessions and windows'
        'attach:Attach to a session or worktree window'
        'stop:Stop a worktree window or entire session'
        'status:Show live status of all sessions'
        'recover:Recover all sessions after reboot/crash'
        'update:Update sussmost from GitHub'
        'completions:Install/update shell completions'
        'help:Show help'
        'version:Show version'
    )

    if (( CURRENT == 2 )); then
        _describe 'command' commands
        return
    fi

    case "$words[2]" in
        hub)
            _sussmost_hub
            ;;
        repo)
            _sussmost_repo
            ;;
        start)
            if (( CURRENT == 3 )); then
                _sussmost_repos
            fi
            ;;
        add)
            if (( CURRENT == 3 )); then
                _sussmost_sessions
            fi
            ;;
        attach)
            if (( CURRENT == 3 )); then
                _sussmost_sessions
            elif (( CURRENT == 4 )); then
                _sussmost_windows "$words[3]"
            fi
            ;;
        stop)
            if (( CURRENT == 3 )); then
                _sussmost_sessions
            elif (( CURRENT == 4 )); then
                _sussmost_windows "$words[3]"
            fi
            ;;
        recover)
            if (( CURRENT == 3 )); then
                local -a recover_subcmds=(
                    'enable:Enable auto-recovery via systemd timer'
                    'disable:Disable auto-recovery'
                )
                _describe 'recover command' recover_subcmds
            fi
            ;;
    esac
}

_sussmost "$@"
