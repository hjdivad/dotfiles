---@type LazySpec[]
return {
  -- see $HOME/.local/share/nvim/lazy/LazyVim/lua/lazyvim/plugins/extras/editor/harpoon2.lua
  "ThePrimeagen/harpoon",
  branch = "harpoon2",
  keys = function()
    local keys = {
      {
        "<leader>ha",
        function()
          require("harpoon"):list():add()
        end,
        desc = "Harpoon add file",
      },
      {
        "<leader>hr",
        function()
          require("harpoon"):list():remove()
        end,
        desc = "Harpoon remove file",
      },
      {
        "<leader>ht",
        function()
          local h = require("harpoon"):list()
          local item = h.config.create_list_item(h.config)
          for i = 1, h:length() + 1 do
            local v = h.items[i]
            if h.config.equals(item, v) then
              h:remove_at(i)
              return
            end
          end
          h:add(item)
        end,
        desc = "Harpoon File (toggle)",
      },
      {
        "<leader>hh",
        function()
          local harpoon = require("harpoon")
          harpoon.ui:toggle_quick_menu(harpoon:list())
        end,
        desc = "Harpoon Quick Menu",
      },
    }

    for i = 1, 5 do
      table.insert(keys, {
        "<leader>" .. i,
        function()
          require("harpoon"):list():select(i)
        end,
        desc = "Harpoon to File " .. i,
      })
    end
    return keys
  end,
}
