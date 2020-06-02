
qemu-system-x86_64 \
    -enable-kvm \
    -m 1024 \
    -nic user,model=virtio,hostfwd=tcp::10022-:22 \
    -drive file=$1,media=disk,if=virtio \
    -curses \
    -serial mon:stdio \
