# Bash completion for sussmost
# Source this file or install to /etc/bash_completion.d/ or
# ~/.local/share/bash-completion/completions/sussmost

_sussmost_completions() {
    local cur prev words cword
    _init_completion || return

    local SUSSMOST_CONFIG_DIR="${SUSSMOST_CONFIG_DIR:-$HOME/.config/sussmost}"
    local SUSSMOST_SESSIONS_DIR="$SUSSMOST_CONFIG_DIR/sessions"
    local SUSSMOST_REPOS_FILE="$SUSSMOST_CONFIG_DIR/repos"

    # Top-level commands
    local commands="hub repo start add list attach stop status recover update completions help version"
    local hub_subcmds="start stop"
    local repo_subcmds="add clone list remove"
    local recover_subcmds="enable disable"

    case "$cword" in
        1)
            COMPREPLY=($(compgen -W "$commands" -- "$cur"))
            return
            ;;
        2)
            case "${words[1]}" in
                hub)
                    COMPREPLY=($(compgen -W "$hub_subcmds" -- "$cur"))
                    return
                    ;;
                repo)
                    COMPREPLY=($(compgen -W "$repo_subcmds" -- "$cur"))
                    return
                    ;;
                start)
                    # Complete with registered repo names
                    if [[ -f "$SUSSMOST_REPOS_FILE" ]]; then
                        local repos
                        repos=$(cut -d= -f1 "$SUSSMOST_REPOS_FILE" 2>/dev/null)
                        COMPREPLY=($(compgen -W "$repos" -- "$cur"))
                    fi
                    return
                    ;;
                add|attach)
                    # Complete with active session names
                    if [[ -d "$SUSSMOST_SESSIONS_DIR" ]]; then
                        local sessions
                        sessions=$(ls "$SUSSMOST_SESSIONS_DIR" 2>/dev/null)
                        COMPREPLY=($(compgen -W "$sessions" -- "$cur"))
                    fi
                    return
                    ;;
                stop)
                    # Complete with active session names
                    if [[ -d "$SUSSMOST_SESSIONS_DIR" ]]; then
                        local sessions
                        sessions=$(ls "$SUSSMOST_SESSIONS_DIR" 2>/dev/null)
                        COMPREPLY=($(compgen -W "$sessions" -- "$cur"))
                    fi
                    return
                    ;;
                recover)
                    COMPREPLY=($(compgen -W "$recover_subcmds" -- "$cur"))
                    return
                    ;;
            esac
            ;;
        3)
            case "${words[1]}" in
                repo)
                    case "${words[2]}" in
                        add)
                            # Complete with directory paths
                            _filedir -d
                            return
                            ;;
                        remove)
                            # Complete with registered repo names
                            if [[ -f "$SUSSMOST_REPOS_FILE" ]]; then
                                local repos
                                repos=$(cut -d= -f1 "$SUSSMOST_REPOS_FILE" 2>/dev/null)
                                COMPREPLY=($(compgen -W "$repos" -- "$cur"))
                            fi
                            return
                            ;;
                    esac
                    ;;
                add)
                    # Second arg to add is the worktree name - no completion
                    return
                    ;;
                stop|attach)
                    # Complete with window/worktree names from the session
                    local session="${words[2]}"
                    local sf="$SUSSMOST_SESSIONS_DIR/$session"
                    if [[ -f "$sf" ]]; then
                        local windows
                        windows=$(grep '^window:' "$sf" 2>/dev/null | sed 's/^window:[0-9]*=//')
                        COMPREPLY=($(compgen -W "$windows" -- "$cur"))
                    fi
                    return
                    ;;
            esac
            ;;
        4)
            case "${words[1]}" in
                repo)
                    case "${words[2]}" in
                        add)
                            # Third arg is the path
                            _filedir -d
                            return
                            ;;
                    esac
                    ;;
            esac
            ;;
    esac
}

complete -F _sussmost_completions sussmost
