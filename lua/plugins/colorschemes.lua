local util = require "util"
return {
  {
    "f-person/auto-dark-mode.nvim",
    opts = {
      set_dark_mode = function()
        vim.api.nvim_set_option_value("background", "dark", {})
        vim.cmd.colorscheme(util.get_setting("night_theme", "catppuccin"))
      end,
      set_light_mode = function()
        vim.api.nvim_set_option_value("background", "light", {})
        vim.cmd.colorscheme(util.get_setting("day_theme", "catppuccin"))
      end,
    },
  },
  {
    "catppuccin/nvim",
    name = "catppuccin",
    priority = 1000,
    opts = {
      integrations = {
        blink_cmp = true,
        cmp = true,
        leap = true,
        markdown = true,
        mason = true,
        mini = true,
        telescope = true,
        treesitter = true,
        native_lsp = {
          enabled = true,
          virtual_text = {
            errors = { "italic" },
            hints = { "italic" },
            warnings = { "italic" },
            information = { "italic" },
            ok = { "italic" },
          },
          underlines = {
            errors = { "undercurl" },
            warnings = { "undercurl" },
            information = { "undercurl" },
            hints = { "underline" },
            ok = { "underline" },
          },
          inlay_hints = {
            background = true,
          },
        },
      },
      custom_highlights = function(colors)
        local u = require("catppuccin.utils.colors")
        return {
          TabLine = { fg = colors.overlay0, bg = colors.mantle },
          TabLineFill = { bg =  colors.mantle },
          CursorLine = { bg = u.blend(colors.overlay0, colors.base, 0.45) },
          CursorLineNr = { bg = u.blend(colors.overlay0, colors.base, 0.75), style = { "bold" } },
          LspReferenceText = { bg = colors.surface2 },
          LspReferenceWrite = { bg = colors.surface2 },
          LspReferenceRead = { bg = colors.surface2 },

          FloatBorder = { fg = colors.blue, bg = colors.mantle },
          FloatTitle = { fg = colors.subtext0, bg = colors.mantle },
        }
      end,
    },
  },
  {
    "neanias/everforest-nvim",
    priority = 1000,
    opts = {
      dim_inactive_windows = true,
      italics = true,
      show_eob = false,
      -- inlay_hints_background = "dimmed",
    },
    config = function (_, opts)
      require("everforest").setup(opts)
    end,
  },
  {
    "edeneast/nightfox.nvim",
    priority = 1000,
    opts = {
      options = {
        styles = {
          keywords = "italic",
          conditionals = "italic",
          comments = "italic",
        },
        modules = {
          blink = true,
          mini = true,
          lsp_saga = true,
          lsp_trouble = true,
          notify = true,
          telescope = true,
          whichkey = true,
        },
      },
    },
  },
  {
    "webhooked/kanso.nvim",
    priority = 1000,
  },
}