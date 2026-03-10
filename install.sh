#!/usr/bin/env bash
set -euo pipefail

# sussmost installer
# Works both as: curl -fsSL <url>/install.sh | bash
# And as:        ./install.sh (from cloned repo)

INSTALL_BIN="${SUSSMOST_INSTALL_BIN:-$HOME/.local/bin}"
INSTALL_COMPLETIONS="${SUSSMOST_INSTALL_COMPLETIONS:-$HOME/.local/share/bash-completion/completions}"
SUSSMOST_CONFIG_DIR="${SUSSMOST_CONFIG_DIR:-$HOME/.config/sussmost}"
SUSSMOST_CLONE_DIR="${SUSSMOST_CLONE_DIR:-$HOME/.local/share/sussmost/repos}"
GITHUB_RAW_BASE="https://raw.githubusercontent.com/ak0rz/sussmost/main"

info() { echo "[sussmost] $*"; }
warn() { echo "[sussmost] WARNING: $*" >&2; }
die()  { echo "[sussmost] ERROR: $*" >&2; exit 1; }

# Detect if running from a local clone or via curl pipe
is_local() {
    local script_dir
    script_dir="$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")" && pwd)"
    [[ -f "$script_dir/sussmost" ]]
}

install_from_local() {
    local script_dir
    script_dir="$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")" && pwd)"
    info "installing from local clone: $script_dir"

    cp "$script_dir/sussmost" "$INSTALL_BIN/sussmost"
    chmod +x "$INSTALL_BIN/sussmost"

    if [[ -f "$script_dir/completions/sussmost.bash" ]]; then
        cp "$script_dir/completions/sussmost.bash" "$INSTALL_COMPLETIONS/sussmost"
    fi
}

install_from_remote() {
    info "downloading from GitHub..."

    if command -v curl >/dev/null 2>&1; then
        curl -fsSL "$GITHUB_RAW_BASE/sussmost" -o "$INSTALL_BIN/sussmost"
        curl -fsSL "$GITHUB_RAW_BASE/completions/sussmost.bash" -o "$INSTALL_COMPLETIONS/sussmost" 2>/dev/null || warn "could not download completions"
    elif command -v wget >/dev/null 2>&1; then
        wget -qO "$INSTALL_BIN/sussmost" "$GITHUB_RAW_BASE/sussmost"
        wget -qO "$INSTALL_COMPLETIONS/sussmost" "$GITHUB_RAW_BASE/completions/sussmost.bash" 2>/dev/null || warn "could not download completions"
    else
        die "neither curl nor wget found"
    fi

    chmod +x "$INSTALL_BIN/sussmost"
}

main() {
    # Check dependencies
    command -v tmux >/dev/null 2>&1 || die "tmux is required but not installed"
    command -v git >/dev/null 2>&1  || die "git is required but not installed"

    # Create directories
    mkdir -p "$INSTALL_BIN" "$INSTALL_COMPLETIONS" "$SUSSMOST_CONFIG_DIR/sessions" "$SUSSMOST_CLONE_DIR"

    # Install
    if is_local; then
        install_from_local
    else
        install_from_remote
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
        echo "  echo 'export PATH=\"$INSTALL_BIN:\$PATH\"' >> ~/.bashrc"
        echo ""
    fi

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
