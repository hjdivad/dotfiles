local init = require('hjdivad_init')

local main = init.main
local create_debug_functions = init.create_debug_functions

-- This actually runs init
main {
  plugins = 'all',
  mappings = true,
}

-- This only sets up utility functions but doesn't otherwise change options or
-- do anything
create_debug_functions()
