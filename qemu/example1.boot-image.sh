#!/bin/sh

# See more at https://drewdevault.com/2018/09/10/Getting-started-with-qemu.html
# -sdl
#
# can be used for direct rendering instead of -vga and -spice
#
#
# -enable-kvm
#
# makes the kvm features available which should increse performance
#
#
# -m 1024
#
# gives the vm access to 1024 MB of RAM
#
#
# -nic ...
#
# enables the default virtual network interface, using the virtio model for
# transport. hostfwd maps the tcp port 10022 of the host machine to the guest's
# port 22 over TCP. This means that one can access the guest via ssh (given that
# the guest has sshd configured and running) as such:
#
# ssh user@localhost -p 10022
#
# NOTE: for root to be able to login via ssh, /etc/ssh/sshd_config must have "PermitRootLogin yes"
#
# -nic tap
#
# enable the TAP interface. See qemu-ifup
#
# -drive ...
#
# tells QEMU which image to load and how.
#
#
# -vga ?
#
#
# -spice
#
# defines how to connect to the guest via the SPICE protocol
#
#
$image_file="system-image.qcow2"
qemu-system-i386 \
    -enable-kvm \
    -m 1024 \
    -nic user,model=virtio,hostfwd=tcp::10022-:22 \
    -nic tap \
    -drive file=$image_file,media=disk,if=virtio \
    -vga qxl \
    -spice port=5900,addr=127.0.0.1,disable-ticketing

