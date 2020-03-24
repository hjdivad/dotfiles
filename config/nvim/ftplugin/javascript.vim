" rely on local prettierrc for decent options like single quote, print width
" 120 &c.
let &l:formatprg = "prettier --stdin --stdin-filepath " . expand('%')
