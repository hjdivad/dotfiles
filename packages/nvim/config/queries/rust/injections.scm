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
;

; TODO: This works but rust-analyzer clears the highlighting after it
; initializes.
;
; (macro_invocation
;   macro: [
;     (scoped_identifier
;       name: (_) @_macro_name)
;     (identifier) @_macro_name
;   ]
;   (token_tree
;     (raw_string_literal
;       (string_content) @injection.content))
;   (#eq? @_macro_name "lua")
;   (#offset! @injection.content 0 1 0 -1)
;   (#set! injection.language "lua")
;   (#set! injection.include-children))
