augroup ExtraTypes
  autocmd!

  autocmd BufRead,BufNewFile *-test.js set ft+=.qunit
augroup end

fun! s:InitializeWorkspace()
  if !(&ft =~ 'gitcommit' || &ft =~ 'gitrebase' || expand('%') == '.git/PULLREQ_EDITMSG')
    wincmd v | exec "term" | wincmd n | exec "term"
  endif
endfunction

augroup Workspace
  autocmd!

  autocmd VimEnter * ++nested call s:InitializeWorkspace()
augroup end
