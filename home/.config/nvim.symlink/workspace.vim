let s:wrapped = ($NVIM_WRAPPER =~ "1")

fun! s:InitializeWorkspace()
  if !s:wrapped
    vertical topleft Topen
  endif
endfunction

augroup Workspace
  autocmd!

  autocmd VimEnter * ++nested call s:InitializeWorkspace()
augroup end
