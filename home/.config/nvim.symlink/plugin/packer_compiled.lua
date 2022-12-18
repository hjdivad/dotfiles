-- Automatically generated packer.nvim plugin loader code

if vim.api.nvim_call_function('has', {'nvim-0.5'}) ~= 1 then
  vim.api.nvim_command('echohl WarningMsg | echom "Invalid Neovim version for packer.nvim! | echohl None"')
  return
end

vim.api.nvim_command('packadd packer.nvim')

local no_errors, error_msg = pcall(function()

_G._packer = _G._packer or {}
_G._packer.inside_compile = true

local time
local profile_info
local should_profile = false
if should_profile then
  local hrtime = vim.loop.hrtime
  profile_info = {}
  time = function(chunk, start)
    if start then
      profile_info[chunk] = hrtime()
    else
      profile_info[chunk] = (hrtime() - profile_info[chunk]) / 1e6
    end
  end
else
  time = function(chunk, start) end
end

local function save_profiles(threshold)
  local sorted_times = {}
  for chunk_name, time_taken in pairs(profile_info) do
    sorted_times[#sorted_times + 1] = {chunk_name, time_taken}
  end
  table.sort(sorted_times, function(a, b) return a[2] > b[2] end)
  local results = {}
  for i, elem in ipairs(sorted_times) do
    if not threshold or threshold and elem[2] > threshold then
      results[i] = elem[1] .. ' took ' .. elem[2] .. 'ms'
    end
  end
  if threshold then
    table.insert(results, '(Only showing plugins that took longer than ' .. threshold .. ' ms ' .. 'to load)')
  end

  _G._packer.profile_output = results
end

time([[Luarocks path setup]], true)
local package_path_str = "/Users/hjdivad/.cache/nvim/packer_hererocks/2.1.0-beta3/share/lua/5.1/?.lua;/Users/hjdivad/.cache/nvim/packer_hererocks/2.1.0-beta3/share/lua/5.1/?/init.lua;/Users/hjdivad/.cache/nvim/packer_hererocks/2.1.0-beta3/lib/luarocks/rocks-5.1/?.lua;/Users/hjdivad/.cache/nvim/packer_hererocks/2.1.0-beta3/lib/luarocks/rocks-5.1/?/init.lua"
local install_cpath_pattern = "/Users/hjdivad/.cache/nvim/packer_hererocks/2.1.0-beta3/lib/lua/5.1/?.so"
if not string.find(package.path, package_path_str, 1, true) then
  package.path = package.path .. ';' .. package_path_str
end

if not string.find(package.cpath, install_cpath_pattern, 1, true) then
  package.cpath = package.cpath .. ';' .. install_cpath_pattern
end

time([[Luarocks path setup]], false)
time([[try_loadstring definition]], true)
local function try_loadstring(s, component, name)
  local success, result = pcall(loadstring(s), name, _G.packer_plugins[name])
  if not success then
    vim.schedule(function()
      vim.api.nvim_notify('packer.nvim: Error running ' .. component .. ' for ' .. name .. ': ' .. result, vim.log.levels.ERROR, {})
    end)
  end
  return result
end

time([[try_loadstring definition]], false)
time([[Defining packer_plugins]], true)
_G.packer_plugins = {
  ["BetterLua.vim"] = {
    loaded = true,
    path = "/Users/hjdivad/tmp/test/nvim/site/pack/packer/start/BetterLua.vim",
    url = "https://github.com/euclidianAce/BetterLua.vim"
  },
  bclose = {
    config = { "\27LJ\2\n;\0\0\2\0\3\0\0056\0\0\0009\0\1\0+\1\2\0=\1\2\0K\0\1\0\30bclose_no_default_mapping\6g\bvim\0" },
    loaded = true,
    path = "/Users/hjdivad/tmp/test/nvim/site/pack/packer/start/bclose",
    url = "https://github.com/bcaccinolo/bclose"
  },
  ["cmp-cmdline"] = {
    loaded = true,
    path = "/Users/hjdivad/tmp/test/nvim/site/pack/packer/start/cmp-cmdline",
    url = "https://github.com/hrsh7th/cmp-cmdline"
  },
  ["cmp-emoji"] = {
    loaded = true,
    path = "/Users/hjdivad/tmp/test/nvim/site/pack/packer/start/cmp-emoji",
    url = "https://github.com/hrsh7th/cmp-emoji"
  },
  ["cmp-nvim-lsp"] = {
    loaded = true,
    path = "/Users/hjdivad/tmp/test/nvim/site/pack/packer/start/cmp-nvim-lsp",
    url = "https://github.com/hrsh7th/cmp-nvim-lsp"
  },
  ["cmp-nvim-lsp-document-symbol"] = {
    loaded = true,
    path = "/Users/hjdivad/tmp/test/nvim/site/pack/packer/start/cmp-nvim-lsp-document-symbol",
    url = "https://github.com/hrsh7th/cmp-nvim-lsp-document-symbol"
  },
  ["cmp-nvim-lsp-signature-help"] = {
    loaded = true,
    path = "/Users/hjdivad/tmp/test/nvim/site/pack/packer/start/cmp-nvim-lsp-signature-help",
    url = "https://github.com/hrsh7th/cmp-nvim-lsp-signature-help"
  },
  ["cmp-nvim-lua"] = {
    loaded = true,
    path = "/Users/hjdivad/tmp/test/nvim/site/pack/packer/start/cmp-nvim-lua",
    url = "https://github.com/hrsh7th/cmp-nvim-lua"
  },
  ["cmp-nvim-ultisnips"] = {
    loaded = true,
    path = "/Users/hjdivad/tmp/test/nvim/site/pack/packer/start/cmp-nvim-ultisnips",
    url = "https://github.com/quangnguyen30192/cmp-nvim-ultisnips"
  },
  ["cmp-nvim-wikilinks"] = {
    loaded = true,
    path = "/Users/hjdivad/tmp/test/nvim/site/pack/packer/start/cmp-nvim-wikilinks",
    url = "https://github.com/hjdivad/cmp-nvim-wikilinks"
  },
  ["cmp-path"] = {
    loaded = true,
    path = "/Users/hjdivad/tmp/test/nvim/site/pack/packer/start/cmp-path",
    url = "https://github.com/hrsh7th/cmp-path"
  },
  ["common.nvim"] = {
    config = { "\27LJ\2\n;\0\0\3\0\3\0\a6\0\0\0'\2\1\0B\0\2\0029\0\2\0004\2\0\0B\0\2\1K\0\1\0\nsetup\14malleatus\frequire\0" },
    loaded = true,
    path = "/Users/hjdivad/tmp/test/nvim/site/pack/packer/start/common.nvim",
    url = "https://github.com/malleatus/common.nvim"
  },
  ["editorconfig-vim"] = {
    loaded = true,
    path = "/Users/hjdivad/tmp/test/nvim/site/pack/packer/start/editorconfig-vim",
    url = "https://github.com/editorconfig/editorconfig-vim"
  },
  fd = {
    loaded = true,
    path = "/Users/hjdivad/tmp/test/nvim/site/pack/packer/start/fd",
    url = "https://github.com/sharkdp/fd"
  },
  ["json5.vim"] = {
    loaded = true,
    path = "/Users/hjdivad/tmp/test/nvim/site/pack/packer/start/json5.vim",
    url = "https://github.com/gutenye/json5.vim"
  },
  ["lsp-colors.nvim"] = {
    loaded = true,
    path = "/Users/hjdivad/tmp/test/nvim/site/pack/packer/start/lsp-colors.nvim",
    url = "https://github.com/folke/lsp-colors.nvim"
  },
  ["lspsaga.nvim"] = {
    config = { "\27LJ\2\nÎ\1\0\0\4\0\n\0\r6\0\0\0'\2\1\0B\0\2\0029\0\2\0005\2\4\0005\3\3\0=\3\5\0025\3\6\0=\3\a\0025\3\b\0=\3\t\2B\0\2\1K\0\1\0\21code_action_keys\1\0\2\tquit\n<C-c>\texec\t<cr>\23finder_action_keys\1\0\2\topen\t<cr>\tquit\n<C-c>\17move_in_saga\1\0\0\1\0\2\tprev\6k\tnext\6j\18init_lsp_saga\flspsaga\frequire\0" },
    loaded = true,
    path = "/Users/hjdivad/tmp/test/nvim/site/pack/packer/start/lspsaga.nvim",
    url = "https://github.com/glepnir/lspsaga.nvim"
  },
  ["markdown-preview.nvim"] = {
    loaded = true,
    path = "/Users/hjdivad/tmp/test/nvim/site/pack/packer/start/markdown-preview.nvim",
    url = "https://github.com/iamcco/markdown-preview.nvim"
  },
  neoterm = {
    config = { "\27LJ\2\nO\0\0\3\0\4\0\a6\0\0\0'\2\1\0B\0\2\0029\0\2\0005\2\3\0B\0\2\1K\0\1\0\1\0\1\rmappings\2\nsetup\21hjdivad/terminal\frequire\0" },
    loaded = true,
    path = "/Users/hjdivad/tmp/test/nvim/site/pack/packer/start/neoterm",
    url = "https://github.com/kassio/neoterm"
  },
  ["nvim-cmp"] = {
    config = { "\27LJ\2\n:\0\1\4\0\4\0\0066\1\0\0009\1\1\0019\1\2\0019\3\3\0B\1\2\1K\0\1\0\tbody\19UltiSnips#Anon\afn\bvimL\0\0\3\1\3\0\n-\0\0\0009\0\0\0B\0\1\2\15\0\0\0X\1\4€-\0\0\0009\0\1\0005\2\2\0B\0\2\1K\0\1\0\0À\1\0\1\vselect\2\fconfirm\fvisible†\6\1\0\n\0,\0\\6\0\0\0'\2\1\0B\0\2\0026\1\0\0'\3\2\0B\1\2\0029\1\3\0014\3\0\0B\1\2\0019\1\3\0005\3\a\0005\4\5\0003\5\4\0=\5\6\4=\4\b\0035\4\f\0009\5\t\0009\5\n\0055\a\v\0B\5\2\2=\5\r\0049\5\t\0009\5\14\5B\5\1\2=\5\15\0049\5\t\0009\5\16\5B\5\1\2=\5\17\0049\5\t\0009\5\18\5B\5\1\2=\5\19\4=\4\t\0035\4\23\0009\5\20\0009\5\21\0059\5\22\5B\5\1\2=\5\24\0049\5\20\0009\5\21\0059\5\22\5B\5\1\2=\5\25\4=\4\21\0039\4\20\0009\4\26\0044\6\b\0005\a\27\0>\a\1\0065\a\28\0>\a\2\0065\a\29\0>\a\3\0065\a\30\0>\a\4\0065\a\31\0>\a\5\0065\a \0>\a\6\0065\a!\0>\a\a\6B\4\2\2=\4\26\3B\1\2\0019\1\3\0009\1\"\1'\3#\0005\4)\0009\5\t\0009\5$\0059\5\"\0055\a(\0005\b&\0003\t%\0=\t'\b=\b\r\aB\5\2\2=\5\t\0049\5\20\0009\5\26\0054\a\3\0005\b*\0>\b\1\a5\b+\0>\b\2\aB\5\2\2=\5\26\4B\1\3\0012\0\0€K\0\1\0\1\0\1\tname\tpath\1\0\1\tname\fcmdline\1\0\0\1\0\0\6c\1\0\0\0\vpreset\6:\fcmdline\1\0\1\tname\nemoji\1\0\1\tname\14wikilinks\1\0\1\tname\tpath\1\0\1\tname\rnvim_lua\1\0\1\tname\28nvim_lsp_signature_help\1\0\1\tname\rnvim_lsp\1\0\1\tname\14ultisnips\fsources\18documentation\15completion\1\0\0\rbordered\vwindow\vconfig\n<c-p>\21select_prev_item\n<c-n>\21select_next_item\n<c-c>\nabort\n<c-l>\1\0\0\1\0\1\vselect\2\fconfirm\fmapping\fsnippet\1\0\0\vexpand\1\0\0\0\nsetup\23cmp_nvim_wikilinks\bcmp\frequire\0" },
    loaded = true,
    path = "/Users/hjdivad/tmp/test/nvim/site/pack/packer/start/nvim-cmp",
    url = "https://github.com/hrsh7th/nvim-cmp"
  },
  ["nvim-lspconfig"] = {
    config = { "\27LJ\2\nJ\0\0\3\0\3\0\a6\0\0\0'\2\1\0B\0\2\2\18\2\0\0009\0\2\0B\0\2\1K\0\1\0\21render_hover_doc\18lspsaga.hover\frequireP\0\0\3\0\3\0\a6\0\0\0'\2\1\0B\0\2\2\18\2\0\0009\0\2\0B\0\2\1K\0\1\0\19signature_help\26lspsaga.signaturehelp\frequireE\0\0\3\0\3\0\a6\0\0\0'\2\1\0B\0\2\2\18\2\0\0009\0\2\0B\0\2\1K\0\1\0\15lsp_finder\19lspsaga.finder\frequireI\0\0\3\0\3\0\0066\0\0\0'\2\1\0B\0\2\0029\0\2\0B\0\1\1K\0\1\0\20lsp_definitions\22telescope.builtin\frequireN\0\0\3\0\3\0\0066\0\0\0'\2\1\0B\0\2\0029\0\2\0B\0\1\1K\0\1\0\25lsp_type_definitions\22telescope.builtin\frequireM\0\0\3\0\3\0\0066\0\0\0'\2\1\0B\0\2\0029\0\2\0B\0\1\1K\0\1\0\24lsp_implementations\22telescope.builtin\frequireH\0\0\3\0\3\0\0066\0\0\0'\2\1\0B\0\2\0029\0\2\0B\0\1\1K\0\1\0\19lsp_references\22telescope.builtin\frequire(\0\0\3\0\3\0\0056\0\0\0009\0\1\0'\2\2\0B\0\2\1K\0\1\0\tcope\bcmd\bvimN\0\0\3\0\3\0\0066\0\0\0'\2\1\0B\0\2\0029\0\2\0B\0\1\1K\0\1\0\25lsp_document_symbols\22telescope.builtin\frequireW\0\0\3\0\3\0\0066\0\0\0'\2\1\0B\0\2\0029\0\2\0B\0\1\1K\0\1\0\"lsp_dynamic_workspace_symbols\22telescope.builtin\frequireW\0\0\3\0\3\0\0066\0\0\0'\2\1\0B\0\2\0029\0\2\0B\0\1\1K\0\1\0\"lsp_dynamic_workspace_symbols\22telescope.builtin\frequirer\0\0\4\0\6\0\t6\0\0\0'\2\1\0B\0\2\0029\0\2\0005\2\4\0005\3\3\0=\3\5\2B\0\2\1K\0\1\0\fsymbols\1\0\0\1\2\0\0\rfunction\25lsp_document_symbols\22telescope.builtin\frequireQ\0\0\3\0\3\0\a6\0\0\0'\2\1\0B\0\2\2\18\2\0\0009\0\2\0B\0\2\1K\0\1\0\23preview_definition\23lspsaga.definition\frequireJ\0\0\3\0\3\0\a6\0\0\0'\2\1\0B\0\2\2\18\2\0\0009\0\2\0B\0\2\1K\0\1\0\16code_action\23lspsaga.codeaction\frequire±\1\0\0\b\0\t\0\0196\0\0\0009\0\1\0009\0\2\0006\2\0\0009\2\3\0029\2\4\2'\4\5\0+\5\2\0+\6\1\0+\a\2\0B\2\5\0A\0\0\0016\0\6\0'\2\a\0B\0\2\2\18\2\0\0009\0\b\0B\0\2\1K\0\1\0\22range_code_action\23lspsaga.codeaction\frequire\n<C-U>\27nvim_replace_termcodes\bapi\rfeedkeys\afn\bvimE\0\0\3\0\3\0\a6\0\0\0'\2\1\0B\0\2\2\18\2\0\0009\0\2\0B\0\2\1K\0\1\0\15lsp_rename\19lspsaga.rename\frequire?\0\0\2\0\4\0\0066\0\0\0009\0\1\0009\0\2\0009\0\3\0B\0\1\1K\0\1\0\24formatting_seq_sync\bbuf\blsp\bvimP\0\0\3\0\3\0\a6\0\0\0'\2\1\0B\0\2\2\18\2\0\0009\0\2\0B\0\2\1K\0\1\0\19signature_help\26lspsaga.signaturehelp\frequireª\2\0\0\b\0\14\0*6\0\0\0009\0\1\0009\0\2\0)\2\0\0'\3\3\0B\0\3\0026\1\0\0009\1\1\0019\1\2\1)\3\0\0'\4\4\0B\1\3\0026\2\0\0009\2\5\2'\4\6\0\18\5\0\0\18\6\1\0B\2\4\0016\2\0\0009\2\a\0029\2\b\0029\2\t\0024\4\0\0\18\5\0\0\18\6\1\0B\2\4\0016\2\0\0009\2\1\0029\2\n\2'\4\v\0+\5\2\0+\6\1\0+\a\2\0B\2\5\0026\3\0\0009\3\1\0039\3\f\3\18\5\2\0'\6\r\0+\a\1\0B\3\4\1K\0\1\0\6n\18nvim_feedkeys\n<esc>\27nvim_replace_termcodes\21range_formatting\bbuf\blsp\14range fmt\17pretty_print\6>\6<\22nvim_buf_get_mark\bapi\bvimì\r\1\0\6\0G\0·\0016\0\0\0009\0\1\0009\0\2\0'\2\3\0'\3\4\0003\4\5\0005\5\6\0B\0\5\0016\0\0\0009\0\1\0009\0\2\0'\2\3\0'\3\a\0003\4\b\0005\5\t\0B\0\5\0016\0\0\0009\0\1\0009\0\2\0'\2\3\0'\3\n\0003\4\v\0005\5\f\0B\0\5\0016\0\0\0009\0\1\0009\0\2\0'\2\3\0'\3\r\0003\4\14\0005\5\15\0B\0\5\0016\0\0\0009\0\1\0009\0\2\0'\2\3\0'\3\16\0003\4\17\0005\5\18\0B\0\5\0016\0\0\0009\0\1\0009\0\2\0'\2\3\0'\3\19\0003\4\20\0005\5\21\0B\0\5\0016\0\0\0009\0\1\0009\0\2\0'\2\3\0'\3\22\0003\4\23\0005\5\24\0B\0\5\0016\0\0\0009\0\1\0009\0\2\0'\2\3\0'\3\25\0003\4\26\0005\5\27\0B\0\5\0016\0\0\0009\0\1\0009\0\2\0'\2\3\0'\3\28\0006\4\0\0009\4\29\0049\4\30\0049\4\31\0045\5 \0B\0\5\0016\0\0\0009\0\1\0009\0\2\0'\2\3\0'\3!\0006\4\0\0009\4\29\0049\4\30\0049\4\"\0045\5#\0B\0\5\0016\0\0\0009\0\1\0009\0\2\0'\2\3\0'\3$\0003\4%\0005\5&\0B\0\5\0016\0\0\0009\0\1\0009\0\2\0'\2\3\0'\3'\0003\4(\0005\5)\0B\0\5\0016\0\0\0009\0\1\0009\0\2\0'\2\3\0'\3*\0003\4+\0005\5,\0B\0\5\0016\0\0\0009\0\1\0009\0\2\0'\2\3\0'\3-\0003\4.\0005\5/\0B\0\5\0016\0\0\0009\0\1\0009\0\2\0'\2\3\0'\0030\0'\0041\0005\0052\0B\0\5\0016\0\0\0009\0\1\0009\0\2\0'\2\3\0'\0033\0003\0044\0005\0055\0B\0\5\0016\0\0\0009\0\1\0009\0\2\0'\2\3\0'\0036\0003\0047\0005\0058\0B\0\5\0016\0\0\0009\0\1\0009\0\2\0'\0029\0'\0036\0003\4:\0005\5;\0B\0\5\0016\0\0\0009\0\1\0009\0\2\0'\2\3\0'\3<\0003\4=\0005\5>\0B\0\5\0016\0\0\0009\0\1\0009\0\2\0'\2\3\0'\3?\0003\4@\0005\5A\0B\0\5\0016\0\0\0009\0\1\0009\0\2\0'\2B\0'\3\a\0003\4C\0005\5D\0B\0\5\0016\0\0\0009\0\1\0009\0\2\0'\0029\0'\3?\0003\4E\0005\5F\0B\0\5\1K\0\1\0\1\0\1\tdesc\26Format selected range\0\1\0\1\tdesc\24show signature help\0\6i\1\0\1\tdesc\18format buffer\0\15<leader>rf\1\0\1\tdesc\31rename symbol under cursor\0\15<leader>rn\1\0\1\tdesc\31list code actions in range\0\6v\1\0\1\tdesc#list code actions under cursor\0\15<leader>ca\1\0\1\tdesc\28show definition preview\0\15<leader>sd\1\0\1\tdesc\17show outline\29<cmd>LSoutlineToggle<cr>\15<leader>so\1\0\1\tdesc\19show functions\0\15<leader>sf\1\0\1\tdesc\27show workspace symbols\0\15<leader>SS\1\0\1\tdesc\27show workspace symbols\0\15<leader>sS\1\0\1\tdesc\26show document symbols\0\15<leader>ss\1\0\1\tdesc-go to calls (outbound) -- who do i call?\19outgoing_calls\16<leader>gco\1\0\1\tdesc+go to calls (inbound) -- who calls me?\19incoming_calls\bbuf\blsp\16<leader>gci\1\0\1\tdesc\30go to linting diagnostics\0\15<leader>gl\1\0\1\tdesc\21go to references\0\15<leader>gr\1\0\1\tdesc\26go to implementations\0\15<leader>gi\1\0\1\tdesc\26go to type definition\0\15<leader>gD\1\0\1\tdesc\21go to definition\0\15<leader>gd\1\0\1\tdesc8go go go (to something, defintion, references, &c.)\0\15<leader>gg\1\0\1\tdesc\28Show LSP signature help\0\n<c-h>\1\0\1\tdesc'Show LSP hover (fn docs, help &c.)\0\6K\6n\bset\vkeymap\bvim¯\1\0\0\5\1\a\0\17-\0\0\0B\0\1\0016\0\0\0009\0\1\0009\0\2\0)\2\0\0'\3\3\0'\4\4\0B\0\4\0016\0\0\0009\0\1\0009\0\2\0)\2\0\0'\3\5\0'\4\6\0B\0\4\1K\0\1\0\0À\31v:lua.vim.lsp.formatexpr()\15formatexpr\27v:lua.vim.lsp.omnifunc\romnifunc\24nvim_buf_set_option\bapi\bvimî\15\1\0\15\0b\0¸\1X\0\0€X\0\26€6\0\0\0006\1\2\0'\3\3\0B\1\2\2=\1\1\0006\0\0\0006\1\2\0'\3\5\0B\1\2\2=\1\4\0006\0\0\0006\1\2\0'\3\a\0B\1\2\2=\1\6\0006\0\0\0009\0\4\0006\1\0\0009\1\4\0019\1\b\1\14\0\1\0X\2\3€6\1\2\0'\3\t\0B\1\2\2=\1\b\0003\0\n\0003\1\v\0006\2\2\0'\4\f\0B\2\2\0029\2\r\2B\2\1\0026\3\2\0'\5\14\0B\3\2\0026\4\0\0009\4\15\0046\6\16\0009\6\17\6'\a\18\0B\4\3\0026\5\19\0009\5\20\5\18\a\4\0'\b\21\0B\5\3\0016\5\19\0009\5\20\5\18\a\4\0'\b\22\0B\5\3\0019\5\23\0039\5\24\0055\a\25\0=\2\26\a5\b\27\0=\b\28\a5\b,\0005\t\30\0005\n\29\0=\4\17\n=\n\31\t5\n!\0005\v \0=\v\"\n=\n#\t5\n'\0006\v\0\0009\v$\v9\v%\v'\r&\0+\14\2\0B\v\3\2=\v(\n=\n)\t5\n*\0=\n+\t=\t-\b=\b.\a=\1/\aB\5\2\0019\0050\0039\5\24\0055\a1\0=\2\26\a=\1/\aB\5\2\0019\0052\0039\5\24\0055\a3\0=\2\26\a=\1/\aB\5\2\0019\0054\0039\5\24\0055\a5\0=\2\26\a=\1/\aB\5\2\0019\0056\0039\5\24\0055\a7\0=\2\26\a=\1/\aB\5\2\0019\0058\0039\5\24\0055\a9\0=\2\26\a=\1/\aB\5\2\0019\5:\0039\5\24\0055\a;\0=\2\26\a=\1/\aB\5\2\0019\5<\0039\5\24\0055\a=\0=\2\26\a=\1/\aB\5\2\0019\5>\0039\5\24\0055\a?\0=\2\26\a=\1/\a5\b@\0=\bA\aB\5\2\0019\5B\0039\5\24\0055\aC\0=\2\26\a=\1/\aB\5\2\0019\5D\0039\5\24\0055\aE\0=\2\26\a=\1/\aB\5\2\0019\5F\0039\5\24\0055\aG\0=\2\26\a=\1/\aB\5\2\0015\5Q\0005\6H\0005\aI\0=\aJ\0065\aK\0=\aL\0065\aM\0=\aN\0065\aO\0=\aP\6=\6R\0055\6U\0005\aS\0005\bT\0=\bJ\a=\aV\0069\aW\0039\a\24\a5\tY\0005\nX\0=\nZ\t5\n[\0=\5\\\n5\v]\0=\vZ\n=\6^\n5\v_\0=\v`\n=\na\tB\a\2\0012\0\0€K\0\1\0\17init_options\20formatFiletypes\1\0\4\15javascript\rprettier\15typescript\rprettier\fgraphql\rprettier\rmarkdown\rprettier\15formatters\1\0\2\15javascript\veslint\15typescript\veslint\flinters\1\0\0\14filetypes\1\0\0\1\5\0\0\15typescript\15javascript\rmarkdown\fgraphql\17diagnosticls\rprettier\1\0\0\1\3\0\0\21--stdin-filepath\14%filepath\1\0\1\fcommand\rprettier\veslint\1\0\0\17rootPatterns\1\a\0\0\14.eslintrc\18.eslintrc.cjs\17.eslintrc.js\19.eslintrc.json\19.eslintrc.yaml\18.eslintrc.yml\15securities\1\0\2\4\0€€€€\4\nerror\4\0€€Àÿ\3\fwarning\14parseJson\1\0\a\fmessage\27${message} [${ruleId}]\15errorsRoot\17[0].messages\14endColumn\14endColumn\fendLine\fendLine\vcolumn\vcolumn\rsecurity\rseverity\tline\tline\targs\1\6\0\0\f--stdin\21--stdin-filename\14%filepath\r--format\tjson\1\0\3\rdebounce\3d\fcommand\veslint\15sourceName\veslint\1\0\0\npylsp\1\0\0\tccls\1\0\0\vbashls\fschemas\1\0\0016https://json.schemastore.org/github-workflow.json\25/.github/workflows/*\1\0\0\vyamlls\1\0\0\ncssls\1\0\0\thtml\1\0\0\fgraphql\1\0\0\vjsonls\1\0\0\nvimls\1\0\0\18rust_analyzer\1\0\0\rtsserver\14on_attach\rsettings\bLua\1\0\0\14telemetry\1\0\1\venable\1\14workspace\flibrary\1\0\0\5\26nvim_get_runtime_file\bapi\16diagnostics\fglobals\1\0\0\1\2\0\0\bvim\fruntime\1\0\0\1\0\1\fversion\vLuaJIT\bcmd\1\2\0\0\24lua-language-server\17capabilities\1\0\0\nsetup\16sumneko_lua\19lua/?/init.lua\14lua/?.lua\vinsert\ntable\6;\tpath\fpackage\nsplit\14lspconfig\25default_capabilities\17cmp_nvim_lsp\0\0\16vim.lsp.buf\bbuf\vvim.fn\afn\fvim.lsp\blsp\15vim.keymap\frequire\vkeymap\bvim\0" },
    loaded = true,
    path = "/Users/hjdivad/tmp/test/nvim/site/pack/packer/start/nvim-lspconfig",
    url = "https://github.com/neovim/nvim-lspconfig"
  },
  ["nvim-nonicons"] = {
    config = { "\27LJ\2\nB\0\0\4\0\4\0\a6\0\0\0'\2\1\0B\0\2\0029\1\2\0'\3\3\0B\1\2\1K\0\1\0\tfile\bget\18nvim-nonicons\frequire\0" },
    loaded = true,
    path = "/Users/hjdivad/tmp/test/nvim/site/pack/packer/start/nvim-nonicons",
    url = "https://github.com/yamatsum/nvim-nonicons"
  },
  ["nvim-tree.lua"] = {
    config = { "\27LJ\2\n~\0\1\6\0\6\0\v6\1\0\0'\3\1\0B\1\2\0029\1\2\0015\3\3\0004\4\3\0009\5\4\0>\5\1\4=\4\5\3B\1\2\1K\0\1\0\16search_dirs\18absolute_path\1\0\1\vsearch\5\16grep_string\22telescope.builtin\frequireÐ\14\1\0\b\0C\0q6\0\0\0'\2\1\0B\0\2\0029\0\2\0005\0025\0005\0033\0005\4\3\0004\5)\0005\6\5\0005\a\4\0=\a\6\6>\6\1\0055\6\a\0>\6\2\0055\6\t\0005\a\b\0=\a\6\6>\6\3\0055\6\v\0005\a\n\0=\a\6\6>\6\4\0055\6\f\0>\6\5\0055\6\r\0>\6\6\0055\6\14\0>\6\a\0055\6\15\0>\6\b\0055\6\16\0>\6\t\0055\6\17\0>\6\n\0055\6\18\0>\6\v\0055\6\19\0>\6\f\0055\6\20\0>\6\r\0055\6\21\0>\6\14\0055\6\22\0>\6\15\0055\6\23\0>\6\16\0055\6\24\0>\6\17\0055\6\25\0>\6\18\0055\6\26\0>\6\19\0055\6\27\0>\6\20\0055\6\28\0>\6\21\0055\6\29\0>\6\22\0055\6\30\0>\6\23\0055\6\31\0>\6\24\0055\6 \0>\6\25\0055\6!\0>\6\26\0055\6\"\0>\6\27\0055\6#\0>\6\28\0055\6$\0>\6\29\0055\6%\0>\6\30\0055\6&\0>\6\31\0055\6'\0>\6 \0055\6(\0>\6!\0055\6)\0>\6\"\0055\6*\0>\6#\0055\6+\0>\6$\0055\6,\0>\6%\0055\6-\0>\6&\0055\6.\0>\6'\0055\6/\0003\a0\0=\a1\6>\6(\5=\0052\4=\0044\3=\0036\0025\0037\0=\0038\0025\0039\0=\3:\0025\3;\0=\3<\0025\3@\0005\4=\0005\5>\0=\5?\4=\4A\3=\3B\2B\0\2\1K\0\1\0\factions\14open_file\1\0\0\18window_picker\1\0\1\venable\1\1\0\1\17quit_on_open\2\24update_focused_file\1\0\2\venable\2\15update_cwd\1\16diagnostics\1\0\2\venable\2\17show_on_dirs\2\rrenderer\1\0\2\27highlight_opened_files\ball\16group_empty\2\tview\1\0\0\rmappings\1\0\0\tlist\14action_cb\0\1\0\2\vaction\5\bkey\15<leader>fr\1\0\2\bkey\6U\vaction\18toggle_custom\1\0\2\bkey\n<C-k>\vaction\21toggle_file_info\1\0\2\bkey\6.\vaction\21run_file_command\1\0\2\bkey\6S\vaction\16search_node\1\0\2\bkey\6W\vaction\17collapse_all\1\0\2\bkey\ag?\vaction\16toggle_help\1\0\2\bkey\6q\vaction\nclose\1\0\2\bkey\6s\vaction\16system_open\1\0\2\bkey\6-\vaction\vdir_up\1\0\2\bkey\a]c\vaction\18next_git_item\1\0\2\bkey\a[c\vaction\18prev_git_item\1\0\2\bkey\agy\vaction\23copy_absolute_path\1\0\2\bkey\6Y\vaction\14copy_path\1\0\2\bkey\6y\vaction\14copy_name\1\0\2\bkey\6p\vaction\npaste\1\0\2\bkey\6c\vaction\tcopy\1\0\2\bkey\6x\vaction\bcut\1\0\2\bkey\n<C-r>\vaction\16full_rename\1\0\2\bkey\6r\vaction\vrename\1\0\2\bkey\6D\vaction\ntrash\1\0\2\bkey\6d\vaction\vremove\1\0\2\bkey\6a\vaction\vcreate\1\0\2\bkey\6R\vaction\frefresh\1\0\2\bkey\6H\vaction\20toggle_dotfiles\1\0\2\bkey\6I\vaction\23toggle_git_ignored\1\0\2\bkey\6J\vaction\17last_sibling\1\0\2\bkey\6K\vaction\18first_sibling\1\0\2\bkey\n<Tab>\vaction\fpreview\1\0\2\bkey\t<BS>\vaction\15close_node\1\0\2\bkey\6P\vaction\16parent_node\1\0\2\bkey\6>\vaction\17next_sibling\1\0\2\bkey\6<\vaction\17prev_sibling\1\0\2\bkey\n<C-t>\vaction\vtabnew\1\0\2\bkey\n<C-x>\vaction\nsplit\1\0\2\bkey\n<C-v>\vaction\vvsplit\1\0\1\vaction\acd\1\3\0\0\19<2-RightMouse>\n<C-]>\1\0\1\vaction\19edit_no_picker\1\2\0\0\6O\1\0\2\bkey\n<C-e>\vaction\18edit_in_place\bkey\1\0\1\vaction\tedit\1\4\0\0\t<CR>\6o\18<2-LeftMouse>\1\0\1\16custom_only\2\nsetup\14nvim-tree\frequire\0" },
    loaded = true,
    path = "/Users/hjdivad/tmp/test/nvim/site/pack/packer/start/nvim-tree.lua",
    url = "https://github.com/kyazdani42/nvim-tree.lua"
  },
  ["nvim-treesitter"] = {
    config = { "\27LJ\2\n­\1\0\0\5\1\n\0\16-\0\0\0\14\0\0\0X\0\f€6\0\0\0'\2\1\0B\0\2\0029\0\2\0005\2\6\0005\3\3\0005\4\4\0=\4\5\3=\3\a\0025\3\b\0=\3\t\2B\0\2\1K\0\1\0\0\0\vindent\1\0\1\venable\2\14highlight\1\0\0\fdisable\1\3\0\0\blua\bvim\1\0\1\venable\2\nsetup\28nvim-treesitter.configs\frequire\0" },
    loaded = true,
    path = "/Users/hjdivad/tmp/test/nvim/site/pack/packer/start/nvim-treesitter",
    url = "https://github.com/nvim-treesitter/nvim-treesitter"
  },
  ["nvim-treesitter-textobjects"] = {
    loaded = true,
    path = "/Users/hjdivad/tmp/test/nvim/site/pack/packer/start/nvim-treesitter-textobjects",
    url = "https://github.com/nvim-treesitter/nvim-treesitter-textobjects"
  },
  ["nvim-web-devicons"] = {
    loaded = true,
    path = "/Users/hjdivad/tmp/test/nvim/site/pack/packer/start/nvim-web-devicons",
    url = "https://github.com/kyazdani42/nvim-web-devicons"
  },
  ["onedark.vim"] = {
    loaded = true,
    path = "/Users/hjdivad/tmp/test/nvim/site/pack/packer/start/onedark.vim",
    url = "https://github.com/joshdick/onedark.vim"
  },
  ["packer.nvim"] = {
    loaded = true,
    path = "/Users/hjdivad/tmp/test/nvim/site/pack/packer/start/packer.nvim",
    url = "https://github.com/wbthomason/packer.nvim"
  },
  playground = {
    loaded = true,
    path = "/Users/hjdivad/tmp/test/nvim/site/pack/packer/start/playground",
    url = "https://github.com/nvim-treesitter/playground"
  },
  ["plenary.nvim"] = {
    loaded = true,
    path = "/Users/hjdivad/tmp/test/nvim/site/pack/packer/start/plenary.nvim",
    url = "https://github.com/nvim-lua/plenary.nvim"
  },
  ["popup.nvim"] = {
    loaded = true,
    path = "/Users/hjdivad/tmp/test/nvim/site/pack/packer/start/popup.nvim",
    url = "https://github.com/nvim-lua/popup.nvim"
  },
  tabular = {
    loaded = true,
    path = "/Users/hjdivad/tmp/test/nvim/site/pack/packer/start/tabular",
    url = "https://github.com/godlygeek/tabular"
  },
  ["telescope-fzf-native.nvim"] = {
    loaded = true,
    path = "/Users/hjdivad/tmp/test/nvim/site/pack/packer/start/telescope-fzf-native.nvim",
    url = "https://github.com/nvim-telescope/telescope-fzf-native.nvim"
  },
  ["telescope-tmux.nvim"] = {
    loaded = true,
    path = "/Users/hjdivad/tmp/test/nvim/site/pack/packer/start/telescope-tmux.nvim",
    url = "https://github.com/camgraff/telescope-tmux.nvim"
  },
  ["telescope-ui-select.nvim"] = {
    loaded = true,
    path = "/Users/hjdivad/tmp/test/nvim/site/pack/packer/start/telescope-ui-select.nvim",
    url = "https://github.com/nvim-telescope/telescope-ui-select.nvim"
  },
  ["telescope.nvim"] = {
    config = { "\27LJ\2\nÌ\2\0\0\t\0\17\1\0306\0\0\0'\2\1\0B\0\2\0029\1\2\0005\3\b\0005\4\6\0005\5\4\0005\6\3\0=\6\5\5=\5\a\4=\4\t\0035\4\f\0004\5\3\0006\6\0\0'\b\n\0B\6\2\0029\6\v\0064\b\0\0B\6\2\0?\6\0\0=\5\r\4=\4\14\3B\1\2\0019\1\15\0'\3\16\0B\1\2\0019\1\15\0'\3\r\0B\1\2\1K\0\1\0\bfzf\19load_extension\15extensions\14ui-select\1\0\0\15get_cursor\21telescope.themes\rdefaults\1\0\0\rmappings\1\0\0\6i\1\0\0\1\0\3\n<C-j>\24move_selection_next\n<C-h>\14which_key\n<C-k>\28move_selection_previous\nsetup\14telescope\frequire\3€€À™\4\0" },
    loaded = true,
    path = "/Users/hjdivad/tmp/test/nvim/site/pack/packer/start/telescope.nvim",
    url = "https://github.com/nvim-telescope/telescope.nvim"
  },
  terminus = {
    loaded = true,
    path = "/Users/hjdivad/tmp/test/nvim/site/pack/packer/start/terminus",
    url = "https://github.com/wincent/terminus"
  },
  ultisnips = {
    config = { "\27LJ\2\nv\0\0\2\0\6\0\t6\0\0\0009\0\1\0'\1\3\0=\1\2\0006\0\0\0009\0\1\0'\1\5\0=\1\4\0K\0\1\0\n<c-j>!UltiSnipsJumpBackwardTrigger\n<c-k> UltiSnipsJumpForwardTrigger\6g\bvim\0" },
    loaded = true,
    path = "/Users/hjdivad/tmp/test/nvim/site/pack/packer/start/ultisnips",
    url = "https://github.com/SirVer/ultisnips"
  },
  ["vim-airline"] = {
    config = { "\27LJ\2\nÖ\1\0\0\2\0\a\0\r6\0\0\0009\0\1\0)\1\2\0=\1\2\0006\0\0\0009\0\3\0)\1\1\0=\1\4\0006\0\0\0009\0\3\0005\1\6\0=\1\5\0K\0\1\0\1\f\0\0\vbranch\17fugitiveline\nhunks\vkeymap\nnetrw\fnvimlsp\apo\rquickfix\16searchcount\tterm\14wordcount\23airline_extensions\31airline_highlighting_cache\6g\15laststatus\6o\bvim\0" },
    loaded = true,
    path = "/Users/hjdivad/tmp/test/nvim/site/pack/packer/start/vim-airline",
    url = "https://github.com/vim-airline/vim-airline"
  },
  ["vim-airline-themes"] = {
    loaded = true,
    path = "/Users/hjdivad/tmp/test/nvim/site/pack/packer/start/vim-airline-themes",
    url = "https://github.com/vim-airline/vim-airline-themes"
  },
  ["vim-commentary"] = {
    loaded = true,
    path = "/Users/hjdivad/tmp/test/nvim/site/pack/packer/start/vim-commentary",
    url = "https://github.com/tpope/vim-commentary"
  },
  ["vim-fugitive"] = {
    loaded = true,
    path = "/Users/hjdivad/tmp/test/nvim/site/pack/packer/start/vim-fugitive",
    url = "https://github.com/tpope/vim-fugitive"
  },
  ["vim-git"] = {
    loaded = true,
    path = "/Users/hjdivad/tmp/test/nvim/site/pack/packer/start/vim-git",
    url = "https://github.com/tpope/vim-git"
  },
  ["vim-gitgutter"] = {
    config = { "\27LJ\2\nf\0\0\2\0\5\0\t6\0\0\0009\0\1\0'\1\3\0=\1\2\0006\0\0\0009\0\1\0)\1\0\0=\1\4\0K\0\1\0\23gitgutter_map_keys\18origin/master\24gitgutter_diff_base\6g\bvim\0" },
    loaded = true,
    path = "/Users/hjdivad/tmp/test/nvim/site/pack/packer/start/vim-gitgutter",
    url = "https://github.com/airblade/vim-gitgutter"
  },
  ["vim-graphql"] = {
    loaded = true,
    path = "/Users/hjdivad/tmp/test/nvim/site/pack/packer/start/vim-graphql",
    url = "https://github.com/jparise/vim-graphql"
  },
  ["vim-markdown"] = {
    config = { "\27LJ\2\nð\2\0\0\2\0\n\0\0296\0\0\0009\0\1\0005\1\3\0=\1\2\0006\0\0\0009\0\1\0)\1\1\0=\1\4\0006\0\0\0009\0\1\0)\1\1\0=\1\5\0006\0\0\0009\0\1\0)\1\1\0=\1\6\0006\0\0\0009\0\1\0)\1\1\0=\1\a\0006\0\0\0009\0\1\0)\1\0\0=\1\b\0006\0\0\0009\0\1\0)\1\0\0=\1\t\0K\0\1\0&vim_markdown_new_list_item_indent!markdown_auto_insert_bullets\31vim_markdown_strikethrough\29vim_markdown_frontmatter\31vim_markdown_follow_anchor+vim_markdown_no_extensions_in_markdown\1\3\0\0\18js=javascript\18ts=typescript\30markdown_fenced_languages\6g\bvim\0" },
    loaded = true,
    path = "/Users/hjdivad/tmp/test/nvim/site/pack/packer/start/vim-markdown",
    url = "https://github.com/preservim/vim-markdown"
  },
  ["vim-pdl"] = {
    loaded = true,
    path = "/Users/hjdivad/tmp/test/nvim/site/pack/packer/start/vim-pdl",
    url = "https://github.com/hjdivad/vim-pdl"
  },
  ["vim-repeat"] = {
    loaded = true,
    path = "/Users/hjdivad/tmp/test/nvim/site/pack/packer/start/vim-repeat",
    url = "https://github.com/tpope/vim-repeat"
  },
  ["vim-rhubarb"] = {
    loaded = true,
    path = "/Users/hjdivad/tmp/test/nvim/site/pack/packer/start/vim-rhubarb",
    url = "https://github.com/tpope/vim-rhubarb"
  },
  ["vim-sensible"] = {
    loaded = true,
    path = "/Users/hjdivad/tmp/test/nvim/site/pack/packer/start/vim-sensible",
    url = "https://github.com/tpope/vim-sensible"
  },
  ["vim-surround"] = {
    loaded = true,
    path = "/Users/hjdivad/tmp/test/nvim/site/pack/packer/start/vim-surround",
    url = "https://github.com/tpope/vim-surround"
  },
  ["vim-test"] = {
    config = { "\27LJ\2\nE\0\0\3\0\3\0\0066\0\0\0'\2\1\0B\0\2\0029\0\2\0B\0\1\1K\0\1\0\18setup_vimtest\20hjdivad/testing\frequire\0" },
    loaded = true,
    path = "/Users/hjdivad/tmp/test/nvim/site/pack/packer/start/vim-test",
    url = "https://github.com/vim-test/vim-test"
  },
  ["vim-unimpaired"] = {
    loaded = true,
    path = "/Users/hjdivad/tmp/test/nvim/site/pack/packer/start/vim-unimpaired",
    url = "https://github.com/tpope/vim-unimpaired"
  }
}

time([[Defining packer_plugins]], false)
-- Config for: vim-gitgutter
time([[Config for vim-gitgutter]], true)
try_loadstring("\27LJ\2\nf\0\0\2\0\5\0\t6\0\0\0009\0\1\0'\1\3\0=\1\2\0006\0\0\0009\0\1\0)\1\0\0=\1\4\0K\0\1\0\23gitgutter_map_keys\18origin/master\24gitgutter_diff_base\6g\bvim\0", "config", "vim-gitgutter")
time([[Config for vim-gitgutter]], false)
-- Config for: vim-markdown
time([[Config for vim-markdown]], true)
try_loadstring("\27LJ\2\nð\2\0\0\2\0\n\0\0296\0\0\0009\0\1\0005\1\3\0=\1\2\0006\0\0\0009\0\1\0)\1\1\0=\1\4\0006\0\0\0009\0\1\0)\1\1\0=\1\5\0006\0\0\0009\0\1\0)\1\1\0=\1\6\0006\0\0\0009\0\1\0)\1\1\0=\1\a\0006\0\0\0009\0\1\0)\1\0\0=\1\b\0006\0\0\0009\0\1\0)\1\0\0=\1\t\0K\0\1\0&vim_markdown_new_list_item_indent!markdown_auto_insert_bullets\31vim_markdown_strikethrough\29vim_markdown_frontmatter\31vim_markdown_follow_anchor+vim_markdown_no_extensions_in_markdown\1\3\0\0\18js=javascript\18ts=typescript\30markdown_fenced_languages\6g\bvim\0", "config", "vim-markdown")
time([[Config for vim-markdown]], false)
-- Config for: vim-test
time([[Config for vim-test]], true)
try_loadstring("\27LJ\2\nE\0\0\3\0\3\0\0066\0\0\0'\2\1\0B\0\2\0029\0\2\0B\0\1\1K\0\1\0\18setup_vimtest\20hjdivad/testing\frequire\0", "config", "vim-test")
time([[Config for vim-test]], false)
-- Config for: nvim-treesitter
time([[Config for nvim-treesitter]], true)
try_loadstring("\27LJ\2\n­\1\0\0\5\1\n\0\16-\0\0\0\14\0\0\0X\0\f€6\0\0\0'\2\1\0B\0\2\0029\0\2\0005\2\6\0005\3\3\0005\4\4\0=\4\5\3=\3\a\0025\3\b\0=\3\t\2B\0\2\1K\0\1\0\0\0\vindent\1\0\1\venable\2\14highlight\1\0\0\fdisable\1\3\0\0\blua\bvim\1\0\1\venable\2\nsetup\28nvim-treesitter.configs\frequire\0", "config", "nvim-treesitter")
time([[Config for nvim-treesitter]], false)
-- Config for: nvim-cmp
time([[Config for nvim-cmp]], true)
try_loadstring("\27LJ\2\n:\0\1\4\0\4\0\0066\1\0\0009\1\1\0019\1\2\0019\3\3\0B\1\2\1K\0\1\0\tbody\19UltiSnips#Anon\afn\bvimL\0\0\3\1\3\0\n-\0\0\0009\0\0\0B\0\1\2\15\0\0\0X\1\4€-\0\0\0009\0\1\0005\2\2\0B\0\2\1K\0\1\0\0À\1\0\1\vselect\2\fconfirm\fvisible†\6\1\0\n\0,\0\\6\0\0\0'\2\1\0B\0\2\0026\1\0\0'\3\2\0B\1\2\0029\1\3\0014\3\0\0B\1\2\0019\1\3\0005\3\a\0005\4\5\0003\5\4\0=\5\6\4=\4\b\0035\4\f\0009\5\t\0009\5\n\0055\a\v\0B\5\2\2=\5\r\0049\5\t\0009\5\14\5B\5\1\2=\5\15\0049\5\t\0009\5\16\5B\5\1\2=\5\17\0049\5\t\0009\5\18\5B\5\1\2=\5\19\4=\4\t\0035\4\23\0009\5\20\0009\5\21\0059\5\22\5B\5\1\2=\5\24\0049\5\20\0009\5\21\0059\5\22\5B\5\1\2=\5\25\4=\4\21\0039\4\20\0009\4\26\0044\6\b\0005\a\27\0>\a\1\0065\a\28\0>\a\2\0065\a\29\0>\a\3\0065\a\30\0>\a\4\0065\a\31\0>\a\5\0065\a \0>\a\6\0065\a!\0>\a\a\6B\4\2\2=\4\26\3B\1\2\0019\1\3\0009\1\"\1'\3#\0005\4)\0009\5\t\0009\5$\0059\5\"\0055\a(\0005\b&\0003\t%\0=\t'\b=\b\r\aB\5\2\2=\5\t\0049\5\20\0009\5\26\0054\a\3\0005\b*\0>\b\1\a5\b+\0>\b\2\aB\5\2\2=\5\26\4B\1\3\0012\0\0€K\0\1\0\1\0\1\tname\tpath\1\0\1\tname\fcmdline\1\0\0\1\0\0\6c\1\0\0\0\vpreset\6:\fcmdline\1\0\1\tname\nemoji\1\0\1\tname\14wikilinks\1\0\1\tname\tpath\1\0\1\tname\rnvim_lua\1\0\1\tname\28nvim_lsp_signature_help\1\0\1\tname\rnvim_lsp\1\0\1\tname\14ultisnips\fsources\18documentation\15completion\1\0\0\rbordered\vwindow\vconfig\n<c-p>\21select_prev_item\n<c-n>\21select_next_item\n<c-c>\nabort\n<c-l>\1\0\0\1\0\1\vselect\2\fconfirm\fmapping\fsnippet\1\0\0\vexpand\1\0\0\0\nsetup\23cmp_nvim_wikilinks\bcmp\frequire\0", "config", "nvim-cmp")
time([[Config for nvim-cmp]], false)
-- Config for: nvim-tree.lua
time([[Config for nvim-tree.lua]], true)
try_loadstring("\27LJ\2\n~\0\1\6\0\6\0\v6\1\0\0'\3\1\0B\1\2\0029\1\2\0015\3\3\0004\4\3\0009\5\4\0>\5\1\4=\4\5\3B\1\2\1K\0\1\0\16search_dirs\18absolute_path\1\0\1\vsearch\5\16grep_string\22telescope.builtin\frequireÐ\14\1\0\b\0C\0q6\0\0\0'\2\1\0B\0\2\0029\0\2\0005\0025\0005\0033\0005\4\3\0004\5)\0005\6\5\0005\a\4\0=\a\6\6>\6\1\0055\6\a\0>\6\2\0055\6\t\0005\a\b\0=\a\6\6>\6\3\0055\6\v\0005\a\n\0=\a\6\6>\6\4\0055\6\f\0>\6\5\0055\6\r\0>\6\6\0055\6\14\0>\6\a\0055\6\15\0>\6\b\0055\6\16\0>\6\t\0055\6\17\0>\6\n\0055\6\18\0>\6\v\0055\6\19\0>\6\f\0055\6\20\0>\6\r\0055\6\21\0>\6\14\0055\6\22\0>\6\15\0055\6\23\0>\6\16\0055\6\24\0>\6\17\0055\6\25\0>\6\18\0055\6\26\0>\6\19\0055\6\27\0>\6\20\0055\6\28\0>\6\21\0055\6\29\0>\6\22\0055\6\30\0>\6\23\0055\6\31\0>\6\24\0055\6 \0>\6\25\0055\6!\0>\6\26\0055\6\"\0>\6\27\0055\6#\0>\6\28\0055\6$\0>\6\29\0055\6%\0>\6\30\0055\6&\0>\6\31\0055\6'\0>\6 \0055\6(\0>\6!\0055\6)\0>\6\"\0055\6*\0>\6#\0055\6+\0>\6$\0055\6,\0>\6%\0055\6-\0>\6&\0055\6.\0>\6'\0055\6/\0003\a0\0=\a1\6>\6(\5=\0052\4=\0044\3=\0036\0025\0037\0=\0038\0025\0039\0=\3:\0025\3;\0=\3<\0025\3@\0005\4=\0005\5>\0=\5?\4=\4A\3=\3B\2B\0\2\1K\0\1\0\factions\14open_file\1\0\0\18window_picker\1\0\1\venable\1\1\0\1\17quit_on_open\2\24update_focused_file\1\0\2\venable\2\15update_cwd\1\16diagnostics\1\0\2\venable\2\17show_on_dirs\2\rrenderer\1\0\2\27highlight_opened_files\ball\16group_empty\2\tview\1\0\0\rmappings\1\0\0\tlist\14action_cb\0\1\0\2\vaction\5\bkey\15<leader>fr\1\0\2\bkey\6U\vaction\18toggle_custom\1\0\2\bkey\n<C-k>\vaction\21toggle_file_info\1\0\2\bkey\6.\vaction\21run_file_command\1\0\2\bkey\6S\vaction\16search_node\1\0\2\bkey\6W\vaction\17collapse_all\1\0\2\bkey\ag?\vaction\16toggle_help\1\0\2\bkey\6q\vaction\nclose\1\0\2\bkey\6s\vaction\16system_open\1\0\2\bkey\6-\vaction\vdir_up\1\0\2\bkey\a]c\vaction\18next_git_item\1\0\2\bkey\a[c\vaction\18prev_git_item\1\0\2\bkey\agy\vaction\23copy_absolute_path\1\0\2\bkey\6Y\vaction\14copy_path\1\0\2\bkey\6y\vaction\14copy_name\1\0\2\bkey\6p\vaction\npaste\1\0\2\bkey\6c\vaction\tcopy\1\0\2\bkey\6x\vaction\bcut\1\0\2\bkey\n<C-r>\vaction\16full_rename\1\0\2\bkey\6r\vaction\vrename\1\0\2\bkey\6D\vaction\ntrash\1\0\2\bkey\6d\vaction\vremove\1\0\2\bkey\6a\vaction\vcreate\1\0\2\bkey\6R\vaction\frefresh\1\0\2\bkey\6H\vaction\20toggle_dotfiles\1\0\2\bkey\6I\vaction\23toggle_git_ignored\1\0\2\bkey\6J\vaction\17last_sibling\1\0\2\bkey\6K\vaction\18first_sibling\1\0\2\bkey\n<Tab>\vaction\fpreview\1\0\2\bkey\t<BS>\vaction\15close_node\1\0\2\bkey\6P\vaction\16parent_node\1\0\2\bkey\6>\vaction\17next_sibling\1\0\2\bkey\6<\vaction\17prev_sibling\1\0\2\bkey\n<C-t>\vaction\vtabnew\1\0\2\bkey\n<C-x>\vaction\nsplit\1\0\2\bkey\n<C-v>\vaction\vvsplit\1\0\1\vaction\acd\1\3\0\0\19<2-RightMouse>\n<C-]>\1\0\1\vaction\19edit_no_picker\1\2\0\0\6O\1\0\2\bkey\n<C-e>\vaction\18edit_in_place\bkey\1\0\1\vaction\tedit\1\4\0\0\t<CR>\6o\18<2-LeftMouse>\1\0\1\16custom_only\2\nsetup\14nvim-tree\frequire\0", "config", "nvim-tree.lua")
time([[Config for nvim-tree.lua]], false)
-- Config for: nvim-lspconfig
time([[Config for nvim-lspconfig]], true)
try_loadstring("\27LJ\2\nJ\0\0\3\0\3\0\a6\0\0\0'\2\1\0B\0\2\2\18\2\0\0009\0\2\0B\0\2\1K\0\1\0\21render_hover_doc\18lspsaga.hover\frequireP\0\0\3\0\3\0\a6\0\0\0'\2\1\0B\0\2\2\18\2\0\0009\0\2\0B\0\2\1K\0\1\0\19signature_help\26lspsaga.signaturehelp\frequireE\0\0\3\0\3\0\a6\0\0\0'\2\1\0B\0\2\2\18\2\0\0009\0\2\0B\0\2\1K\0\1\0\15lsp_finder\19lspsaga.finder\frequireI\0\0\3\0\3\0\0066\0\0\0'\2\1\0B\0\2\0029\0\2\0B\0\1\1K\0\1\0\20lsp_definitions\22telescope.builtin\frequireN\0\0\3\0\3\0\0066\0\0\0'\2\1\0B\0\2\0029\0\2\0B\0\1\1K\0\1\0\25lsp_type_definitions\22telescope.builtin\frequireM\0\0\3\0\3\0\0066\0\0\0'\2\1\0B\0\2\0029\0\2\0B\0\1\1K\0\1\0\24lsp_implementations\22telescope.builtin\frequireH\0\0\3\0\3\0\0066\0\0\0'\2\1\0B\0\2\0029\0\2\0B\0\1\1K\0\1\0\19lsp_references\22telescope.builtin\frequire(\0\0\3\0\3\0\0056\0\0\0009\0\1\0'\2\2\0B\0\2\1K\0\1\0\tcope\bcmd\bvimN\0\0\3\0\3\0\0066\0\0\0'\2\1\0B\0\2\0029\0\2\0B\0\1\1K\0\1\0\25lsp_document_symbols\22telescope.builtin\frequireW\0\0\3\0\3\0\0066\0\0\0'\2\1\0B\0\2\0029\0\2\0B\0\1\1K\0\1\0\"lsp_dynamic_workspace_symbols\22telescope.builtin\frequireW\0\0\3\0\3\0\0066\0\0\0'\2\1\0B\0\2\0029\0\2\0B\0\1\1K\0\1\0\"lsp_dynamic_workspace_symbols\22telescope.builtin\frequirer\0\0\4\0\6\0\t6\0\0\0'\2\1\0B\0\2\0029\0\2\0005\2\4\0005\3\3\0=\3\5\2B\0\2\1K\0\1\0\fsymbols\1\0\0\1\2\0\0\rfunction\25lsp_document_symbols\22telescope.builtin\frequireQ\0\0\3\0\3\0\a6\0\0\0'\2\1\0B\0\2\2\18\2\0\0009\0\2\0B\0\2\1K\0\1\0\23preview_definition\23lspsaga.definition\frequireJ\0\0\3\0\3\0\a6\0\0\0'\2\1\0B\0\2\2\18\2\0\0009\0\2\0B\0\2\1K\0\1\0\16code_action\23lspsaga.codeaction\frequire±\1\0\0\b\0\t\0\0196\0\0\0009\0\1\0009\0\2\0006\2\0\0009\2\3\0029\2\4\2'\4\5\0+\5\2\0+\6\1\0+\a\2\0B\2\5\0A\0\0\0016\0\6\0'\2\a\0B\0\2\2\18\2\0\0009\0\b\0B\0\2\1K\0\1\0\22range_code_action\23lspsaga.codeaction\frequire\n<C-U>\27nvim_replace_termcodes\bapi\rfeedkeys\afn\bvimE\0\0\3\0\3\0\a6\0\0\0'\2\1\0B\0\2\2\18\2\0\0009\0\2\0B\0\2\1K\0\1\0\15lsp_rename\19lspsaga.rename\frequire?\0\0\2\0\4\0\0066\0\0\0009\0\1\0009\0\2\0009\0\3\0B\0\1\1K\0\1\0\24formatting_seq_sync\bbuf\blsp\bvimP\0\0\3\0\3\0\a6\0\0\0'\2\1\0B\0\2\2\18\2\0\0009\0\2\0B\0\2\1K\0\1\0\19signature_help\26lspsaga.signaturehelp\frequireª\2\0\0\b\0\14\0*6\0\0\0009\0\1\0009\0\2\0)\2\0\0'\3\3\0B\0\3\0026\1\0\0009\1\1\0019\1\2\1)\3\0\0'\4\4\0B\1\3\0026\2\0\0009\2\5\2'\4\6\0\18\5\0\0\18\6\1\0B\2\4\0016\2\0\0009\2\a\0029\2\b\0029\2\t\0024\4\0\0\18\5\0\0\18\6\1\0B\2\4\0016\2\0\0009\2\1\0029\2\n\2'\4\v\0+\5\2\0+\6\1\0+\a\2\0B\2\5\0026\3\0\0009\3\1\0039\3\f\3\18\5\2\0'\6\r\0+\a\1\0B\3\4\1K\0\1\0\6n\18nvim_feedkeys\n<esc>\27nvim_replace_termcodes\21range_formatting\bbuf\blsp\14range fmt\17pretty_print\6>\6<\22nvim_buf_get_mark\bapi\bvimì\r\1\0\6\0G\0·\0016\0\0\0009\0\1\0009\0\2\0'\2\3\0'\3\4\0003\4\5\0005\5\6\0B\0\5\0016\0\0\0009\0\1\0009\0\2\0'\2\3\0'\3\a\0003\4\b\0005\5\t\0B\0\5\0016\0\0\0009\0\1\0009\0\2\0'\2\3\0'\3\n\0003\4\v\0005\5\f\0B\0\5\0016\0\0\0009\0\1\0009\0\2\0'\2\3\0'\3\r\0003\4\14\0005\5\15\0B\0\5\0016\0\0\0009\0\1\0009\0\2\0'\2\3\0'\3\16\0003\4\17\0005\5\18\0B\0\5\0016\0\0\0009\0\1\0009\0\2\0'\2\3\0'\3\19\0003\4\20\0005\5\21\0B\0\5\0016\0\0\0009\0\1\0009\0\2\0'\2\3\0'\3\22\0003\4\23\0005\5\24\0B\0\5\0016\0\0\0009\0\1\0009\0\2\0'\2\3\0'\3\25\0003\4\26\0005\5\27\0B\0\5\0016\0\0\0009\0\1\0009\0\2\0'\2\3\0'\3\28\0006\4\0\0009\4\29\0049\4\30\0049\4\31\0045\5 \0B\0\5\0016\0\0\0009\0\1\0009\0\2\0'\2\3\0'\3!\0006\4\0\0009\4\29\0049\4\30\0049\4\"\0045\5#\0B\0\5\0016\0\0\0009\0\1\0009\0\2\0'\2\3\0'\3$\0003\4%\0005\5&\0B\0\5\0016\0\0\0009\0\1\0009\0\2\0'\2\3\0'\3'\0003\4(\0005\5)\0B\0\5\0016\0\0\0009\0\1\0009\0\2\0'\2\3\0'\3*\0003\4+\0005\5,\0B\0\5\0016\0\0\0009\0\1\0009\0\2\0'\2\3\0'\3-\0003\4.\0005\5/\0B\0\5\0016\0\0\0009\0\1\0009\0\2\0'\2\3\0'\0030\0'\0041\0005\0052\0B\0\5\0016\0\0\0009\0\1\0009\0\2\0'\2\3\0'\0033\0003\0044\0005\0055\0B\0\5\0016\0\0\0009\0\1\0009\0\2\0'\2\3\0'\0036\0003\0047\0005\0058\0B\0\5\0016\0\0\0009\0\1\0009\0\2\0'\0029\0'\0036\0003\4:\0005\5;\0B\0\5\0016\0\0\0009\0\1\0009\0\2\0'\2\3\0'\3<\0003\4=\0005\5>\0B\0\5\0016\0\0\0009\0\1\0009\0\2\0'\2\3\0'\3?\0003\4@\0005\5A\0B\0\5\0016\0\0\0009\0\1\0009\0\2\0'\2B\0'\3\a\0003\4C\0005\5D\0B\0\5\0016\0\0\0009\0\1\0009\0\2\0'\0029\0'\3?\0003\4E\0005\5F\0B\0\5\1K\0\1\0\1\0\1\tdesc\26Format selected range\0\1\0\1\tdesc\24show signature help\0\6i\1\0\1\tdesc\18format buffer\0\15<leader>rf\1\0\1\tdesc\31rename symbol under cursor\0\15<leader>rn\1\0\1\tdesc\31list code actions in range\0\6v\1\0\1\tdesc#list code actions under cursor\0\15<leader>ca\1\0\1\tdesc\28show definition preview\0\15<leader>sd\1\0\1\tdesc\17show outline\29<cmd>LSoutlineToggle<cr>\15<leader>so\1\0\1\tdesc\19show functions\0\15<leader>sf\1\0\1\tdesc\27show workspace symbols\0\15<leader>SS\1\0\1\tdesc\27show workspace symbols\0\15<leader>sS\1\0\1\tdesc\26show document symbols\0\15<leader>ss\1\0\1\tdesc-go to calls (outbound) -- who do i call?\19outgoing_calls\16<leader>gco\1\0\1\tdesc+go to calls (inbound) -- who calls me?\19incoming_calls\bbuf\blsp\16<leader>gci\1\0\1\tdesc\30go to linting diagnostics\0\15<leader>gl\1\0\1\tdesc\21go to references\0\15<leader>gr\1\0\1\tdesc\26go to implementations\0\15<leader>gi\1\0\1\tdesc\26go to type definition\0\15<leader>gD\1\0\1\tdesc\21go to definition\0\15<leader>gd\1\0\1\tdesc8go go go (to something, defintion, references, &c.)\0\15<leader>gg\1\0\1\tdesc\28Show LSP signature help\0\n<c-h>\1\0\1\tdesc'Show LSP hover (fn docs, help &c.)\0\6K\6n\bset\vkeymap\bvim¯\1\0\0\5\1\a\0\17-\0\0\0B\0\1\0016\0\0\0009\0\1\0009\0\2\0)\2\0\0'\3\3\0'\4\4\0B\0\4\0016\0\0\0009\0\1\0009\0\2\0)\2\0\0'\3\5\0'\4\6\0B\0\4\1K\0\1\0\0À\31v:lua.vim.lsp.formatexpr()\15formatexpr\27v:lua.vim.lsp.omnifunc\romnifunc\24nvim_buf_set_option\bapi\bvimî\15\1\0\15\0b\0¸\1X\0\0€X\0\26€6\0\0\0006\1\2\0'\3\3\0B\1\2\2=\1\1\0006\0\0\0006\1\2\0'\3\5\0B\1\2\2=\1\4\0006\0\0\0006\1\2\0'\3\a\0B\1\2\2=\1\6\0006\0\0\0009\0\4\0006\1\0\0009\1\4\0019\1\b\1\14\0\1\0X\2\3€6\1\2\0'\3\t\0B\1\2\2=\1\b\0003\0\n\0003\1\v\0006\2\2\0'\4\f\0B\2\2\0029\2\r\2B\2\1\0026\3\2\0'\5\14\0B\3\2\0026\4\0\0009\4\15\0046\6\16\0009\6\17\6'\a\18\0B\4\3\0026\5\19\0009\5\20\5\18\a\4\0'\b\21\0B\5\3\0016\5\19\0009\5\20\5\18\a\4\0'\b\22\0B\5\3\0019\5\23\0039\5\24\0055\a\25\0=\2\26\a5\b\27\0=\b\28\a5\b,\0005\t\30\0005\n\29\0=\4\17\n=\n\31\t5\n!\0005\v \0=\v\"\n=\n#\t5\n'\0006\v\0\0009\v$\v9\v%\v'\r&\0+\14\2\0B\v\3\2=\v(\n=\n)\t5\n*\0=\n+\t=\t-\b=\b.\a=\1/\aB\5\2\0019\0050\0039\5\24\0055\a1\0=\2\26\a=\1/\aB\5\2\0019\0052\0039\5\24\0055\a3\0=\2\26\a=\1/\aB\5\2\0019\0054\0039\5\24\0055\a5\0=\2\26\a=\1/\aB\5\2\0019\0056\0039\5\24\0055\a7\0=\2\26\a=\1/\aB\5\2\0019\0058\0039\5\24\0055\a9\0=\2\26\a=\1/\aB\5\2\0019\5:\0039\5\24\0055\a;\0=\2\26\a=\1/\aB\5\2\0019\5<\0039\5\24\0055\a=\0=\2\26\a=\1/\aB\5\2\0019\5>\0039\5\24\0055\a?\0=\2\26\a=\1/\a5\b@\0=\bA\aB\5\2\0019\5B\0039\5\24\0055\aC\0=\2\26\a=\1/\aB\5\2\0019\5D\0039\5\24\0055\aE\0=\2\26\a=\1/\aB\5\2\0019\5F\0039\5\24\0055\aG\0=\2\26\a=\1/\aB\5\2\0015\5Q\0005\6H\0005\aI\0=\aJ\0065\aK\0=\aL\0065\aM\0=\aN\0065\aO\0=\aP\6=\6R\0055\6U\0005\aS\0005\bT\0=\bJ\a=\aV\0069\aW\0039\a\24\a5\tY\0005\nX\0=\nZ\t5\n[\0=\5\\\n5\v]\0=\vZ\n=\6^\n5\v_\0=\v`\n=\na\tB\a\2\0012\0\0€K\0\1\0\17init_options\20formatFiletypes\1\0\4\15javascript\rprettier\15typescript\rprettier\fgraphql\rprettier\rmarkdown\rprettier\15formatters\1\0\2\15javascript\veslint\15typescript\veslint\flinters\1\0\0\14filetypes\1\0\0\1\5\0\0\15typescript\15javascript\rmarkdown\fgraphql\17diagnosticls\rprettier\1\0\0\1\3\0\0\21--stdin-filepath\14%filepath\1\0\1\fcommand\rprettier\veslint\1\0\0\17rootPatterns\1\a\0\0\14.eslintrc\18.eslintrc.cjs\17.eslintrc.js\19.eslintrc.json\19.eslintrc.yaml\18.eslintrc.yml\15securities\1\0\2\4\0€€€€\4\nerror\4\0€€Àÿ\3\fwarning\14parseJson\1\0\a\fmessage\27${message} [${ruleId}]\15errorsRoot\17[0].messages\14endColumn\14endColumn\fendLine\fendLine\vcolumn\vcolumn\rsecurity\rseverity\tline\tline\targs\1\6\0\0\f--stdin\21--stdin-filename\14%filepath\r--format\tjson\1\0\3\rdebounce\3d\fcommand\veslint\15sourceName\veslint\1\0\0\npylsp\1\0\0\tccls\1\0\0\vbashls\fschemas\1\0\0016https://json.schemastore.org/github-workflow.json\25/.github/workflows/*\1\0\0\vyamlls\1\0\0\ncssls\1\0\0\thtml\1\0\0\fgraphql\1\0\0\vjsonls\1\0\0\nvimls\1\0\0\18rust_analyzer\1\0\0\rtsserver\14on_attach\rsettings\bLua\1\0\0\14telemetry\1\0\1\venable\1\14workspace\flibrary\1\0\0\5\26nvim_get_runtime_file\bapi\16diagnostics\fglobals\1\0\0\1\2\0\0\bvim\fruntime\1\0\0\1\0\1\fversion\vLuaJIT\bcmd\1\2\0\0\24lua-language-server\17capabilities\1\0\0\nsetup\16sumneko_lua\19lua/?/init.lua\14lua/?.lua\vinsert\ntable\6;\tpath\fpackage\nsplit\14lspconfig\25default_capabilities\17cmp_nvim_lsp\0\0\16vim.lsp.buf\bbuf\vvim.fn\afn\fvim.lsp\blsp\15vim.keymap\frequire\vkeymap\bvim\0", "config", "nvim-lspconfig")
time([[Config for nvim-lspconfig]], false)
-- Config for: bclose
time([[Config for bclose]], true)
try_loadstring("\27LJ\2\n;\0\0\2\0\3\0\0056\0\0\0009\0\1\0+\1\2\0=\1\2\0K\0\1\0\30bclose_no_default_mapping\6g\bvim\0", "config", "bclose")
time([[Config for bclose]], false)
-- Config for: ultisnips
time([[Config for ultisnips]], true)
try_loadstring("\27LJ\2\nv\0\0\2\0\6\0\t6\0\0\0009\0\1\0'\1\3\0=\1\2\0006\0\0\0009\0\1\0'\1\5\0=\1\4\0K\0\1\0\n<c-j>!UltiSnipsJumpBackwardTrigger\n<c-k> UltiSnipsJumpForwardTrigger\6g\bvim\0", "config", "ultisnips")
time([[Config for ultisnips]], false)
-- Config for: vim-airline
time([[Config for vim-airline]], true)
try_loadstring("\27LJ\2\nÖ\1\0\0\2\0\a\0\r6\0\0\0009\0\1\0)\1\2\0=\1\2\0006\0\0\0009\0\3\0)\1\1\0=\1\4\0006\0\0\0009\0\3\0005\1\6\0=\1\5\0K\0\1\0\1\f\0\0\vbranch\17fugitiveline\nhunks\vkeymap\nnetrw\fnvimlsp\apo\rquickfix\16searchcount\tterm\14wordcount\23airline_extensions\31airline_highlighting_cache\6g\15laststatus\6o\bvim\0", "config", "vim-airline")
time([[Config for vim-airline]], false)
-- Config for: common.nvim
time([[Config for common.nvim]], true)
try_loadstring("\27LJ\2\n;\0\0\3\0\3\0\a6\0\0\0'\2\1\0B\0\2\0029\0\2\0004\2\0\0B\0\2\1K\0\1\0\nsetup\14malleatus\frequire\0", "config", "common.nvim")
time([[Config for common.nvim]], false)
-- Config for: telescope.nvim
time([[Config for telescope.nvim]], true)
try_loadstring("\27LJ\2\nÌ\2\0\0\t\0\17\1\0306\0\0\0'\2\1\0B\0\2\0029\1\2\0005\3\b\0005\4\6\0005\5\4\0005\6\3\0=\6\5\5=\5\a\4=\4\t\0035\4\f\0004\5\3\0006\6\0\0'\b\n\0B\6\2\0029\6\v\0064\b\0\0B\6\2\0?\6\0\0=\5\r\4=\4\14\3B\1\2\0019\1\15\0'\3\16\0B\1\2\0019\1\15\0'\3\r\0B\1\2\1K\0\1\0\bfzf\19load_extension\15extensions\14ui-select\1\0\0\15get_cursor\21telescope.themes\rdefaults\1\0\0\rmappings\1\0\0\6i\1\0\0\1\0\3\n<C-j>\24move_selection_next\n<C-h>\14which_key\n<C-k>\28move_selection_previous\nsetup\14telescope\frequire\3€€À™\4\0", "config", "telescope.nvim")
time([[Config for telescope.nvim]], false)
-- Config for: lspsaga.nvim
time([[Config for lspsaga.nvim]], true)
try_loadstring("\27LJ\2\nÎ\1\0\0\4\0\n\0\r6\0\0\0'\2\1\0B\0\2\0029\0\2\0005\2\4\0005\3\3\0=\3\5\0025\3\6\0=\3\a\0025\3\b\0=\3\t\2B\0\2\1K\0\1\0\21code_action_keys\1\0\2\tquit\n<C-c>\texec\t<cr>\23finder_action_keys\1\0\2\topen\t<cr>\tquit\n<C-c>\17move_in_saga\1\0\0\1\0\2\tprev\6k\tnext\6j\18init_lsp_saga\flspsaga\frequire\0", "config", "lspsaga.nvim")
time([[Config for lspsaga.nvim]], false)
-- Config for: neoterm
time([[Config for neoterm]], true)
try_loadstring("\27LJ\2\nO\0\0\3\0\4\0\a6\0\0\0'\2\1\0B\0\2\0029\0\2\0005\2\3\0B\0\2\1K\0\1\0\1\0\1\rmappings\2\nsetup\21hjdivad/terminal\frequire\0", "config", "neoterm")
time([[Config for neoterm]], false)
-- Config for: nvim-nonicons
time([[Config for nvim-nonicons]], true)
try_loadstring("\27LJ\2\nB\0\0\4\0\4\0\a6\0\0\0'\2\1\0B\0\2\0029\1\2\0'\3\3\0B\1\2\1K\0\1\0\tfile\bget\18nvim-nonicons\frequire\0", "config", "nvim-nonicons")
time([[Config for nvim-nonicons]], false)

_G._packer.inside_compile = false
if _G._packer.needs_bufread == true then
  vim.cmd("doautocmd BufRead")
end
_G._packer.needs_bufread = false

if should_profile then save_profiles() end

end)

if not no_errors then
  error_msg = error_msg:gsub('"', '\\"')
  vim.api.nvim_command('echohl ErrorMsg | echom "Error in packer_compiled: '..error_msg..'" | echom "Please check your config for correctness" | echohl None')
end
