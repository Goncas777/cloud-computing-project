#!/bin/bash

# test.sh - Run basic infrastructure tests

set -e

echo "Infrastructure Tests"
echo "==================="
echo ""

TERRAFORM_DIR="terraform"
PASS_COUNT=0
FAIL_COUNT=0

# Test 1: Terraform formatting
echo "Test 1: Terraform Code Format"
echo "-----------------------------"
cd "$TERRAFORM_DIR"
if terraform fmt -check -recursive . >/dev/null 2>&1; then
    echo "✓ PASS: Terraform code is properly formatted"
    ((PASS_COUNT++))
else
    echo "✗ FAIL: Terraform code formatting issues found"
    echo "  Run 'make fmt' to fix formatting"
    ((FAIL_COUNT++))
fi

# Test 2: Terraform validation
echo ""
echo "Test 2: Terraform Configuration Validation"
echo "----------------------------------------"
if terraform validate >/dev/null 2>&1; then
    echo "✓ PASS: Terraform configuration is valid"
    ((PASS_COUNT++))
else
    echo "✗ FAIL: Terraform configuration validation failed"
    ((FAIL_COUNT++))
fi

cd ..

# Test 3: Check script files exist
echo ""
echo "Test 3: Required Script Files"
echo "----------------------------"
SCRIPTS=(
    "scripts/update_hosts.sh"
    "scripts/validate_deployments.sh"
    "scripts/get_logs.sh"
    "scripts/status.sh"
)

for script in "${SCRIPTS[@]}"; do
    if [ -f "$script" ]; then
        if [ -x "$script" ]; then
            echo "✓ PASS: $script exists and is executable"
            ((PASS_COUNT++))
        else
            echo "⚠ WARN: $script exists but is not executable"
            chmod +x "$script"
        fi
    else
        echo "✗ FAIL: $script not found"
        ((FAIL_COUNT++))
    fi
done

# Test 4: Check Makefile
echo ""
echo "Test 4: Makefile Verification"
echo "----------------------------"
if [ -f "Makefile" ]; then
    echo "✓ PASS: Makefile exists"
    ((PASS_COUNT++))
else
    echo "✗ FAIL: Makefile not found"
    ((FAIL_COUNT++))
fi

# Test 5: README documentation
echo ""
echo "Test 5: Documentation"
echo "-------------------"
if [ -f "README.md" ]; then
    echo "✓ PASS: README.md exists"
    ((PASS_COUNT++))
else
    echo "✗ FAIL: README.md not found"
    ((FAIL_COUNT++))
fi

# Summary
echo ""
echo "Test Summary"
echo "============"
echo "Passed: $PASS_COUNT"
echo "Failed: $FAIL_COUNT"
echo ""

if [ "$FAIL_COUNT" -eq 0 ]; then
    echo "✓ All tests passed!"
    exit 0
else
    echo "✗ Some tests failed. Please review the errors above."
    exit 1
fi
