local util = require('util')

return {
  -- Colorschemes
  {
    'f-person/auto-dark-mode.nvim',
    opts = {
      set_dark_mode = function()
        vim.api.nvim_set_option_value('background', 'dark', {})
      end,
      set_light_mode = function()
        vim.api.nvim_set_option_value('background', 'light', {})
      end,
    },
  },
  { 'edeneast/nightfox.nvim', priority = 1000, cond = util.not_vscode },
  {
    'catppuccin/nvim',
    name = 'catppuccin',
    cond = util.not_vscode,
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
            errors = { 'italic' },
            hints = { 'italic' },
            warnings = { 'italic' },
            information = { 'italic' },
            ok = { 'italic' },
          },
          underlines = {
            errors = { 'undercurl' },
            warnings = { 'undercurl' },
            information = { 'undercurl' },
            hints = { 'underline' },
            ok = { 'underline' },
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
        }
      end,
    },
  },

  -- Meta plugins
  { 'tpope/vim-repeat' },
  { 'equalsraf/neovim-gui-shim' },
  { 'nvim-lua/plenary.nvim' },
  { 'airblade/vim-rooter' },
  { 'nvim-tree/nvim-web-devicons' },
  { 'folke/lsp-colors.nvim', cond = util.not_vscode },
  {
    'nvim-focus/focus.nvim',
    cond = util.not_vscode,
    opts = {
      autoresize = {
        minheight = 10,
        minwidth = 40,
      },
    },
    init = function ()
      -- Disable auto-resize in windows that aren't "editor" windows.
      local user_focus_group = vim.api.nvim_create_augroup('UserFocusConfig', { clear = true })
      local ignore_buftypes = { 'nofile', 'nowrite', 'prompt', 'popup' }
      local ignore_filetypes = { 'TelescopePrompt', 'toggleterm', 'trouble', 'undotree', 'qf' }
      vim.api.nvim_create_autocmd({ 'WinNew', 'WinEnter' }, {
        desc = '[Focus] Disable auto-resize on configured buftypes',
        group = user_focus_group,
        callback = function () vim.w.focus_disable = (not vim.bo.buftype) or vim.tbl_contains(ignore_buftypes, vim.bo.buftype) end,
      })
      vim.api.nvim_create_autocmd({ 'BufNew', 'BufReadPre' }, {
        desc = '[Focus] Disable auto-resize on configured buftypes',
        group = user_focus_group,
        callback = function (ev) vim.b[ev.buf].focus_disable = vim.tbl_contains(ignore_buftypes, vim.bo[ev.buf].buftype) end,
      })
      vim.api.nvim_create_autocmd('FileType', {
        desc = '[Focus] Disable auto-resize on configured filetypes',
        group = user_focus_group,
        callback = function (ev) vim.b[ev.buf].focus_disable = vim.tbl_contains(ignore_filetypes, vim.bo[ev.buf].buftype) end,
      })

      util.keymap('<leader>rr', '[Focus] Toggle maximized', [[<cmd>FocusMaxOrEqual<cr>]])
      util.keymap('<leader>rx', '[Focus] Pin window', function ()
        if vim.w.focus_disable ~= true then
          vim.w.focus_disable = true
          vim.notify('[Focus] Pinned window')
        else
          vim.w.focus_disable = false
          vim.notify('[Focus] Unpinned window')
        end
      end)
      util.keymap(']r', '[Focus] Enable auto-resize', function ()
          vim.g.focus_disable = false
          vim.notify('[Focus] Auto-resize enabled')
      end)
      util.keymap('[r', '[Focus] Disable auto-resize', function ()
          vim.g.focus_disable = true
          vim.notify('[Focus] Auto-resize disabled')
      end)
    end,
  },
  {
    'wesrupert/snacks.nvim',
    branch = 'feat/notifier/skip',
    cond = util.not_vscode,
    priority = 1000,
    lazy = false,
    opts = {
      bufdelete = { enabled = true },
      git = { enabled = true },
      gitbrowse = { enabled = true },
      statuscolumn = { enabled = true },
      notifier = {
        enabled = true,
        style = 'fancy',
        skip = function (msg)
          if msg.msg == 'No information available' then return true end
          if msg.msg:match([[^Error in decoration provider]]) then return true end
          if msg.msg:match([[^# Config Change Detected. Reloading...]]) then return true end
          return false
        end,
      },
    },
    init = function ()
      local snacks = require('snacks')
      vim.print = snacks.debug.inspect -- Override print to use snacks for `:=` command
      util.keymap('<leader>m',  '[Snacks] Show messages',         snacks.notifier.show_history)
      util.keymap('<leader>gb', '[Snacks] Blame current line',    snacks.git.blame_line)
      util.keymap('gs',         '[Snacks] Scratch buffer',        function () snacks.scratch() end)
      util.keymap('<a-s>',      '[Snacks] Pick Scratch buffer',   snacks.scratch.select)
      util.keymap('gol',        '[Snacks] Open lazygit',          snacks.lazygit.open)
      util.keymap('gox',        '[Snacks] Open on remote',        snacks.gitbrowse.open)
      util.keymap('goX',        '[Snacks] Open branch on remote', function ()
        vim.ui.input({ prompt = 'Choose a branch: ', default = 'master' }, function(branch)
          snacks.gitbrowse.open({
            url_patterns = { ['github.com'] = { branch = '/tree/'..branch, file = '/blob/'..branch..'/{file}#L{line}' } }
          })
        end)
      end)

      util.keymap ('<leader>bd', '[Snacks] Delete buffer', function () snacks.bufdelete() end)
      vim.api.nvim_create_user_command('BD', function () snacks.bufdelete() end, {})
      vim.api.nvim_create_user_command('BOnly', snacks.bufdelete.other, {})
    end,
  },
  {
    'folke/which-key.nvim',
    event = 'VeryLazy',
    cond = util.not_vscode,
    opts = {
      preset = 'helix',
      keys = {
        scroll_down = '<c-j>',
        scroll_up = '<c-k>',
      },
    },
    init = function ()
      util.keymap('<leader>k', '[Which-Key] Show keymaps for buffer', function() require('which-key').show({ global = false }) end)
    end,
  },
  {
    'folke/trouble.nvim',
    cond = util.not_vscode,
    event = 'VeryLazy',
    config = true,
    opts = {
      focus = true,
    },
    init = function ()
      local trouble = require('trouble')
      local user_trouble_config_group = vim.api.nvim_create_augroup('UserTroubleConfig', { clear = true })
      local trouble_close_on_leave = util.use_get_setting('trouble_close_on_leave', false)
      local trouble_quickfix_takeover = util.use_get_setting('trouble_quickfix_takeover', true)


      util.keymap('<leader>dd', '[Trouble] Diagnostics', function () trouble.toggle('diagnostics') end)
      util.keymap('<leader>dD', '[Trouble] Buffer diagnostics', function () trouble.open({ mode = 'diagnostics', filter = { buf = 0 } }) end)
      util.keymap('<leader>ds', '[Trouble] Symbols', function () trouble.toggle({ mode = 'symbols', focus = false }) end)
      util.keymap('<leader>dr', '[Trouble] References', function () trouble.toggle({ mode = 'lsp', focus = false, win = { position = 'right' } }) end)
      util.keymap('<leader>dq', '[Trouble] Quickfix List', function () trouble.toggle('qflist') end)
      util.keymap('<leader>dQ', '[Trouble] Location List', function () trouble.toggle('loclist') end)
      util.keymap('<leader>dc', '[Trouble] Close', trouble.close)

      vim.api.nvim_create_autocmd('BufLeave', {
        group = user_trouble_config_group,
        callback = function (ev)
          if vim.bo[ev.buf].filetype == 'trouble' and trouble_close_on_leave() then
            trouble.close()
          end
        end,
      })

      vim.api.nvim_create_autocmd('BufRead', {
        group = user_trouble_config_group,
        callback = function (ev)
          if vim.bo[ev.buf].buftype == 'quickfix' and trouble_quickfix_takeover() then
            vim.schedule(function ()
              vim.cmd([[cclose]])
              vim.cmd([[lclose]])
              trouble.open('qflist')
            end)
          end
        end,
      })

      vim.api.nvim_create_autocmd('QuickFixCmdPost', {
        group = user_trouble_config_group,
        pattern = 'l[^h]*',
        callback = function () trouble.open('loclist') end,
      })

      vim.api.nvim_create_autocmd('QuickFixCmdPost', {
        group = user_trouble_config_group,
        pattern = '[^l]*',
        callback = function () trouble.open('qflist') end,
      })
    end,
  },
  {
    'folke/todo-comments.nvim',
    dependencies = { 'folke/trouble.nvim', 'nvim-lua/plenary.nvim' },
    opts = {
      -- TODO: Test text
      -- Test continuation
      -- Todo: Alt text
      -- todo: Alt text
      -- FIX: Test text
      -- Test continuation
      -- FIXME: Alt text
      -- BUG: Alt text
      -- FIXIT: Alt text
      -- ISSUE: Alt text
      -- HACK: Test text
      -- Test continuation
      -- WARN: Test text
      -- Test continuation
      -- PERF: Test text
      -- Test continuation
      -- NOTE: Test text
      -- Test continuation
      -- TEST: Test text
      -- Test continuation
      -- IMPL: Test text
      -- Test continuation
      -- NOCOMMIT: Alt text
      -- DON'T COMMIT: Alt text
      -- NOPUSH: Alt text
      -- DON'T PUSH: Alt text
      --
      -- TODO @tag: Test tag syntax
      -- Test continuation
      -- TODO: Test multiple colons: Test text
      -- Test continuation
      -- TODO @tag: Test multiple colons: Test text
      -- Test continuation
      -- TODO test tag: Test text
      -- Test continuation
      -- @todo Test @ syntax
      -- Test continuation
      -- @todo @test-tag Test @ syntax
      -- Test continuation
      --
      -- No continuation test
      -- tOdO: False positive test
      -- TODO False positive test
      -- @ TODO False positive test
      keywords = {
        TODO = { alt = { 'Todo', 'ToDo', 'todo' } },
        TEST = { icon = ' ' },
        IMPL = {
          icon = ' ',
          color = 'warning',
          alt = { 'QWOP', 'qwop', 'FUCK', 'fuck', 'NOCOMMIT', "DON'T COMMIT", 'NOPUSH', "DON'T PUSH" },
        },
      },
      highlight = {
        pattern = {
          [[.*(<(KEYWORDS)>([^:]*)):]],
          [[.*(\@(KEYWORDS)>(\s+\@[A-Za-z0-9_-]+)*)]],
        },
      },
      search = {
        pattern = [[(\b(?:KEYWORDS)(?:\s+[^:\s]+)*\s*:)|(@(?:KEYWORDS)\b)]],
      },
    },
    init = function ()
      local trouble = require('trouble')
      local todo_comments = require('todo-comments')
      util.keymap('<leader>t', '[Trouble] Todos', function () trouble.toggle('todo') end)
      util.keymap('<leader>T', '[Trouble] Buffer todos', function () trouble.toggle({ mode = 'todo', filter = { buf = 0 } }) end)
      util.keymap(']t', '[Todos] Jump next', todo_comments.jump_next)
      util.keymap('[t', '[Todos] Jump prev', todo_comments.jump_prev)
    end
  },
  {
    'folke/noice.nvim',
    cond = util.not_vscode,
    dependencies = { 'MunifTanjim/nui.nvim' },
    event = 'VeryLazy',
    opts = {
      presets = {
        command_palette = true,
        lsp_doc_border = true,
      },
      commands = {
        all = { view = 'popup' },
        history = { view = 'popup' },
      },
      messages = {
        view = 'mini',
        view_error = 'notify',
        view_warn = 'notify',
        view_search = 'mini',
        view_history = 'popup',
      },
      lsp = {
        override = {
          ['vim.lsp.util.convert_input_to_markdown_lines'] = true,
          ['vim.lsp.util.stylize_markdown'] = true,
          ['cmp.entry.get_documentation'] = true,
        },
      },
      routes = {
        {
          filter = {
            event = 'lsp',
            kind = 'progress',
            cond = function(message)
              local client = vim.tbl_get(message.opts, 'progress', 'client')
              return client == 'null-ls'
            end,
          },
          opts = { skip = true },
        },
      },
    },
    init = function ()
      util.keymap('<leader>M', '[Notify] Show noice log', '<cmd>Telescope noice<cr>')
    end,
  },
  {
    'nvim-telescope/telescope.nvim',
    dependencies = { 'nvim-telescope/telescope-ui-select.nvim' },
    cond = vim.g.vscode ~= 1,
    event = 'VeryLazy',
    config = true,
  },
  { 'conormcd/matchindent.vim' },
  {
    'tummetott/reticle.nvim',
    event = 'VeryLazy',
    config = true,
  },
  {
    'axkirillov/hbac.nvim',
    config = true,
    init = function ()
      local hbac = require('hbac')
      util.keymap('<leader>bp', '[Bufclose] Pin/Unpin', hbac.toggle_pin)
      util.keymap('<leader>bo', '[Bufclose] Close unpinned', hbac.close_unpinned)
      util.keymap('<leader>ba', '[Bufclose] Toggle autoclose', hbac.toggle_autoclose)
    end
  },
  {
    'wesrupert/lualine.nvim',
    branch = 'feat/altfile',
    cond = util.not_vscode,
    dependencies = { 'nvim-tree/nvim-web-devicons', 'yavorski/lualine-macro-recording.nvim' },
    opts = function ()
      return {
        sections = {
          lualine_a = { 'mode', 'macro_recording' },
          lualine_x = { 'filetype' },
        },
        inactive_sections = {
          lualine_x = {},
        },
        tabline = {
          lualine_a = { function () return '  '.. (vim.g.mini_sessions_current or '') end },
          lualine_b = { { 'tabs', mode = 2, use_mode_colors = true } },
          lualine_x = { { 'altfile', path = 1, symbols = { separator = '󰘵 ' } } },
          lualine_z = { { 'filename', path = 1 } },
        },
      }
    end,
  },

  -- Action plugins
  {
    'mbbill/undotree',
    cond = util.not_vscode,
    config = function ()
      vim.g.undotree_TreeNodeShape   = ''
      vim.g.undotree_TreeReturnShape = '╮'
      vim.g.undotree_TreeVertShape   = '│'
      vim.g.undotree_TreeSplitShape  = '╯'
    end,
    init = function ()
      util.keymap('<leader>u', '[Undotree] Toggle', [[<cmd>UndotreeToggle<cr>]])

      -- Hotfix window management if focus.nvim is present
      vim.api.nvim_create_autocmd('VimEnter', {
        group = vim.api.nvim_create_augroup('UserFocusConfig', { clear = true }),
        callback = function ()
          local rebind_undotree_command = function (name)
            vim.api.nvim_del_user_command(name)
            vim.api.nvim_create_user_command(name, function ()
              local focus_ok, focus = pcall(require, 'focus')
              if focus_ok then focus.focus_disable() end
              vim.cmd([[call undotree#]] .. name .. [[()]])
              if focus_ok then focus.focus_enable() end
            end, { desc = '[Undotree] Patched ' .. name })
          end
          rebind_undotree_command('UndotreeShow')
          rebind_undotree_command('UndotreeToggle')
          return false
        end,
      })
    end,
  },
  {
    'folke/zen-mode.nvim',
    cond = util.not_vscode,
    opts = {
      window = {
        width = 0.8,
        height = 0.9,
      },
    },
    init = function ()
      util.keymap('gz', '[Zen mode] Toggle', require('zen-mode').toggle)
    end,
  },

  -- Text object plugins
  { 'glts/vim-textobj-comment', dependencies = { 'kana/vim-textobj-user' } },
  { 'kana/vim-textobj-indent', dependencies = { 'kana/vim-textobj-user' } },
  { 'lucapette/vim-textobj-underscore', dependencies = { 'kana/vim-textobj-user' } },
  { 'sgur/vim-textobj-parameter', dependencies = { 'kana/vim-textobj-user' } },

  -- Command plugins
  {
    'chrisgrieser/nvim-spider',
    init = function()
      local spider = require('spider')
      util.keymap('w',  '[Spider] Go word',        function () spider.motion('w') end)
      util.keymap('o',  '[Spider] Go word',        function () spider.motion('w') end,  { 'o', 'x' })
      util.keymap('e',  '[Spider] Go End',         function () spider.motion('e') end,  { 'n', 'o', 'x' })
      util.keymap('ge', '[Spider] Go end (back)',  function () spider.motion('ge') end, { 'n', 'o', 'x' })
      util.keymap('b',  '[Spider] Go word',        function () spider.motion('b') end)
      util.keymap('u',  '[Spider] Go word (back)', function () spider.motion('b') end,  { 'o', 'x' })
    end,
  },
  { 'kylechui/nvim-surround', event = 'VeryLazy', config = true },

  -- Filetype plugins
  { 'herringtondarkholme/yats.vim' },
  { 'aklt/plantuml-syntax' },
  { 'cakebaker/scss-syntax.vim' },
  { 'groenewege/vim-less' },
  { 'ipkiss42/xwiki.vim' },
  {
    'OXY2DEV/markview.nvim',
    cond = util.not_vscode,
    lazy = false,
    opts = {
      initial_state = false,
    },
  },
  { 'othree/yajs.vim' },
  { 'pangloss/vim-javascript' },
  {
    'posva/vim-vue',
    init = function ()
      vim.g.vue_pre_processors = 'detect_on_enter'
    end,
  },
  { 'sheerun/html5.vim' },
  { 'tpope/vim-git' },
}