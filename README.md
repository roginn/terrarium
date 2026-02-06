# Claude Code Docker Sandbox

Run [Claude Code](https://docs.anthropic.com/en/docs/claude-code) with `--dangerously-skip-permissions` safely inside a Docker container, with VS Code Dev Container support for file editing.

## Features

- **Isolated environment**: Claude Code runs in a sandboxed Docker container with limited host access
- **Dev Container support**: Full VS Code integration via Dev Containers
- **Pre-installed tools**: Node.js 22, Python 3, gh CLI, git, ripgrep, and build essentials
- **Persistent authentication**: Auth persists across container restarts via mounted `~/.claude` directory
- **Lightweight base**: Debian bookworm-slim (~1GB final image)

## Prerequisites

- Docker and Docker Compose
- (Optional) VS Code with Dev Containers extension

## Quick Start

```bash
# Clone the repository
git clone <repository-url>
cd enclaude

# Start the container and launch Claude Code
./start.sh --claude

# Authenticate when prompted (first time only)
# Choose "Claude account with subscription" and complete browser login

# Or start the container and get a shell
./start.sh --shell

# Or just start the container in the background
./start.sh --run
```

## Usage

The `start.sh` script provides several options:

```bash
./start.sh           # Show usage and options
./start.sh --run     # Start the container in the background
./start.sh --shell   # Start the container and open a bash shell
./start.sh --claude  # Start the container and launch Claude Code
./start.sh --build   # Rebuild the image and restart the container
./start.sh --stop    # Stop the running container
./start.sh --help    # Show help message
```

## VS Code Dev Container

1. Open this folder in VS Code
2. Click "Reopen in Container" when prompted (or use Command Palette → "Dev Containers: Reopen in Container")
3. VS Code will attach to the running container with full IDE features
4. Files in `/workspace` are shared between the container and the host

## GitHub Authentication

To let Claude Code push/pull and use `gh` inside the container, create a **fine-grained Personal Access Token** (PAT):

1. Go to [GitHub → Settings → Developer settings → Fine-grained tokens](https://github.com/settings/tokens?type=beta)
2. Click **Generate new token**
3. Set a name (e.g., "enclaude") and expiration (90 days recommended)
4. Under **Repository access**, select only the repos you need
5. Under **Permissions → Repository permissions**, grant:
   - **Contents**: Read and write (for git push/pull)
   - **Pull requests**: Read and write (if you want Claude to create PRs)
   - **Issues**: Read and write (if you want Claude to manage issues)
6. Generate the token and add it to your `.env` file:

```bash
GITHUB_TOKEN=github_pat_...
```

The container automatically configures both `gh` and `git` to use this token on startup. The token is never written to disk inside the container.

**Security notes:**
- Fine-grained PATs are scoped to specific repos and permissions — if compromised, the blast radius is limited
- Set an expiration and rotate periodically
- Revoke immediately at [github.com/settings/tokens](https://github.com/settings/tokens) if you suspect a leak

## Configuration

Environment variables can be set in a `.env` file (see `.env.example`):

```bash
# GitHub fine-grained PAT (see "GitHub Authentication" above)
GITHUB_TOKEN=github_pat_...

# Optional: Host directory to mount as /workspace (defaults to ./workspace)
WORKSPACE_DIR=./workspace
```

## File Structure

```
enclaude/
├── Dockerfile                   # Container image definition
├── docker-compose.yml           # Container orchestration
├── entrypoint.sh                # Container startup (configures GitHub auth)
├── .devcontainer/
│   └── devcontainer.json        # VS Code Dev Container config
├── start.sh                     # Convenience script
├── .env.example                 # Example environment variables
├── .gitignore                   # Git ignore rules
└── workspace/                   # Your project files (gitignored)
```

## How It Works

- **Workspace isolation**: The `./workspace` directory on your host is bind-mounted to `/workspace` inside the container. Claude Code can only access files in this directory, not your entire filesystem.
- **Authentication**: Your `~/.claude` directory is mounted so authentication persists across container restarts. Authenticate once inside the container (via browser), and you won't need to re-login.
- **Permissions**: Claude Code runs with `--dangerously-skip-permissions` inside the container, but this only affects the sandboxed environment, not your host system.

## Installed Tools

- **Node.js**: 22 LTS
- **Python**: 3.11 (`python` and `python3` both available)
- **Claude Code**: Latest native build
- **GitHub CLI**: `gh`
- **Build tools**: gcc, g++, make, cmake
- **Utilities**: git, curl, wget, jq, ripgrep, fd-find, vim

## Troubleshooting

**Container won't start:**
```bash
./start.sh --stop
./start.sh --build
```

**First time setup:**
Run `./start.sh --claude` and authenticate via browser when prompted. Choose "Claude account with subscription" and complete the login. Your authentication will persist across container restarts.

**Python command not found:**
The container symlinks `python` → `python3`. If you rebuilt an old version, run `./start.sh --build` to update.

## License

MIT
