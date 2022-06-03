local utils = require('hjdivad/utils')
local Path = utils.Path
local File = utils.File

-- Save nvim's vim.ui.select as our prompt causes a race with telescope-ui-select
local select = vim.ui.select

local exrc_entry_sep = ' ⊱ '

local function get_data_path()
  return Path.join(vim.fn.stdpath('data'), 'hjdivad-init/exrc_dir_choices')
end

local function ierr(msg)
  return '[internal error hjdivad/exrc]: ' .. msg
end

local function exrc(vimrc, vim_rtp, ...)
  assert(vimrc or vim_rtp, ierr('one of vimrc or vim_ftp is required'))

  -- LuaJIT (i.e. Lua5.1) compatible variant onf table.pack(...)[1]
  local opts = ({ ... })[1] or {}

  local io = opts.io or io
  local loadfile = opts.loadfile or loadfile

  if vimrc then
    if vim.endswith(vimrc, '.lua') then
      local vimrc_lua = loadfile(vimrc, 't')
      if vimrc_lua then
        vimrc_lua()
      end
    else
      local viml = io.open(vimrc, 'r'):read('a')
      vim.api.nvim_exec(viml, false)
    end
  end

  if vim_rtp then vim.opt.runtimepath:append(vim_rtp) end
end

local function update_exrc_choices(data_file, path, allow)
  local file = io.open(data_file, 'a')
  if not file then
    vim.fn.mkdir(Path.dirname(data_file))
    file = io.open(data_file, 'a')
  end

  if file then
    file:write(path)
    file:write(exrc_entry_sep)
    file:write(allow and '1' or '0')
    file:write('\n')
    file:close()
  else
    error('Unable to write to "' .. data_file .. '"')
  end
end

local function iterate_exrc_choices()
  local exrc_dir_choices = io.open(get_data_path(), 'r')
  if not exrc_dir_choices then return function() end end

  local next_line = exrc_dir_choices:lines()
  return function()
    local entry_line = next_line()
    if entry_line then
      local entry = vim.split(entry_line, exrc_entry_sep, { plain = true })
      return entry[1], entry[2], exrc_dir_choices, entry_line
    else
      exrc_dir_choices:close()
      return nil
    end
  end
end

local function load_saved_exrc_choice(path)
  for entry_path, entry_choice, file in iterate_exrc_choices() do
    if entry_path == path then
      local allow = entry_choice == '1' and true or false

      file:close()
      return allow
    end
  end
end

local function run_exrc()
  local cwd = vim.fn.getcwd()
  local vimrc = nil
  if File.readable(Path.join(cwd, '.vimrc.lua')) then
    vimrc = Path.join(cwd, '.vimrc.lua')
  elseif File.readable(Path.join(cwd, '.vimrc')) then
    vimrc = Path.join(cwd, '.vimrc')
  end

  local rtp = nil
  if File.isdirectory(Path.join(cwd, '.vim')) then rtp = Path.join(cwd, '.vim') end

  if vimrc == nil and rtp == nil then
    -- early exit, there is no .vimrc or .vim/
    return
  end

  local previously_saved_choice = load_saved_exrc_choice(cwd)
  if previously_saved_choice == true then
    exrc(vimrc, rtp)
    return
  elseif previously_saved_choice == false then
    return
  end

  -- found vimrc or .vim/ and no previously saved choice

  local saved_choice = nil
  local prompt_start = nil
  if vimrc and rtp then
    prompt_start = vimrc .. ' and .vim detected. Source and add to runtimepath?'
  elseif vimrc then
    prompt_start = vimrc .. ' detected. Source?'
  else
    prompt_start = '.vim detected. Add to runtimepath?'
  end
  select({
    --[[1]]
    'Yes: trust       ' .. cwd .. ' (remember choice)',
    --[[2]]
    'No: do not trust ' .. cwd .. ' (remember choice)',
    --[[3]]
    'Yes: but only this time',
    --[[4]]
    'No:  but only this time',
  }, {
    prompt = prompt_start .. ' Only do this if you trust the contents at ' .. cwd
  }, function(_, idx)
    if idx == 1 then
      -- run & save
      exrc(vimrc, rtp)
      saved_choice = true
    elseif idx == 2 then
      -- ignore & save
      saved_choice = false
    elseif idx == 3 then
      -- run this time
      exrc(vimrc, rtp)
      return
    elseif idx == 4 then
      -- skip this time
      return
    else
      --- NOP user canceled via q or blank selection
    end
  end)

  if saved_choice ~= nil then update_exrc_choices(get_data_path(), cwd, saved_choice) end
end

---Initialize `cwd` with a `.vimrc.lua` and `.vim/` for auto-exection.
---
---Does not update the saved choices file -- next time nvim is started in `cwd`
---you will be prompted before executing `.vimrc.lua`
local function exrc_init()
  local blueprints = vim.api.nvim_get_runtime_file('blueprints/project', false)
  local cwd = vim.fn.getcwd()
  if #blueprints == 0 then error('Unable to find blueprints/project anywhere in &runtimepath') end

  local blueprint = blueprints[1]
  File.cp_r(blueprint .. '/', cwd)
  print('Written .vimrc.lua and .vim blueprint to "' .. cwd .. '"')
end

---List saved exrc choices, one per line as:
---
---```markdown
---   **path** ⊱ **choice**
---```
---
--- Where `choice` is either `1` (run `.vimrc.lua` and read `.vim`) or `0` (ignore `.vimrc.lua` and `.vim`)
local function exrc_ls()
  local data_path = get_data_path()
  local exrc_dir_choices = io.open(data_path, 'r')
  if exrc_dir_choices then
    for entry_line in exrc_dir_choices:lines() do print(entry_line) end
    exrc_dir_choices:close()
  else
    print('<none>: no exrc choices saved to "' .. data_path .. '"')
  end
end

---Remove `cwd` from the saved choices list.
---
---If `cwd` contains `.vimrc.lua` or `.vim` you will again be prompted before
---executing the rc file.
local function exrc_rm()
  local data_path = get_data_path()
  local exrc_dir_choices = io.open(data_path, 'r')
  local path = vim.fn.getcwd()

  local updated_choices = {}
  local found = false
  for entry_path, _, _, entry_line in iterate_exrc_choices() do
    if entry_path ~= path then
      table.insert(updated_choices, entry_line)
    else
      found = true
    end
  end

  if found then
    exrc_dir_choices = io.open(data_path, 'w+')
    if exrc_dir_choices then
      exrc_dir_choices:write(table.concat(updated_choices, '\n'))
      exrc_dir_choices:write('\n')
      exrc_dir_choices:close()
    else
      assert(false, ierr('exrc_dir_choices vanished mid-read'))
    end
  else
    print('<nop>: no entry "' .. path .. '" in "' .. data_path .. '"')
  end
end

local function create_user_commands()
  vim.api.nvim_create_user_command('HiExrcInit', exrc_init, { desc = 'Create a {.vimrc.lua, .vim/} for the current directory' })
  vim.api.nvim_create_user_command('HiExrcList', exrc_ls, { desc = 'List saved exrc choices' })
  vim.api.nvim_create_user_command('HiExrcRemove', exrc_rm, { desc = 'Remove the current directory from the list of saved exrc choices' })
end

local did_setup = false
local function setup()
  did_setup = true

  create_user_commands()
end

local function run_if_setup(cb)
  if did_setup then
    return cb()
  end
end

return {
  _get_data_path = get_data_path,
  _exrc = exrc,

  run_exrc = run_exrc,
  run_if_setup = run_if_setup,
  setup = setup,
}
