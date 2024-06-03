# Prebuilt OVS

Supported OS:
* Rocky 9

## ONOS SONA OpenFlow Version Issue

[ONOS SONA](https://groups.google.com/a/onosproject.org/g/onos-discuss/c/BaV1xrUvkxY) has a problem with OpenFlow 1.5.
`ovs-2.17-rollback-to-openflow14.patch` changes the default OpenFlow version from 1.5 to 1.4.

## Rocky 9 RPM Build Guide - ARM64

``` bash
# Tools to build rpm
sudo dnf install -y rpm-build rpmdevtools epel-release

# Dependencies of openvswitch rpm packages
sudo dnf install -y centos-release-nfv-openvswitch
sudo dnf install -y openvswitch-selinux-extra-policy libreswan

# Get rpm source from nfv9-openvswitch-common-release
# https://cbs.centos.org/koji/taginfo?tagID=2748
rpm -ivh https://cbs.centos.org/kojifiles/packages/openvswitch2.17/2.17.0/154.el9s/src/openvswitch2.17-2.17.0-154.el9s.src.rpm

# Rollback from OpenFlow 1.5 to OpenFlow 1.4
cat ovs-2.17-rollback-to-openflow14.patch >> ~/rpmbuild/SOURCES/openvswitch-2.17.0.patch

# Install build dependencies
sudo dnf --enablerepo=crb builddep -y ~/rpmbuild/SPECS/openvswitch2.17.spec

# Build rpm packages
rpmbuild -bb --target aarch64 ~/rpmbuild/SPECS/openvswitch2.17.spec

# Install rpm packages
ls ~/rpmbuild/RPMS/aarch64/
sudo rpm -ivh ~/rpmbuild/RPMS/aarch64/*.rpm
sudo systemctl enable --now openvswitch
```

