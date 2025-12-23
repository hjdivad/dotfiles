local agent = require("hjdivad.agent")

describe("agent StartAgentPrompt", function()
  local assert = require("luassert")
  local stub = require("luassert.stub")

  local system_stub
  local mkdir_stub
  local cmd_stub
  local echo_stub
  local expand_stub
  local lstat_stub
  local unlink_stub
  local symlink_stub

  local mkdir_calls
  local cmd_calls
  local echo_calls
  local unlink_calls
  local symlink_calls
  local lstat_responses

  local function revert_stubs()
    if system_stub then
      system_stub:revert()
      system_stub = nil
    end
    if mkdir_stub then
      mkdir_stub:revert()
      mkdir_stub = nil
    end
    if cmd_stub then
      cmd_stub:revert()
      cmd_stub = nil
    end
    if echo_stub then
      echo_stub:revert()
      echo_stub = nil
    end
    if expand_stub then
      expand_stub:revert()
      expand_stub = nil
    end
    if lstat_stub then
      lstat_stub:revert()
      lstat_stub = nil
    end
    if unlink_stub then
      unlink_stub:revert()
      unlink_stub = nil
    end
    if symlink_stub then
      symlink_stub:revert()
      symlink_stub = nil
    end
  end

  local function stub_system(responses)
    system_stub = stub(vim.fn, "system", function(cmd)
      local key = type(cmd) == "table" and table.concat(cmd, " ") or cmd
      local resp = responses[key]
      if resp == nil then
        vim.v = { shell_error = 1 }
        return ""
      end

      vim.v = { shell_error = resp.code or 0 }
      return resp.out
    end)
  end

  before_each(function()
    mkdir_calls = {}
    cmd_calls = {}
    echo_calls = {}
    unlink_calls = {}
    symlink_calls = {}
    lstat_responses = {}

    mkdir_stub = stub(vim.fn, "mkdir", function(path, flags)
      table.insert(mkdir_calls, { path = path, flags = flags })
    end)

    cmd_stub = stub(vim, "cmd", function(cmd)
      table.insert(cmd_calls, cmd)
    end)

    echo_stub = stub(vim.api, "nvim_echo", function(msg, history, opts)
      table.insert(echo_calls, { msg = msg, history = history, opts = opts })
    end)

    expand_stub = stub(vim.fn, "expand", function(path)
      return path:gsub("%$HOME", "/home/test")
    end)

    lstat_stub = stub(vim.loop, "fs_lstat", function(path)
      local resp = lstat_responses[path]
      if resp == nil then
        return nil, "ENOENT"
      end
      return resp
    end)

    unlink_stub = stub(vim.loop, "fs_unlink", function(path)
      table.insert(unlink_calls, path)
      return true
    end)

    symlink_stub = stub(vim.loop, "fs_symlink", function(target, path)
      table.insert(symlink_calls, { target = target, path = path })
      return true
    end)
  end)

  after_each(function()
    revert_stubs()
  end)

  it("opens prompt in linked worktree on work branch", function()
    stub_system({
      ["git rev-parse --absolute-git-dir"] = { out = "/repo/.git/worktrees/wt\n" },
      ["git rev-parse --show-toplevel"] = { out = "/tmp/repo-wt\n" },
      ["git rev-parse --abbrev-ref HEAD"] = { out = "hjdivad/uc-123/extra\n" },
    })

    agent.StartAgentPrompt()

    assert.same({ { path = "/tmp/repo-wt/.uc", flags = "p" } }, mkdir_calls)
    assert.same({
      "cd " .. vim.fn.fnameescape("/tmp/repo-wt/.uc"),
      "edit " .. vim.fn.fnameescape("/tmp/repo-wt/.uc/uc-123.prompt.md"),
    }, cmd_calls)
  end)

  it("opens prompt in main worktree on work branch", function()
    stub_system({
      ["git rev-parse --absolute-git-dir"] = { out = "/Users/me/src/github/hjdivad/dotfiles/.git\n" },
      ["git rev-parse --show-toplevel"] = { out = "/Users/me/src/github/hjdivad/dotfiles\n" },
      ["git rev-parse --abbrev-ref HEAD"] = { out = "hjdivad/uc-987\n" },
    })

    agent.StartAgentPrompt()

    assert.same({ { path = "/home/test/.local/state/uc/github/hjdivad/dotfiles/uc-987", flags = "p" } }, mkdir_calls)
    assert.same({ { target = "/home/test/.local/state/uc/github/hjdivad/dotfiles/uc-987", path = "/Users/me/src/github/hjdivad/dotfiles/.uc" } }, symlink_calls)
    assert.same({}, unlink_calls)
    assert.same({
      "cd " .. vim.fn.fnameescape("/Users/me/src/github/hjdivad/dotfiles"),
      "edit " .. vim.fn.fnameescape(".uc/uc-987.prompt.md"),
    }, cmd_calls)
  end)

  it("uses fallback task name on main worktree when branch is not a work branch", function()
    stub_system({
      ["git rev-parse --absolute-git-dir"] = { out = "/Users/me/src/github/hjdivad/dotfiles/.git\n" },
      ["git rev-parse --show-toplevel"] = { out = "/Users/me/src/github/hjdivad/dotfiles\n" },
      ["git rev-parse --abbrev-ref HEAD"] = { out = "main\n" },
    })

    agent.StartAgentPrompt()

    assert.same({ { path = "/home/test/.local/state/uc/github/hjdivad/dotfiles/task", flags = "p" } }, mkdir_calls)
    assert.same({ { target = "/home/test/.local/state/uc/github/hjdivad/dotfiles/task", path = "/Users/me/src/github/hjdivad/dotfiles/.uc" } }, symlink_calls)
    assert.same({}, unlink_calls)
    assert.same({
      "cd " .. vim.fn.fnameescape("/Users/me/src/github/hjdivad/dotfiles"),
      "edit " .. vim.fn.fnameescape(".uc/task.prompt.md"),
    }, cmd_calls)
  end)

  it("replaces existing .uc symlink on main worktree", function()
    stub_system({
      ["git rev-parse --absolute-git-dir"] = { out = "/Users/me/src/github/hjdivad/dotfiles/.git\n" },
      ["git rev-parse --show-toplevel"] = { out = "/Users/me/src/github/hjdivad/dotfiles\n" },
      ["git rev-parse --abbrev-ref HEAD"] = { out = "hjdivad/uc-987\n" },
    })

    lstat_responses["/Users/me/src/github/hjdivad/dotfiles/.uc"] = { type = "link" }

    agent.StartAgentPrompt()

    assert.same({ { path = "/home/test/.local/state/uc/github/hjdivad/dotfiles/uc-987", flags = "p" } }, mkdir_calls)
    assert.same({ "/Users/me/src/github/hjdivad/dotfiles/.uc" }, unlink_calls)
    assert.same({ { target = "/home/test/.local/state/uc/github/hjdivad/dotfiles/uc-987", path = "/Users/me/src/github/hjdivad/dotfiles/.uc" } }, symlink_calls)
    assert.same({
      "cd " .. vim.fn.fnameescape("/Users/me/src/github/hjdivad/dotfiles"),
      "edit " .. vim.fn.fnameescape(".uc/uc-987.prompt.md"),
    }, cmd_calls)
  end)

  it("errors when .uc exists and is not a symlink", function()
    stub_system({
      ["git rev-parse --absolute-git-dir"] = { out = "/Users/me/src/github/hjdivad/dotfiles/.git\n" },
      ["git rev-parse --show-toplevel"] = { out = "/Users/me/src/github/hjdivad/dotfiles\n" },
      ["git rev-parse --abbrev-ref HEAD"] = { out = "hjdivad/uc-987\n" },
    })

    lstat_responses["/Users/me/src/github/hjdivad/dotfiles/.uc"] = { type = "directory" }

    agent.StartAgentPrompt()

    assert.same({}, mkdir_calls)
    assert.same({}, unlink_calls)
    assert.same({}, symlink_calls)
    assert.same({}, cmd_calls)
    assert.same({
      { msg = { { "StartAgentPrompt: .uc already exists and is not a symlink" } }, history = true, opts = { err = true } },
    }, echo_calls)
  end)

  it("errors on linked worktree when branch is not a work branch", function()
    stub_system({
      ["git rev-parse --absolute-git-dir"] = { out = "/repo/.git/worktrees/wt\n" },
      ["git rev-parse --show-toplevel"] = { out = "/tmp/repo-wt\n" },
      ["git rev-parse --abbrev-ref HEAD"] = { out = "detached\n" },
    })

    agent.StartAgentPrompt()

    assert.same({}, mkdir_calls)
    assert.same({}, cmd_calls)
    assert.same({
      { msg = { { "StartAgentPrompt: linked worktree must be on hjdivad/* (got detached)" } }, history = true, opts = { err = true } },
    }, echo_calls)
  end)

  it("errors when not inside a git repository", function()
    stub_system({})

    agent.StartAgentPrompt()

    assert.same({}, mkdir_calls)
    assert.same({}, cmd_calls)
    assert.same({
      { msg = { { "StartAgentPrompt: not inside a git repository" } }, history = true, opts = { err = true } },
    }, echo_calls)
  end)
end)
