return {
  {
    "hamidi-dev/org-list.nvim",
    dependencies = { "tpope/vim-repeat" },
    opts = {
      mapping = {
        {
          key = "<c-_>",
          desc = "[Org List] Cycle list types",
          filetypes = { "org", "markdown" },
        },
        checkbox_toggle = {
          enabled = true,
          key = "<a-_>",
          desc = "[Org List] Toggle state",
          filetypes = { "org", "markdown" },
        },
      },
    },
  },
  {
    "chentoast/marks.nvim",
    event = "VeryLazy",
    config = true,
  },
}