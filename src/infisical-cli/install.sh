#!/bin/sh

set -e

# Debian / Ubuntu packages
install_debian_packages() {
    # Install prerequisites
    apt-get -y update
    if ! -x $(command -v curl); then
        apt-get -y install --no-install-recommends curl
    fi

    # Add Infisical repository
    curl -1sLf 'https://dl.cloudsmith.io/public/infisical/infisical-cli/setup.deb.sh' | bash

    # Install Infisical CLI
    apt-get -y install --no-install-recommends infisical

    # Clean up
    apt-get -y clean
    rm -rf /var/lib/apt/lists/*
}

# RedHat / RockyLinux / CentOS / Fedora packages
install_redhat_packages() {
    local install_cmd=microdnf
    if ! type microdnf > /dev/null 2>&1; then
        install_cmd=dnf
        if ! type dnf > /dev/null 2>&1; then
            install_cmd=yum
        fi
    fi

    # Add Infisical repository
    curl -1sLf 'https://dl.cloudsmith.io/public/infisical/infisical-cli/setup.rpm.sh' | bash

    # Install Infisical CLI
    ${install_cmd} -y install infisical
}

# Alpine Linux packages
install_alpine_packages() {
    # Install prerequisites
    apk add --no-cache bash sudo

    # Add Infisical repository
    curl -1sLf 'https://dl.cloudsmith.io/public/infisical/infisical-cli/setup.alpine.sh' | bash

    # Install Infisical CLI
    apk update
    apk add --no-cache infisical
}

if [ "$(id -u)" -ne 0 ]; then
    echo -e 'Script must be run as root. Use sudo, su, or add "USER root" to your Dockerfile before running this script.'
    exit 1
fi

# Bring in ID, ID_LIKE, VERSION_ID, VERSION_CODENAME
. /etc/os-release

# Get an adjusted ID independent of distro variants
if [ "${ID}" = "debian" ] || [ "${ID_LIKE}" = "debian" ]; then
    ADJUSTED_ID="debian"
elif [[ "${ID}" = "rhel" || "${ID}" = "fedora" || "${ID}" = "mariner" || "${ID_LIKE}" = *"rhel"* || "${ID_LIKE}" = *"fedora"* || "${ID_LIKE}" = *"mariner"* ]]; then
    ADJUSTED_ID="rhel"
elif [ "${ID}" = "alpine" ]; then
    ADJUSTED_ID="alpine"
else
    echo "Linux distro ${ID} not supported."
    exit 1
fi

# Install packages for appropriate OS
case "${ADJUSTED_ID}" in
    "debian")
        install_debian_packages
        ;;
    "rhel")
        install_redhat_packages
        ;;
    "alpine")
        install_alpine_packages
        ;;
esac
