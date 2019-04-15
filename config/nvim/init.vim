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
Plug 'sjl/gundo.vim'

Plug 'tpope/vim-surround'
Plug 'tpope/vim-repeat'
Plug 'tpope/vim-commentary'
Plug 'terryma/vim-multiple-cursors'
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

" Plug 'Valloric/YouCompleteMe'
" Plug 'SirVer/ultisnips'

Plug 'tpope/vim-fugitive'
Plug 'airblade/vim-gitgutter'

Plug 'scrooloose/nerdtree'
Plug 'Xuyuanp/nerdtree-git-plugin'

" asynchronous linting
Plug 'w0rp/ale'
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


Plug 'altercation/vim-colors-solarized'

" This can be slow
Plug 'nelstrom/vim-markdown-folding'

" TODO: get this working
" Plug 'kassio/neoterm'
" Plug 'janko-m/vim-test'


" TODO: experiment with this: TLS support in vim + nvim
" https://github.com/neoclide/coc.nvim
" Plug 'neoclide/coc.nvim', {'tag': '*', 'do': { -> coc#util#install()}}

call plug#end()

"}}}

set background=dark
colorscheme solarized

" Simple snippets in mustache files
let g:mustache_abbreviations = 1

" Spaces vs tabs
set tabstop=2
set softtabstop=2
set shiftwidth=2
set expandtab
set smartindent
set autoindent

set number
set relativenumber

" Terminal mode output buffer
set scrollback=1000

set iskeyword+=-

set foldlevelstart=0
set foldnestmax=5
set foldmethod=syntax
set foldenable

" Resize windows with the mouse
set mouse=a

set cursorline

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


function! s:fzf_statusline()
  " Override statusline as you like
  highlight fzf1 ctermfg=161 ctermbg=251
  highlight fzf2 ctermfg=23 ctermbg=251
  highlight fzf3 ctermfg=237 ctermbg=251
  setlocal statusline=%#fzf1#\ >\ %#fzf2#fz%#fzf3#f
endfunction
autocmd! User FzfStatusLine call <SID>fzf_statusline()

hi CursorLine   cterm=NONE ctermbg=233
" SignColumn should match background
highlight clear SignColumn
" Current line number row will have same background color in relative mode
highlight clear LineNr

let javaScript_fold=1
let perl_fold=1
let php_folding=1
let r_syntax_folding=1
let ruby_fold=1
let sh_fold_enabled=1
let vimsyn_folding='af'
let xml_syntax_folding=1

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

let g:ale_linters = {
\   'javascript': ['eslint'],
\   'typescript': ['tslint'],
\}
let g:ale_fixers = {
\   'javascript': ['eslint'],
\}

" Have ale report the linter that is saying whatever it is that's being said
let g:ale_echo_msg_format = '%linter%: %code: %%s'

" Put the fzf window to the right to not interfere with terminals (which i
" keep on the left)
let g:fzf_layout = {
\   'right': '~40%'
\}

" It's way more useful to see the diff against master than against the index
let g:gitgutter_diff_base = 'origin/master'


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
  autocmd WinLeave term://* :checktime
augroup end

augroup WindowManagement
  autocmd!

  " re-arrange windows on resize
  autocmd VimResized * wincmd =
augroup end


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

let g:gitgutter_map_keys = 0

" Keybindings
" nmap <leader>r
" nmap <leader>R
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
nmap <leader>gn :GitGutterNextHunk<CR>
nmap <Leader>gp :GitGutterPrevHunk<CR>
nmap <Leader>ga :GitGutterStageHunk<CR>
nmap <Leader>gu :GitGutterUndoHunk<CR>
nmap <Leader>gP :GitGutterPreviewHunk<CR>
nmap <leader>ne :edit .<CR>
nmap <leader>nt :NERDTreeFocus<CR>
nmap <leader>nf :NERDTreeFind<CR>
nmap <leader>ln :ALENext<CR>
nmap <leader>lf :ALEFix<CR>
nmap <leader>tt :terminal<CR>
" TODO: these don't work from  a new buffer for reasons that aren't clear to
" me; it seems that nothing works after a wincmd; i'll have to debug later
" with verbose
" nmap <leader>ts <C-w>v<CR> <Cmd>terminal bash -ic ts<CR>
" nmap <leader>tw <C-w>v<CR> <Cmd>terminal bash -ic tw<CR>
nmap <leader>fd :ALEGoToDefinition<CR>
nmap <leader>fr :ALEFindReferences<CR>
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

if has("digraphs")
  digraph .. 8230   " …
  digraph !? 8253   " ‽

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

  digraph ** 9733   " ★
  digraph <3 9829   " ♥
  digraph sw 9876   " ⚔ 
  digraph mc 10016  " ✠ 
  digraph ra 9762   " ☢ 
  digraph bh 9763   " ☣ 
  digraph ki 9812   " ♔ 
  digraph kn 9816   " ♘ 
endif

" emoji
abbreviate :beer: 🍺
abbreviate :beers: 🍻
abbreviate :hamster: 🐹

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
