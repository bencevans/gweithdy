FROM ubuntu:latest

# Install base packages
RUN apt-get update && apt-get install -y \
    wget curl vim nano tmux build-essential git sudo \
    htop jq ripgrep bat fzf \
    postgresql-client redis-tools default-mysql-client \
    ssh-client ca-certificates gnupg lsb-release unzip ffmpeg


# R language
#
RUN apt-get update && apt-get install -y \
  r-base r-base-dev && \
  apt-get clean && rm -rf /var/lib/apt/lists/*

#
# VS Code CLI
#
RUN curl -Lk 'https://code.visualstudio.com/sha/download?build=stable&os=cli-alpine-x64' --output /tmp/vscode_cli.tar.gz && \
  tar -xf /tmp/vscode_cli.tar.gz -C /usr/local/bin && \
  rm /tmp/vscode_cli.tar.gz

#
# Create non-root user with sudo privileges
#
RUN useradd -m -s /bin/bash dev && \
    usermod -aG sudo dev && \
    echo "dev ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers.d/dev && \
    mkdir -p /home/dev/.vscode-server/cli-data-dir && \
    chown -R dev:dev /home/dev && \
  chmod 0440 /etc/sudoers.d/dev

# Ensure dev-local tools (uv, etc.) are on PATH
ENV PATH="/home/dev/.local/bin:${PATH}"

# Install uv for dev user (after user creation)
RUN su - dev -c "curl -LsSf https://astral.sh/uv/install.sh | sh" \
  && ln -sf /home/dev/.local/bin/uv /usr/local/bin/uv \
  && ln -sf /home/dev/.local/bin/uvx /usr/local/bin/uvx


#
# Rust toolchain

# Install Rust toolchain for the non-root `dev` user and ensure cargo is on their PATH
RUN su - dev -c "curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y" && \
  echo 'export PATH="/home/dev/.cargo/bin:$PATH"' >> /home/dev/.bashrc && \
  chown dev:dev /home/dev/.bashrc


#
# GitHub CLI
#
RUN mkdir -p /etc/apt/keyrings && \
    curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | \
    gpg --dearmor -o /etc/apt/keyrings/githubcli-archive-keyring.gpg && \
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | \
    tee /etc/apt/sources.list.d/github-cli.list > /dev/null && \
    apt-get update && apt-get install -y gh

#
# Node.js toolchain (installed for `dev` user below)
# Node.js toolchain
# Install nvm for the non-root `dev` user and make it available in their shell
ENV NVM_DIR="/home/dev/.nvm"
RUN su - dev -c "curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.4/install.sh | bash" \
  && su - dev -c "bash -lc 'source /home/dev/.nvm/nvm.sh && nvm install --lts && nvm alias default node'"

# Install Bun for the `dev` user (install writes to $HOME/.bun)
RUN su - dev -c "HOME=/home/dev bash -lc 'curl -fsSL https://bun.sh/install | bash'" || true

# Ensure `dev` user's shell loads nvm and bun on login
RUN echo "export NVM_DIR=\"/home/dev/.nvm\"" >> /home/dev/.bashrc && \
    echo "[ -s \"$NVM_DIR/nvm.sh\" ] && \. \"$NVM_DIR/nvm.sh\"" >> /home/dev/.bashrc && \
    echo "export PATH=\"/home/dev/.bun/bin:\$NVM_DIR/versions/node/$(ls -1 /home/dev/.nvm/versions/node | tail -n1)/bin:/home/dev/.local/bin:\$PATH\"" >> /home/dev/.bashrc && \
    chown dev:dev /home/dev/.bashrc


#
# Create custom MOTD
#
RUN cat > /etc/motd << 'EOF'
╔═══════════════════════════════════════════════════════════════╗
║                   🚀 gweithdy Dev Container                   ║
╚═══════════════════════════════════════════════════════════════╝

Available Tools & Runtimes:
  🧮 R              → R, Rscript (CRAN via r-base)
  🐍 Python         → uv (pip/venv), python
  🦀 Rust           → cargo, rustup
  📦 Node.js        → node, npm, pnpm, nvm
  🍞 Bun            → bun
  🔧 System         → git, gh (GitHub CLI), tmux, vim, nano
  📊 Databases      → psql, redis-cli, mysql
  🔍 Utilities      → ripgrep, bat, fzf, jq, ffmpeg

Quick Start:

  R:       R -q --vanilla
           Rscript script.R
  Python:  uv init myproject && cd myproject
           uv add <package>
           uv run python script.py
  Node:    nvm list-remote && nvm install <version>
  Rust:    cargo new <project>

For more info on any tool, use: <tool> --help
═══════════════════════════════════════════════════════════════
EOF

# Add MOTD display to bashrc
RUN echo '' >> /home/dev/.bashrc && \
    echo '# Display MOTD on interactive login' >> /home/dev/.bashrc && \
    echo '[ -f /etc/motd ] && cat /etc/motd && echo' >> /home/dev/.bashrc && \
    chown dev:dev /home/dev/.bashrc


#
# Entrypoint
#
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh
USER dev
ENTRYPOINT ["/entrypoint.sh"]
CMD ["code", "tunnel"]
