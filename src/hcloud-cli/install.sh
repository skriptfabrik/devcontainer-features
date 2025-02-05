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
apt-get -y install --no-install-recommends curl ca-certificates jq git

# Clean up
apt-get -y clean
rm -rf /var/lib/apt/lists/*

# Fetch latest version if needed
if [ "${CLI_VERSION}" = "latest" ]; then
    CLI_VERSION=$(curl -s https://api.github.com/repos/hetznercloud/cli/releases/latest | jq -r '.tag_name' | awk '{print substr($1, 2)}')
fi

# Detect current machine architecture
if [ "$(uname -m)" = "aarch64" ]; then
    ARCH="arm64"
else
    ARCH="amd64"
fi

# Download URL
DOWNLOAD_URL="https://github.com/hetznercloud/cli/releases/download/v${CLI_VERSION}/hcloud-linux-${ARCH}.tar.gz"

# Download and install hcloud
echo "Downloading hcloud from ${DOWNLOAD_URL}"
curl -sSL "${DOWNLOAD_URL}" | tar -xz -C /usr/local/bin hcloud

# Install bash completion
hcloud completion bash > /etc/bash_completion.d/hcloud
