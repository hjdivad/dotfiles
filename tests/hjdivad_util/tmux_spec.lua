local tmux = require("hjdivad_util.tmux")

describe("tmux", function()
	local assert = require("luassert")
	local pp = vim.print

	---@param tmux_cmd string[]
	local function tsys(tmux_cmd)
		local sys_cmd = { "tmux", "-L", "tmux_spec" }
		vim.list_extend(sys_cmd, tmux_cmd)
		local result = vim.system(sys_cmd):wait()

		if result.code ~= 0 then
			local cmd_str = table.concat(sys_cmd, " ")
			error(string.format("Command failed: %s\nError: %s", cmd_str, result.stderr))
		end
	end

	before_each(function()
		tsys({ "kill-server" })
	end)

	describe("get_tmux_panes", function()
		it("lists sessions with their windows", function()
			tsys({ "new-session", "-d", "-s", "foo", "-n", "a" })
			tsys({ "new-window", "-d", "-t", "foo", "-n", "b" })
			tsys({ "new-session", "-d", "-s", "bar", "-n", "c" })
			tsys({ "new-window", "-d", "-t", "bar", "-n", "d" })
			tsys({ "new-window", "-d", "-t", "bar", "-n", "e" })

			assert.same({
				{ pane_id = "%2", session_name = "bar", window_name = "c" },
				{ pane_id = "%3", session_name = "bar", window_name = "d" },
				{ pane_id = "%4", session_name = "bar", window_name = "e" },
				{ pane_id = "%0", session_name = "foo", window_name = "a" },
				{ pane_id = "%1", session_name = "foo", window_name = "b" },
			}, tmux.get_tmux_panes({ socket_name = "tmux_spec" }), "get_tmux_panes can read tmux list-panes")
		end)
	end)
end)
