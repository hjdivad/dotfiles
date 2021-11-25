" force ft=handlebars instead of html.handlebars
"
" html doesn't add anything I care about and it conflicts with coc-prettier
" I'd be happy to drop this if coc-prettier supported &filetype containing
" multiple filetypes
"
" Still requires https://github.com/neoclide/coc-prettier/pull/99 to format
" handlebars on save.
if stridx(&filetype, "html") > -1
  set ft=handlebars
endif
