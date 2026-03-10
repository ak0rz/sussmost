#!/usr/bin/env bash
set -euo pipefail

# sussmost installer
# Works both as: curl -fsSL <url>/install.sh | bash
# And as:        ./install.sh (from cloned repo)

INSTALL_BIN="${SUSSMOST_INSTALL_BIN:-$HOME/.local/bin}"
INSTALL_BASH_COMPLETIONS="$HOME/.local/share/bash-completion/completions"
INSTALL_ZSH_COMPLETIONS="$HOME/.local/share/zsh/site-functions"
INSTALL_FISH_COMPLETIONS="$HOME/.config/fish/completions"
SUSSMOST_CONFIG_DIR="${SUSSMOST_CONFIG_DIR:-$HOME/.config/sussmost}"
SUSSMOST_CLONE_DIR="${SUSSMOST_CLONE_DIR:-$HOME/.local/share/sussmost/repos}"
GITHUB_RAW_BASE="https://raw.githubusercontent.com/ak0rz/sussmost/main"

info() { echo "[sussmost] $*"; }
warn() { echo "[sussmost] WARNING: $*" >&2; }
die()  { echo "[sussmost] ERROR: $*" >&2; exit 1; }

_fetch() {
    local url="$1" dest="$2"
    if command -v curl >/dev/null 2>&1; then
        curl -fsSL "$url" -o "$dest"
    elif command -v wget >/dev/null 2>&1; then
        wget -qO "$dest" "$url"
    else
        die "neither curl nor wget found"
    fi
}

# Detect if running from a local clone or via curl pipe
is_local() {
    local script_dir
    script_dir="$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")" && pwd)"
    [[ -f "$script_dir/sussmost" ]]
}

get_script_dir() {
    cd "$(dirname "${BASH_SOURCE[0]:-$0}")" && pwd
}

detect_shells() {
    local shells=()
    # Always install bash completions (installer itself is bash)
    shells+=(bash)
    # Check for zsh
    if command -v zsh >/dev/null 2>&1; then
        shells+=(zsh)
    fi
    # Check for fish
    if command -v fish >/dev/null 2>&1; then
        shells+=(fish)
    fi
    echo "${shells[@]}"
}

install_completions_local() {
    local script_dir="$1"
    shift
    local shells=("$@")

    for shell in "${shells[@]}"; do
        case "$shell" in
            bash)
                if [[ -f "$script_dir/completions/sussmost.bash" ]]; then
                    mkdir -p "$INSTALL_BASH_COMPLETIONS"
                    cp "$script_dir/completions/sussmost.bash" "$INSTALL_BASH_COMPLETIONS/sussmost"
                    info "installed bash completions"
                fi
                ;;
            zsh)
                if [[ -f "$script_dir/completions/sussmost.zsh" ]]; then
                    mkdir -p "$INSTALL_ZSH_COMPLETIONS"
                    cp "$script_dir/completions/sussmost.zsh" "$INSTALL_ZSH_COMPLETIONS/_sussmost"
                    info "installed zsh completions"
                fi
                ;;
            fish)
                if [[ -f "$script_dir/completions/sussmost.fish" ]]; then
                    mkdir -p "$INSTALL_FISH_COMPLETIONS"
                    cp "$script_dir/completions/sussmost.fish" "$INSTALL_FISH_COMPLETIONS/sussmost.fish"
                    info "installed fish completions"
                fi
                ;;
        esac
    done
}

install_completions_remote() {
    local shells=("$@")

    for shell in "${shells[@]}"; do
        case "$shell" in
            bash)
                mkdir -p "$INSTALL_BASH_COMPLETIONS"
                _fetch "$GITHUB_RAW_BASE/completions/sussmost.bash" "$INSTALL_BASH_COMPLETIONS/sussmost" \
                    || warn "could not download bash completions"
                info "installed bash completions"
                ;;
            zsh)
                mkdir -p "$INSTALL_ZSH_COMPLETIONS"
                _fetch "$GITHUB_RAW_BASE/completions/sussmost.zsh" "$INSTALL_ZSH_COMPLETIONS/_sussmost" \
                    || warn "could not download zsh completions"
                info "installed zsh completions"
                ;;
            fish)
                mkdir -p "$INSTALL_FISH_COMPLETIONS"
                _fetch "$GITHUB_RAW_BASE/completions/sussmost.fish" "$INSTALL_FISH_COMPLETIONS/sussmost.fish" \
                    || warn "could not download fish completions"
                info "installed fish completions"
                ;;
        esac
    done
}

main() {
    # Check dependencies
    command -v tmux >/dev/null 2>&1 || die "tmux is required but not installed"
    command -v git >/dev/null 2>&1  || die "git is required but not installed"

    # Detect available shells
    local shells
    read -ra shells <<< "$(detect_shells)"
    info "detected shells: ${shells[*]}"

    # Create directories
    mkdir -p "$INSTALL_BIN" "$SUSSMOST_CONFIG_DIR/sessions" "$SUSSMOST_CLONE_DIR"

    # Install main script
    if is_local; then
        local script_dir
        script_dir="$(get_script_dir)"
        info "installing from local clone: $script_dir"
        cp "$script_dir/sussmost" "$INSTALL_BIN/sussmost"
        chmod +x "$INSTALL_BIN/sussmost"
        install_completions_local "$script_dir" "${shells[@]}"
    else
        info "downloading from GitHub..."
        _fetch "$GITHUB_RAW_BASE/sussmost" "$INSTALL_BIN/sussmost"
        chmod +x "$INSTALL_BIN/sussmost"
        install_completions_remote "${shells[@]}"
    fi

    # Verify installation
    if [[ ! -x "$INSTALL_BIN/sussmost" ]]; then
        die "installation failed: $INSTALL_BIN/sussmost not found or not executable"
    fi

    info "installed sussmost to $INSTALL_BIN/sussmost"

    # Check PATH
    if ! echo "$PATH" | tr ':' '\n' | grep -qx "$INSTALL_BIN"; then
        warn "$INSTALL_BIN is not in your PATH"
        echo ""
        echo "Add it to your shell profile:"
        for shell in "${shells[@]}"; do
            case "$shell" in
                bash) echo "  echo 'export PATH=\"$INSTALL_BIN:\$PATH\"' >> ~/.bashrc" ;;
                zsh)  echo "  echo 'export PATH=\"$INSTALL_BIN:\$PATH\"' >> ~/.zshrc" ;;
                fish) echo "  fish_add_path $INSTALL_BIN" ;;
            esac
        done
        echo ""
    fi

    # Shell-specific notes
    for shell in "${shells[@]}"; do
        case "$shell" in
            zsh)
                if ! zsh -c 'echo $fpath' 2>/dev/null | grep -q "$INSTALL_ZSH_COMPLETIONS"; then
                    echo "  [zsh] Add to ~/.zshrc:  fpath=($INSTALL_ZSH_COMPLETIONS \$fpath); autoload -Uz compinit && compinit"
                fi
                ;;
        esac
    done

    info "config directory: $SUSSMOST_CONFIG_DIR"
    info "clone directory:  $SUSSMOST_CLONE_DIR"
    echo ""
    info "installation complete!"
    echo ""
    echo "Get started:"
    echo "  sussmost hub start         # Start the hub (remote-controllable command center)"
    echo "  sussmost repo add <n> <p>  # Register a repo"
    echo "  sussmost start <repo>      # Start a session"
    echo "  sussmost help              # Full usage"
}

main "$@"
