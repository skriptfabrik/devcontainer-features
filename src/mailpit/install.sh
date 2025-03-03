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
    CLI_VERSION=$(curl -s https://api.github.com/repos/axllent/mailpit/releases/latest | jq -r '.tag_name' | awk '{print substr($1, 2)}')
fi

# Detect current machine architecture
if [ "$(uname -m)" = "aarch64" ]; then
    ARCH="arm64"
else
    ARCH="amd64"
fi

# Download URL
DOWNLOAD_URL="https://github.com/axllent/mailpit/releases/download/v${CLI_VERSION}/mailpit-linux-${ARCH}.tar.gz"

# Download and install Mailpit
echo "Downloading Mailpit from ${DOWNLOAD_URL}"
curl -sSL "${DOWNLOAD_URL}" | tar -xz -C /usr/local/bin mailpit

# Create entrypoint script
cat << 'EOF' > /usr/local/share/mailpit-init.sh
#!/bin/bash

set -e

mkdir -p /var/lib/mailpit

# Start mailpit
start-stop-daemon --start --background --quiet \
    --make-pidfile --pidfile /var/run/mailpit.pid \
    --startas /bin/bash -- -c '/usr/local/bin/mailpit -d /var/lib/mailpit/mailpit.db > /var/log/mailpit.log 2>&1'

set +e

# Execute whatever commands were passed in (if any). This allows us
# to set this script to ENTRYPOINT while still executing the default CMD.
exec "$@"
EOF
chmod +x /usr/local/share/mailpit-init.sh
