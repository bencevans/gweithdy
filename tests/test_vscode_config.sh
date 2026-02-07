#!/bin/bash

#
# Tests for VS Code Tunnel configuration setup
# Verifies that CODE_* environment variables are properly
# processed by the entrypoint when starting the container
#

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
NC='\033[0m' # No Color

TESTS_PASSED=0
TESTS_FAILED=0

# Test helper function
run_test() {
    local test_name="$1"
    local tunnel_name="$2"
    local extensions_dir="$3"
    local server_data_dir="$4"
    local accept_license="$5"
    local expected_check="$6"
    
    echo -n "Testing: $test_name ... "
    
    # Build the docker command
    local docker_args=("docker" "run" "--rm")
    [[ -n "$tunnel_name" ]] && docker_args+=("-e" "CODE_TUNNEL_NAME=$tunnel_name")
    [[ -n "$extensions_dir" ]] && docker_args+=("-e" "CODE_EXTENSIONS_DIR=$extensions_dir")
    [[ -n "$server_data_dir" ]] && docker_args+=("-e" "CODE_SERVER_DATA_DIR=$server_data_dir")
    [[ -n "$accept_license" ]] && docker_args+=("-e" "CODE_ACCEPT_LICENSE=$accept_license")
    docker_args+=("gweithdy:latest" "bash" "-c" "$expected_check")
    
    if output=$("${docker_args[@]}" 2>&1); then
        echo -e "${GREEN}PASSED${NC}"
        ((TESTS_PASSED++))
        return 0
    else
        echo -e "${RED}FAILED${NC}"
        echo "  Error: $output"
        ((TESTS_FAILED++))
        return 1
    fi
}

echo "=========================================="
echo "VS Code Tunnel Configuration Tests"
echo "=========================================="
echo ""

# Run tests
echo "Running test suite..."
echo ""

# Test 1: Verify user is 'dev' and has sudo access
run_test "Container runs as 'dev' user" \
    "" "" "" "" \
    "[ \"\$(whoami)\" = \"dev\" ]"

# Test 2: Verify dev user has sudo privileges
run_test "Dev user has sudo privileges" \
    "" "" "" "" \
    "sudo -l | grep -q 'NOPASSWD:ALL'"

# Test 3: Verify code command is available
run_test "VS Code CLI is available" \
    "" "" "" "" \
    "which code"

# Test 4: Verify environment variable is read
run_test "CODE_TUNNEL_NAME environment variable is passed" \
    "my-dev-tunnel" "" "" "" \
    "echo \$CODE_TUNNEL_NAME | grep -q 'my-dev-tunnel'"

# Test 5: Verify multiple environment variables
run_test "Multiple CODE_* variables are passed" \
    "test-tunnel" "/custom/extensions" "/custom/data" "true" \
    "[ \"\$CODE_TUNNEL_NAME\" = \"test-tunnel\" ] && [ \"\$CODE_EXTENSIONS_DIR\" = \"/custom/extensions\" ] && [ \"\$CODE_SERVER_DATA_DIR\" = \"/custom/data\" ] && [ \"\$CODE_ACCEPT_LICENSE\" = \"true\" ]"

# Test 6: Verify entrypoint doesn't break on normal command
run_test "Entrypoint allows bash execution" \
    "" "" "" "" \
    "bash -c 'echo test' | grep -q 'test'"

# Test 7: Verify special characters in tunnel name
run_test "CODE_TUNNEL_NAME with special characters" \
    "my-dev-machine_01" "" "" "" \
    "echo \$CODE_TUNNEL_NAME | grep -q 'my-dev-machine_01'"

echo ""
echo "=========================================="
echo "Test Results"
echo "=========================================="
echo -e "${GREEN}Passed: $TESTS_PASSED${NC}"
if [ $TESTS_FAILED -gt 0 ]; then
    echo -e "${RED}Failed: $TESTS_FAILED${NC}"
else
    echo -e "${GREEN}Failed: $TESTS_FAILED${NC}"
fi
echo "=========================================="

if [ $TESTS_FAILED -gt 0 ]; then
    exit 1
fi

exit 0
