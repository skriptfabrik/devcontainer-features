#!/bin/sh

set -e

CLI_VERSION="${VERSION:-"latest"}"

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
apt-get -y install --no-install-recommends curl ca-certificates jq

# Clean up
apt-get -y clean
rm -rf /var/lib/apt/lists/*

# Fetch latest version if needed
if [ "${CLI_VERSION}" = "latest" ]; then
    CLI_VERSION=$(curl -s https://api.github.com/repos/infisical/infisical/releases/latest | jq -r '.tag_name' | awk '{print substr($1, 16)}')
fi

# Detect current machine architecture
if [ "$(uname -m)" = "aarch64" ]; then
    ARCH="arm64"
else
    ARCH="amd64"
fi

# DEB package and download URL
DEB_PACKAGE="infisical_${CLI_VERSION}_linux_${ARCH}.deb"
DOWNLOAD_URL="https://github.com/Infisical/infisical/releases/download/infisical-cli/v${CLI_VERSION}/${DEB_PACKAGE}"

# Download and install infisical-cli
echo "Downloading infisical-cli from ${DOWNLOAD_URL}"
curl -sSLO "${DOWNLOAD_URL}"
dpkg -i "${DEB_PACKAGE}"
rm -f "${DEB_PACKAGE}"
