local util = require('util')
local user_mini_config = vim.api.nvim_create_augroup('UserMiniConfig', { clear = true })

local plugins = {
  -- Load these first, as other minis have dependencies on it.
  extra = true,
  icons = true,
  visits = {
    init = function ()
      local mini_visits = require('mini.visits')
      util.keymap('gov', '[MiniVisits] Add label',    mini_visits.add_label)
      util.keymap('goV', '[MiniVisits] Remove label', mini_visits.remove_label)
    end,
  },

  align = true,
  files = util.not_vscode,
  pairs = util.not_vscode,
  splitjoin = true,
  trailspace = true,

  ai = {
    opts = function ()
      local gen_ai_spec = require('mini.extra').gen_ai_spec
      return {
        custom_textobjects = {
          d = gen_ai_spec.diagnostic(),
          l = gen_ai_spec.line(),
          n = gen_ai_spec.number(),
        },
      }
    end,
  },

  bracketed = {
    opts = {
      treesitter = { suffix = '' },
    },
  },

  bufremove = {
    cond = util.not_vscode,
    init = function ()
      util.keymap('<leader>zz', '[MiniBufremove] Save and close buffer', function ()
        vim.cmd('write')
        require('mini.bufremove').delete()
      end)
      util.keymap('<leader>zq', '[MiniBufremove] Close buffer', require('mini.bufremove').delete)
    end,
  },

  diff = {
    cond = util.not_vscode,
    opts = {
      view = {
        signs = { add = '┃', change = '┃', delete = '┃' },
      },
    },
    init = function ()
      local mini_diff = require('mini.diff')
      util.keymap(']g', '[MiniDiff] Toggle overlay', mini_diff.toggle_overlay)
      util.keymap('[g', '[MiniDiff] Toggle overlay', mini_diff.toggle_overlay)
    end,
  },

  hipatterns = {
    opts = function ()
      return {
        highlighters = {
          hex_color = require('mini.hipatterns').gen_highlighter.hex_color(),
        },
      }
    end
  },

  indentscope = {
    cond = util.not_vscode,
    opts = {
      symbol = '│',
      options = { try_as_border = true },
    },
    init = function ()
      vim.api.nvim_create_autocmd('ColorScheme', {
        group = user_mini_config,
        callback = function()
          vim.api.nvim_set_hl(0, 'MiniIndentscopeSymbol', { link = 'Comment', force = true })
        end,
      })
    end,
  },

  pick = {
    cond = util.not_vscode,
    opts = {
      options = {
        use_cache = true,
        mappings = {
          toggle_info = '<pgdn>',
          toggle_preview = '<pgup>',
          delete_word = '<c-bs>',
        },
      },
      window = {
        config = function ()
          -- Width/height should fit in the window, at scale of window size between min and max values.
          local style = { scale = 0.618, width  = { min = 50, max = 100, border = 18 }, height = { min = 10, max = 25,  border = 2  } }
          local width = math.min(vim.o.columns - 2, math.max(style.width.min, math.min(style.width.max,
            math.floor(style.scale * (vim.o.columns - (2 * style.width.border)))
          )))
          local height = math.min(vim.o.lines - 2, math.max(style.height.min, math.min(style.height.max,
            math.floor(style.scale * (vim.o.lines - (2 * style.height.border)))
          )))
          return {
            anchor = 'NW', height = height, width = width,
            row = height >= vim.o.lines - 2 and 0 or style.height.border,
            col = math.floor(0.5 * (vim.o.columns - width)),
          }
        end
      },
    },
    init = function ()
      local mini_extra = require('mini.extra')
      local mini_pick = require('mini.pick')
      local mini_visits = require('mini.visits')

      -- Use as the builtin select dialog.
      vim.ui.select = mini_pick.ui_select

      ---Pick from files, sorted by MRU.
      ---@param local_opts table|nil Options defining behavior of this particular picker.
      ---@param opts table|nil Options forwarded to |MiniPick.start()|.
      ---@see https://github.com/echasnovski/mini.nvim/discussions/609
      mini_pick.registry.mrufiles = function (local_opts, opts)
        local cwd = opts and opts.cwd or nil
        local get_mru = function ()
          local mru = mini_visits.list_paths(cwd, { sort = mini_visits.gen_sort.z() })
          mru = vim.tbl_map(function (path) return vim.fn.fnamemodify(path, ":.") end, mru)
          return mru
        end

        local visit_paths = get_mru()
        vim.tbl_add_reverse_lookup(visit_paths)
        local current_file = vim.fn.expand("%:.")
        if visit_paths[current_file] then
          -- Current file last
          visit_paths[current_file] = math.huge
        end

        mini_pick.builtin.files(local_opts or nil, {
          source = {
            name = "Files (MRU)",
            cwd = cwd,
            match = function(items, indices, query)
              local get_weight = function (idx) return visit_paths[items[idx]] or math.huge end
              local matched = query == ''
                and vim.tbl_filter(function (idx) return visit_paths[items[idx]] == nil end, indices)
                or mini_pick.default_match(items, indices, query, { sync = true })
              table.sort(matched, function(idx1, idx2) return get_weight(idx1) < get_weight(idx2) end)
              return matched
            end,
          },
        })
      end

      mini_pick.registry.manage_buffers = function (local_opts, opts)
        local wipeout = function ()
          vim.api.nvim_buf_delete(mini_pick.get_picker_matches().current.bufnr, {})
          -- Relaunch to remove from items
          mini_pick.registry.manage_buffers(local_opts, opts)
        end
        local merged_opts = vim.tbl_deep_extend('keep', { mappings = { wipeout = { char = '<c-d>', func = wipeout } } }, opts or {})
        mini_pick.builtin.buffers(local_opts, merged_opts)
      end

      util.keymap('<c-p>', '[MiniPick] Files (cwd)',   mini_pick.registry.mrufiles)
      util.keymap('<a-p>', '[MiniPick] Recent files',  function() mini_extra.pickers.visit_paths({ cwd = '' }) end)
      util.keymap('<c-;>', '[MiniPick] Commands',      function() mini_extra.pickers.history({ scope = ':' }) end)
      util.keymap('<c-e>', '[MiniPick] Explorer',      mini_extra.pickers.explorer)
      util.keymap('<c-b>', '[MiniPick] Buffers',       mini_pick.registry.manage_buffers)
      util.keymap('<c-/>', '[MiniPick] Find',          mini_pick.builtin.grep_live)
      util.keymap('<a-/>', '[MiniPick] Searches',      function() mini_extra.pickers.history({ scope = '/' }) end)
      util.keymap('<c-g>', '[MiniPick] Git hunks',     mini_extra.pickers.git_hunks)
      util.keymap('<a-g>', '[MiniPick] Git branches',  mini_extra.pickers.git_branches)
      util.keymap('<a-t>', '[MiniPick] Treesitter',    mini_extra.pickers.treesitter)
      util.keymap('<a-o>', '[MiniPick] Jumplist',      function() mini_extra.pickers.list({ scope = 'jump' }) end)
      util.keymap('<a-u>', '[MiniPick] Changelist',    function() mini_extra.pickers.list({ scope = 'change' }) end)
      util.keymap('<a-q>', '[MiniPick] Location list', function() mini_extra.pickers.list({ scope = 'location-list' }) end)
      util.keymap('<c-q>', '[MiniPick] Quickfix',      function() mini_extra.pickers.list({ scope = 'quickfix' }) end)
      util.keymap('<a-k>', '[MiniPick] Keymaps',       mini_extra.pickers.keymaps)
      util.keymap("<c-'>", '[MiniPick] Marks',         mini_extra.pickers.marks)
      util.keymap('<c-s>', '[MiniPick] Spellcheck',    mini_extra.pickers.spellsuggest)
      util.keymap('<c-,>', '[MiniPick] Options',       mini_extra.pickers.options)
    end,
  },

  sessions = {
    cond = util.not_vscode,
    config = function ()
      local mini_sessions = require('mini.sessions')
      mini_sessions.setup({
        autoread = true,
        autowrite = true,
        hooks = {
          post = {
            read = function (ev) vim.g.mini_sessions_current = ev.name end,
            write = function (ev) vim.g.mini_sessions_current = ev.name end,
            delete = function (ev)
              if vim.g.mini_sessions_current == ev.name then vim.g.mini_sessions_current = nil end
            end
          },
        },
      })
    end,
    init = function ()
      local mini_sessions = require('mini.sessions')
      vim.o.sessionoptions = 'curdir,folds,help,tabpages,winsize,terminal'
      util.keymap('<leader>ss', '[MiniSession] Select', mini_sessions.select)
      util.keymap('<leader>sw', '[MiniSession] Update', function ()
        mini_sessions.write(vim.g.mini_sessions_current or vim.fn.input('Session Name: '))
      end)
      util.keymap('<leader>sW', '[MiniSession] Write',  function () mini_sessions.write(vim.fn.input('Session Name: ')) end)
    end,
  },

  starter = {
    cond = util.not_vscode,
    config = function ()
      local starter = require('mini.starter')
      local lazy_status_sok, lazy_status = pcall(require, 'lazy.status')
      starter.setup({
        autoopen = false,
        header = function()
          local lines
          local add_line = function(l)
            if lines == nil then lines = l else lines = lines..'\n'..l end
          end

          local hour = tonumber(vim.fn.strftime('%H'))
          local day_part =
            6 <= hour and hour < 12 and 'morning' or
            12 <= hour and hour < 17 and 'afternoon' or 'evening'
          local username = vim.loop.os_get_passwd()['username'] or 'USERNAME'
          add_line(('Good %s, %s'):format(day_part, username))

          if lazy_status_sok and lazy_status.has_updates() then
            add_line('! '..lazy_status.updates()..' plugin updates available')
          end

          add_line('> '..vim.fn.getcwd())

          return lines
        end,
        items = {
          { section = 'Files',     name = 'E.  Explorer',             action = 'Pick explorer' },
          { section = 'Files',     name = 'F.  Files',                action = 'Pick mrufiles' },
          { section = 'Files',     name = 'R.  Recent Files',         action = 'Pick visit_paths cwd=""' },
          { section = 'Files',     name = 'T.  Tracked Files',        action = 'Pick git_files' },
          { section = 'Files',     name = 'B.  Branches (Git)',       action = 'Pick git_branches' },
          { section = 'Files',     name = 'M.  Changes (Git)',        action = 'Pick git_hunks' },
          { section = 'Files',     name = 'G.  Live Grep',            action = 'Pick grep_live tool="rg"' },
          { section = 'Files',     name = 'C.  Recent Commands',      action = 'Pick history' },
          starter.sections.sessions(5, true),
          starter.sections.recent_files(10, false, false),
          { section = 'System',    name = 'S.  Settings',             action = function () vim.cmd('edit '..vim.g.vimrc) end },
          { section = 'System',    name = 'SL. Settings (local)',     action = function () vim.cmd('edit '..vim.g.vimrc_custom) end},
          { section = 'System',    name = 'SP. Settings (plugins)',   action = function () vim.cmd('edit '..vim.g.vimrc_plug) end},
          { section = 'System',    name = 'P.  Plugins',              action = 'Lazy' },
          { section = 'System',    name = 'L.  LSPs',                 action = 'Mason' },
          { section = 'System',    name = 'Q.  Quit',                 action = 'qall' },
        },
        content_hooks = {
          starter.gen_hook.indexing('all', { 'Files', 'System', 'Recent files' }),
          starter.gen_hook.aligning('center', 'center'),
          starter.gen_hook.adding_bullet(),
        },
      })
    end,
    init = function ()
      util.keymap('<a-n>', '[MiniStarter] Open', require('mini.starter').open)
    end,
  },
}

return {
  {
    'echasnovski/mini.nvim',
    config = function()
      local print_mini = function (m, ...) print('[Mini.'..m..'] ', ...) end
      local loaded = {}

      for k, p in pairs(plugins) do
        -- Set up modules (load opts and run config)
        xpcall(function ()
          local plugin_ok, plugin = util.maybe_pcall(p)
          if not plugin_ok then return end

          local plugin_is_table = type(plugin) == 'table'
          if plugin_is_table and util.has_key(plugin, 'cond') then
            local cond_ok = util.maybe_pcall(plugin.cond)
            if not cond_ok then return end
          end


          -- Get opts
          local opts = {}
          if util.has_key(plugin, 'opts') then
            local opts_ok, opts_result = util.maybe_pcall(plugin.opts)
            if not opts_ok or type(opts_result) ~= 'table' then
              print_mini(k, 'Error loading opts', opts_result)
              return
            end
            opts = opts_result
          end

          -- Setup module
          if util.has_key(plugin, 'config') then
            local config_ok, config_result = util.maybe_pcall(plugin.config, opts)
            if not config_ok then
              print_mini(k, 'Error loading config', config_result)
              return
            end
          else
            local module_ok, module_result = pcall(require, 'mini.' .. k)
            if not module_ok then
              print_mini(k, 'Error importing module', module_result)
              return
            end
            local setup_ok, setup_result = pcall(module_result.setup, opts)
            if not setup_ok then
              print_mini(k, 'Error running setup', setup_result)
              return
            end
          end

          -- Setup complete, add to post-setup init modules
          loaded[k] = plugin
        end, function(err) print(err) end)
      end

      -- Run post-install scripts
      for k, p in pairs(loaded) do
        xpcall(function ()
          if util.has_key(p, 'init') then
            local init_ok, init_result = util.maybe_pcall(p.init)
            if not init_ok then
              print_mini(k, 'Error running init', init_result)
              return
            end
          end
        end, function(err) print(err) end)
      end
    end,
  },
}