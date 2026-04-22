# Gweithdy



> Gweithdy (Welsh for "Workshop" — a place for making things or training).

Gweithdy is an opinionated development environment. It bundles common toolchains for Python, Node.js, Rust and R, and uses

Visual Studio Code as the editor via a VS Code Tunnel so you can connect with a local VS Code installation (Remote Tunnels extension) or through [vscode.dev](https://vscode.dev).

Gweithdy does not include Conda — it prefers [uv](https://docs.astral.sh/uv/) for creating and managing distinct, project-focused Python environments. To learn more about connecting via a tunnel, see the [VS Code Remote Tunnels documentation](https://code.visualstudio.com/docs/remote/tunnels).

## Features

- [x] Automated Git setup
- [x] Ubuntu LTS Base
- [x] [uv](https://docs.astral.sh/uv/) for managing Python environments
- [x] [Rust](https://www.rust-lang.org/) toolchain
- [x] [nvm](https://github.com/nvm-sh/nvm) for managing Node.js projects
- [x] [bun](https://bun.sh) runtime
- [x] Opinionated: includes toolchains for Python, Node.js, Rust and R, with VS Code Tunnel as the editor
- [x] Essential CLI tools: `git`, `vim`, `nano`, `curl`, `wget`, `jq`
- [x] Development tools: `tmux`, `htop`, `build-essential`, `glances`
- [x] Fast utilities: `ripgrep`, `bat`, `fzf`
- [x] GitHub CLI (`gh`) for repository management
- [x] Database clients: PostgreSQL, Redis, MySQL

## Build

```bash
git clone ...
cd gweithdy
docker build -t ghcr.io/bencevans/gweithdy:latest .
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
  ghcr.io/bencevans/gweithdy:latest
```

To run a bash shell instead:

```bash
docker run -it \
  -e GIT_USER="Your Name" \
  -e GIT_EMAIL="your.email@example.com" \
  ghcr.io/bencevans/gweithdy:latest \
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
  --environment-variable GIT_USER="Your Name" \
  --environment-variable GIT_EMAIL="your.email@example.com" \
  --environment-variable CODE_ACCEPT_LICENSE="true"
```

Check the workspace logs for a link and authorisation code to establish the VS Code tunnel connection. Once connected, a link for the tunnel will be printed in the terminal or should be accessible in the VS Code Remote Explorer.

## Setting up a Jupyter kernel

To use Jupyter notebooks with the Python environments in Gweithdy, you can set up a Jupyter kernel that points to the Python interpreter inside the container. Once connected to the container via VS Code Tunnel, you can create a new Python environment with `uv`:

```bash
uv new myenv && cd myenv
```

Then, install the `ipykernel` package in that environment:

```bash
uv add --dev ipykernel
```

Open the folder in VS Code by running:

```bash
code .
```

A new window / tab should open with the folder set as the workspace. Creating a new notebook by `Ctrl+Shift+P` → "Jupyter: Create New Notebook" should automatically detect the Python environment and prompt you to select it as the kernel. If it doesn't, you can manually select the kernel by clicking on the kernel name in the top right of the notebook editor and choosing the correct Python interpreter from the list.

## Testing

Run the git configuration tests to verify that `GIT_USER` and `GIT_EMAIL` environment variables are properly applied.

```bash
bash tests/test_git_config.sh
```

For more details, see [tests/README.md](tests/README.md).
