#!/bin/bash

set -o errexit
set -o pipefail
set -o nounset

BUILDER_IMAGE="local/$(basename $(pwd))/deb-builder"

docker build -t ${BUILDER_IMAGE} deb-builder

# Remove old results
rm -fv openmediavault-ldap_*

# Note: We need to mount the parent directory as dpkg-buildpackage writes there
docker run \
  --rm \
  -t \
  -v $(pwd)/../:$(pwd)/../ \
  -w $(pwd) \
  ${BUILDER_IMAGE} \
  dpkg-buildpackage -uc -us

# Move results from parent directory
mv -v ../openmediavault-ldap_* .
