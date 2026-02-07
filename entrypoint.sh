#!/bin/bash
set -e

# Set HOME for the dev user
export HOME=/home/dev

# Display MOTD if running an interactive shell (for tunnel login or bash)
if [[ $- == *i* ]]; then
    [ -f /etc/motd ] && cat /etc/motd
fi

#
# Git
#
# Configure git user if environment variables are set
[ -n "$GIT_USER" ] &&
    git config --global user.name "$GIT_USER"
[ -n "$GIT_EMAIL" ] &&
    git config --global user.email "$GIT_EMAIL"

#
# VS Code Tunnel Configuration
#
# If CODE_TUNNEL_PROVIDER is set and we're running code tunnel, handle provider setup first
if [ "$1" = "code" ] && [ "$2" = "tunnel" ] && [ -n "$CODE_TUNNEL_PROVIDER" ]; then
    shift 2  # Remove 'code tunnel' from arguments
    
    # Set up CLI data directory first
    CLI_DATA_DIR="${CODE_SERVER_DATA_DIR:-/home/dev/.vscode-server/cli-data-dir}"
    mkdir -p "$CLI_DATA_DIR" 2>/dev/null || true
    
    # Clear any existing auth to force re-authentication with the specified provider
    rm -f "$CLI_DATA_DIR/coder/auth.json" 2>/dev/null || true
    
    # Run the login command to set the provider
    # This will prompt for authentication with the specified provider
    code tunnel user login --cli-data-dir "$CLI_DATA_DIR" --provider "$CODE_TUNNEL_PROVIDER"
    
    # After login completes, start the tunnel with the configured CLI data directory
    TUNNEL_ARGS=("--cli-data-dir" "$CLI_DATA_DIR")
    
    # Add tunnel name if set
    [ -n "$CODE_TUNNEL_NAME" ] && TUNNEL_ARGS+=("--name" "$CODE_TUNNEL_NAME")
    
    # Add extensions directory if set
    [ -n "$CODE_EXTENSIONS_DIR" ] && TUNNEL_ARGS+=("--extensions-dir" "$CODE_EXTENSIONS_DIR")
    
    # Accept server license terms if set
    [ "$CODE_ACCEPT_LICENSE" = "true" ] && TUNNEL_ARGS+=("--accept-server-license-terms")
    
    # Execute code tunnel with all arguments
    exec code tunnel "${TUNNEL_ARGS[@]}" "$@"
    
# If the command is 'code tunnel' without provider, handle normally
elif [ "$1" = "code" ] && [ "$2" = "tunnel" ]; then
    shift 2  # Remove 'code tunnel' from arguments
    
    TUNNEL_ARGS=()
    
    # Set up CLI data directory
    CLI_DATA_DIR="${CODE_SERVER_DATA_DIR:-/home/dev/.vscode-server/cli-data-dir}"
    mkdir -p "$CLI_DATA_DIR" 2>/dev/null || true
    TUNNEL_ARGS+=("--cli-data-dir" "$CLI_DATA_DIR")
    
    # Add tunnel name if set
    [ -n "$CODE_TUNNEL_NAME" ] && TUNNEL_ARGS+=("--name" "$CODE_TUNNEL_NAME")
    
    # Add extensions directory if set
    [ -n "$CODE_EXTENSIONS_DIR" ] && TUNNEL_ARGS+=("--extensions-dir" "$CODE_EXTENSIONS_DIR")
    
    # Accept server license terms if set
    [ "$CODE_ACCEPT_LICENSE" = "true" ] && TUNNEL_ARGS+=("--accept-server-license-terms")
    
    # Execute code tunnel with all arguments
    exec code tunnel "${TUNNEL_ARGS[@]}" "$@"
fi

# Execute the provided command
# Install VS Code extensions if needed (run as the current user; container runs as `dev`)
# Use `VSCODE_EXTENSIONS` env var (comma-separated) to override, otherwise use DEFAULT_VSCODE_EXTENSIONS
EXT_DIR="${CODE_EXTENSIONS_DIR:-/home/dev/.vscode-server/extensions}"
EXT_LIST="${VSCODE_EXTENSIONS:-${DEFAULT_VSCODE_EXTENSIONS:-}}"
if [ -n "$EXT_LIST" ]; then
    IFS=',' read -ra EXTS <<< "$EXT_LIST"
    for e in "${EXTS[@]}"; do
        e_trimmed="$(echo "$e" | xargs)"
        if [ -n "$e_trimmed" ]; then
            echo "[entrypoint] Installing VS Code extension: $e_trimmed"
            code --extensions-dir "$EXT_DIR" --install-extension "$e_trimmed" || true
        fi
    done
    chown -R dev:dev "$EXT_DIR" || true
fi

exec "$@"
