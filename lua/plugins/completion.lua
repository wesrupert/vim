local util = require("util")

return {
  {
    "saghen/blink.cmp",
    dependencies = { "nvim-mini/mini.snippets" },
    version = "*",
    lazy = false, -- lazy loading handled internally
    opts = {
      keymap = {
        ["<cr>"] = { "accept", "fallback_to_mappings" },
        ["<tab>"] = { "accept", "fallback_to_mappings" },
        ["<c-x>"] = { "hide", "fallback" },
        ["<left>"] = { "scroll_documentation_up", "fallback" },
        ["<right>"] = { "scroll_documentation_down", "fallback" },
      },
      sources = {
        default = { "lsp", "path", "snippets", "buffer" },
        providers = {
          -- Show buffer options when lsp is attached.
          lsp = { score_offset = 50, fallbacks = {} },
        },
      },
      completion = {
        keyword = { range = "full" },
        trigger = {
          show_on_x_blocked_trigger_characters = { ",", '"', "'", "`", "(", "{" },
        },
        menu = {
          draw = {
            gap = 2,
            columns = { { "label", "label_description", gap = 1 }, { "kind_icon", "kind", gap = 1 } },
            treesitter = { "lsp" },
          },
        },
        ghost_text = { enabled = true, show_without_selection = false, show_with_menu = false },
        documentation = { auto_show = true, auto_show_delay_ms = 50 },
      },
      appearance = {
        nerd_font_variant = "normal",
        kind_icons = util.duplicate(util.kind_icons),
      },
      fuzzy = { sorts = { "exact", "score", "sort_text", "label" } },
      cmdline = { completion = { menu = { auto_show = true } } },
      snippets = { preset = "mini_snippets" },
      signature = { enabled = true },
    },
    opts_extend = { "sources.default" },
  },
  { "nvim-mini/mini.snippets", dependencies = { "nvim-mini/mini.icons" }, config = true },
  {
    "xzbdmw/colorful-menu.nvim",
    opts = {
      ls = {
        vtsls = { extra_info_hl = false },
      },
    },
    specs = {
      {
        "saghen/blink.cmp",
        optional = true,
        opts = {
          completion = {
            menu = {
              draw = {
                columns = { { "kind_icon" }, { "label", "label_description", gap = 1 }, { "kind" } },
                treesitter = nil,
                components = {
                  label = {
                    text = function (ctx) return require("colorful-menu").blink_components_text(ctx) end,
                    highlight = function (ctx) return require("colorful-menu").blink_components_highlight(ctx) end,
                  },
                },
              },
            },
          },
        },
      },
    },
  },
  {
    "mikavilpas/blink-ripgrep.nvim",
    specs = {
      {
        "saghen/blink.cmp",
        optional = true,
        opts = function (_, opts)
          local sources_default = vim.tbl_get(opts or {}, "sources", "default") or {}
          table.insert(sources_default, #sources_default, "ripgrep")
          return util.merge(opts or {}, {
            sources = {
              default = sources_default,
              providers = {
                ripgrep = {
                  name = "Ripgrep",
                  module = "blink-ripgrep",
                  opts = { backend = { ripgrep = { search_casing = "--smart-case" } } },
                  transform_items = function(_, items)
                    for _, item in ipairs(items) do item.kind_name = "Workspace" end
                    return items
                  end,
                },
              },
            },
          })
        end,
      },
    },
  },
}