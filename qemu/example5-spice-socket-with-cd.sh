
qemu-system-x86_64 \
    -enable-kvm \
    -m 1024 \
    -nic user,model=virtio,hostfwd=tcp::10022-:22 \
    -drive file=$1,media=disk,if=virtio \
    -cdrom $2 \
    -device virtio-serial-pci \
    -device virtserialport,chardev=spicechannel0,name=com.redhat.spice.0 \
    -spice unix,addr=/tmp/vm_spice.socket,disable-ticketing \
    -chardev spicevmc,id=spicechannel0,name=vdagent
