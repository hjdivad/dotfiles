local function main()
  local succ, exrc = pcall(require, 'hjdivad/exrc')

  -- TODO: this check is only necessary b/c this isn't managed as a plugin
  if not succ then
    print('skipping exrc, dependencies not loaded')
    return
  end

  exrc.run_if_setup(function()
    exrc.run_exrc()
  end)
end

main()
