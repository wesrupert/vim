local util = require('util')
return {
  {
    'oxy2dev/ui.nvim',
    priority = 1000,
    lazy = false,
    opts = {
      popupmenu = { enabled = false },
    },
  },
  {
    'wesrupert/lualine.nvim',
    branch = 'feat/altfile',
    dependencies = {
      'nvim-tree/nvim-web-devicons',
      'yavorski/lualine-macro-recording.nvim',
      'andrem222/copilot-lualine',
    },
    opts = function ()
      return {
        sections = {
          lualine_a = { 'mode', 'macro_recording' },
          lualine_c = { '%n', 'filename' },
          lualine_x = { { 'copilot', symbols = { spinners = 'dots' } }, 'filetype' },
        },
        inactive_sections = {
          lualine_c = { '%n', 'filename' },
          lualine_x = {},
        },
        tabline = {
          lualine_a = { function () return util.kind_icons.NeoVim .. '  '.. (vim.g.mini_sessions_current or '') end },
          lualine_b = { { 'tabs', mode = 2, use_mode_colors = true } },
          lualine_x = { { 'altfile', path = 1, symbols = { separator = '󰘵 ' } } },
          lualine_z = { { 'filename', path = 1 } },
        },
      }
    end,
  },
  {
    'bekaboo/dropbar.nvim',
    dependencies = {
      'nvim-telescope/telescope-fzf-native.nvim',
      build = 'make',
    },
    opts = {
      bar = {
        sources = function(buf, _)
          local sources = require('dropbar.sources')
          local utils = require('dropbar.utils')
          if vim.bo[buf].ft == 'markdown' then
            return { sources.markdown }
          elseif vim.bo[buf].ft == 'vue' then
            return { sources.lsp } -- Treesitter messes up the script/style tag symbols
          elseif vim.bo[buf].buftype == 'terminal' then
            return { sources.terminal }
          end
          return { utils.source.fallback({ sources.lsp, sources.treesitter }) }
        end,
      },
      icons = { kinds = { symbols = vim.tbl_map(function (v) return v .. ' ' end, util.kind_icons) } },
    },
    config = function (_, opts)
      local dropbar = require('dropbar')
      local dropbar_api = require('dropbar.api')
      dropbar.setup(opts)

      vim.ui.select = require('dropbar.utils.menu').select
      util.keymap('g;', '[Dropbar] Pick symbols in winbar', dropbar_api.pick)
      util.keymap('[;', '[Dropbar] Go to start of current context', dropbar_api.goto_context_start)
      util.keymap('];', '[Dropbar] Select next context', dropbar_api.select_next_context)
    end,
  },
  {
    'folke/which-key.nvim',
    event = 'VeryLazy',
    opts = {
      preset = 'helix',
      -- TODO: Workaround till https://github.com/folke/which-key.nvim/issues/967
      show_help = false,
      sort = { 'icase', 'alphanum' },
    },
    config = function (_, opts)
      local which_key = require('which-key')
      local which_key_extras = require('which-key.extras')
      which_key.setup(opts)

      which_key.add({
        { 'gb', group = 'buffers', expand = which_key_extras.expand.buf },
      })

      util.keymap('<leader>k', '[Which-Key] Show keymaps', which_key.show)
      util.keymap('<leader>K', '[Which-Key] Show keymaps for buffer', function() which_key.show({ global = false }) end)
    end,
  },
  {
    'tummetott/reticle.nvim',
    event = 'VeryLazy',
    opts = {
      always_highlight_number = true,
    },
  },
  {
    'axkirillov/hbac.nvim',
    config = function (_, opts)
      local hbac = require('hbac')
      hbac.setup(opts)
      util.keymap('<leader>bp', '[Bufclose] Pin/Unpin', hbac.toggle_pin)
      util.keymap('<leader>bo', '[Bufclose] Close unpinned', hbac.close_unpinned)
      util.keymap('<leader>ba', '[Bufclose] Toggle autoclose', hbac.toggle_autoclose)
    end
  },
  {
    'folke/zen-mode.nvim',
    opts = { window = { width = 0.8, height = 0.9 } },
    config = function (_, opts)
      local zen_mode = require('zen-mode')
      zen_mode.setup(opts)
      util.keymap('gz', '[Zen mode] Toggle', zen_mode.toggle)
    end,
  },
  { 'airblade/vim-rooter' },
  { 'conormcd/matchindent.vim' },
  {
    "alexghergh/nvim-tmux-navigation",
    opts = {
      disable_when_zoomed = true,
      keybindings = {
        left = "<c-h>",
        down = "<c-j>",
        up = "<c-k>",
        right = "<c-l>",
        last_active = "<c-\\>",
      },
    },
  },
}