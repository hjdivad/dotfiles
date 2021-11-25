let ws = $HOME . "/.config/nvim/workspace.vim"
if filereadable(ws)
  execute "source " . ws
endif


" function s:RunTestWithExtraEnv()
"   let t:env_extra = ['MY_ENV_VAR=1']
"   exe 'TestNearest'
"   let t:env_extra = []
" endfunction

" function s:DebugTestWithExtraEnv()
"   let t:env_extra = ['MY_ENV_VAR=1']
"   call s:DebugNearest()
"   let t:env_extra = []
" endfunction

" nmap <leader>rT :call <SID>RecordTestNearest()<CR>
" nmap <leader>rD :call <SID>RecordDebugNearest()<CR>


" h#EditREPL(repl_cmd, repl_buffer_name)
" nmap <leader>re :call h#EditREPL('yarn repl', '.repl.ts')<CR>
" vmap <leader>re :TREPLSendSelection<CR>



