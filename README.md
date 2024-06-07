# Prebuilt OVS

Supported OS:
- Rocky 8 / OVS version 3.1
- Rocky 9 / OVS version 3.3

## ONOS SONA OpenFlow Version Issue

[ONOS SONA](https://groups.google.com/a/onosproject.org/g/onos-discuss/c/BaV1xrUvkxY) has a problem with OVS versions using OpenFlow 1.5.
`rollback-to-openflow14.patch` changes the default OpenFlow version from 1.5 to 1.4.

## OVS Install Guide

``` bash
sudo dnf install -y epel-release
pushd [RELEASE]/[ARCH]
sudo dnf install *.rpm
popd
```

## OVS RPM Build Guide

Run `./build-rpm.sh`
