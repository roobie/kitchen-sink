#!/usr/bin/env lua
local function getopt (arg, opts)
  local skip_opts, result, counter_cache, table_cache, i = false, {
    opt = { }
  }, { }, { }, 0
  while i < #arg do
    local _continue_0 = false
    repeat
      i = i + 1
      if (not skip_opts) and (#arg[i] > 0) then
        if arg[i] == "--" then
          skip_opts = true
          _continue_0 = true
          break
        end
        if opts.options and opts.options[arg[i]] then
          local name = arg[i]
          local o = opts.options[arg[i]]
          do
            local value
            local _exp_0 = o.type
            if "string" == _exp_0 then
              i = i + 1
              if i > #arg then
                error("Option " .. tostring(name) .. " requires a string", 2)
              end
              value = arg[i]
            elseif "number" == _exp_0 then
              i = i + 1
              if i > #arg then
                error("Option " .. tostring(name) .. " requires a number", 2)
              end
              value = tonumber(arg[i])
            elseif "boolean" == _exp_0 then
              value = true
            elseif "counter" == _exp_0 then
              if not counter_cache[name] then
                counter_cache[name] = 1
                value = 1
              else
                counter_cache[name] = counter_cache[name] + 1
                value = counter_cache[name]
              end
            elseif "table" == _exp_0 then
              i = i + 1
              if not table_cache[name] then
                table_cache[name] = {
                  arg[i]
                }
                value = table_cache[name]
              else
                table.insert(table_cache[name], arg[i])
                value = table_cache[name]
              end
            else
              error("Invalid option type " .. tostring(o.type) .. " for option " .. tostring(name), 2)
            end
            if o.call then
              result.opt[name] = o.call((value))
            else
              result.opt[name] = value
            end
          end
          _continue_0 = true
          break
        end
        if ((arg[i]:sub(1, 1)) == "-") or ((arg[i]:sub(1, 1)) == "@") then
          if (#arg[i] > 1) and ((arg[i]:sub(2, 2)) == "-") then
            if arg[i] == "--help" then
              local format
              format = string.format
              local output = opts.help_output or io.write
              if opts.help then
                opts.name = opts.name or ""
                opts.version = opts.version or " "
                output(tostring(opts.name) .. " " .. tostring(opts.version) .. ": ")
                output(opts.help)
                output("\n")
              end
              output("Options:\n")
              local longest_opt, o = 4, { }
              if opts.flags then
                for k, v in pairs(opts.flags) do
                  o[#o + 1] = {
                    name = k,
                    desc = v.help or "?"
                  }
                  if v.type == "counter" then
                    o[#o].name = o[#o].name .. " ..."
                  end
                  if o[#o].name:len() > longest_opt then
                    longest_opt = o[#o].name:len()
                  end
                end
              end
              if opts.options then
                for k, v in pairs(opts.options) do
                  local e = {
                    desc = v.help or "?"
                  }
                  local _exp_0 = v.type
                  if "string" == _exp_0 then
                    e.name = "  " .. tostring(k) .. " <string>"
                  elseif "number" == _exp_0 then
                    e.name = "  " .. tostring(k) .. " <number>"
                  elseif "boolean" == _exp_0 then
                    e.name = "  " .. tostring(k)
                  elseif "counter" == _exp_0 then
                    e.name = "  " .. tostring(k) .. " ..."
                  elseif "table" == _exp_0 then
                    e.name = "  " .. tostring(k) .. " ..."
                  else
                    error("Invalid option type " .. tostring(o.type) .. " for option " .. tostring(k), 2)
                  end
                  if e.name:len() > longest_opt then
                    longest_opt = e.name:len()
                  end
                  o[#o + 1] = e
                end
              end
              local fmtstr
              if longest_opt > 20 then
                fmtstr = "%-20s"
              else
                fmtstr = "%-" .. tostring(longest_opt) .. "s"
              end
              for k, opt in pairs(o) do
                output(format(fmtstr, opt.name))
                if opt.name:len() > 20 then
                  output("\n                     ")
                else
                  output("  ")
                end
                output(opt.desc)
                output("\n")
                o[k] = nil
              end
              return "help"
            end
          elseif opts.flags then
            local s = arg[i]:sub(2)
            for c = 1, #s, 1 do
              local f = s:sub(c, c)
              if opts.flags[f] then
                if opts.flags[f].type == "counter" then
                  if not result.opt[f] then
                    result.opt[f] = 1
                  else
                    result.opt[f] = result.opt[f] + 1
                  end
                else
                  result.opt[f] = true
                end
              else
                return nil, "invalid flag: " .. tostring(f), i
              end
            end
            _continue_0 = true
            break
          end
        end
      end
      if not result.unhandled then
        result.unhandled = { }
      end
      result.unhandled[#result.unhandled + 1] = arg[i]
      _continue_0 = true
    until true
    if not _continue_0 then
      break
    end
  end
  return result
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
      type = 'boolean';
    };
    ['--config'] = {
      help = 'Specify config file';
      type = 'string';
    };
    ['--detach'] = {
      help = 'Whether to detach immediately from the tmux session';
      type = 'boolean';
    };
    ['--cdrom'] = {
      help = 'Specify a cdrom to mount';
      type = 'string';
    };
    -- more options
  };
}


local function cond (pred, vtrue, vfalse)
  if pred then
    return vtrue()
  else
    return vfalse()
  end
end

local function val (v)
  return function ()
    return v
  end
end

local function empty_string_fn ()
  return ''
end


local cfg = getopt(arg, getopt_cfg)


if cfg == nil then
  print('Invalid invocation.')
  print(getopt_cfg.help)
else
  -- dump(cfg)
end


local function test_port (port_no)
  local fd = io.popen('nmap -p '..port_no..' localhost')
  local result = fd:read('*a')
  fd:close()
  return result
end


local display_version = cfg.opt['--version']
local config_file = cfg.opt['--config']
local cdrom = cfg.opt['--cdrom']
local detach = cfg.opt['--detach']
local config = require(string.gsub(config_file, '.lua', ''))
-- dump(config)


local function start_tmux (name, qemu_cmd)
  -- # create a new tmux session named $name, but detach immediately
  os.execute('tmux new-session -d -s '..name)
  -- # send keys to start up qemu (C-m means Return)
  qemu_cmd = string.gsub(qemu_cmd, ' ', ' Space ')
  -- os.execute('tmux send-keys '..qemu_cmd..' C-m')
  print(string.format([[A new tmux session was created with the name "%s".]], name))
  if not detach then
    os.execute('tmux attach -t '..name)
  end
end


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
  ' '..
  cond(cdrom, function () return '-cdrom '..cdrom end, empty_string_fn)..
  ' '..
  '-monitor stdio'..
  ''

print(qemu_command)
start_tmux(config.name, qemu_command)
