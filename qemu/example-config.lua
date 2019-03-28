
return {
  name = 'example-vm';
  arch = 'x86_64';
  accel = 'kvm';
  m = '1024';
  drives = {
    'file=vm-image.qcow2,media=disk,if=virtio';
  };
  smp = 4;
  vga = 'qxl';
  spice = 'port=5900,addr=127.0.0.1,disable-ticketing';
  nics = {
    'tap,ifname=tap0,mac=52:54:d8:ce:12:ab';
  };
}
