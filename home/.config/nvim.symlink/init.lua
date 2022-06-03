local init = require('hjdivad')

-- This actually runs init
init.main {
  plugins = 'all',
  mappings = true,
}

-- This only sets up utility functions but doesn't otherwise change options or
-- do anything
init.create_debug_functions()
