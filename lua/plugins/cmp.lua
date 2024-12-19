local util = require('util')

local function is_in_start_tag()
  local ts_utils = require('nvim-treesitter.ts_utils')
  local node = ts_utils.get_node_at_cursor()
  if not node then
    return false
  end
  local node_to_check = { 'start_tag', 'self_closing_tag', 'directive_attribute' }
  return vim.tbl_contains(node_to_check, node:type())
end

return {
  {
    'saghen/blink.cmp',
    cond = util.not_vscode,
    dependencies = { 'giuxtaposition/blink-cmp-copilot' },
    build = 'cargo build --release',
    lazy = false, -- lazy loading handled internally
    opts = function ()
      local blink_types = require('blink.cmp.types')
      return {
        keymap = {
          preset = 'enter',
          cmdline = { preset = 'super-tab' },
        },
        sources = {
          default = { 'copilot', 'lsp', 'lazydev', 'path', 'snippets', 'luasnip', 'buffer' },
          providers = {
            copilot = {
              name = 'Copilot',
              module = 'blink-cmp-copilot',
              async = true,
              score_offset = 100,
              transform_items = function (_, items)
                if not items or not #items then return end
                local completion_kinds = blink_types.CompletionItemKind
                local kind_idx = #completion_kinds + 1
                completion_kinds[kind_idx] = 'Copilot'
                for _, item in ipairs(items) do
                  item.kind = kind_idx
                end
                return items
              end,
            },
            lazydev = {
              name = 'NeoVim',
              module = 'lazydev.integrations.blink',
              score_offset = 50,
              fallbacks = { 'lsp' },
            },
            lsp = {
              score_offset = 50,
            },
          },
        },
        completion = {
          trigger = {
            show_on_trigger_character = false,
            show_on_x_blocked_trigger_characters = { ',', "'", '"', '`', '(', '{' },
          },
          documentation = {
            auto_show = true,
            auto_show_delay_ms = 50,
            window = {
              border = 'rounded',
              winhighlight = 'Normal:Normal,FloatBorder:FloatBorder,CursorLine:BlinkCmpDocCursorLine,Search:None',
            },
          },
          ghost_text = { enabled = true },
          menu = {
            border = 'rounded',
            winhighlight = 'Normal:Normal,FloatBorder:FloatBorder,CursorLine:BlinkCmpMenuSelection,Search:None',
            draw = {
              gap = 2,
              columns = { { 'label', 'label_description', gap = 1 }, { 'kind_icon', 'kind',  gap = 1 } },
              treesitter = { 'copilot', 'lazydev', 'lsp' },
            },
            cmdline_position = function ()
              if vim.g.ui_cmdline_pos ~= nil then
                local pos = vim.g.ui_cmdline_pos -- (1, 0)-indexed
                return { pos[1], pos[2] }
              end
              local height = (vim.o.cmdheight == 0) and 1 or vim.o.cmdheight
              return { vim.o.lines - height, 0 }
            end,
          },
        },
        appearance = {
          nerd_font_variant = 'normal',
          kind_icons = {
            Copilot = '',
            NeoVim = '',

            Text = '󰉿',
            Method = '󰊕',
            Function = '󰊕',
            Constructor = '󰒓',

            Variable = '',
            Field = '',
            Property = '',

            Class = '',
            Struct = '',
            Interface = '',
            Module = '󰅩',

            Unit = '󰪚',
            Value = '󰦨',
            Enum = '',
            EnumMember = '',

            Keyword = '',
            Constant = '',

            Snippet = '󱄽',
            Color = '󰏘',
            File = '',
            Reference = '',
            Folder = '',
            Event = '',
            Operator = '',
            TypeParameter = '',
          },
        },
        signature = { enabled = true },
      }
    end,
    opts_extend = { 'sources.default' },
  },
  {
    'zbirenbaum/copilot.lua',
    cond = util.not_vscode,
    -- cmd = 'Copilot',
    -- event = 'InsertEnter',
    opts = {
      filetypes = {
        lua = false,
        vim = false,
        sh = false,
        json = false,
        markdown = false,
      },
      suggestion = { enabled = false },
      panel = { enabled = false },
    },
  },
  {
    {
      'copilotc-nvim/copilotchat.nvim',
      cond = util.not_vscode,
      dependencies = { 'zbirenbaum/copilot.lua', 'nvim-lua/plenary.nvim' },
      opts = {
        -- See Configuration section for options
      },
      init = function ()
        util.keymap('<a-c>', '[Copilot] Toggle chat', [[<cmd>CopilotChatToggle<cr>]])
      end,
    },
  },
  {
    'giuxtaposition/blink-cmp-copilot',
    dependencies = { 'zbirenbaum/copilot.lua' },
  },
}