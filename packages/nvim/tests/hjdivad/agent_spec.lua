describe("agent", function()
  local assert = require("luassert")
  local stub = require("luassert.stub")
  local agent = require("hjdivad.agent")

  local original_agents_prompt
  local original_agents_vadnu
  local original_agent_cmd
  local stdpath_stub
  local getcwd_stub
  local original_cmd
  local original_defer_fn

  local function restore_env()
    vim.env.AGENTS_PROMPT = original_agents_prompt
    vim.env.AGENTS_VADNU = original_agents_vadnu
    vim.env.NVIM_AGENT_CMD = original_agent_cmd
  end

  before_each(function()
    original_agents_prompt = vim.env.AGENTS_PROMPT
    original_agents_vadnu = vim.env.AGENTS_VADNU
    original_agent_cmd = vim.env.NVIM_AGENT_CMD
    vim.env.AGENTS_PROMPT = nil
    vim.env.AGENTS_VADNU = nil
    vim.env.NVIM_AGENT_CMD = nil
    original_cmd = vim.cmd
    original_defer_fn = vim.defer_fn
  end)

  after_each(function()
    restore_env()

    if stdpath_stub then
      stdpath_stub:revert()
      stdpath_stub = nil
    end

    if getcwd_stub then
      getcwd_stub:revert()
      getcwd_stub = nil
    end

    vim.cmd = original_cmd
    vim.defer_fn = original_defer_fn
  end)

  describe("_agent_paths", function()
    it("uses cache prompt paths as fallbacks", function()
      stdpath_stub = stub(vim.fn, "stdpath", function(name)
        assert.equals("cache", name)
        return "/cache"
      end)

      assert.same({
        prompt = "/cache/prompt/github/repo.prompt.md",
        vadnu = "/cache/prompt/github/repo.vadnu.md",
      }, agent._agent_paths("/Users/me/github/repo"))
    end)

    it("uses env var paths without expanding them", function()
      stdpath_stub = stub(vim.fn, "stdpath", function()
        return "/cache"
      end)
      vim.env.AGENTS_PROMPT = "relative/prompt.md"
      vim.env.AGENTS_VADNU = "~/relative/vadnu.md"

      assert.same({
        prompt = "relative/prompt.md",
        vadnu = "~/relative/vadnu.md",
      }, agent._agent_paths("/Users/me/github/repo"))
    end)

    it("falls back independently for unset env vars", function()
      stdpath_stub = stub(vim.fn, "stdpath", function()
        return "/cache"
      end)
      vim.env.AGENTS_PROMPT = "prompt.md"

      assert.same({
        prompt = "prompt.md",
        vadnu = "/cache/prompt/github/repo.vadnu.md",
      }, agent._agent_paths("/Users/me/github/repo"))
    end)
  end)

  describe("_ensure_vadnu_file", function()
    it("creates vadnu.md with a tasks section when missing", function()
      local path = vim.fn.tempname() .. "/vadnu.md"

      agent._ensure_vadnu_file(path)

      assert.same({ "## Tasks" }, vim.fn.readfile(path))
    end)

    it("leaves existing vadnu.md content alone", function()
      local path = vim.fn.tempname() .. "/vadnu.md"
      vim.fn.mkdir(vim.fn.fnamemodify(path, ":h"), "p")
      vim.fn.writefile({ "custom" }, path)

      agent._ensure_vadnu_file(path)

      assert.same({ "custom" }, vim.fn.readfile(path))
    end)
  end)

  describe("StartAgent", function()
    local function start_command(agent_name)
      local root = vim.fn.tempname()
      vim.env.AGENTS_VADNU = root .. "/vadnu.md"
      vim.env.AGENTS_PROMPT = root .. "/prompt.md"
      getcwd_stub = stub(vim.fn, "getcwd", function()
        return "/Users/me/github/repo"
      end)

      local terminal_command
      vim.cmd = function(cmd)
        if cmd:sub(1, 5) == "term " then
          terminal_command = cmd
        end
      end
      vim.defer_fn = function() end

      agent.StartAgent(agent_name)
      return terminal_command
    end

    it("uses NVIM_AGENT_CMD for the default agent", function()
      vim.env.NVIM_AGENT_CMD = "custom-agent --flag value"

      assert.equals("term custom-agent --flag value", start_command())
    end)

    it("uses codex when NVIM_AGENT_CMD is unset", function()
      assert.equals("term codex", start_command())
    end)

    it("uses codex when NVIM_AGENT_CMD is empty", function()
      vim.env.NVIM_AGENT_CMD = ""

      assert.equals("term codex", start_command())
    end)

    it("opens the three-column agent layout with terminals on the left and vadnu above prompt in the middle", function()
      vim.env.NVIM_AGENT_CMD = "custom-agent --flag value"
      local root = vim.fn.tempname()
      vim.env.AGENTS_VADNU = root .. "/vadnu.md"
      vim.env.AGENTS_PROMPT = root .. "/prompt.md"
      getcwd_stub = stub(vim.fn, "getcwd", function()
        return "/Users/me/github/repo"
      end)

      local commands = {}
      local deferred
      local defer_delay
      vim.cmd = function(cmd)
        table.insert(commands, cmd)
      end
      vim.defer_fn = function(callback, delay)
        deferred = callback
        defer_delay = delay
      end

      agent.StartAgent("cursor")

      assert.same({
        "tabnew",
        "rightbelow vsplit",
        "rightbelow vsplit",
        "term cursor-agent --force --approve-mcps",
        "wincmd h",
        "edit " .. vim.fn.fnameescape(vim.env.AGENTS_VADNU),
        "rightbelow split",
        "edit " .. vim.fn.fnameescape(vim.env.AGENTS_PROMPT),
        "setlocal winfixheight",
        "resize 15",
        "wincmd h",
        "terminal",
        "rightbelow split",
        "terminal",
        "wincmd l",
      }, commands)
      assert.same({ "## Tasks" }, vim.fn.readfile(vim.env.AGENTS_VADNU))
      assert.equals(0, vim.fn.filereadable(vim.env.AGENTS_PROMPT))

      assert.is_function(deferred)
      assert.equals(100, defer_delay)
      deferred()
      assert.equals("wincmd =", commands[#commands])
    end)
  end)

  describe("StartExternalAgentWorkspace", function()
    local original_agents_project
    local original_p
    local original_neotree_command
    local original_neotree_manager
    local original_neotree_renderer
    local get_current_win_stub
    local set_current_win_stub

    local ops
    local tree_state
    local focused_win

    local terminal_grid = {
      "tabnew",
      "terminal",
      "rightbelow vsplit",
      "terminal",
      "rightbelow split",
      "terminal",
      "wincmd h",
      "rightbelow split",
      "terminal",
      "wincmd =",
    }

    local function concat(...)
      local result = {}
      for _, list in ipairs({ ... }) do
        vim.list_extend(result, list)
      end
      return result
    end

    before_each(function()
      original_agents_project = vim.env.AGENTS_PROJECT
      original_p = vim.env.P
      vim.env.AGENTS_PROJECT = nil
      vim.env.P = nil

      ops = {}
      tree_state = nil
      focused_win = nil

      original_neotree_command = package.loaded["neo-tree.command"]
      original_neotree_manager = package.loaded["neo-tree.sources.manager"]
      original_neotree_renderer = package.loaded["neo-tree.ui.renderer"]
      package.loaded["neo-tree.command"] = {
        execute = function(args)
          table.insert(ops, {
            neotree = args,
            bind_to_cwd = tree_state.bind_to_cwd,
          })
          tree_state._ready = true
        end,
      }
      package.loaded["neo-tree.sources.manager"] = {
        get_state = function(source)
          assert.equals("filesystem", source)
          -- a fresh per-tab state, as neo-tree creates for each tab
          tree_state = { bind_to_cwd = true }
          return tree_state
        end,
      }
      package.loaded["neo-tree.ui.renderer"] = {
        window_exists = function(state)
          return state == tree_state
        end,
      }

      getcwd_stub = stub(vim.fn, "getcwd", function()
        return "/Users/me/github/repo"
      end)

      local tab = 1
      vim.cmd = function(cmd)
        if cmd == "tabnew" then
          tab = tab + 1
        end
        table.insert(ops, cmd)
      end
      get_current_win_stub = stub(vim.api, "nvim_get_current_win", function()
        return 1000 + tab
      end)
      set_current_win_stub = stub(vim.api, "nvim_set_current_win", function(win)
        focused_win = win
        table.insert(ops, { focus = win })
      end)
    end)

    after_each(function()
      vim.env.AGENTS_PROJECT = original_agents_project
      vim.env.P = original_p
      package.loaded["neo-tree.command"] = original_neotree_command
      package.loaded["neo-tree.sources.manager"] = original_neotree_manager
      package.loaded["neo-tree.ui.renderer"] = original_neotree_renderer
      get_current_win_stub:revert()
      set_current_win_stub:revert()
    end)

    local function tree(dir)
      return {
        neotree = { action = "show", source = "filesystem", dir = dir },
        bind_to_cwd = false,
      }
    end

    local function project_workspace(project)
      return concat(
        { tree("/Users/me/github/repo") },
        {
          "tabnew",
          "edit " .. vim.fn.fnameescape(project .. "/vadnu.md"),
          tree(project),
        },
        terminal_grid,
        { { focus = 1002 } }
      )
    end

    it("opens cwd tree, unbound project tree with vadnu.md, and a terminal grid", function()
      local project = vim.fn.tempname()
      vim.env.AGENTS_PROJECT = project

      agent.StartExternalAgentWorkspace()

      assert.same(project_workspace(project), ops)
      assert.same({ "## Tasks" }, vim.fn.readfile(project .. "/vadnu.md"))
      assert.equals(1002, focused_win)
    end)

    it("falls back to $P when AGENTS_PROJECT is empty", function()
      local project = vim.fn.tempname()
      vim.env.AGENTS_PROJECT = ""
      vim.env.P = project

      agent.StartExternalAgentWorkspace()

      assert.same(project_workspace(project), ops)
      assert.equals(1002, focused_win)
    end)

    it("skips the project tab and focuses tab 1 without a project", function()
      agent.StartExternalAgentWorkspace()

      assert.same(concat({ tree("/Users/me/github/repo") }, terminal_grid, { { focus = 1001 } }), ops)
      assert.equals(1001, focused_win)
    end)

    it("warns and continues when a tree is not ready in time", function()
      package.loaded["neo-tree.ui.renderer"].window_exists = function()
        return false
      end
      local wait_stub = stub(vim, "wait", function(_, predicate)
        return predicate()
      end)
      local notify_stub = stub(vim, "notify")

      agent.StartExternalAgentWorkspace()

      wait_stub:revert()
      notify_stub:revert()
      assert.stub(notify_stub).was_called_with(
        "Timed out waiting for neo-tree at /Users/me/github/repo",
        vim.log.levels.WARN
      )
      assert.equals(1001, focused_win)
    end)
  end)
end)
