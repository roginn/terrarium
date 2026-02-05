#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

CONTAINER_NAME="claude-sandbox"

usage() {
    echo "Claude Code Docker Sandbox"
    echo ""
    echo "Usage: ./start.sh [OPTION]"
    echo ""
    echo "Options:"
    echo "  --run      Start the container in the background"
    echo "  --shell    Start the container and open an interactive bash shell"
    echo "  --claude   Start the container and launch Claude Code"
    echo "             (with --dangerously-skip-permissions)"
    echo "  --build    Rebuild the image and restart the container"
    echo "  --stop     Stop the running container"
    echo "  --help     Show this help message"
    echo ""
    echo "VS Code: Open this folder and use 'Reopen in Container'"
    echo "         to attach VS Code to the running container."
}

ensure_container() {
    # Create workspace directory if it doesn't exist
    local workspace_dir="${WORKSPACE_DIR:-./workspace}"
    mkdir -p "$workspace_dir"

    # Start the container (quietly, no rebuild)
    docker compose up -d --quiet-pull 2>/dev/null
}

case "${1:-}" in
    --run)
        ensure_container
        echo "Container '$CONTAINER_NAME' is running."
        ;;
    --shell)
        ensure_container
        docker exec -it "$CONTAINER_NAME" bash
        ;;
    --claude)
        ensure_container
        docker exec -it "$CONTAINER_NAME" claude --dangerously-skip-permissions
        ;;
    --build)
        echo "Building image..."
        docker compose up -d --build
        echo "Container '$CONTAINER_NAME' is running."
        ;;
    --stop)
        docker compose down
        echo "Container stopped."
        ;;
    --help)
        usage
        ;;
    *)
        usage
        ;;
esac
