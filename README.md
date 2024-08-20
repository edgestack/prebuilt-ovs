# Prebuilt OVS

Supported OS:
- Ubuntu 22.04 / OVS version 2.17.10
- Ubuntu 24.04 / OVS version 3.3.0

## ONOS SONA OpenFlow Version Issue

[ONOS SONA](https://groups.google.com/a/onosproject.org/g/onos-discuss/c/BaV1xrUvkxY) has a problem with OVS versions using OpenFlow 1.5.
`rollback-to-openflow14.patch` changes the default OpenFlow version from 1.5 to 1.4.

## OVS Install Guide

``` bash
sudo apt-get update -y
sudo dpkg -i $(ls ./*.deb | grep -v "openvswitch-ipsec"| grep -v "openvswitch-datapath")
sudo apt-get install -f
```

## OVS DEB Build Guide

Run `./build-deb.sh`
