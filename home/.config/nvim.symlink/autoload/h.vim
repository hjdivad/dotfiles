" home.vim
" 
" A file for autoload functions that I want to share from dotfiles to
" project-specific .vimrc


function h#DebugNearest()
  let t:test_debugging = 1
  exe 'TestNearest'
  let t:test_debugging = 0
endfunction


function h#EditREPL(repl_cmd, repl_file)
  if has_key(g:neoterm, 'repl') && has_key(g:neoterm.repl, 'instance_id')
    exe 'edit ' . a:repl_file
  else
    let starting_bufnr = bufnr()
    100wincmd h
    100wincmd k
    wincmd n
    exe "Tnew"
    exe g:neoterm.last_id . 'T ' . a:repl_cmd
    exe "TREPLSetTerm " . g:neoterm.last_id
    stopinsert

    exe bufwinnr(starting_bufnr) . 'wincmd w'
    exe 'edit ' . a:repl_file
  endif
endfunction
