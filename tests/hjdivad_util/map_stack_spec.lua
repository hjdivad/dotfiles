describe("map_stack", function()
	local assert = require("luassert")
	local pp = vim.print
	---@type MapStack
	local map_stack = require("hjdivad_util/map_stack")

	local function filter_keymaps(keymaps, properties)
		local result = {}
		for _, keymap in ipairs(keymaps) do
			local filtered_keymap = {}
			for _, property in ipairs(properties) do
				filtered_keymap[property] = keymap[property]
			end
			table.insert(result, filtered_keymap)
		end
		return result
	end

	---@param mode string
	---@param properties table<string>
	local function get_keymaps(mode, properties)
		return filter_keymaps(vim.api.nvim_get_keymap(mode), properties)
	end

	---@param buffer integer
	---@param mode string
	---@param properties table<string>
	local function get_buf_keymaps(buffer, mode, properties)
		return filter_keymaps(vim.api.nvim_buf_get_keymap(buffer, mode), properties)
	end

	local ALL_MODES = {
		"n", -- normal
		"i", -- insert
		"v", -- visual + select
		-- "x", -- visual
		-- "s", -- select
		"o", -- operator-pending
		"t", -- terminal
	}

	local function delete_all_keymaps()
		for _, mode in ipairs(ALL_MODES) do
			for _, keymap in ipairs(get_keymaps(mode, { "lhs" })) do
				local lhs = keymap["lhs"]
				vim.keymap.del(mode, lhs)
			end
		end
	end

	before_each(function()
		map_stack._debug().reset()
		delete_all_keymaps()
	end)

	-- see he: vim.keymap.set
	it("push(cb) can set a keymap", function()
		assert.same({}, get_keymaps("n", { "lhs" }), "Initially no keymaps")
		map_stack.push(function(keymap)
			keymap.set("n", ";;test", "ok")
		end)
		assert.same({ { lhs = ";;test", rhs = "ok" } }, get_keymaps("n", { "lhs", "rhs" }), "keymap is added in stack")
	end)

	it("push(cb) can delete a keymap", function()
		vim.keymap.set("n", ";;test", "ok")
		assert.same({ { lhs = ";;test" } }, get_keymaps("n", { "lhs" }), "Initially 1 keymap")
		map_stack.push(function(keymap)
			keymap.del("n", ";;test")
		end)
		assert.same({}, get_keymaps("n", { "lhs" }), "keymap is deleted")
	end)

	it("keymaps can be restored (nothing -> set)", function()
		assert.same({}, get_keymaps("n", { "lhs" }), "Initially no keymaps")
		map_stack.push(function(keymap)
			keymap.set("n", ";;test", "ok")
		end)
		assert.same({ { lhs = ";;test", rhs = "ok" } }, get_keymaps("n", { "lhs", "rhs" }), "keymap is added in stack")

		map_stack.pop()
		assert.same({}, get_keymaps("n", { "lhs" }), "keymaps restored")
	end)

	it("keymaps can be restored (keymap -> set)", function()
		vim.keymap.set("n", ";;test", "ok")
		assert.same({ { lhs = ";;test" } }, get_keymaps("n", { "lhs" }), "Initially 1 keymap")
		map_stack.push(function(keymap)
			keymap.set("n", ";;test", "updated")
		end)
		assert.same({ { lhs = ";;test", rhs = "updated" } }, get_keymaps("n", { "lhs", "rhs" }), "keymap is shadowed")

		map_stack.pop()
		assert.same({ { lhs = ";;test", rhs = "ok" } }, get_keymaps("n", { "lhs", "rhs" }), "keymaps restored")
	end)

	it("keymaps can be restored (non-normalized lhs)", function()
		vim.keymap.set("n", "<c-P>", "rhs-init")
		assert.same({ { lhs = "<C-P>" } }, get_keymaps("n", { "lhs" }), "Initially 1 keymap")
		map_stack.push(function(keymap)
			keymap.set("n", "<C-P>", "updated")
		end)
		assert.same({ { lhs = "<C-P>", rhs = "updated" } }, get_keymaps("n", { "lhs", "rhs" }), "keymap is shadowed")

		map_stack.pop()
		assert.same({ { lhs = "<C-P>", rhs = "rhs-init" } }, get_keymaps("n", { "lhs", "rhs" }), "keymaps restored")
	end)

	it("keymaps can be restored (keymap -> del)", function()
		vim.keymap.set("n", ";;test", "init")
		assert.same({ { lhs = ";;test" } }, get_keymaps("n", { "lhs" }), "Initially 1 keymap")
		map_stack.push(function(keymap)
			keymap.del("n", ";;test")
		end)
		assert.same({}, get_keymaps("n", { "lhs" }), "keymap is deleted")

		map_stack.pop()
		assert.same({ { lhs = ";;test", rhs = "init" } }, get_keymaps("n", { "lhs", "rhs" }), "keymaps restored")
	end)

	it("keymaps can be restored over multiple frames", function()
		vim.keymap.set("n", ";;km2", "init")
		vim.keymap.set("n", ";;km1", "init")
		assert.same({
			{ lhs = ";;km1", rhs = "init" },
			{ lhs = ";;km2", rhs = "init" },
		}, get_keymaps("n", { "lhs", "rhs" }), "Initially 1 keymap")

		map_stack.push(function(keymap)
			keymap.set("n", ";;km1", "updated1")
		end)
		assert.same({
			{ lhs = ";;km1", rhs = "updated1" },
			{ lhs = ";;km2", rhs = "init" },
		}, get_keymaps("n", { "lhs", "rhs" }), "stack 1 - one keymap shadowed")

		map_stack.push(function(keymap)
			keymap.set("n", ";;km1", "updated2")
			keymap.del("n", ";;km2")
		end)
		assert.same({
			{ lhs = ";;km1", rhs = "updated2" },
		}, get_keymaps("n", { "lhs", "rhs" }), "stack 2 - one shadowed/one del")
		--
		map_stack.push(function(keymap)
			keymap.del("n", ";;km1")
		end)
		assert.same({}, get_keymaps("n", { "lhs", "rhs" }), "stack 3 - both del")

		map_stack.pop()
		assert.same({
			{ lhs = ";;km1", rhs = "updated2" },
		}, get_keymaps("n", { "lhs", "rhs" }), "stack 2 - one shadowed/one del")

		map_stack.pop()
		assert.same({
			{ lhs = ";;km2", rhs = "init" },
			{ lhs = ";;km1", rhs = "updated1" },
		}, get_keymaps("n", { "lhs", "rhs" }), "stack 1 - one keymap shadowed")

		map_stack.pop()
		assert.same({
			{ lhs = ";;km1", rhs = "init" },
			{ lhs = ";;km2", rhs = "init" },
		}, get_keymaps("n", { "lhs", "rhs" }), "keymaps restored")
	end)

	it("keymap stacks work with other modes", function()
		local modes = ALL_MODES

		for _, mode in ipairs(modes) do
			assert.same(get_keymaps(mode, { "lhs" }), {}, mode .. " - initial keymaps")
		end

		map_stack.push(function(keymap)
			keymap.set(modes, ";;km1", "ok")
		end)
		for _, mode in ipairs(modes) do
			assert.same({ { lhs = ";;km1" } }, get_keymaps(mode, { "lhs" }), mode .. " - stack1")
		end

		map_stack.pop()
		for _, mode in ipairs(modes) do
			assert.same(get_keymaps(mode, { "lhs" }), {}, mode .. " - restored")
		end
	end)

	--TODO: what options? silent?
	--  nowait
	--  silent
	--  script
	--  unique
	--  noremap
	--  replace_keycodes
	--  desc
	--  callback
	it("keymaps can shadow by options only", function()
		local props = { "expr", "lhs", "lhsraw", "rhs", "noremap", "nowait", "silent" }
		vim.keymap.set("n", ";;km", "init")
		assert.same({
			{
				expr = 0,
				lhs = ";;km",
				lhsraw = ";;km",
				rhs = "init",
				noremap = 1,
				nowait = 0,
				silent = 0,
			},
		}, get_keymaps("n", props), "initial keymaps")

		map_stack.push(function(keymap)
			keymap.set("n", ";;km", "stack1", { nowait = true, silent = true, remap = true })
			keymap.set("n", ";;km2", '"stack1"', { expr = true, replace_keycodes = true })
		end)
		assert.same({
			{
				expr = 1,
				lhs = ";;km2",
				lhsraw = ";;km2",
				rhs = '"stack1"',
				noremap = 1,
				nowait = 0,
				silent = 0,
			},
			{
				expr = 0,
				lhs = ";;km",
				lhsraw = ";;km",
				rhs = "stack1",
				noremap = 0,
				nowait = 1,
				silent = 1,
			},
		}, get_keymaps("n", props), "stack1 keymaps")

		map_stack.pop()
		assert.same({
			{
				expr = 0,
				lhs = ";;km",
				lhsraw = ";;km",
				rhs = "init",
				noremap = 1,
				nowait = 0,
				silent = 0,
			},
		}, get_keymaps("n", props), "keymaps restored")
	end)

	it("keymaps with callbacks", function()
		assert.same({}, get_keymaps("n", { "lhs" }), "init")

		local function hello()
			return "hello"
		end

		map_stack.push(function(keymap)
			keymap.set("n", ";;km", hello)
		end)
		assert.same(
			{ {
				lhs = ";;km",
				callback = hello,
			} },
			get_keymaps("n", { "lhs", "rhs", "callback" }),
			"stack1"
		)

		map_stack.pop()
		assert.same({}, get_keymaps("n", { "lhs" }), "restored")
	end)

  -- TODO: update push_restore so it supports buffer keymaps
  --
	-- it("keymap stacks work with buffer-local keys", function()
	-- 	vim.api.nvim_buf_set_keymap(0, "n", ";;km", "init", {})
	-- 	assert.same({ { lhs = ";;km" } }, get_buf_keymaps(0, "n", { "lhs" }), "init")
	--
	-- 	map_stack.push(function(keymap)
	-- 		keymap.buf.del(0, "n", ";;km")
	-- 		keymap.buf.set(0, "n", ";;km2", "ok")
	-- 	end)
	-- 	assert.same({ { lhs = ";;km2" } }, get_buf_keymaps(0, "n", { "lhs" }), "stack1")
	--
	-- 	map_stack.pop()
	-- 	assert.same({ { lhs = ";;km" } }, get_buf_keymaps(0, "n", { "lhs" }), "restored")
	-- end)
end)
