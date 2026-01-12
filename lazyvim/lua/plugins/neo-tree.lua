return {
  {
    "nvim-neo-tree/neo-tree.nvim",
    keys = {
      {
        "<leader>k",
        function()
          local manager = require("neo-tree.sources.manager")
          local neotree = require("neo-tree.command")

          -- Get filesystem state
          local state = manager.get_state("filesystem")

          if state and state.winid and vim.api.nvim_win_is_valid(state.winid) then
            -- Neo-tree is open → close it
            neotree.execute({ action = "close" })
          else
            -- Neo-tree is closed → open and reveal current file
            neotree.execute({
              action = "show",
              source = "filesystem",
              reveal_file = vim.fn.expand("%:p"),
              reveal_force_cwd = true,
            })
          end
        end,
        desc = "Toggle Neo-tree (reveal current file)",
      },
    },
  },
}
