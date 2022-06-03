local function main()
  local exrc = require('hjdivad/exrc')

  exrc.run_if_setup(function()
    exrc.run_exrc()
  end)
end

main()
