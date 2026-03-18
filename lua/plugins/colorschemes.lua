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
    "catppuccin/nvim",
    name = "catppuccin",
    priority = 1000,
    opts = {
      background = {
        light = "latte",
        dark = "mocha",
      },
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
    "edeneast/nightfox.nvim",
    priority = 1000,
    opts = function ()
      local nf_palettes = require("nightfox.palette")
      local nf_color = require("nightfox.lib.color")
      local foxes = nf_palettes.load()
      local hex = nf_color.from_hex

      local palettes = {}
      for _, fox in ipairs(nf_palettes.foxes) do
        ---Nightfox's type annotations aren't configured properly, suppress warning on blend.
        ---@diagnostic disable-next-line: undefined-field
        palettes[fox] = { bg2 = hex(foxes[fox].bg2):blend(hex(foxes[fox].bg1), 0.8):to_css() }
      end

      return {
        options = {
          dim_inactive = true,
          styles = {
            keywords = "italic",
            conditionals = "italic",
            comments = "italic",
          },
          modules = {
            blink = true,
            diagnostic = true,
            lazy = true,
            lsp_semantic_tokens = true,
            lsp_trouble = true,
            mini = true,
            native_lsp = true,
            notify = true,
            treesitter = true,
            whichkey = true,
          },
        },
        palettes = palettes,
        groups = {
          all = {
            InlayHint = { bg = "bg2", fg = "palette.comment" },
            LspInlayHint = { link = "InlayHint" },
            CocInlayHint = { link = "InlayHint" },
            TinyInlineDiagnosticVirtualTextBg = { link = "InlayHint" },
            TinyInlineInvDiagnosticVirtualTextHint = { link = "TinyInlineDiagnosticVirtualTextBg" },
            TinyInlineInvDiagnosticVirtualTextInfo = { link = "TinyInlineDiagnosticVirtualTextBg" },
            TinyInlineInvDiagnosticVirtualTextWarn = { link = "TinyInlineDiagnosticVirtualTextBg" },
            TinyInlineInvDiagnosticVirtualTextError = { link = "TinyInlineDiagnosticVirtualTextBg" },
            TinyInlineDiagnosticVirtualTextHint = { link = "DiagnosticVirtualTextHint" },
            TinyInlineDiagnosticVirtualTextInfo = { link = "DiagnosticVirtualTextInfo" },
            TinyInlineDiagnosticVirtualTextWarn = { link = "DiagnosticVirtualTextWarn" },
            TinyInlineDiagnosticVirtualTextArrow = { link = "DiagnosticVirtualTextArrow" },
            TinyInlineDiagnosticVirtualTextError = { link = "DiagnosticVirtualTextError" },
            TinyInlineDiagnosticVirtualTextHintMixHint = { link = "DiagnosticVirtualTextHint" },
            TinyInlineDiagnosticVirtualTextHintMixInfo = { link = "DiagnosticVirtualTextInfo" },
            TinyInlineDiagnosticVirtualTextHintMixWarn = { link = "DiagnosticVirtualTextWarn" },
            TinyInlineDiagnosticVirtualTextInfoMixHint = { link = "DiagnosticVirtualTextHint" },
            TinyInlineDiagnosticVirtualTextInfoMixInfo = { link = "DiagnosticVirtualTextInfo" },
            TinyInlineDiagnosticVirtualTextInfoMixWarn = { link = "DiagnosticVirtualTextWarn" },
            TinyInlineDiagnosticVirtualTextWarnMixHint = { link = "DiagnosticVirtualTextHint" },
            TinyInlineDiagnosticVirtualTextWarnMixInfo = { link = "DiagnosticVirtualTextInfo" },
            TinyInlineDiagnosticVirtualTextWarnMixWarn = { link = "DiagnosticVirtualTextWarn" },
            TinyInlineDiagnosticVirtualTextErrorMixHint = { link = "DiagnosticVirtualTextHint" },
            TinyInlineDiagnosticVirtualTextErrorMixInfo = { link = "DiagnosticVirtualTextInfo" },
            TinyInlineDiagnosticVirtualTextErrorMixWarn = { link = "DiagnosticVirtualTextWarn" },
            TinyInlineDiagnosticVirtualTextHintMixError = { link = "DiagnosticVirtualTextError" },
            TinyInlineDiagnosticVirtualTextInfoMixError = { link = "DiagnosticVirtualTextError" },
            TinyInlineDiagnosticVirtualTextWarnMixError = { link = "DiagnosticVirtualTextError" },
            TinyInlineDiagnosticVirtualTextErrorMixError = { link = "DiagnosticVirtualTextError" },
          },
        },
      }
    end,
    config = function (_, opts)
      require("nightfox").setup(opts)
    end
  },
  {
    "webhooked/kanso.nvim",
    priority = 1000,
    opts = {
      foreground = {
        dark = "saturated",
      },
    },
  },
}