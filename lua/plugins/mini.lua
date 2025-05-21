local util = require('util')
local user_mini_config = vim.api.nvim_create_augroup('UserMiniConfig', { clear = true })

---@class MiniConfig
---@field cond boolean|(fun(): boolean)|nil
---@field opts table|(fun(): table)|nil
---@field config (fun(opts: table))|nil
---@field init (fun(opts: table))|nil

---@type { [string]: boolean|MiniConfig }
local plugins = {
  -- Load these first, as other minis have dependencies on it.
  extra = true,
  icons = true,
  visits = {
    config = function (opts)
      local visits = require('mini.visits')
      visits.setup(opts)

      util.keymap('gov', '[MiniVisits] Add label',    visits.add_label)
      util.keymap('goV', '[MiniVisits] Remove label', visits.remove_label)
    end,
  },

  -- Default configs

  align = true,
  files = true,
  jump = true,
  jump2d = true,
  move = true,
  snippets = true,
  trailspace = true,

  -- Custom configs

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
    config = function (opts)
      local bufremove = require('mini.bufremove')
      bufremove.setup(opts)
      util.keymap('<leader>zz', '[MiniBufremove] Save and close buffer', function ()
        vim.cmd('write')
        bufremove.delete()
      end)
      util.keymap('<leader>zq', '[MiniBufremove] Close buffer', bufremove.delete)
    end,
  },

  diff = {
    opts = {
      view = {
        signs = { add = '┃', change = '┃', delete = '┃' },
      },
    },
    config = function (opts)
      local diff = require('mini.diff')
      diff.setup(opts)
      util.keymap(']g', '[MiniDiff] Toggle overlay', diff.toggle_overlay)
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
    opts = {
      symbol = '│',
      options = { try_as_border = true },
    },
    init = function ()
      local ignore_buftypes, ignore_filetypes = util.get_special_types('indent')
      vim.api.nvim_create_autocmd({ 'BufNew', 'BufRead', 'TermEnter', 'Filetype' }, {
        group = user_mini_config,
        callback = function()
          if vim.tbl_contains(ignore_buftypes, vim.bo.buftype)
            or vim.tbl_contains(ignore_filetypes, vim.bo.filetype) then
            vim.b.miniindentscope_disable = true
          end
        end,
      })
      vim.api.nvim_create_autocmd('ColorScheme', {
        group = user_mini_config,
        callback = function()
          vim.api.nvim_set_hl(0, 'MiniIndentscopeSymbol', { link = 'Comment', force = true })
        end,
      })
    end,
  },

  operators = {
    opts = {
      evaluate = { prefix = 'g=' },
      exchange = { prefix = 'g<tab>' },
      multiply = { prefix = 'g+' },
      replace  = { prefix = 'gor' },
      sort     = { prefix = 'gos' },
    },
  },

  sessions = {
    opts = {
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
    },
    config = function (opts)
      local sessions = require('mini.sessions')

      -- Autoread with command line support
      local init_session = vim.g.init_session
      if init_session then
        vim.tbl_extend('force', opts or {}, { autoread = false })
        vim.api.nvim_create_autocmd('VimEnter', {
          desc = 'Autoread environment session',
          group = user_mini_config,
          nested = true,
          once = true,
          callback = function () sessions.read(init_session) end,
        })
      end

      sessions.setup(opts)

      util.keymap('<c-s>',      '[MiniSession] Select', sessions.select)
      util.keymap('<leader>se', '[MiniSession] Select', sessions.select)
      util.keymap('<leader>sw', '[MiniSession] Write',  function () sessions.write(vim.fn.input('Session Name: ')) end)
      util.keymap('<leader>ss', '[MiniSession] Update', function ()
        sessions.write(vim.g.mini_sessions_current or vim.fn.input('Session Name: '))
      end)
    end,
  },

  splitjoin = {
    config = function ()
      local splitjoin = require('mini.splitjoin')
      local hook_opts = { brackets = { '%b{}' } }
      splitjoin.setup({
        split = {
          hooks_post = { splitjoin.gen_hook.add_trailing_separator(hook_opts) },
        },
        join = {
          hooks_post= {
            splitjoin.gen_hook.del_trailing_separator(hook_opts),
            splitjoin.gen_hook.pad_brackets(hook_opts),
          },
        },
      })
    end,
  },

  starter = {
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

      util.keymap('<a-n>', '[MiniStarter] Open', starter.open)
    end,
  },
}

return {
  'echasnovski/mini.nvim',
  config = function()
    local print_mini = function (m, ...) print('[Mini.'..m..'] ', ...) end
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

        -- Run pre-install scripts
        if util.has_key(p, 'init') then
          local init_ok, init_result = util.maybe_pcall(p.init)
          if not init_ok then
            print_mini(k, 'Error running init', init_result)
            return
          end
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
      end, function(err) print(err) end)
    end
  end,
}