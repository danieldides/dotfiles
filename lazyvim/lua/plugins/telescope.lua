return {
  {
    "nvim-telescope/telescope.nvim",
    keys = {
      -- Override or add your own mapping
      {
        "<leader>fg",
        function()
          require("telescope.builtin").live_grep()
        end,
        desc = "Live Grep",
      },
    },
  },
}
