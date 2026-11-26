#!/bin/bash

# Test an ordinary shell and a Run:ai workspace under Docker's default seccomp policy.

set -euo pipefail

IMAGE="${IMAGE:-ghcr.io/bencevans/gweithdy:latest}"

docker run --rm -e DEFAULT_VSCODE_EXTENSIONS= "$IMAGE" bash -ic '
    set -e
    command -v opencode
    command -v codex
    test ! -e /etc/codex/config.toml
'

docker run --rm --cap-drop=ALL --security-opt=no-new-privileges \
    -e DEFAULT_VSCODE_EXTENSIONS= -e RUNAI_JOB_NAME=gweithdy-test \
    "$IMAGE" bash -ic '
    set -e
    if bwrap --unshare-user --ro-bind / / -- /bin/true; then
        echo "This test requires a runtime that denies nested namespaces." >&2
        exit 1
    fi
    codex sandbox -- /bin/ls -a

    # A user who explicitly requests a restricted sandbox must still get one.
    mkdir -p ~/.codex
    echo "default_permissions = \":read-only\"" > ~/.codex/config.toml
    if denial=$(codex sandbox -- /bin/true 2>&1); then
        echo "Codex ignored the read-only permission profile." >&2
        exit 1
    fi
    [[ $denial == *"namespace"* ]]
'
