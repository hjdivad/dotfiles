describe("zellij", function()
  local assert = require("luassert")
  local stub = require("luassert.stub")
  local zellij = require("hjdivad.zellij")

  local winnr_stub
  local cmd_stub
  local system_stub

  after_each(function()
    if winnr_stub then
      winnr_stub:revert()
      winnr_stub = nil
    end
    if cmd_stub then
      cmd_stub:revert()
      cmd_stub = nil
    end
    if system_stub then
      system_stub:revert()
      system_stub = nil
    end
  end)

  local function stub_winnr(edge_dir, at_edge)
    return stub(vim.fn, "winnr", function(dir)
      if dir == nil then
        return 1
      end
      if dir == edge_dir then
        return at_edge and 1 or 2
      end
      return 2
    end)
  end

  local cases = {
    { name = "winleft", zellij_dir = "left", wincmd_dir = "h" },
    { name = "winright", zellij_dir = "right", wincmd_dir = "l" },
    { name = "winup", zellij_dir = "up", wincmd_dir = "k" },
    { name = "windown", zellij_dir = "down", wincmd_dir = "j" },
  }

  for _, case in ipairs(cases) do
    describe(case.name, function()
      it("uses zellij when at the edge", function()
        winnr_stub = stub_winnr(case.wincmd_dir, true)
        cmd_stub = stub(vim, "cmd")
        system_stub = stub(vim, "system")

        zellij[case.name]()

        assert.stub(vim.system).was_called_with({ "zellij", "action", "move-focus", case.zellij_dir })
        assert.stub(vim.cmd).was_not_called()
      end)

      it("uses wincmd when a window exists", function()
        winnr_stub = stub_winnr(case.wincmd_dir, false)
        cmd_stub = stub(vim, "cmd")
        system_stub = stub(vim, "system")

        zellij[case.name]()

        assert.stub(vim.cmd).was_called_with("wincmd " .. case.wincmd_dir)
        assert.stub(vim.system).was_not_called()
      end)
    end)
  end
end)
