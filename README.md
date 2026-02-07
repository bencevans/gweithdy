# Gweithdy

> Gweithdy: Workshop (a place for making things or training).

## Features

- [x] Automated Git setup
- [x] Ubuntu LTS Base
- [x] [`uv`] for managing Python environments
- [x] [Rust] toolchain
- [x] [`nvm`] for managing Node.js projects
- [x] [`bun`] runtime
- [x] Essential CLI tools: `git`, `vim`, `nano`, `curl`, `wget`, `jq`
- [x] Development tools: `tmux`, `htop`, `build-essential`
- [x] Fast utilities: `ripgrep`, `bat`, `fzf`
- [x] GitHub CLI (`gh`) for repository management
- [x] Database clients: PostgreSQL, Redis, MySQL

## Build

```bash
git clone ...
cd gweithdy
docker build -t gweithdy:latest .
```

## Usage

### Running the Container

The container runs `code tunnel` by default. Configure it with environment variables:

```bash
docker run -d \
  -e GIT_USER="Your Name" \
  -e GIT_EMAIL="your.email@example.com" \
  -e CODE_TUNNEL_NAME="my-dev-machine" \
  -e CODE_ACCEPT_LICENSE="true" \
  gweithdy:latest
```

To run a bash shell instead:

```bash
docker run -it \
  -e GIT_USER="Your Name" \
  -e GIT_EMAIL="your.email@example.com" \
  gweithdy:latest \
  /bin/bash
```

### Environment Variables

**Git Configuration:**
- `GIT_USER` - Your Git username (optional)
- `GIT_EMAIL` - Your Git email address (optional)

**VS Code Tunnel Configuration:**
- `CODE_TUNNEL_NAME` - Name for the tunnel (optional, defaults to machine/container hostname)
- `CODE_ACCEPT_LICENSE` - Set to `true` to accept VS Code server license terms (optional)
- `CODE_EXTENSIONS_DIR` - Custom directory for VS Code extensions (optional)
- `CODE_SERVER_DATA_DIR` - Custom directory for VS Code CLI data (optional)

## Run:AI

...


## Testing

Run the git configuration tests to verify that `GIT_USER` and `GIT_EMAIL` environment variables are properly applied.

```bash
bash tests/test_git_config.sh
```

For more details, see [tests/README.md](tests/README.md).
