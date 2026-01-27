local util = require("util")

return {
  {
    "stevearc/overseer.nvim",
    config = function (_, opts)
      local overseer = require("overseer")
      overseer.setup(opts or {})
      util.keymap("glO", "[Overseer] Toggle",      [[<cmd>OverseerToggle<cr>]])
      util.keymap("glo", "[Overseer] Run",         [[<cmd>OverseerRun<cr>]])
      util.keymap("gla", "[Overseer] Modify Task", [[<cmd>OverseerTaskAction<cr>]])
    end,
  },
}