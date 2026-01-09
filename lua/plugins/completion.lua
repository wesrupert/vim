local util = require("util")

local use_native_completion = vim.g.USE_NATIVE_COMPLETION == true
if use_native_completion then
  require("util.lsp").on_supports_method("textDocument/completion", function (bufnr, client)
    client.server_capabilities.completionProvider.triggerCharacters = vim.split("qwertyuiopasdfghjklzxcvbnm_-./ ", "")
    vim.lsp.completion.enable(true, client.id, bufnr, { autotrigger = true })
    vim.api.nvim_create_autocmd({ 'TextChangedI' }, {
      group = vim.api.nvim_create_augroup('UserLspCompletion', { clear = true }),
      buffer = bufnr,
      callback = function ()
        vim.lsp.completion.get()
      end
    })
  end)
end

return util.tbl_join(
  -- Engine-specific plugins
  use_native_completion and {} or {
    {
      "saghen/blink.cmp",
      version = "*",
      lazy = false, -- lazy loading handled internally
      opts = {
        keymap = {
          ["<cr>"] = { "accept", "fallback_to_mappings" },
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
        cmdline = {
          completion = { menu = { auto_show = true } },
        },
        completion = {
          keyword = { range = "full" },
          trigger = {
            show_on_x_blocked_trigger_characters = { ",", '"', "'", "`", "(", "{" },
          },
          menu = {
            winblend = vim.o.pumblend,
            winhighlight = "Normal:Normal,FloatBorder:FloatBorder,CursorLine:BlinkCmpMenuSelection,Search:None",
            draw = {
              gap = 2,
              columns = { { "label", "label_description", gap = 1 }, { "kind_icon", "kind", gap = 1 } },
              treesitter = { "lsp" },
            },
            cmdline_position = function ()
              if vim.g.ui_cmdline_pos ~= nil then
                local pos = vim.g.ui_cmdline_pos -- (1, 0)-indexed
                return { pos[1], pos[2] }
              end
              local height = (vim.o.cmdheight == 0) and 1 or vim.o.cmdheight
              return { vim.o.lines - height - 1, 0 }
            end,
          },
          ghost_text = { enabled = true, show_without_selection = true },
          documentation = {
            auto_show = true,
            auto_show_delay_ms = 50,
            window = {
              winblend = vim.o.pumblend,
              winhighlight = "Normal:Normal,FloatBorder:FloatBorder,CursorLine:BlinkCmpDocCursorLine,Search:None",
            },
          },
        },
        fuzzy = {
          sorts = { "exact", "score", "sort_text" },
        },
        appearance = {
          nerd_font_variant = "normal",
          kind_icons = util.duplicate(util.kind_icons),
        },
        snippets = {
          preset = "mini_snippets",
        },
      },
      opts_extend = { "sources.default" },
    },
    {
      "xzbdmw/colorful-menu.nvim",
      opts = {
        ls = {
          vtsls = {
            extra_info_hl = false, -- HACK: See xzbdmw/colorful-menu.nvim#42
          },
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
  }, {
    -- Engine-agnostic plugins
  }
)