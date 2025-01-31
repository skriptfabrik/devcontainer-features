#!/bin/sh

set -e

CLI_VERSION="${VERSION:-"latest"}"

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
    CLI_VERSION=$(curl -s https://api.github.com/repos/plumber-cd/terraform-backend-git/releases/latest | jq -r '.tag_name' | awk '{print substr($1, 2)}')
fi

# Detect current machine architecture
if [ "$(uname -m)" = "aarch64" ]; then
    ARCH="arm64"
else
    ARCH="amd64"
fi

# Download URL
DOWNLOAD_URL="https://github.com/plumber-cd/terraform-backend-git/releases/download/v${CLI_VERSION}/terraform-backend-git-linux-${ARCH}"

# Download and install terraform-backend-git
echo "Downloading terraform-backend-git from ${DOWNLOAD_URL}"
curl -sSLo /usr/local/bin/terraform-backend-git "${DOWNLOAD_URL}"
chmod +x /usr/local/bin/terraform-backend-git

# Create start script
cat << 'EOF' > /usr/local/bin/terraform-backend-git-start
#!/bin/bash

set -ae

TF_BACKEND_GIT_ENV_PATH="${TF_BACKEND_GIT_ENV_PATH:-terraform-backend-git.env}"
TF_BACKEND_GIT_LOG_PATH="${TF_BACKEND_GIT_LOG_PATH:-terraform-backend-git.log}"

if [ -f "$TF_BACKEND_GIT_ENV_PATH" ]; then
    echo "Sourcing $TF_BACKEND_GIT_ENV_PATH"
    source "$TF_BACKEND_GIT_ENV_PATH"
fi

set +a

echo "Stopping terraform-backend-git"
terraform-backend-git stop || true

echo "Starting terraform-backend-git in the background"
nohup sh -c "terraform-backend-git $TF_BACKEND_GIT_ARGS &" >> "$TF_BACKEND_GIT_LOG_PATH"
EOF
chmod +x /usr/local/bin/terraform-backend-git-start
