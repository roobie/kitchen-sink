#!/bin/sh

# $1 is the virtual drive to be used
# $2 is the cdrom to virtually mount

echo "Trying to boot image $1 with cdrom $2"

# -sdl
qemu-system-i386 \
    -enable-kvm \
    -m 1024 \
    -nic user,model=virtio,hostfwd=tcp::10022-:22 \
    -nic tap \
    -drive file=$1,media=disk,if=virtio \
    -cdrom $2 \
    -vga qxl \
    -spice port=5900,addr=127.0.0.1,disable-ticketing

