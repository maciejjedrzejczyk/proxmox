#!/bin/sh
sudo sh -c "echo 'nameserver 192.168.0.2' > /etc/resolvconf/resolv.conf.d/head"
sudo sh -c "echo 'mj ALL=(ALL:ALL) NOPASSWD: ALL' >> /etc/sudoers"