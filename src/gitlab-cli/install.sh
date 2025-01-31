#!/bin/sh

set -e

if [ "$(id -u)" -ne 0 ]; then
    echo -e 'Script must be run as root. Use sudo, su, or add "USER root" to your Dockerfile before running this script.'
    exit 1
fi

# Bring in ID, ID_LIKE, VERSION_ID, VERSION_CODENAME
. /etc/os-release

# Get an adjusted ID independent of distro variants
if [ "${ID}" != "debian" ] && [ "${ID_LIKE}" != "debian" ]; then
    echo "Linux distro ${ID} not supported."
    exit 1
fi

# Install prerequisites
apt-get -y update
apt-get -y install --no-install-recommends curl ca-certificates

# Add WakeMeOps repository
curl -sSL "https://raw.githubusercontent.com/upciti/wakemeops/main/assets/install_repository" | bash

# Install glab
apt-get -y install --no-install-recommends glab

# Clean up
apt-get -y clean
rm -rf /var/lib/apt/lists/*
