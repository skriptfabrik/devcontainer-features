#!/bin/sh

set -e

ADJUSTED_VERSION="${VERSION:-"latest"}"

# Debian / Ubuntu packages
install_debian_packages() {
    # Install prerequisites
    apt-get -y update
    apt-get -y install --no-install-recommends curl ca-certificates

    # Clean up
    apt-get -y clean
    rm -rf /var/lib/apt/lists/*
}

# Bring in ID, ID_LIKE, VERSION_ID, VERSION_CODENAME
. /etc/os-release

# Get an adjusted ID independent of distro variants
if [ "${ID}" = "debian" ] || [ "${ID_LIKE}" = "debian" ]; then
    ADJUSTED_ID="debian"
else
    echo "Linux distro ${ID} not supported."
    exit 1
fi

# Install packages for appropriate OS
case "${ADJUSTED_ID}" in
    "debian")
        install_debian_packages
        ;;
esac

# Fetch latest version if needed
if [ "${ADJUSTED_VERSION}" = "latest" ]; then
    ADJUSTED_VERSION=$(curl -s https://api.github.com/repos/plumber-cd/terraform-backend-git/releases/latest | grep "tag_name" | awk '{print substr($2, 3, length($2)-4)}')
fi

# Detect current machine architecture
if [ "$(uname -m)" = "aarch64" ]; then
    ARCH="arm64"
else
    ARCH="amd64"
fi

# Download URL
DOWNLOAD_URL="https://github.com/plumber-cd/terraform-backend-git/releases/download/v${ADJUSTED_VERSION}/terraform-backend-git-linux-${ARCH}"

# Download and install terraform-backend-git
echo "Downloading terraform-backend-git from ${DOWNLOAD_URL}"
curl -sSLo /usr/local/bin/terraform-backend-git "${DOWNLOAD_URL}"
chmod +x /usr/local/bin/terraform-backend-git
