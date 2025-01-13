local util = require('util')
local blink_tag = '*'

return {
  {
    'saghen/blink.cmp',
    cond = util.not_vscode,
    dependencies = { 'giuxtaposition/blink-cmp-copilot' },
    version = blink_tag and blink_tag or nil,
    build =  not blink_tag and 'cargo build --release' or nil,
    lazy = false, -- lazy loading handled internally
    opts = function ()
      -- HACK: Workaround until custom kinds are supported.
      -- https://github.com/Saghen/blink.cmp/issues/590
      local blink_types = require('blink.cmp.types')
      local create_kind_transforms = 0
      local create_kind_transform = function (name)
        create_kind_transforms = create_kind_transforms + 1
        local kind_idx = create_kind_transforms
        local completion_kinds = blink_types.CompletionItemKind
        return function (_, items)
          if not items or not #items then return end
          local idx = #completion_kinds + kind_idx
          completion_kinds[idx] = name
          for _, item in ipairs(items) do item.kind = idx end
          return items
        end
      end

      return {
        keymap = {
          preset = 'enter',
          cmdline = { preset = 'super-tab' },
        },
        snippets = { preset = 'mini_snippets' },
        sources = {
          default = { 'copilot', 'lsp', 'lazydev', 'path', 'snippets', 'buffer' },
          providers = {
            copilot = {
              name = 'Copilot',
              module = 'blink-cmp-copilot',
              async = true,
              score_offset = 100,
              transform_items = create_kind_transform('Copilot'),
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
          menu = {
            border = 'rounded',
            winblend = vim.o.pumblend,
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
          ghost_text = { enabled = true },
          documentation = {
            auto_show = true,
            auto_show_delay_ms = 50,
            window = {
              border = 'rounded',
              winblend = vim.o.pumblend,
              winhighlight = 'Normal:Normal,FloatBorder:FloatBorder,CursorLine:BlinkCmpDocCursorLine,Search:None',
            },
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