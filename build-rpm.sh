#!/bin/bash

set -x

# Check if the user has sudo privileges
if ! sudo -v &> /dev/null; then
	echo "The user does not have sudo privileges."
	exit 1
fi

# Determine the OS release version
if grep -q "Rocky-Linux-8" /etc/os-release; then
	RELEASE="RedHat-8"
	DEVEL_REPO="powertools"
elif grep -q "Rocky-Linux-9" /etc/os-release; then
	RELEASE="RedHat-9"
	DEVEL_REPO="crb"
else
	echo "$(cat /etc/system-release) is not supported"
	exit 1
fi

# Get the architecture
ARCH=$(arch)

# Set OVS source package url based on release version
if [[ ${RELEASE} == "RedHat-8" ]]; then
	# https://cbs.centos.org/koji/builds?tagID=2257 / ver. 2024.05.07
	OVS_VERSION="3.1"
	RPM_SRC="https://cbs.centos.org/kojifiles/packages/openvswitch3.1/3.1.0/116.el8s/src/openvswitch3.1-3.1.0-116.el8s.src.rpm"
	RPM_SELINUX="https://cbs.centos.org/kojifiles/packages/openvswitch-selinux-extra-policy/1.0/29.el8s/noarch/openvswitch-selinux-extra-policy-1.0-29.el8s.noarch.rpm"
elif [[ ${RELEASE} == "RedHat-9" ]]; then
	# https://cbs.centos.org/koji/builds?tagID=2748 / ver. 2024.05.28
	OVS_VERSION="3.3"
	RPM_SRC="https://cbs.centos.org/kojifiles/packages/openvswitch3.3/3.3.0/2.el9/src/openvswitch3.3-3.3.0-2.el9.src.rpm"
	RPM_SELINUX="https://cbs.centos.org/kojifiles/packages/openvswitch-selinux-extra-policy/1.0/30.el9/noarch/openvswitch-selinux-extra-policy-1.0-30.el9.noarch.rpm"
else
	echo "Unknown RELEASE: ${RELEASE}"
	exit 1
fi

SPEC_PATH="${HOME}/rpmbuild/SPECS/openvswitch${OVS_VERSION}.spec"
PATCH_PATH="${HOME}/rpmbuild/SOURCES/openvswitch-${OVS_VERSION}.0.patch"

# Install tools to build rpm package
sudo dnf install -y rpm-build rpmdevtools epel-release

# Download openvswitch rpm build source
rm -rf ${HOME}/rpmbuild
rpm -ivh ${RPM_SRC}

# Rollback from OpenFlow 1.5 to OpenFlow 1.4
cat rollback-to-openflow14.patch >> ${PATCH_PATH}

# Resolve spec parsing error and disable dpdk
sed -i 's/%endif	# build dpdk/%endif/' ${SPEC_PATH}
sed -i 's/%define dpdkarches.*//g' ${SPEC_PATH}

# Install build dependencies
sudo dnf --enablerepo=${DEVEL_REPO} builddep -y ${SPEC_PATH}

# Build rpm packages
rpmbuild -bb --target ${ARCH} ${SPEC_PATH}

# Download openvswitch-selinux-extra-policy
pushd "${HOME}/rpmbuild/RPMS/${ARCH}"
curl -LO ${RPM_SELINUX}

echo "${RELEASE} ${ARCH} RPM build completed successfully."
pwd
ls
popd
