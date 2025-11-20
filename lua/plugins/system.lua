local util = require("util")

return {
  { "tpope/vim-repeat", lazy = false, priority = 999 },
  {
    "sindrets/diffview.nvim",
    specs = {
      {
        "yannvanhalewyn/jujutsu.nvim",
        optional = true,
        opts = function (_, opts) return util.merge(opts or {}, { diff_preset = "diffview" }) end,
      },
    },
  },
  { "rafikdraoui/jj-diffconflicts" },
  {
    "wesrupert/filler-begone.nvim",
    dev = true,
    init = function ()
      -- Only enable in floating windows
      vim.api.nvim_create_autocmd({ "WinNew", "BufNew", "BufWinEnter" }, {
        pattern = "*",
        group = vim.api.nvim_create_augroup("UserFillerBegoneConfig", { clear = true }),
        desc = "[FillerBegone] Enable in floating windows",
        callback = function ()
          local winnr = vim.api.nvim_get_current_win()
          local win_config = vim.api.nvim_win_get_config(winnr)
          if win_config.relative == "" and not win_config.external then
            vim.w[winnr].filler_begone = false
          end
        end,
      })
    end,
  },
}