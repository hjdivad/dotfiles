; extends
;
; example code-fence aliasing
;
; (fenced_code_block
;   (info_string) @language
;   (#match? @language "^ts-alias")
;
;   (code_fence_content) @injection.content
;   (#set! injection.language "typescript")
;  )
