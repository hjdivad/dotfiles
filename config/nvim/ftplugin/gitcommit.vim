function! s:FinishCommitMessage()
  let l:commitMsgBuf = bufnr('%')
  let l:nvrChannelId = b:nvr[0]

  " TODO: find the "nearest" terminal window on this page
  wincmd j

  execute ':bdelete ' . l:commitMsgBuf
  call rpcnotify(l:nvrChannelId, 'BufDelete')
  execute ':start!'
endfunction

augroup GitCommitInNvim
  autocmd!
  autocmd BufWritePost COMMIT_EDITMSG call s:FinishCommitMessage()
augroup end
