#!/bin/bash

set -o errexit
set -o pipefail
set -o nounset

# Install OMV in a test environment based on Debian
# See https://openmediavault.readthedocs.io/en/stable/installation/on_debian.html

echo "Installing openmediavault gpg keyring"
apt-get install --yes gnupg
wget -O "/etc/apt/trusted.gpg.d/openmediavault-archive-keyring.asc" https://packages.openmediavault.org/public/archive.key
apt-key add "/etc/apt/trusted.gpg.d/openmediavault-archive-keyring.asc"

echo "Add package repositories"
cat <<EOF >> /etc/apt/sources.list.d/openmediavault.list
deb https://packages.openmediavault.org/public shaitan main
# deb https://downloads.sourceforge.net/project/openmediavault/packages shaitan main
## Uncomment the following line to add software from the proposed repository.
# deb https://packages.openmediavault.org/public shaitan-proposed main
# deb https://downloads.sourceforge.net/project/openmediavault/packages shaitan-proposed main
## This software is not part of OpenMediaVault, but is offered by third-party
## developers as a service to OpenMediaVault users.
# deb https://packages.openmediavault.org/public shaitan partner
# deb https://downloads.sourceforge.net/project/openmediavault/packages shaitan partner
EOF

echo "Install openmediavault package"
export LANG=C.UTF-8
export DEBIAN_FRONTEND=noninteractive
export APT_LISTCHANGES_FRONTEND=none
apt-get update
apt-get --yes --auto-remove --show-upgraded \
    --allow-downgrades --allow-change-held-packages \
    --no-install-recommends \
    --option DPkg::Options::="--force-confdef" \
    --option DPkg::Options::="--force-confold" \
    install openmediavault-keyring openmediavault

omv-confdbadm populate

echo "Don't forget to add vagrant to the ssh group!"
echo "Now do a reboot or vagrant reload"
