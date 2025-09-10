describe("git", function()
  local assert = require("luassert")
  local git = require("hjdivad.git")
  local stub = require("luassert.stub")

  local vim_fn_system_stub
  local original_vim_v

  before_each(function()
    original_vim_v = vim.v
  end)

  after_each(function()
    if vim_fn_system_stub then
      vim_fn_system_stub:revert()
    end
    vim.v = original_vim_v
  end)

  it("merge_base returns commit hash when origin/master exists", function()
    local call_count = 0
    vim_fn_system_stub = stub(vim.fn, "system", function(cmd)
      call_count = call_count + 1
      if cmd == "git rev-parse --git-dir 2>/dev/null" then
        vim.v = { shell_error = 0 }
        return ".git"
      elseif cmd == "git rev-parse --verify origin/master 2>/dev/null" then
        vim.v = { shell_error = 0 }
        return "abcd1234"
      elseif cmd == "git merge-base HEAD origin/master 2>/dev/null" then
        vim.v = { shell_error = 0 }
        return "efgh5678\n"
      end
      vim.v = { shell_error = 1 }
      return ""
    end)

    local result = git.merge_base()

    assert.equal("efgh5678", result)
  end)

  it("merge_base falls back to origin/HEAD when origin/master missing", function()
    vim_fn_system_stub = stub(vim.fn, "system", function(cmd)
      if cmd == "git rev-parse --git-dir 2>/dev/null" then
        vim.v = { shell_error = 0 }
        return ".git"
      elseif cmd == "git rev-parse --verify origin/master 2>/dev/null" then
        vim.v = { shell_error = 1 }
        return ""
      elseif cmd == "git rev-parse --verify origin/HEAD 2>/dev/null" then
        vim.v = { shell_error = 0 }
        return "abcd1234"
      elseif cmd == "git merge-base HEAD origin/HEAD 2>/dev/null" then
        vim.v = { shell_error = 0 }
        return "ijkl9012\n"
      end
      vim.v = { shell_error = 1 }
      return ""
    end)

    local result = git.merge_base()

    assert.equal("ijkl9012", result)
  end)

  it("merge_base falls back to origin/main as last resort", function()
    vim_fn_system_stub = stub(vim.fn, "system", function(cmd)
      if cmd == "git rev-parse --git-dir 2>/dev/null" then
        vim.v = { shell_error = 0 }
        return ".git"
      elseif cmd == "git rev-parse --verify origin/master 2>/dev/null" then
        vim.v = { shell_error = 1 }
        return ""
      elseif cmd == "git rev-parse --verify origin/HEAD 2>/dev/null" then
        vim.v = { shell_error = 1 }
        return ""
      elseif cmd == "git rev-parse --verify origin/main 2>/dev/null" then
        vim.v = { shell_error = 0 }
        return "abcd1234"
      elseif cmd == "git merge-base HEAD origin/main 2>/dev/null" then
        vim.v = { shell_error = 0 }
        return "mnop3456\n"
      end
      vim.v = { shell_error = 1 }
      return ""
    end)

    local result = git.merge_base()

    assert.equal("mnop3456", result)
  end)

  it("merge_base returns nil when no upstream branch found", function()
    vim_fn_system_stub = stub(vim.fn, "system", function(cmd)
      if cmd == "git rev-parse --git-dir 2>/dev/null" then
        vim.v = { shell_error = 0 }
        return ".git"
      end
      vim.v = { shell_error = 1 }
      return ""
    end)

    local result = git.merge_base()

    assert.is_nil(result)
  end)

  it("merge_base returns nil when not in git repository", function()
    vim_fn_system_stub = stub(vim.fn, "system", function(cmd)
      vim.v = { shell_error = 1 }
      return ""
    end)

    local result = git.merge_base()

    assert.is_nil(result)
  end)
end)

