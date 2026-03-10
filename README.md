# sussmost

Remote Claude session manager for Linux. Uses tmux sessions and git worktrees to run multiple isolated Claude Code instances per repository, all controllable from the Claude app.

## How it works

```
sussmost-hub (tmux session — your command center)
  └─ Claude remote-control (manage everything from Claude app)

sussmost-myapi (tmux session — one per repo)
  ├─ control window (shell with session context)
  ├─ claude -w auth-feature remote-control
  └─ claude -w billing-fix remote-control

sussmost-frontend (another repo)
  ├─ control window
  ├─ claude -w header remote-control
  └─ claude -w sidebar remote-control
```

- **Each tmux session** = one git repository
- **Each tmux window** = one Claude instance in an isolated git worktree
- **Each Claude instance** runs with `remote-control`, so you can connect from [claude.ai](https://claude.ai) or the Claude mobile app
- **The hub** is a persistent Claude session that knows how to use `sussmost` — tell it what to do from the app and it manages everything for you

## Requirements

- Linux
- [tmux](https://github.com/tmux/tmux)
- [git](https://git-scm.com/)
- [Claude Code](https://docs.anthropic.com/en/docs/claude-code) (`claude` CLI)

## Install

**One-liner:**

```bash
curl -fsSL https://raw.githubusercontent.com/ak0rz/sussmost/main/install.sh | bash
```

**From source:**

```bash
git clone https://github.com/ak0rz/sussmost.git
cd sussmost
./install.sh
```

The installer puts `sussmost` in `~/.local/bin/` and auto-detects your shells to install completions for bash, zsh, and/or fish. Make sure `~/.local/bin` is in your `PATH`.

Completion install locations:
- **bash:** `~/.local/share/bash-completion/completions/sussmost`
- **zsh:** `~/.local/share/zsh/site-functions/_sussmost`
- **fish:** `~/.config/fish/completions/sussmost.fish`

## Quick start

```bash
# 1. Start the hub (Claude remote-control command center)
sussmost hub start

# 2. Register a repo
sussmost repo add myapi ~/projects/my-api

# 3. Start a session for that repo
sussmost start myapi

# 4. Add worktree windows (each gets its own Claude instance)
sussmost add myapi auth-feature
sussmost add myapi billing-fix

# 5. Check what's running
sussmost status
```

Now open the Claude app — you'll see `sussmost-hub`, `myapi/auth-feature`, and `myapi/billing-fix` as separate remote-control sessions. Each Claude instance works in its own worktree, fully isolated.

## Usage from the Claude app

Once the hub is running, connect to it from the Claude app and manage everything by asking:

> "Register my project at ~/projects/frontend"

> "Start a session for frontend with worktrees for navbar, footer, and dark-mode"

> "What's running right now?"

> "The navbar feature is done, shut down that worktree"

> "Clone https://github.com/acme/tools.git and start working on it"

The hub Claude session has `sussmost` available as a tool and knows how to use it.

## Commands

### Hub

| Command | Description |
|---------|-------------|
| `sussmost hub start` | Start the hub session with Claude remote-control |
| `sussmost hub stop` | Stop the hub |

### Repos

| Command | Description |
|---------|-------------|
| `sussmost repo add <name> <path>` | Register an existing git repo |
| `sussmost repo clone <url> [name]` | Clone a repo and register it |
| `sussmost repo list` | List registered repos |
| `sussmost repo remove <name>` | Unregister (doesn't delete files) |

### Sessions

| Command | Description |
|---------|-------------|
| `sussmost start <repo> [-w <worktree>]` | Start a tmux session for a repo |
| `sussmost add [session] <worktree>` | Add a Claude worktree window |
| `sussmost list` | List all sessions and windows |
| `sussmost attach [session] [worktree]` | Attach to a session or specific worktree window |
| `sussmost stop [session] [window]` | Stop a window or entire session |
| `sussmost status` | Live status with process info |
| `sussmost recover` | Recover all sessions after reboot/crash |
| `sussmost recover enable` | Enable auto-recovery via systemd timer (checks every 60s) |
| `sussmost recover disable` | Disable auto-recovery |

### Auto-detection

Inside a sussmost tmux session, the session name is auto-detected — no need to repeat it:

```bash
# Inside the myapi session's control window:
sussmost add new-feature      # instead of: sussmost add myapi new-feature
sussmost attach new-feature   # instead of: sussmost attach myapi new-feature
sussmost stop old-feature     # instead of: sussmost stop myapi old-feature
```

## Configuration

| Variable | Default | Description |
|----------|---------|-------------|
| `SUSSMOST_CONFIG_DIR` | `~/.config/sussmost` | Config and metadata |
| `SUSSMOST_CLONE_DIR` | `~/.local/share/sussmost/repos` | Where `repo clone` puts repos |

## License

MIT
