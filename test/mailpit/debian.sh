#!/bin/bash

set -e

# Optional: Import test library bundled with the devcontainer CLI
# See https://github.com/devcontainers/cli/blob/HEAD/docs/features/test.md#dev-container-features-test-lib
# Provides the 'check' and 'reportResults' commands.
source dev-container-features-test-lib

# Definition specific tests
. /etc/os-release

# Scenario-specific tests
# The 'check' command comes from the dev-container-features-test-lib. Syntax is...
# check <LABEL> <cmd> [args...]
check "distro" test "${ID}" = "debian"
check "check for mailpit" mailpit version

# Report results
# If any of the checks above exited with a non-zero exit code, the test will fail.
reportResults
