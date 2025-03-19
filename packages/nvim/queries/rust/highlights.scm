; extends
;
; using @comment @text.todo @text.underline captures to debug queries
;
; see he: treesitter-highlight
;
; (macro_invocation
;     macro: (identifier) @macro.name
;     (#match? @macro.name "^sql$")
;     (token_tree
;       (string_literal
;         "\"" @comment
;         "\"" @comment) @text.todo))
