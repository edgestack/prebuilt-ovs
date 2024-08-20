#!/bin/bash

set -x

# Check if the user has sudo privileges
if ! sudo -n true 2>/dev/null; then
	echo "The user does not have sudo privileges."
	exit 1
fi

# Determine the OS release version
if grep -q "Ubuntu 22.04" /etc/os-release; then
	RELEASE="Ubuntu-22.04"
elif grep -q "Ubuntu 24.04" /etc/os-release; then
	RELEASE="Ubuntu-24.04"
else
	echo "$(cat /etc/system-release) is not supported"
	exit 1
fi

# Get the architecture
ARCH=$(arch)

# Build direcetory
OVS_BUILD_DIR="ovs-build-dir"

# Set OVS source package url based on release version
if [[ ${RELEASE} == "Ubuntu-22.04" ]]; then
	OVS_VERSION="2.17.10"
elif [[ ${RELEASE} == "Ubuntu-24.04" ]]; then
	OVS_VERSION="3.3.0"
else
	echo "Unknown RELEASE: ${RELEASE}"
	exit 1
fi

PKG_SRC="https://github.com/openvswitch/ovs/archive/refs/tags/v${OVS_VERSION}.tar.gz"

# Install dependencies
sudo DEBIAN_FRONTEND=noninteractive apt-get update -y
sudo DEBIAN_FRONTEND=noninteractive apt-get install build-essential fakeroot autoconf libtool devscripts debhelper -y
sudo DEBIAN_FRONTEND=noninteractive apt-get install debhelper-compat dh-python graphviz libcap-ng-dev libdbus-1-dev libdpdk-dev libnuma-dev libpcap-dev libssl-dev libunbound-dev pkg-config python3-all-dev python3-sortedcontainers python3-sphinx dh-make -y

# Download OVS sources
rm -rf ${OVS_BUILD_DIR}
rm -rf "v${OVS_VERSION}.tar.gz"
wget ${PKG_SRC}
mkdir -p ${OVS_BUILD_DIR}
tar xvfz "v${OVS_VERSION}.tar.gz" -C ${OVS_BUILD_DIR}

# Copy patches
cp rollback-to-openflow14.patch "${OVS_BUILD_DIR}/ovs-${OVS_VERSION}"

# Apply patches
cd "${OVS_BUILD_DIR}/ovs-${OVS_VERSION}"
patch -p1 < rollback-to-openflow14.patch

# Build OVS
#DEB_BUILD_OPTIONS=nocheck debuild -us -uc -b
debuild -us -uc -b

echo "${RELEASE} ${ARCH} RPM build completed successfully."
