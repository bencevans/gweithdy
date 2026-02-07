# Container Configuration Tests

This directory contains tests to verify that the Docker container correctly configures Git and VS Code with environment variables.

## Test Files

### `test_git_config.sh` - Git Configuration Tests
A bash script that tests git configuration setup. No external dependencies required beyond Docker.

**Run with:**
```bash
bash tests/test_git_config.sh
```

**Tests:**
- Git username is set correctly
- Git email is set correctly
- Both username and email are set together
- Special characters in usernames are handled
- Complex email formats work correctly

### `test_vscode_config.sh` - VS Code Tunnel Configuration Tests
A bash script that tests VS Code tunnel configuration and entrypoint behavior.

**Run with:**
```bash
bash tests/test_vscode_config.sh
```

**Tests:**
- Container runs as 'dev' user (non-root)
- Dev user has sudo privileges without password
- VS Code CLI is available
- CODE_TUNNEL_NAME environment variable is passed correctly
- Multiple CODE_* variables work together
- Entrypoint allows normal bash execution
- Special characters in tunnel names are handled

## Prerequisites

All tests require:
- Docker installed and running
- The gweithdy Docker image built locally: `docker build -t gweithdy:latest .`

## Test Coverage

The tests verify:
1. ✅ Git username is correctly set from `GIT_USER` env var
2. ✅ Git email is correctly set from `GIT_EMAIL` env var
3. ✅ VS Code environment variables are passed through
4. ✅ Container runs as non-root 'dev' user
5. ✅ Sudo access works without password prompt
6. ✅ Special characters and complex formats are handled
7. ✅ Configuration persists after setup

## Docker Build and Test

```bash
# Build the Docker image
docker build -t gweithdy:latest .

# Run all tests
bash tests/test_git_config.sh
bash tests/test_vscode_config.sh
```

## Running Tests Together

```bash
# Run both test suites
for test in tests/test_*.sh; do bash "$test" || exit 1; done
```

## CI/CD Integration

These tests can be integrated into CI/CD pipelines:

```yaml
# Example GitHub Actions
- name: Build Docker Image
  run: docker build -t gweithdy:latest .

- name: Run Git Config Tests
  run: bash tests/test_git_config.sh
```

```yaml
# Example GitLab CI
test:git-config:
  script:
    - docker build -t gweithdy:latest .
    - bash tests/test_git_config.sh
```
