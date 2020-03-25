let mapleader = ','
let maplocalleader = ','

" clipboard {{{

set clipboard=unnamed
if $SSH_TTY != '' || $SSH_CLIENT != ''
  " We're in a remote terminal
  let g:clipboard = {
    \   'name': 'ssh-pbcopy',
    \   'copy': {
    \     '+': 'ssh client pbcopy',
    \     '*': 'ssh client pbcopy'
    \   },
    \   'paste': {
    \     '+': 'ssh client pbpaste',
    \     '*': 'ssh client pbpaste'
    \   },
    \   'cache_enabled': 1
    \ }
else
  " Check if we're in WSL
  let x=system('grep -q Microsoft /proc/version')
  if !v:shell_error
    " TODO: dos2unix doesn't work here but should be able to change paste to a
    " lambda that does the right thing
    let g:clipboard = {
      \   'name': 'wsl-1083',
      \   'copy': {
      \     '+': 'clip.exe',
      \     '*': 'clip.exe'
      \   },
      \   'paste': {
      \     '+': 'powershell.exe Get-Clipboard',
      \     '*': 'powershell.exe Get-Clipboard'
      \   },
      \   'cache_enabled': 1
      \ }
  endif
endif

"}}}

" auto-generated files (swap, backup &c.) {{{

set noswapfile

if has('macunix')
  set backupdir=/private/tmp
  set dir=/private/tmp
elseif has('unix')
  set backupdir=/tmp
  set dir=/tmp
end

" Ignore conflicting swap files.
" autocmd SwapExists * let v:swapchoice='e'

"}}}

" Plugins {{{

" Using https://github.com/junegunn/vim-plug
" for managing plugins
"
" see https://github.com/junegunn/vim-plug#commands
call plug#begin()

Plug 'bcaccinolo/bclose'
Plug 'rizzatti/dash.vim'
Plug 'ekalinin/Dockerfile.vim'

" Visualiztion for undo tree (as opposed to undo stack)
" seems to be broken
" Plug 'sjl/gundo.vim'

Plug 'tpope/vim-surround'
Plug 'tpope/vim-repeat'
Plug 'tpope/vim-commentary'
" I think airline supersedes powerline
" Plug 'powerline/powerline'
Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'
" e some_file:123  open some_file at line 123
Plug 'bogado/file-line'

" This is nice but it conflicts with conceallevel in javascript at least
" Plug 'Yggdroot/indentLine'

" autoclose quotes &c.  Does more harm than good.
" Plug 'Raimondi/delimitMate'

Plug 'junegunn/fzf', { 'dir': '~/.fzf', 'do': './install --all' }
Plug 'junegunn/fzf.vim'
Plug 'fszymanski/fzf-quickfix'

" Plug 'Valloric/YouCompleteMe'
" Plug 'SirVer/ultisnips'

Plug 'tpope/vim-fugitive'
Plug 'airblade/vim-gitgutter'

Plug 'scrooloose/nerdtree'
Plug 'Xuyuanp/nerdtree-git-plugin'

" Formatting
Plug 'sbdchd/neoformat'

" rails.vim for node
Plug 'moll/vim-node'

Plug 'leafgarland/typescript-vim'
" Plug "Shougo/vimproc" " might help make tsuoquyomi work per @rwjblue
" make vim a client for typescript lang-server
"   doesn't work in neovim but see https://github.com/neovim/neovim/pull/6856
" Plug 'Quramy/tsuquyomi'

" Language supports
Plug 'mustache/vim-mustache-handlebars'
Plug 'rust-lang/rust.vim'
Plug 'pangloss/vim-javascript'
Plug 'dag/vim-fish'
Plug 'gutenye/json5.vim'
Plug 'jparise/vim-graphql'
Plug 'cespare/vim-toml'

" This can be slow
Plug 'nelstrom/vim-markdown-folding'


Plug 'altercation/vim-colors-solarized'
Plug 'morhetz/gruvbox'
Plug 'junegunn/seoul256.vim'

" TODO: get this working
" Plug 'kassio/neoterm'
" Plug 'janko-m/vim-test'

" CocConfig to open configuration
Plug 'neoclide/coc.nvim', {'branch': 'release'}

Plug 'junegunn/goyo.vim'
Plug 'junegunn/limelight.vim'

Plug 'tpope/vim-scriptease'

call plug#end()

"}}}

" Misc normal options {{{

" https://github.com/tmux/tmux/issues/1246
if has("termguicolors")
  set termguicolors
endif

set background=dark
" colorscheme solarized
colorscheme gruvbox
" hack to make diagnostic preview window readable
" these end up with CocDiagnosticError CocFloating
" CocDiagnosticsError → GruvboxRed
" CocFloating → NormalFloat → PMenu
" this ends up with guifg=#fb4934 guibg=#504945 which has nowhere near enough contrast
hi Pmenu guibg=#1d2021
" gruvbox sets the terminal red colour to its s.gb.neutral_red colour, '#cc241d'
" I find has too little contrast with the background and prefer to lighten it 10%
let g:terminal_color_1='#d25855'

" Spaces vs tabs
set tabstop=2
set softtabstop=2
set shiftwidth=2
set expandtab
set smartindent
set autoindent

set number
set relativenumber

" recommended by https://github.com/neoclide/coc.nvim
set updatetime=300

" Terminal mode output buffer
set scrollback=1000

set iskeyword+=-

set foldlevelstart=0
set foldnestmax=5
set foldmethod=syntax
set foldenable

" Resize windows with the mouse
set mouse=a

" I'd prefer to turn cursorline on but it causes emoji rendering issues
" https://github.com/hjdivad/dotfiles/issues/50
set nocursorline

set virtualedit=onemore

set wildmenu
set wildmode=list:longest,full
" set whichwrap=b,s,h,l,<,>,[,]
" Scroll context lines
set scrolloff=3

set list
" Highlight problematic whitespace
set listchars=tab:›\ ,trail:•,extends:#,nbsp:.

" Search case-insensitive when the entire search is lowercase.  Search with \C
" if you want to case-sensitive all-lowercase search
set ignorecase
set smartcase

" Make searches very magic by default
nnoremap / /\v

" Do not search over closed folds
set foldopen-=search

set lazyredraw

" Switch modified buffers without being forced to save
set hidden

set spelllang=sv,en_gb,en_us
set spellfile=.vimspell.utf8.add
set spellfile+=~/.vim/spell/en.utf-8.add
set spellfile+=~/.vim/spell/sv.utf-8.add

set conceallevel=2
" Don't use conceal characters for cursor line.  It causes many rendering
" problems
set concealcursor=

hi CursorLine   cterm=NONE ctermbg=233
" SignColumn should match background
highlight clear SignColumn
" Current line number row will have same background color in relative mode
highlight clear LineNr
"}}}

" script util{{{
function! s:chomp(string)
  return substitute(a:string, '\n\+$', '', '')
endfunction
"}}}

" misc autocmd {{{
augroup Autoread
  autocmd!

  " Check for updates each time we switch to some buffer
  autocmd FocusGained,BufEnter * :execute 'checktime ' . bufnr('%')
augroup end
"}}}

" Language-specific syntax options {{{

" Simple snippets in mustache files
let g:mustache_abbreviations = 1

let g:javascript_plugin_jsdoc=1
let g:javascript_conceal=1
let g:javascript_conceal_function   = "ƒ"
let g:javascript_conceal_null       = "ø"
let g:javascript_conceal_this       = "@"
let g:javascript_conceal_return     = "⇚"
let g:javascript_conceal_undefined  = "¿"
let g:javascript_conceal_NaN        = "ℕ"
let g:javascript_conceal_prototype  = "¶"
let g:javascript_conceal_static     = "•"
let g:javascript_conceal_super      = "Ω"

let javaScript_fold=1
let perl_fold=1
let php_folding=1
let r_syntax_folding=1
let ruby_fold=1
let sh_fold_enabled=1
let vimsyn_folding='af'
let xml_syntax_folding=1
"}}}

" Plugin config {{{
function! s:fzf_statusline()
  " Override statusline as you like
  highlight fzf1 ctermfg=161 ctermbg=251
  highlight fzf2 ctermfg=23 ctermbg=251
  highlight fzf3 ctermfg=237 ctermbg=251
  setlocal statusline=%#fzf1#\ >\ %#fzf2#fz%#fzf3#f
endfunction
autocmd! User FzfStatusLine call <SID>fzf_statusline()

let g:indent_guides_auto_colors=1

let g:UltiSnipsExpandTrigger="<tab>"
let g:UltiSnipsJumpForwardTrigger="<tab>"
let g:UltiSnipsJumpBackwardTrigger="<s-tab>"

" Don't confirm  buffer deletes
let NERDTreeAutoDeleteBuffer=1
" Don't show files hidden by wildignore
let NERDTreeRespectWildIgnore=1

" This makes the tabline a buffer list when there is only one tab
let g:airline#extensions#tabline#enabled = 1

let g:NERDTreeIndicatorMapCustom = {
    \ "Modified"  : "✗",
    \ "Staged"    : "✚",
    \ "Untracked" : "✭",
    \ "Renamed"   : "➜",
    \ "Unmerged"  : "═",
    \ "Deleted"   : "y",
    \ "Dirty"     : "✗",
    \ "Clean"     : "✔︎",
    \ "Unknown"   : "?"
    \ }

let g:neoformat_try_formatprg = 1
let g:neoformat_basic_format_retab = 1
let g:neoformat_basic_format_trim = 1

let g:markdown_fenced_languages = ['javascript', 'js=javascript', 'sh']
let g:markdown_fold_style = 'nested'

let g:bclose_no_default_mapping=1

" Put the fzf window to the right to not interfere with terminals (which i
" keep on the left)
let g:fzf_layout = {
\   'right': '~40%'
\}

" It's way more useful to see the diff against master than against the index
let g:gitgutter_diff_base = 'origin/master'

let g:gitgutter_map_keys = 0


" From https://github.com/neoclide/coc.nvim
function! s:show_documentation()
  if (index(['vim','help'], &filetype) >= 0)
    execute 'h '.expand('<cword>')
  else
    call CocAction('doHover')
  endif
endfunction


" From https://github.com/neoclide/coc.nvim
augroup coctls
  autocmd!
  " Update signature help on jump placeholder
  autocmd User CocJumpPlaceholder call CocActionAsync('showSignatureHelp')
augroup end

autocmd CursorHold * silent call CocActionAsync('highlight')
"}}}

" Terminal Setup {{{
function! s:GetVisual() range
  let reg_save = getreg('"')
  let regtype_save = getregtype('"')
  let cb_save = &clipboard
  set clipboard&
  normal! ""gvy
  let selection = getreg('"')
  call setreg('"', reg_save, regtype_save)
  let &clipboard = cb_save
  return selection
endfunction

function! s:TerminalRun(mapping)
  let l:job_var = 'g:terminal_run_' . a:mapping . '_job'
  let l:job_cmd_var = 'g:terminal_run_' . a:mapping . '_cmd'

  if !exists(l:job_cmd_var)
    echom 'termianl command for ' . mapping . ' has not been set up yet'
    return
  endif

  call jobsend({l:job_var}, {l:job_cmd_var})
endfunction

function! s:SetupTerminalRun(mapping) range
  let l:job_var = 'g:terminal_run_' . a:mapping . '_job'
  let l:job_cmd_var = 'g:terminal_run_' . a:mapping . '_cmd'
  let l:selection = <SID>GetVisual()
  let l:terminal_cmd = [l:selection, '']

  let {l:job_var} = b:terminal_job_id
  let {l:job_cmd_var} = l:terminal_cmd
endfunction

function s:setup_terminal()
  setlocal winfixwidth nonumber norelativenumber
  vertical resize 100

  vmap <buffer> <leader>rr :call <SID>SetupTerminalRun('rr')<CR>
  vmap <buffer> <leader>rd :call <SID>SetupTerminalRun('rd')<CR>
  vmap <buffer> <leader>rt :call <SID>SetupTerminalRun('rt')<CR>
endfunction

nmap <leader>rr :call <SID>TerminalRun('rr')<CR>
nmap <leader>rd :call <SID>TerminalRun('rd')<CR>
nmap <leader>rt :call <SID>TerminalRun('rt')<CR>

augroup TermExtra
  autocmd!
  " When switching to a term window, go to insert mode by default (this is
  " only pleasant when you also have window motions in terminal mode)
  autocmd BufEnter term://* start!
  autocmd TermOpen * call <SID>setup_terminal() | start!
  autocmd TermClose * setlocal nowinfixwidth

  " from https://github.com/rwjblue/dotvim/commit/6c05d8573451a4ca45868c53f650dce44d3ab408
  "
  " working around the bug reported in https://github.com/neovim/neovim/issues/11072
  " specifically, scrolloff being set _within_ terminal mode causes "weird"
  " ghosting to occur in certain terminal UIs (e.g. nested nvim, htop,
  " anything with ncurses)
  autocmd TermEnter * setlocal scrolloff=0
  " TODO: instead when bufenter call fn; if not term setlocal scrolloff=3 doing
  " this always on termleave gets you the issue when switching from one term
  " buffer to another
  " autocmd TermLeave * setlocal scrolloff=3

  autocmd WinLeave term://* :checktime
augroup end
"}}}

" window management {{{
augroup WindowManagement
  autocmd!

  " re-arrange windows on resize
  autocmd VimResized * wincmd =
augroup end
"}}}

" tmux {{{
function s:tmux_select_previous_session()
  " tmux calls this the "last" session, but it means the previously used one
  silent exec "!tmux switch-client -l"
endfunction

function s:tmux_select_todos_session()
  silent exec "!tmux switch-client -t todos"
endfunction

function s:tmux_toggle_todos_session()
  let session = s:chomp(system('tmux display -p "#S"'))
  if session == 'todos'
    call s:tmux_select_previous_session()
  else
    call s:tmux_select_todos_session()
  endif
endfunction
"}}}

" Keybindings {{{
"
" Use <CR> to clear text search, but unmap it when in the command window as
" <CR> there is used to run command
function s:install_enter_hook()
  nnoremap <CR> :nohl<CR>
endfunction

augroup EnterKeyManager
  autocmd!

  autocmd CmdwinEnter * nunmap <CR>
  autocmd CmdwinLeave * call s:install_enter_hook() 
augroup end
call s:install_enter_hook()

" use coc.vim for K doc lookup
nnoremap <silent> K :call <SID>show_documentation()<CR>
nmap <leader>gd <Plug>(coc-definition)
nmap <leader>gD <Plug>(coc-type-definition)
nmap <leader>gi <Plug>(coc-implementation)
nmap <leader>gr <Plug>(coc-references)
nmap <leader>rn <Plug>(coc-rename)
" Format using formatprg
nmap <leader>rf gggqG<C-o><C-o>
nmap <leader>ss :CocList symbols<CR>
nmap <leader>sl :CocList outline<CR>
nmap <leader>df :call CocAction('showSignatureHelp')<CR>

nmap <leader>tt :call <SID>tmux_toggle_todos_session()<CR>
nmap <leader>fg :GFiles<CR>
nmap <leader>ff :Files<CR>
nmap <leader>fl :BLines<CR>
nmap <leader>fL :Lines<CR>
nmap <leader>fs :GFiles?<CR>
nmap <leader>fb :Buffers<CR>
nmap <leader>fm :Marks<CR>
nmap <leader>fc :BCommits!<CR>
nmap <leader>fC :Commits!<CR>
nmap <leader>fh :Helptags<CR>
nmap <leader>hn :GitGutterNextHunk<CR>
nmap <Leader>hp :GitGutterPrevHunk<CR>
nmap <Leader>hu :GitGutterUndoHunk<CR>
nmap <Leader>hP :GitGutterPreviewHunk<CR>
nmap <leader>ne :edit .<CR>
nmap <leader>nt :NERDTreeFocus<CR>
nmap <leader>nf :NERDTreeFind<CR>
nmap <leader>ln <Plug>(coc-diagnostic-next)<CR>
nmap <leader>lf <Plug>(coc-fix-current)<CR>
nmap <leader>ll :Quickfix<CR>
" TODO: these don't work from  a new buffer for reasons that aren't clear to
" me; it seems that nothing works after a wincmd; i'll have to debug later
" with verbose
" nmap <leader>ts <C-w>v<CR> <Cmd>terminal bash -ic ts<CR>
" nmap <leader>tw <C-w>v<CR> <Cmd>terminal bash -ic tw<CR>
nmap <leader>d :Bclose!<CR>:enew<CR>
if has('clipboard')
  " Yank file (to clipboard)
  nmap <leader>yf :let @+=expand('%')<CR>
else
  " Yank file (to clipboard)
  nmap <leader>yf :let @"=expand('%')<CR>
endif

" Window-motion out of terminals
tnoremap <C-w>h <C-\><C-n><C-w>h
tnoremap <C-w><C-h> <C-\><C-n><C-w>h
tnoremap <C-w>j <C-\><C-n><C-w>j
tnoremap <C-w><C-j> <C-\><C-n><C-w>j
tnoremap <C-w>k <C-\><C-n><C-w>k
tnoremap <C-w><C-k> <C-\><C-n><C-w>k
tnoremap <C-w>l <C-\><C-n><C-w>l
tnoremap <C-w><C-l> <C-\><C-n><C-w>l

" Create new (terminal) window from terminal mode
tnoremap <C-w>n <C-\><C-n><C-w>n:term<CR>
tnoremap <C-w><C-n> <C-\><C-n><C-w>n:term<CR>

" Use C-\ C-\ as terminal escape
tnoremap <C-\><C-\> <C-\><C-n>

" Move row-wise instead of line-wise
nnoremap j gj
nnoremap k gk

" 'x is much easier to hit than `x and has more useful semantics: ie switching
" to the column of the mark as well as the row
nnoremap ' `

" Tab navigation
map <leader>1 1gt
map <leader>2 2gt
map <leader>3 3gt
map <leader>4 4gt
map <leader>5 5gt
map <leader>6 6gt
map <leader>7 7gt
map <leader>8 8gt
map <leader>9 9gt
map <leader>0 10gt

" No arrow keys
noremap <Up> <NOP>
noremap <Down> <NOP>
noremap <Left> <NOP>
noremap <Right> <NOP>
"}}}

" Digraphs & Abbreviations {{{
if has("digraphs")
  digraph .. 8230   " …
  digraph !? 8253   " ‽

  digraph ua 228 " ä
  digraph uA 196 " Ä
  digraph uo 246 " ö
  digraph uO 214 " Ö
  digraph oa 229 " å
  digraph oA 197 " Å

  digraph RN 8477   " ℝ 
  digraph PN 8473   " ℙ 
  digraph QN 8474   " ℚ 
  digraph NN 8469   " ℕ 
  digraph ZN 8484   " ℤ 

  digraph cc 8984   " ⌘ 
  digraph op 8997   " ⌥ 
  digraph es 9099   " ⎋ 
  digraph sh 8679   " ⇧
  digraph rt 9166   " ⏎ 
  digraph bs 9003   " ⌫  

  digraph is 7522   " ᵢ

  " Builtin digraphs
  "
  " digraph -< 8592   " ←
  " digraph -> 8594   " →
  " digraph -! 8593   " ↑
  " digraph -v 8595   " ↓

  digraph iO 9432     " ⓘ
  digraph wa 9888     " ⚠
  digraph er 9940     " ⛔
  digraph wc 9898     " ⚪
  digraph rc 128308   " 🔴
  digraph bc 128309   " 🔵
  digraph ok 127823   " 🍏
  digraph wt 9200     " ⏰
  digraph tb 9203     " ⏳
  digraph OK 9989     " ✅
  digraph NO 10060    " ❌
  digraph fe 128293   " 🔥
  digraph jo 128514   " 😂
  digraph bo 9889     " ⚡
  digraph rk 128640   " 🚀
  digraph tu 128077   " 👍
  digraph ti 129300   " 🤔
  digraph ax 129683   " 🪓
  digraph ey 128064   " 👀
  digraph ch 128172   " 💬

  digraph ** 9733   " ★
  digraph <3 9829   " ♥
  digraph sw 9876   " ⚔ 
  digraph mc 10016  " ✠ 
  digraph ra 9762   " ☢ 
  digraph bh 9763   " ☣ 
  digraph ki 9812   " ♔ 
  digraph kn 9816   " ♘ 

  " <C-k> space space to enter non-breaking space
  digraph <20><20> 160  " non-breaking space;
endif

" emoji
abbreviate :beer: 🍺
abbreviate :beers: 🍻
abbreviate :hamster: 🐹
"}}}
"
" TODO: https://github.com/hjdivad/vim-config/blob/master/vimrc.d/resize.vim
" TODO: https://github.com/hjdivad/vim-config/blob/master/vimrc.d/keybindings.vim#L42-L48


" Project-specific .vimrc and .vim
if !(getcwd() == $HOME)
  if filereadable(".vimrc")
    source .vimrc
  endif
  set runtimepath+=./.vim
endif

" vim:set tw=0 fdm=marker:
