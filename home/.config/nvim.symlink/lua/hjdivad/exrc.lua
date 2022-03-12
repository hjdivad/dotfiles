local utils = require('hjdivad.utils')
local Path = utils.Path
local File = utils.File
local hi = utils.hjdivad_init

local exrc_entry_sep =  ' ⊱ '

local function exrc(vimrc, vim_rtp)
  if vimrc then
    if vim.endswith(vimrc, '.lua') then
      local vimrc_lua = loadfile(vimrc, 't')
      vimrc_lua()
    else
      local viml = io.open(vimrc, 'r'):read('a')
      vim.api.nvim_exec(viml, false)
    end
  end

  if vim_rtp then
    vim.opt.runtimepath:append(vim_rtp)
  end
end

local function update_exrc_choices(data_file, path, allow)
  local file = io.open(data_file, 'a')
  if not file then
    vim.fn['mkdir'](Path.dirname(data_file))
    file = io.open(data_file, 'a')
  end

  if not file then
    error('Unable to write to "' .. data_file .. '"')
  end

  file:write(path)
  file:write(exrc_entry_sep)
  file:write(allow and '1' or '0')
  file:write('\n')
  file:close()
end

local function load_saved_exrc_choice(data_path, path)
  local exrc_dir_choices = io.open(data_path, 'r')
  if exrc_dir_choices then
    for entry_line in exrc_dir_choices:lines() do
      local entry = vim.split(entry_line, exrc_entry_sep, { plain=true })
      local entry_path = entry[1]

      if entry_path == path then
        exrc_dir_choices:close()
        local allow = entry[2] == '1' and true or false

        return allow
      end
    end
    exrc_dir_choices:close()
  end
end

local function setup_exrc()
  local cwd = vim.fn['getcwd']()
  local vimrc = nil
  if File.readable(Path.join(cwd, '.vimrc.lua')) then
    vimrc = Path.join(cwd, '.vimrc.lua')
  elseif File.readable(Path.join(cwd, '.vimrc')) then
    vimrc = Path.join(cwd, '.vimrc')
  end

  local rtp = nil
  if File.isdirectory(Path.join(cwd, '.vim')) then
    rtp = Path.join(cwd, '.vim')
  end

  if vimrc == nil and rtp == nil then
    -- early exit, there is no .vimrc or .vim/
    return
  end

  local data_path = utils.xdg_data_path('nvim/hjdivad-init/exrc_dir_choices')
  local previously_saved_choice = load_saved_exrc_choice(data_path, cwd)
  if previously_saved_choice == true then
    exrc(vimrc, rtp)
    return
  elseif previously_saved_choice == false then
    return
  end

  utils.echo('cwd:', cwd, 'vimrc:', vimrc, 'rtp:', rtp)

  -- found vimrc or .vim/ and no previously saved choice

  local saved_choice = nil
  vim.ui.select(
    {
      --[[1]] 'Yes: run .vimrc and add .vim to runtimepath (remember choice)',
      --[[2]] 'Yes (once): run .vimrc and add .vim to runtimepath (this time)',
      --[[3]] 'No: do not run .vimrc or add .vim to runtimepath (remember choice)',
      --[[4]] 'No (once): do not run .vimrc or add .vim to runtimepath (this time)',
    },
    {
      prompt = '.vimrc or .vim detected.\nRun automatically?\nOnly do this if you trust the contents of "' .. cwd .. '"\n' .. [[see :help 'exrc' for details.]] .. '\n'
    },
    function(_, idx)
      if idx == 1 then
        exrc(vimrc, rtp)
        saved_choice = true
      elseif idx == 2 then
        exrc(vimrc, rtp)
        return
      elseif idx == 3 then
        saved_choice = false
      elseif idx == 4 then
        -- NOP user explicitly said no + don't save
        return
      else
        --- NOP user canceled via q or blank selection
      end
    end
  )

  if saved_choice ~= nil then
    update_exrc_choices(data_path, cwd, saved_choice)
  end
end

function hi.init_exrc()
  -- TODO: blueprint (see <https://github.com/hjdivad/dotfiles/blob/a22557c32bfb69e574114f6c39b832f7b34da132/home/.config/nvim.symlink/init.vim#L895-L901>)
  -- but make it a command instead lua hi.init_exrc
end

return {
  setup_exrc = setup_exrc
}
