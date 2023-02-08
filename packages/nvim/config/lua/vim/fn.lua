local M = {}

---The result is the name of a buffer.  Mostly as it is displayed
---by the `:ls` command, but not using special names such as
---"[No Name]".
---If `buf` is omitted the current buffer is used.
---If `buf` is a Number, that buffer number's name is given.
---Number zero is the alternate buffer for the current window.
---If `buf` is a String, it is used as a |file-pattern| to match
---with the buffer names.  This is always done like 'magic' is
---set and 'cpoptions' is empty.  When there is more than one
---match an empty string is returned.
---"" or "%" can be used for the current buffer, "#" for the
---alternate buffer.
---A full match is preferred, otherwise a match at the start, end
---or middle of the buffer name is accepted.  If you only want a
---full match then put "^" at the start and "$" at the end of the
---pattern.
---Listed buffers are found first.  If there is a single match
---with a listed buffer, that one is returned.  Next unlisted
---buffers are searched for.
---If the `buf` is a String, but you want to use it as a buffer
---number, force it to be a Number by adding zero to it:
---	:echo bufname("3" + 0)
---Can also be used as a |method|:
---	echo bufnr->bufname()
---If the buffer doesn't exist, or doesn't have a name, an empty
---string is returned.
---
---bufname("#")		alternate buffer name
---bufname(3)		name of buffer 3
---bufname("%")		name of current buffer
---bufname("file2")	name of buffer where "file2" matches.
---@param buf?
function M.bufname(buf)
end

return M
