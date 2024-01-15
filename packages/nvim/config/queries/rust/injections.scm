;
; "$HOME/.config/nvim/queries/rust/injections.scm
;
; extends
;
; (macro_invocation
;   macro: (identifier) @macro.name
;   (#match? @macro.name "^sql$")
;   (token_tree
;     (string_literal) @injection.content)
;   (#offset! @injection.content 0 1 0 -1)
;   (#set! injection.language "sql"))
