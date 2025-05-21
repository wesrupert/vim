local util = require("util")
local blink_tag = "*"
return {
  {
    "saghen/blink.cmp",
    version = blink_tag and blink_tag or nil,
    build =  not blink_tag and "cargo build --release" or nil,
    lazy = false, -- lazy loading handled internally
    opts = {
      keymap = { preset = "enter" },
      snippets = { preset = "mini_snippets" },
      sources = {
        default = { "lsp", "lazydev", "path", "snippets", "buffer" },
        providers = {
          lazydev = {
            name = "NeoVim",
            module = "lazydev.integrations.blink",
            score_offset = 50,
            fallbacks = { "lsp" },
          },
          lsp = {
            score_offset = 50,
            -- Show buffer options when lsp is attached.
            fallbacks = {},
          },
        },
      },
      cmdline = {
        keymap = { preset = "super-tab" },
        completion = { menu = { auto_show = true } },
      },
      completion = {
        keyword = { range = "full" },
        trigger = {
          show_on_trigger_character = false,
          show_on_x_blocked_trigger_characters = { ",", '"', "'", "`", "(", "{" },
        },
        menu = {
          winblend = vim.o.pumblend,
          winhighlight = "Normal:Normal,FloatBorder:FloatBorder,CursorLine:BlinkCmpMenuSelection,Search:None",
          draw = {
            gap = 2,
            columns = { { "label", "label_description", gap = 1 }, { "kind_icon", "kind",  gap = 1 } },
            treesitter = { "lazydev", "lsp" },
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
        ghost_text = { enabled = true },
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
        kind_icons = util.tbl_copy(util.kind_icons),
      },
    },
    opts_extend = { "sources.default" },
  },
  {
    "zbirenbaum/copilot.lua",
    -- TODO: Check for copilot integration before enabling.
    event = "InsertEnter",
    opts = {
      suggestion = { enabled = false },
      panel = { enabled = false },
      should_attach = function (_, bufname)
        if not vim.bo.buflisted then return false end
        if vim.bo.buftype ~= "" then return false end
        if string.sub(bufname, 1, #util.dirs.work) ~= util.dirs.work then return false end
        return true
      end,
    },
    specs = {
      {
        "copilotc-nvim/copilotchat.nvim",
        dependencies = { "nvim-lua/plenary.nvim" },
        opts = {
          model = "gpt-4o",
        },
        init = function ()
          util.keymap("<a-c>", "[Copilot] Toggle chat", [[<cmd>CopilotChatToggle<cr>]])
        end,
      },
      {
        "saghen/blink.cmp",
        dependencies = { "giuxtaposition/blink-cmp-copilot" },
        opts = function (_, opts)
          local defaults = {
            sources = { "lsp", "path", "snippets", "buffer" },
            treesitter = { "lsp" },
          }
          local sources_default = vim.tbl_get(opts or {}, "sources", "default") or defaults.sources
          local completion_draw = vim.tbl_get(opts or {}, "completion", "menu", "draw", "treesitter") or defaults.treesitter
          table.insert(sources_default, 1, "copilot")
          table.insert(completion_draw, 1, "copilot")
          return vim.tbl_deep_extend("force", opts or {}, {
            sources = {
              default = sources_default,
              providers = { copilot = { name = "Copilot", module = "blink-cmp-copilot", async = true, score_offset = 100 } },
            },
            completion = { menu = { draw = { treesitter = completion_draw } } },
          })
        end,
      },
    },
  },
}