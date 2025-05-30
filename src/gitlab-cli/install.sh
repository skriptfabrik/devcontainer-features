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
    CLI_VERSION=$(curl -s curl -s https://gitlab.com/api/v4/projects/34675721/releases | jq -r '.[0].tag_name' | awk '{print substr($1, 2)}')
fi

# Detect current machine architecture
if [ "$(uname -m)" = "aarch64" ]; then
    ARCH="arm64"
else
    ARCH="amd64"
fi

# DEB package and download URL
DEB_PACKAGE="glab_${CLI_VERSION}_linux_${ARCH}.deb"
DOWNLOAD_URL="https://gitlab.com/gitlab-org/cli/-/releases/v${CLI_VERSION}/downloads/${DEB_PACKAGE}"

# Download and install gitlab-cli
echo "Downloading gitlab-cli from ${DOWNLOAD_URL}"
curl -sSLO "${DOWNLOAD_URL}"
dpkg -i "${DEB_PACKAGE}"
rm -f "${DEB_PACKAGE}"

# Install bash completion
glab completion -s bash > /etc/bash_completion.d/glab
