#!/bin/sh

# See more at https://drewdevault.com/2018/09/10/Getting-started-with-qemu.html
# -sdl can be used for direct rendering instead of -spice
$image_file="system-image.qcow2"
qemu-system-i386 \
    -enable-kvm \
    -m 1024 \
    -nic user,model=virtio \
    -drive file=$image_file,media=disk,if=virtio \
    -vga qxl \
    -spice port=5900,addr=127.0.0.1,disable-ticketing

