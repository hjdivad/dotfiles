let mapleader = ','
let maplocalleader = ','

set noswapfile
set backupdir=/private/tmp
set dir=/private/tmp
set clipboard=unnamed

" Ignore conflicting swap files.
" autocmd SwapExists * let v:swapchoice='e'


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

" These two seem to do something very similar
Plug 'nathanaelkane/vim-indent-guides'
Plug 'Yggdroot/indentLine'

" autoclose quotes &c.  Definitely not sure if I want this
Plug 'Raimondi/delimitMate'

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
" make vim a lang-server for typescript
Plug 'Quramy/tsuquyomi'
Plug 'mustache/vim-mustache-handlebars'
Plug 'rust-lang/rust.vim'
Plug 'pangloss/vim-javascript'
Plug 'dag/vim-fish'

Plug 'altercation/vim-colors-solarized'

call plug#end()

set background=dark
colorscheme solarized

" Simple snippets in mustache files
let g:mustache_abbreviations = 1

" Spaces vs tabs
set tabstop=2
set softtabstop=2
set shiftwidth=2
set expandtab

set number
set relativenumber

" Terminal mode output buffer
set scrollback=1000

set iskeyword+=-

set foldlevelstart=0
set foldnestmax=5
set foldmethod=syntax
set foldenable

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

set smartindent
set autoindent

set lazyredraw

" Switch modified buffers without being forced to save
set hidden

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


" Replace this with r, R similar
"
" function! REPLSend(lines)
"   call jobsend(g:repl_terminal_job, add(a:lines, ''))
" endfunction

" function! R(command)
"   call jobsend(g:repl_terminal_job, a:command . "\n")
" endfunction

" function! Repl()
"   e term://fish
"   let g:repl_terminal_job = b:terminal_job_id
" endfunction

if has('nvim')
  let $GIT_EDITOR='nvr -cc split --remote-wait'
end

" TODO: continue https://github.com/hjdivad/vim-config

" Keybindings
" nmap <leader>r
" nmap <leader>R
nmap <leader>fg :GFiles<CR>
nmap <leader>ff :Files<CR>
nmap <leader>fs :GFiles?<CR>
nmap <leader>fb :Buffers<CR>
nmap <leader>gn :GitGutterNextHunk<CR>
nmap <Leader>ga :GitGutterStageHunk<CR>
nmap <Leader>gu :GitGutterRevertHunk<CR>
nmap <leader>nt :NERDTreeToggle<CR>
nmap <leader>nf :NERDTreeFocus<CR>
nmap <leader>tt :terminal<CR>
" nnoremap <CR> :nohl<CR>

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

" No arrow keys
noremap <Up> <NOP>
noremap <Down> <NOP>
noremap <Left> <NOP>
noremap <Right> <NOP>

" Project-specific .vimrc and .vim
if !(getcwd() == $HOME)
  if filereadable(".vimrc")
    source .vimrc
  endif
  set runtimepath+=./.vim
endif
