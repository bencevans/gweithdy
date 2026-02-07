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

## Prebuilt container

A prebuilt image is available on GitHub Container Registry:

```bash
docker pull ghcr.io/bencevans/gweithdy:latest
```

Run the prebuilt image (example):

```bash
docker run --rm -it \
  -e GIT_USER="Your Name" \
  -e GIT_EMAIL="your.email@example.com" \
  ghcr.io/bencevans/gweithdy:latest /bin/bash
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

**VS Code Extensions:**
- `DEFAULT_VSCODE_EXTENSIONS` - Image default list of extensions (set in the image). Current default: `ms-python.python,REditorSupport.r,REditorSupport.r-syntax`.
- `VSCODE_EXTENSIONS` - Comma-separated list of extensions to install at container start (overrides the default). Example: `VSCODE_EXTENSIONS="ms-python.python,ms-toolsai.jupyter"`.

Example (override extensions at runtime):
```bash
docker run --rm -it \
  -e VSCODE_EXTENSIONS="ms-python.python,ms-toolsai.jupyter" \
  ghcr.io/bencevans/gweithdy:latest /bin/bash
```

## RunAI

Examples to run the prebuilt image `ghcr.io/bencevans/gweithdy:latest` on Run:AI.

Interactive shell (override entrypoint and attach):

```bash
runai workspace submit gweithdy-shell \
  -p my-project \
  -i ghcr.io/bencevans/gweithdy:latest \
  -c -- /bin/bash \
  --environment-variable GIT_USER="Your Name" \
  --environment-variable GIT_EMAIL="your.email@example.com" \
  --attach
```

Detached run (uses container default, e.g. code tunnel):

```bash
runai workspace submit gweithdy-tunnel \
  -p my-project \
  -i ghcr.io/bencevans/gweithdy:latest \
  --name-prefix gweithdy \
  --environment-variable GIT_USER="Your Name" \
  --environment-variable GIT_EMAIL="your.email@example.com" \
  --environment-variable CODE_ACCEPT_LICENSE="true"
```

Check the workspace logs for a link and authorisation code to establish the VS Code tunnel connection. Once connected, a link for the tunnel will be printed in the terminal or should be accessible in the VS Code Remote Explorer.



## Testing

Run the git configuration tests to verify that `GIT_USER` and `GIT_EMAIL` environment variables are properly applied.

```bash
bash tests/test_git_config.sh
```

For more details, see [tests/README.md](tests/README.md).
