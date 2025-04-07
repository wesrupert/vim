local util = require('util')

return {
  -- Colorschemes
  {
    'f-person/auto-dark-mode.nvim',
    opts = {
      set_dark_mode = function()
        vim.api.nvim_set_option_value('background', 'dark', {})
        if vim.g.nightheme then vim.cmd('colorscheme ' .. vim.g.nightheme) end
      end,
      set_light_mode = function()
        vim.api.nvim_set_option_value('background', 'light', {})
        if vim.g.daytheme then vim.cmd('colorscheme ' .. vim.g.daytheme) end
      end,
    },
  },
  {
    'edeneast/nightfox.nvim',
    priority = 1000,
    cond = util.not_vscode,
    opts = {
      options = {
        styles = {
          keywords = 'italic',
          conditionals = 'italic',
          comments = 'italic',
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
    'wesrupert/snacks.nvim',
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
          if msg.msg:match([[Error in decoration provider]]) then return true end
          if msg.msg:match([[Config Change Detected. Reloading...]]) then return true end
          return false
        end,
      },
      picker = {
        matcher = {
          cwd_bonus = true,
          frecency = true,
          history_bonus = true,
        },
        jump = { reuse_win = true },
        kind_icons = vim.tbl_map(function (v) return v .. ' ' end, util.kind_icons),
      },
    },
    init = function ()
      local snacks = require('snacks')
      local user_snacks_group = vim.api.nvim_create_augroup('UserSnacksConfig', { clear = true })

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

      util.keymap('<c-p>', '[Snacks] Files (cwd)',   snacks.picker.smart)
      util.keymap('<a-p>', '[Snacks] Recent files',  snacks.picker.recent)
      util.keymap('<c-;>', '[Snacks] Commands',      snacks.picker.command_history)
      util.keymap('<a-e>', '[Snacks] Explorer',      snacks.picker.explorer)
      util.keymap('<a-b>', '[Snacks] Buffers',       snacks.picker.buffers)
      util.keymap('<c-/>', '[Snacks] Find',          snacks.picker.grep)
      util.keymap('<a-/>', '[Snacks] Searches',      snacks.picker.search_history)
      util.keymap('<c-g>', '[Snacks] Git hunks',     snacks.picker.git_diff)
      util.keymap('<a-g>', '[Snacks] Git branches',  snacks.picker.git_branches)
      util.keymap('<a-t>', '[Snacks] Treesitter',    snacks.picker.treesitter)
      util.keymap('<a-o>', '[Snacks] Jumplist',      snacks.picker.jumps)
      util.keymap('<a-u>', '[Snacks] Changelist',    snacks.picker.undo)
      util.keymap('<a-q>', '[Snacks] Location list', snacks.picker.loclist)
      util.keymap('<c-q>', '[Snacks] Quickfix',      snacks.picker.qflist)
      util.keymap('<c-k>', '[Snacks] Keymaps',       snacks.picker.keymaps)
      util.keymap("<c-'>", '[Snacks] Marks',         snacks.picker.marks)
      util.keymap('z=',    '[Snacks] Spellcheck',    snacks.picker.spelling)

      vim.api.nvim_create_autocmd('LspAttach', {
        group = user_snacks_group,
        callback = function(ev)
          util.keymap('<leader>dc', '[Snacks] LSP Config',     snacks.picker.lsp_config,      nil, ev.buf)
          util.keymap('<leader>dg', '[Snacks] LSP Definition', snacks.picker.lsp_definitions, nil, ev.buf)
          util.keymap('<leader>dR', '[Snacks] LSP References', snacks.picker.lsp_references,  nil, ev.buf)
          util.keymap('<leader>dS', '[Snacks] LSP Symbols',    snacks.picker.lsp_symbols,     nil, ev.buf)
        end,
      })
    end,
  },
  {
    'folke/which-key.nvim',
    event = 'VeryLazy',
    cond = util.not_vscode,
    opts = {
      preset = 'helix',
    },
    init = function ()
      util.keymap('<leader>k', '[Which-Key] Show keymaps', require('which-key').show)
      util.keymap('<leader>K', '[Which-Key] Show keymaps for buffer', function() require('which-key').show({ global = false }) end)
    end,
  },
  {
    'folke/trouble.nvim',
    dependencies = { 'folke/snacks.nvim' },
    cond = util.not_vscode,
    event = 'VeryLazy',
    opts = {
      focus = true,
    },
    specs = {
      'folke/snacks.nvim',
      opts = function(_, opts)
        return vim.tbl_deep_extend('force', opts or {}, {
          picker = {
            actions = require('trouble.sources.snacks').actions,
            win = {
              input = {
                keys = {
                  ['<c-t>'] = {
                    'trouble_open',
                    mode = { 'n', 'i' },
                  },
                },
              },
            },
          },
        })
      end,
    },
    init = function ()
      local trouble = require('trouble')
      local user_trouble_config_group = vim.api.nvim_create_augroup('UserTroubleConfig', { clear = true })
      local trouble_close_on_leave = util.use_get_setting('trouble_close_on_leave', false)
      local trouble_quickfix_takeover = util.use_get_setting('trouble_quickfix_takeover', true)

      util.keymap('<leader>dd', '[Trouble] Buffer diagnostics', function () trouble.open({ mode = 'diagnostics', filter = { buf = 0 } }) end)
      util.keymap('<leader>dD', '[Trouble] Diagnostics', function () trouble.toggle('diagnostics') end)
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
      util.keymap(']t', '[Todos] Jump next', todo_comments.jump_next)
      util.keymap('[t', '[Todos] Jump prev', todo_comments.jump_prev)
      util.keymap('<leader>t', '[Trouble] Buffer todos', function () trouble.toggle({ mode = 'todo', filter = { buf = 0 } }) end)
      util.keymap('<leader>T', '[Trouble] Todos', function () trouble.toggle('todo') end)
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
          lualine_a = { function () return util.kind_icons.NeoVim .. '  '.. (vim.g.mini_sessions_current or '') end },
          lualine_b = { { 'tabs', mode = 2, use_mode_colors = true } },
          lualine_x = { { 'altfile', path = 1, symbols = { separator = '󰘵 ' } } },
          lualine_z = { { 'filename', path = 1 } },
        },
      }
    end,
  },
  {
    {
      'Bekaboo/dropbar.nvim',
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
    }
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
    opts = { },
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