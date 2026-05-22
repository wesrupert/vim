return {
  {
    "nvim-mini/mini.hipatterns",
    opts = function ()
      return {
        highlighters = {
          hex_color = require("mini.hipatterns").gen_highlighter.hex_color(),
        },
      }
    end,
  },
  {
    "neanias/everforest-nvim",
    priority = 1000,
    ---@module "everforest"
    ---@type Everforest.SetupOptions
    opts = {
      dim_inactive_windows = true,
      italics = true,
      show_eob = false,
    },
    config = function (_, opts)
      require("everforest").setup(opts)
    end,
  },
  {
    "webhooked/kanso.nvim",
    priority = 1000,
    ---@module "kanso"
    ---@type KansoConfig
    opts = {
      dimInactive = true,
      foreground = { dark = "saturated" },
    },
    config = function (_, opts)
      require("kanso").setup(opts)
    end,
  },
}