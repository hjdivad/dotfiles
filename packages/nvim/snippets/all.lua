-- see https://github.com/L3MON4D3/LuaSnip/blob/d33cf7de14eea209b8ed4a7edaed72f0b8cedb30/Examples/snippets.lua#L191

local ls = require("luasnip")
-- some shorthands...
local s = ls.snippet
local sn = ls.snippet_node
local t = ls.text_node
local i = ls.insert_node
local f = ls.function_node
local c = ls.choice_node
local d = ls.dynamic_node
local r = ls.restore_node
local events = require("luasnip.util.events")
local util = require("luasnip.util.util")
local node_util = require("luasnip.nodes.util")
local l = require("luasnip.extras").lambda
local rep = require("luasnip.extras").rep
local p = require("luasnip.extras").partial
local m = require("luasnip.extras").match
local n = require("luasnip.extras").nonempty
local dl = require("luasnip.extras").dynamic_lambda
local fmt = require("luasnip.extras.fmt").fmt
local fmta = require("luasnip.extras.fmt").fmta
local types = require("luasnip.util.types")
local conds = require("luasnip.extras.conditions")
local conds_expand = require("luasnip.extras.conditions.expand")

local chronic = require("chronic")

--- Utility function for updating dynamic nodes from userland code
---
--- @ref <https://github.com/L3MON4D3/LuaSnip/wiki/Misc#dynamicnode-with-user-input>
local function find_dynamic_node(node)
  -- the dynamicNode-key is set on snippets generated by a dynamicNode only (its'
  -- actual use is to refer to the dynamicNode that generated the snippet).
  while not node.dynamicNode do
    node = node.parent
  end
  return node.dynamicNode
end

local external_update_id = 0
--- Utility function for updating dynamic nodes from userland code
---
--- @ref <https://github.com/L3MON4D3/LuaSnip/wiki/Misc#dynamicnode-with-user-input>
local function dynamic_node_external_update(func_indx)
  -- most of this function is about restoring the cursor to the correct
  -- position+mode, the important part are the few lines from
  -- `dynamic_node.snip:store()`.

  -- find current node and the innermost dynamicNode it is inside.
  local current_node = ls.session.current_nodes[vim.api.nvim_get_current_buf()]
  local dynamic_node = find_dynamic_node(current_node)

  -- to identify current node in new snippet, if it is available.
  external_update_id = external_update_id + 1
  current_node.external_update_id = external_update_id

  -- store which mode we're in to restore later.
  local insert_pre_call = vim.fn.mode() == "i"
  -- is byte-indexed! Doesn't matter here, but important to be aware of.
  local cursor_pos_pre_relative = util.pos_sub(util.get_cursor_0ind(), current_node.mark:pos_begin_raw())

  -- leave current generated snippet.
  node_util.leave_nodes_between(dynamic_node.snip, current_node)

  -- call update-function.
  local func = dynamic_node.user_args[func_indx]
  if func then
    -- the same snippet passed to the dynamicNode-function. Any output from func
    -- should be stored in it under some unused key.
    func(dynamic_node.parent.snippet)
  end

  -- last_args is used to store the last args that were used to generate the
  -- snippet. If this function is called, these will most probably not have
  -- changed, so they are set to nil, which will force an update.
  dynamic_node.last_args = nil
  dynamic_node:update()

  -- everything below here isn't strictly necessary, but it's pretty nice to have.

  -- try to find the node we marked earlier.
  local target_node = dynamic_node:find_node(function(test_node)
    return test_node.external_update_id == external_update_id
  end)

  if target_node then
    -- the node that the cursor was in when changeChoice was called exists
    -- in the active choice! Enter it and all nodes between it and this choiceNode,
    -- then set the cursor.
    node_util.enter_nodes_between(dynamic_node, target_node)

    if insert_pre_call then
      util.set_cursor_0ind(util.pos_add(target_node.mark:pos_begin_raw(), cursor_pos_pre_relative))
    else
      node_util.select_node(target_node)
    end
    -- set the new current node correctly.
    ls.session.current_nodes[vim.api.nvim_get_current_buf()] = target_node
  else
    -- the marked node wasn't found, just jump into the new snippet noremally.
    ls.session.current_nodes[vim.api.nvim_get_current_buf()] = dynamic_node.snip:jump_into(1)
  end
end

local tt_states = {
  start = 0,
  complete = 1,
}
local tt_state = tt_states.start

local ONE_DAY_SECS = 86400

local DATE_FORMAT_LONG = '%Y-%m-%d (%A)'
local DATE_FORMAT_SHORT = '%Y-%m-%d'
ls.add_snippets("all", {
  s("@today-long", {
    d(1, function ()
      return sn(nil, t(os.date(DATE_FORMAT_LONG)))
    end)
  }),
  s("@yestesrday-long", {
    d(1, function ()
      return sn(nil, t(os.date(DATE_FORMAT_LONG, os.time() - ONE_DAY_SECS)))
    end)
  }),
  s("@tomorrow-long", {
    d(1, function ()
      return sn(nil, t(os.date(DATE_FORMAT_LONG, os.time() + ONE_DAY_SECS)))
    end)
  }),
  s("@today-short", {
    d(1, function ()
      -- see man strftime
      local date_str =  os.date(DATE_FORMAT_SHORT)
    ---@diagnostic disable-next-line: param-type-mismatch
      local trimmed_date_str = date_str:gsub("^%s*(.-)%s*$", "%1")
      return sn(nil, t(trimmed_date_str))
    end)
  }),
  s("@now", {
    d(1, function ()
      -- see man strftime
      local datetime_str =  os.date('%Y-%m-%d %H:%M')
    ---@diagnostic disable-next-line: param-type-mismatch
      local trimmed_datetime_str = datetime_str:gsub("^%s*(.-)%s*$", "%1")
      return sn(nil, t(trimmed_datetime_str))
    end)
  }),

  -- see https://github.com/L3MON4D3/LuaSnip/wiki/Misc#dynamicnode-with-user-input
  -- plan is to
  --  1. reset state to 0
  --  2. return sn with inputs (date + format)
  --  3. on exit, mv state to 1 and run again
  --    4. this time return the computed date
  s("@date", {
    d(1, function(_args, snip)
      if tt_state == tt_states.start then
        return sn(nil, {
          t({ "", "" }),
          i(1, "Today"),
          t({ "", "" }),
          i(2, "Long"),
          t({ "", "" }),
          f(function(args)
            local date = args[1][1]
            local format = args[2][1]

            snip.date = date
            snip.format = format
          end, { 1, 2 }),
        })
      end

      tt_state = tt_states.start
      return sn(nil, {
        t(chronic.parse(snip.date, { format=snip.format})),
        i(1, ""),
      })
    end, {}, {
      user_args = {
        [1] = function()
          tt_state = tt_states.complete
        end,
      },
    }),
  }, {
    callbacks = {
      [1] = {
        [events.leave] = function()
          if tt_state == tt_states.start then
            dynamic_node_external_update(1)
          end
        end,
      },
    },
  }),
})
