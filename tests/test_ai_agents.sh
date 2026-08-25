#!/bin/bash

# Verify that the image includes both AI coding agent CLIs.

set -euo pipefail

IMAGE="${IMAGE:-ghcr.io/bencevans/gweithdy:latest}"

for command in opencode codex; do
    echo -n "Checking $command ... "
    docker run --rm "$IMAGE" bash -lc "command -v $command >/dev/null"
    echo "PASSED"
done
