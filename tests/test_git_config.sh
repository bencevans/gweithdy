#!/bin/bash

#
# Tests for Git configuration setup
# Verifies that GIT_USER and GIT_EMAIL environment variables
# are properly applied to git global config when the container starts
#

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m' # No Color

TESTS_PASSED=0
TESTS_FAILED=0

# Test helper function
run_test() {
    local test_name="$1"
    local username="$2"
    local email="$3"
    local expected_check="$4"
    
    echo -n "Testing: $test_name ... "
    
    # Build the docker command
    local docker_args=("docker" "run" "--rm")
    [[ -n "$username" ]] && docker_args+=("-e" "GIT_USER=$username")
    [[ -n "$email" ]] && docker_args+=("-e" "GIT_EMAIL=$email")
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
echo "Git Configuration Tests"
echo "=========================================="
echo ""

# Run tests
echo "Running test suite..."
echo ""

# Test 1: Git username is set correctly
run_test "Git username is set correctly" \
    "John Doe" \
    "" \
    "git config --global user.name | grep -q 'John Doe'"

# Test 2: Git email is set correctly
run_test "Git email is set correctly" \
    "" \
    "john@example.com" \
    "git config --global user.email | grep -q 'john@example.com'"

# Test 3: Both username and email are set
run_test "Both username and email are set" \
    "Test User" \
    "test@example.com" \
    "git config --global user.name | grep -q 'Test User' && git config --global user.email | grep -q 'test@example.com'"

# Test 4: Special characters in username
run_test "Special characters in username" \
    "Jean Paul O'Brien" \
    "" \
    "git config --global user.name | grep -q \"Jean Paul O'Brien\""

# Test 5: Complex email format
run_test "Complex email format" \
    "" \
    "user+tag@example.co.uk" \
    "git config --global user.email | grep -q 'user+tag@example.co.uk'"

echo ""
echo "=========================================="
echo "Test Results"
echo "=========================================="
echo -e "${GREEN}Passed: $TESTS_PASSED${NC}"
echo -e "${RED}Failed: $TESTS_FAILED${NC}"
echo "=========================================="

if [ $TESTS_FAILED -gt 0 ]; then
    exit 1
fi

exit 0
