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

Plug 'preservim/nerdtree'
Plug 'Xuyuanp/nerdtree-git-plugin'

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

Plug 'powerman/vim-plugin-AnsiEsc'

Plug 'altercation/vim-colors-solarized'
Plug 'morhetz/gruvbox'
Plug 'junegunn/seoul256.vim'

" CocConfig to open configuration
Plug 'neoclide/coc.nvim'

Plug 'junegunn/goyo.vim'
Plug 'junegunn/limelight.vim'

" neovim in browser
Plug 'glacambre/firenvim', { 'do': { _ -> firenvim#install(0) } }

Plug 'tpope/vim-scriptease'
Plug 'wesQ3/vim-windowswap'

Plug 'kassio/neoterm'
Plug 'janko/vim-test'

Plug 'hjdivad/vim-pdl'

" Run interactive jq in vim :Jqplay
" This plugin does not support neovim https://github.com/bfrg/vim-jqplay/issues/5
"
" Plug 'bfrg/vim-jqplay'

call plug#end()

"}}}

" Misc normal options {{{

" https://github.com/tmux/tmux/issues/1246
if has("termguicolors")
  set termguicolors
endif

set background=dark
colorscheme gruvbox

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
" Abbreviate some messages
set shm+=sAIc

set foldlevelstart=99
set foldnestmax=10
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
  " TODO: re-enable without causing issues
  "   it looks like a race between updating the buffer name & checking bufname
  " autocmd FocusGained,BufEnter * if bufname('%') != '[Command Line]' | checktime | endif
augroup end
"}}}

" Language-specific syntax options {{{

let g:mustache_abbreviations = 0

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

let g:airline_extensions = ['coc', 'fugitiveline', 'netrw', 'quickfix', 'tabline', 'term', 'windowswap', 'wordcount']
" This makes the tabline a buffer list when there is only one tab
let g:airline#extensions#tabline#enabled = 1

let g:NERDTreeGitStatusIndicatorMapCustom = {
  \ 'Modified'  :'✹',
  \ 'Staged'    :'✚',
  \ 'Untracked' :'✭',
  \ 'Renamed'   :'➜',
  \ 'Unmerged'  :'═',
  \ 'Deleted'   :'✖',
  \ 'Dirty'     :'✗',
  \ 'Ignored'   :'☒',
  \ 'Clean'     :'✔︎',
  \ 'Unknown'   :'?',
  \ }

let g:markdown_fenced_languages = ['javascript', 'js=javascript', 'sh', 'typescript', 'ts=typescript']
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


" TODO: https://github.com/neoclide/coc.nvim/wiki/Language-servers#graphql
"  instead of coc-graphql
" coc-graphql would be nice to add here except it does not gracefully fail in a
" non-graphql repo
let g:coc_global_extensions = [
  \ 'coc-css',
  \ 'coc-eslint',
  \ 'coc-highlight',
  \ 'coc-html',
  \ 'coc-java',
  \ 'coc-json',
  \ 'coc-prettier',
  \ 'coc-r-lsp',
  \ 'coc-rls',
  \ 'coc-rust-analyzer',
  \ 'coc-snippets',
  \ 'coc-svg',
  \ 'coc-tsserver',
  \ 'coc-vimlsp',
\ ]

let g:coc_snippet_prev='<C-j>'
let g:coc_snippet_next='<C-k>'

" From https://github.com/neoclide/coc.nvim
function! s:show_documentation()
  if (index(['vim','help'], &filetype) >= 0)
    execute 'h '.expand('<cword>')
  else
    call CocActionAsync('doHover')
  endif
endfunction


" From https://github.com/neoclide/coc.nvim
augroup coctls
  autocmd!
  " Update signature help on jump placeholder
  autocmd User CocJumpPlaceholder call CocActionAsync('showSignatureHelp')
augroup end

autocmd CursorHold * silent call CocActionAsync('highlight')

" I don't quite have this working yet; will have to take a trip through
" TROUBLESHOOTING
" https://github.com/glacambre/firenvim#configuring-firenvim
" let g:firenvim_config = {
"   \ 'globalSettings': {
"   \ },
"   \ 'localSettings': {
"   \ },
" \ }
" let fc = g:firenvim_config['localSettings']

let g:neoterm_automap_keys='<leader><leader>STUPID_PLUGIN_DO_NOT_AUTOMAP'

" vim-test
function! s:neoterm_strategy_fixed(cmd)
  " Get the bottom-left neoterm id if it exists, else make a new neoterm and
  " grab its id
  let starting_bufnr = bufnr()
  100wincmd h
  100wincmd j
  stopinsert
  let bottom_left_winnr = winnr()
  let bottom_left_bufnr = winbufnr(bottom_left_winnr)

  let target_neoterm_id=0
  for term_id in keys(g:neoterm.instances)
    if g:neoterm.instances[term_id].buffer_id == bottom_left_bufnr
      let target_neoterm_id = term_id
      break
    endif
  endfor

  if target_neoterm_id == 0
    vertical topleft Tnew
    let target_neoterm_id = g:neoterm.last_id
  endif

  " end up at the window we started in
  exe bufwinnr(starting_bufnr) . 'wincmd w'

  " modify command for debug mode, extra environment variables
  let cmd = a:cmd
  let env_extra = []
  if exists('t:test_debugging') && t:test_debugging == 1
    if !(cmd =~ 'node')
      echom 'neoterm_strategy_fixed:' "don't know how to debug command:" cmd
      return
    endif

    if cmd =~ 'node'
      call add(env_extra, 'NODE_OPTIONS="--inspect-brk"')
    endif

    if cmd =~ 'jest'
      let parts = split(cmd, "\ --\ ")
      let cmd = join(parts[:-2] + ["--testTimeout=0 --runInBand"] + parts[-1:])
    endif
  endif

  if exists('t:env_extra') && len(t:env_extra) > 0
    let env_extra += t:env_extra
  endif

  if len(env_extra) > 0
    let cmd = 'env ' . join(env_extra) . ' ' . cmd
  endif

  " let cmd = " \<c-c>" . cmd

  call neoterm#do({ 'cmd': " \<c-c>", 'target': target_neoterm_id })
  call neoterm#do({ 'cmd': cmd, 'target': target_neoterm_id })
endfunction

let g:test#custom_strategies = { 'neotermx': function('<SID>neoterm_strategy_fixed') }
let g:test#strategy = 'neotermx'

augroup REPL
  au!
  au BufWritePre .repl.* exe 'TREPLSendFile'
augroup END

if exists('g:started_by_firenvim')
  " Configuration for firenvim frames
  set guifont=Fire\ Code:h12

  " This appears to be too early; I probably need to do this at some event.
  " if &lines < 10
  "   set lines=10
  " endif

  nnoremap <C-f><C-f> :call firenvim#focus_page()<CR>
endif
"}}}

" Terminal Setup {{{
function s:setup_terminal()
  setlocal winfixwidth nonumber norelativenumber
  let twidth = 70 "laptop
  if &columns > 200
    let twidth = 120 "workstation meeting mode
  endif

  execute 'vertical resize ' . twidth
  " start! happens only when a function or script ends so it can be very
  " trollish to do it in TermOpen
endfunction

augroup TermExtra
  autocmd!
  " When switching to a term window, go to insert mode by default (this is
  " only pleasant when you also have window motions in terminal mode)
  autocmd BufEnter term://* start!
  autocmd TermOpen * call <SID>setup_terminal()
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

function s:OpenNERDTree()
  let isFile = (&buftype == "") && (bufname() != "")

  if isFile
    let findCmd = "NERDTreeFind " . expand('%')
  endif

  " open a NERDTree in this window
  edit .

  " make this the implicit NERDTree buffer
  let t:NERDTreeBufName=bufname()

  if isFile
    exe findCmd
  endif
endfunction

" use coc.vim for K doc lookup
nnoremap <silent> K :call <SID>show_documentation()<CR>
nmap <leader>gd <Plug>(coc-definition)
nmap <leader>gD <Plug>(coc-type-definition)
nmap <leader>gi <Plug>(coc-implementation)
nmap <leader>gr <Plug>(coc-references)

" refactor
nmap <leader>rn <Plug>(coc-rename)
nmap <leader>rj <Plug>(coc-codeaction-selected)<CR>

nmap <leader>cc :CocCommand<CR>
nmap <leader>ss :CocList symbols<CR>
nmap <leader>sl :CocList outline<CR>
nmap <leader>sf :call CocAction('showSignatureHelp')<CR>

" run
nmap <leader>rr :TestFile<CR>
nmap <leader>rt :TestNearest<CR>
nmap <leader>rd :call h#DebugNearest()<CR>

" tmux (session)
nmap <leader>tt :call <SID>tmux_select_previous_session()<CR>
nmap <leader>td :call <SID>tmux_toggle_todos_session()<CR>

nmap <leader>fg :GFiles<CR>
nmap <leader>ff :Files<CR>
nmap <leader>fr :Rg<CR>
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

nmap <leader>ne :call <SID>OpenNERDTree()<CR>
" I don't want to fat finger these b/c nerd tree messes up the size of the left
" window when it has winfixwidth
" nmap <leader>nt :NERDTreeFocus<CR>
" nmap <leader>nf :NERDTreeFind<CR>
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

" select the omnicomplete snippet
" use <c-j> <c-k> to jump between snippet variables (the default keybindings)
imap <c-l> <Plug>(coc-snippets-expand)

" Window-motion out of terminals
tnoremap <C-w>h <C-\><C-n><C-w>h
tnoremap <C-w><C-h> <C-\><C-n><C-w>h
tnoremap <C-w>j <C-\><C-n><C-w>j
tnoremap <C-w><C-j> <C-\><C-n><C-w>j
tnoremap <C-w>k <C-\><C-n><C-w>k
tnoremap <C-w><C-k> <C-\><C-n><C-w>k
tnoremap <C-w>l <C-\><C-n><C-w>l
tnoremap <C-w><C-l> <C-\><C-n><C-w>l

" <C-W>b → bottom left
nnoremap <C-w>b :let t:winp=winnr() \| wincmd t \| wincmd j \| wincmd j \| startinsert<CR>
" This is also desirable but it conflicts with <C-b> as tmux escape
" nnoremap <C-w><C-b> :let t:winp=winnr() \| wincmd t \| wincmd j \| wincmd j \| startinsert<CR>
"
" <C-W>p after having gone bottom left
let t:winp = 0
tmap <C-w>p <C-\><C-n>:exe t:winp . "wincmd w"<CR>
tmap <C-w><C-p> <C-\><C-n>:exe t:winp . "wincmd w"<CR>

" Create new (terminal) window from terminal mode
" TODO: Tnew?
tnoremap <C-w>n <C-\><C-n><C-w>n:term<CR>
tnoremap <C-w><C-n> <C-\><C-n><C-w>n:term<CR>

" Use C-\ C-\ as terminal escape
tnoremap <C-\><C-\> <C-\><C-n>
" alternate escape for moonlander
tnoremap <C-g><C-g> <C-\><C-n>

" Move row-wise instead of line-wise
nnoremap j gj
nnoremap k gk

nnoremap zV zMzv

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

  digraph iO 8505     " ℹ️
  " ⚠️ will render in terminal and is different from 9888 somehow (check ga)
  digraph wa 9888     " ⚠ 
  digraph er 9940     " ⛔
  digraph bl 9940     " ⛔
  digraph wc 9898     " ⚪
  digraph oc 128992   " 🟠
  digraph rc 128308   " 🔴
  digraph bc 128309   " 🔵
  digraph ok 127823   " 🍏
  digraph wt 9200     " ⏰
  digraph tb 9203     " ⏳
  digraph OK 9989     " ✅
  digraph NO 10060    " ❌
  digraph fi 128293   " 🔥
  digraph jo 128514   " 😂
  digraph bo 9889     " ⚡
  digraph sh 128674   " 🚢
  digraph wi 128297   " 🔩
  digraph rk 128640   " 🚀
  digraph tu 128077   " 👍
  digraph ti 129300   " 🤔
  digraph ax 129683   " 🪓
  digraph hx 129683   " 🪓
  " TODO: unclear how to make a digraph for ⚙️  i.e. a multi-codepoint character

  digraph ey 128064   " 👀
  digraph ch 128172   " 💬
  digraph th 128173   " 💭

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
abbreviate :sun: ☀️ 
abbreviate :today: ☀️ 
abbreviate :coin: 🪙
abbreviate :week: 🪙
abbreviate :gear: ⚙️  
abbreviate :beer: 🍺
abbreviate :beers: 🍻
abbreviate :hamster: 🐹

" snippety things
abbreviate :td: <C-R>=strftime('%d %B %Y (%A)')<CR>
"}}}


" Project-specific .vimrc and .vim
if !(getcwd() == $HOME)
  if filereadable('.vimrc')
    source .vimrc
  elseif isdirectory('.git')
    let project_vimrc_blueprint = expand("$HOME/.config/nvim/blueprints/project.vimrc")
    if filereadable(project_vimrc_blueprint)
      call system('cp ' . project_vimrc_blueprint . ' .vimrc')
      source .vimrc
    endif
  endif
  set runtimepath+=./.vim
endif

" inform terminals that they are within an nvim
let $NVIM_WRAPPER = 1

" vim:set tw=0 fdm=marker:
