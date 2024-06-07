# Prebuilt OVS

Supported OS:
* Rocky 9

## ONOS SONA OpenFlow Version Issue

[ONOS SONA](https://groups.google.com/a/onosproject.org/g/onos-discuss/c/BaV1xrUvkxY) has a problem with OVS versions using OpenFlow 1.5.
`rollback-to-openflow14.patch` changes the default OpenFlow version from 1.5 to 1.4.

## Rocky 9 RPM Install Guide

``` bash
sudo dnf install -y epel-release
pushd RedHat-9/[ARCH]
sudo dnf install *.rpm
popd
```

## Rocky 9 RPM Build Guide

``` bash
# Tools to build rpm
sudo dnf install -y rpm-build rpmdevtools epel-release

# Dependencies of openvswitch rpm packages
sudo dnf install -y centos-release-nfv-openvswitch
sudo dnf install -y openvswitch-selinux-extra-policy libreswan

# Get rpm source from nfv9-openvswitch-common-release
# https://cbs.centos.org/koji/taginfo?tagID=2748
rpm -ivh https://cbs.centos.org/kojifiles/packages/openvswitch3.3/3.3.0/23.el9s/src/openvswitch3.3-3.3.0-23.el9s.src.rpm

# Rollback from OpenFlow 1.5 to OpenFlow 1.4
cat rollback-to-openflow14.patch >> ~/rpmbuild/SOURCES/openvswitch-3.3.0.patch
sed -i 's/%endif    # build dpdk/%endif/' ~/rpmbuild/SPECS/openvswitch3.3.spec
sed -i 's/%define dpdkarches/# %define dpdkarches/g' ~/rpmbuild/SPECS/openvswitch3.3.spec

# Install build dependencies
sudo dnf --enablerepo=crb builddep -y ~/rpmbuild/SPECS/openvswitch3.3.spec

# Build rpm packages - AMD64
rpmbuild -bb --target x86_64 ~/rpmbuild/SPECS/openvswitch3.3.spec

# Build rpm packages - ARM64
rpmbuild -bb --target aarch64 ~/rpmbuild/SPECS/openvswitch3.3.spec

# Install rpm packages
ls ~/rpmbuild/RPMS/aarch64/
sudo rpm -ivh ~/rpmbuild/RPMS/aarch64/*.rpm
sudo systemctl enable --now openvswitch
```
