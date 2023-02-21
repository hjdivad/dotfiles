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

local time_state = 0
local ix = 0
ls.add_snippets("all", {
  -- see https://github.com/L3MON4D3/LuaSnip/wiki/Misc#dynamicnode-with-user-input
  -- plan is to
  --  1. reset state to 0
  --  2. return sn with inputs (date + format)
  --  3. on exit, mv state to 1 and run again
  --    4. this time return the computed date
  s("::tt", {
    d(1, { })
  })

  -- s("::tt::", {
  --   i(1, "Date"),
  --   t({ "", "" }),
  --   i(2, "Format"),
  --   t({ "", "" }),
  --   f(function(args, snip)
  --     -- vim.pretty_print(ix, args)
  --     local date = args[1][1]
  --     local format = args[2][1]
  --
  --     if time_state == 0 then
  --       return "[0] call: " .. ix
  --     end
  --
  --     args[1] = ''
  --     return "[1] call: " .. ix
  --   end, { 1, 2, } ),
  -- },{
  --     callbacks = {
  --       [1] = {
  --         [events.enter] = function (node, event_args)
  --           time_state = 0
  --         end,
  --       },
  --       [2] = {
  --         [events.leave] = function (node, event_args)
  --           time_state = 1
  --         end,
  --       },
  --     }
  --   }
  -- ),
})
