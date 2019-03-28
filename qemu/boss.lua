#!/usr/bin/env lua

local inspect = require('inspect')
local getopt = require('getopt')
local function dump (item)
  print(inspect(item))
end

local getopt_cfg = {
  name = 'boss.lua - helper for qemu stuff';
  version = '1.0.0-alpa1';
  help = [[
    EXAMPLE
    ./boss.lua --config vm1-config.lua

    That's it.]];
  options = {
    ['--version'] = {
      help = 'Display the version';
      type = 'boolean'; -- See below
    };
    ['--config'] = {
      help = 'Specify config file';
      type = 'string'; -- See below
    };
    ['--cdrom'] = {
      help = 'Specify a cdrom to mount';
      type = 'string'; -- See below
    };
    -- more options
  };
}
local cfg = getopt(arg, getopt_cfg)
if cfg == nil then
  print('Invalid invocation.')
  print(getopt_cfg.help)
else
  dump(cfg)
end

local function test_port (port_no)
  local fd = io.popen('nmap -p '..port_no..' localhost')
  local result = fd:read('*a')
  fd:close()
  return result
end

local function start_tmux (name, qemu_cmd)
  -- # create a new tmux session named $name, but detach immediately
  os.execute('tmux new-session -d -s '..name)
  -- # send keys to start up qemu (C-m means Return)
  qemu_cmd = string.gsub(qemu_cmd, ' ', ' Space ')
  os.execute('tmux send-keys '..qemu_cmd..' C-m')
  os.execute('tmux attach -t '..name)
  print('tmux session name: '..name, [[
    A new tmux session was created with the name.
]])
end

local display_version = cfg.opt['--version']
local config_file = cfg.opt['--config']
local config = require(config_file)
dump(config)

local function m (qemu_arg, k)
  if config[k] then
    return ' '..qemu_arg..' '..config[k]
  else
    return ''
  end
end

local function ml (qemu_arg, k)
  local accumulator = ''
  if config[k] then
    for _, v in ipairs(config[k]) do
      accumulator = ' '..accumulator..qemu_arg..' '..v
    end
  end
  return accumulator
end

local qemu_command = ''..
  'qemu-system-'..config.arch..
  m('-accel', 'accel')..
  m('-m', 'm')..
  ml('-drive', 'drives')..
  m('-smp', 'smp')..
  m('-vga', 'vga')..
  m('-spice', 'spice')..
  ml('-nic', 'nics')..
  ''

print(qemu_command)
start_tmux(config.name, qemu_command)
