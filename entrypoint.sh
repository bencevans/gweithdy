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
exec "$@"
