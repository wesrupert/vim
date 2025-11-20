local util = require("util")

return {
  {
    "chrisgrieser/nvim-spider",
    config = function (_, opts)
      local spider = require("spider")
      spider.setup(opts)
      util.keymap("w",  "[Spider] Go word",        function () spider.motion("w") end)
      util.keymap("o",  "[Spider] Go word",        function () spider.motion("w") end,  { "o", "x" })
      util.keymap("e",  "[Spider] Go End",         function () spider.motion("e") end,  { "n", "o", "x" })
      util.keymap("ge", "[Spider] Go end (back)",  function () spider.motion("ge") end, { "n", "o", "x" })
      util.keymap("b",  "[Spider] Go word",        function () spider.motion("b") end)
      util.keymap("u",  "[Spider] Go word (back)", function () spider.motion("b") end,  { "o", "x" })
    end,
  },
  {
    "chentoast/marks.nvim",
    event = "VeryLazy",
    config = true,
  },
  { "glts/vim-textobj-comment", dependencies = { "kana/vim-textobj-user" } },
  {
    "xxiaoa/atone.nvim",
    cmd = "Atone",
    opts = {
      layout = {
        width = 0.32,
      },
      ui = {
        border = vim.o.winborder,
      },
    },
    keys = {
      { "<a-u>", "<cmd>Atone<cr>", desc = "[Atone] Toggle" },
    },
  },
  {
    "julienvincent/hunk.nvim",
    cmd = { "DiffEditor" },
    config = true,
  },
  {
    "yannvanhalewyn/jujutsu.nvim",
  },
}