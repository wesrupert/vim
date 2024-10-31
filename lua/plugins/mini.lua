local notvscode = vim.g.vscode ~= 1
local plugins = {
  -- Load mini.extra first, as other minis have dependencies on it.
  extra = true,

  align = true,
  bracketed = true,
  files = notvscode,
  notify = notvscode,
  pairs = notvscode,
  splitjoin = true,
  statusline = notvscode,
  trailspace = true,
  visits = true,

  ai = {
    enabled = true,
    opts = function ()
      local gen_ai_spec = require('mini.extra').gen_ai_spec
      require('mini.ai').setup({
        custom_textobjects = {
          d = gen_ai_spec.diagnostic(),
          l = gen_ai_spec.line(),
          n = gen_ai_spec.number(),
        },
      })
    end,
  },

  diff = {
    enabled = notvscode,
    opts = {
      view = {
        signs = { add = '┃', change = '┃', delete = '┃' },
      },
    },
    init = function ()
      vim.keymap.set('n', ']g', require('mini.diff').toggle_overlay, { desc = '[MiniDiff] Toggle overlay' })
      vim.keymap.set('n', '[g', require('mini.diff').toggle_overlay, { desc = '[MiniDiff] Toggle overlay' })
    end,
  },

  indentscope = {
    enabled = notvscode,
    opts = function ()
      return {
        symbol = '│',
        -- draw = {
        --   delay = 500,
        --   animation = require('mini.indentscope').gen_animation.none()
        -- },
        options = {
          try_as_border = true,
        },
      }
    end,
    init = function ()
      vim.api.nvim_create_autocmd('ColorScheme', {
        group = vim.api.nvim_create_augroup('[MiniIndentscope] Update colors', { clear = true }),
        callback = function()
          vim.api.nvim_set_hl(0, 'MiniIndentscopeSymbol', { link = 'Comment', force = true })
        end,
      })
    end,
  },

  pick = {
    enabled = notvscode,
    opts = {
      options = {
        use_cache = true,
        content_from_bottom = true,
      },
      window = {
        config = function ()
          local height = math.floor(0.618 * vim.o.lines)
          local width = math.floor(0.618 * vim.o.columns)
          return {
            anchor = 'NW', height = height, width = width,
            row = math.floor(0.5 * (vim.o.lines - height)),
            col = math.floor(0.5 * (vim.o.columns - width)),
          }
        end
      },
    },
    init = function ()
      local MiniPick = require('mini.pick')
      local MiniVisits = require('mini.visits')

      -- Additional visits-plus-files picker, courtesy https://github.com/echasnovski/mini.nvim/discussions/609
      MiniPick.registry.mrufiles = function ()
        local visit_paths = MiniVisits.list_paths(nil, { sort = MiniVisits.gen_sort.z() })
        visit_paths = vim.tbl_map(function (path) return vim.fn.fnamemodify(path, ":.") end, visit_paths)
        vim.tbl_add_reverse_lookup(visit_paths)

        -- Current file last
        local current_file = vim.fn.expand("%:.")
        if visit_paths[current_file] then
          visit_paths[current_file] = math.huge
        end

        MiniPick.builtin.files(nil, {
          source = {
            name = "Files (MRU)",
            match = function(stritems, indices, query)
              local filtered = MiniPick.default_match(stritems, indices, query, { sync = true }) or {}
              local get_weight = function (item) return visit_paths[stritems[item]] or math.huge end
              table.sort(filtered, function(item1, item2) return get_weight(item1) < get_weight(item2) end)
              return filtered
            end,
          },
        })
      end

      -- Careful not to collide with the pickers in telescope.nvim!
      vim.keymap.set('n', '<c-p>', require('mini.pick').registry.mrufiles, { desc = '[MiniPick] Recent files (cwd)' })
      vim.keymap.set('n', 'goo', function() require('mini.extra').pickers.visit_paths({ cwd = '' }) end, { desc = '[MiniPick] Recent files' })
      vim.keymap.set('n', 'goO', require('mini.visits').add_label, { desc = '[MiniVisits] Add label' })
      vim.keymap.set('n', 'goX', require('mini.visits').remove_label, { desc = '[MiniVisits] Remove label' })
      vim.keymap.set('n', 'gop', require('mini.extra').pickers.visit_paths, { desc = '[MiniPick] Recent files (cwd)' })
      vim.keymap.set('n', 'goc', require('mini.extra').pickers.git_branches, { desc = '[MiniPick] Git branches' })
      vim.keymap.set('n', 'god', function() require('mini.extra').pickers.lsp({ scope = 'definition' }) end, { desc = '[MiniPick] LSP definitions' })
      vim.keymap.set('n', 'gof', require('mini.extra').pickers.explorer, { desc = '[MiniPick] File system' })
      vim.keymap.set('n', 'gog', require('mini.extra').pickers.git_hunks, { desc = '[MiniPick] Git hunks' })
      vim.keymap.set('n', 'goj', function() require('mini.extra').pickers.list({ scope = 'jump' }) end, { desc = '[MiniPick] Jumplist' })
      vim.keymap.set('n', 'goC', function() require('mini.extra').pickers.list({ scope = 'jump' }) end, { desc = '[MiniPick] Changelist' })
      vim.keymap.set('n', 'goQ', function() require('mini.extra').pickers.list({ scope = 'location-list' }) end, { desc = '[MiniPick] Location list' })
      vim.keymap.set('n', 'gok', require('mini.extra').pickers.keymaps, { desc = '[MiniPick] Keymaps' })
      vim.keymap.set('n', 'goq', function() require('mini.extra').pickers.list({ scope = 'quickfix' }) end, { desc = '[MiniPick] Quickfix' })
      vim.keymap.set('n', 'goQ', function() require('mini.extra').pickers.list({ scope = 'location-list' }) end, { desc = '[MiniPick] Location list' })
      vim.keymap.set('n', 'gom', require('mini.extra').pickers.marks, { desc = '[MiniPick] Marks' })
      vim.keymap.set('n', 'gor', function() require('mini.extra').pickers.lsp({ scope = 'references' }) end, { desc = '[MiniPick] LSP references' })
      vim.keymap.set('n', 'gos', require('mini.extra').pickers.spellsuggest, { desc = '[MiniPick] Spellcheck' })
      vim.keymap.set('n', 'got', require('mini.extra').pickers.treesitter, { desc = '[MiniPick] Treesitter nodes' })
      vim.keymap.set('n', 'gov', require('mini.extra').pickers.options, { desc = '[MiniPick] Options' })
      vim.keymap.set('n', 'g/', require('mini.pick').builtin.grep_live, { desc = '[MiniPick] Find' })
      vim.keymap.set('n', 'z/', function() require('mini.extra').pickers.history({ scope = '/' }) end, { desc = '[MiniPick] Recent searches' })
      vim.keymap.set('n', 'z;', function() require('mini.extra').pickers.history({ scope = ':' }) end, { desc = '[MiniPick] Recent commands' })
    end,
  },

  sessions = {
    enabled = notvscode,
    init = function ()
      vim.keymap.set('n', '<leader>ss', require('mini.sessions').select, { desc = '[MiniSession] Select' })
      vim.keymap.set('n', '<leader>sw', function() require('mini.sessions').write(vim.fn.input('Session Name > ')) end, { desc = '[MiniSession] Write' })
      vim.keymap.set('n', '<leader>su', function() require('mini.sessions').write(require('mini.sessions').get_latest(), { force = true }) end, { desc = '[MiniSession] Update' })
    end,
  },

  starter = {
    enabled = notvscode,
    config = function ()
      local starter = require('mini.starter')
      local lazy_status_sok, lazy_status = pcall(require, 'lazy.status')
      starter.setup({
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

      _G.open_starter_if_empty_buffer = function ()
        local buf_id = vim.api.nvim_get_current_buf()
        local is_empty = vim.api.nvim_buf_get_name(buf_id) == "" and vim.bo[buf_id].filetype == ''
        if not is_empty then return end
        starter.open()
      end
    end,
  },
}

local function has_key(obj, key)
  if type(obj) == 'table' then
    return obj[key] ~= nil
  else
    return false
  end
end

return {
  {
    'echasnovski/mini.nvim',
    config = function()
      for k, plugin in pairs(plugins) do
        xpcall(function ()
          if plugin == true or (type(plugin) == 'table' and plugin['enabled'] ~= false) then
            local opts = nil
            if has_key(plugin, 'opts') then
              local o = plugin.opts
              if type(o) == 'function' then opts = o() else opts = o end
            end
            opts = type(opts) == 'table' and opts or {}
            if has_key(plugin, 'config') and type(plugin.config) == 'function' then
              ---@diagnostic disable-next-line LSP is adamant it must be a 0-arg function.
              plugin.config(opts)
            else
              local sok, module = pcall(require, 'mini.' .. k)
              if sok then module.setup(opts) else print('Mini module ' .. k .. ' not found.') end
            end
            if has_key(plugin, 'init') and type(plugin.init) == 'function' then
              plugin.init()
            end
          end
        end, function(err) print(err) end)
      end
    end,
    -- init = function ()
    --   for _, plugin in pairs(plugins) do
    --     xpcall(function ()
    --       if not has_key(plugin, 'enabled') or plugin.enabled ~= false then
    --         if has_key(plugin, 'init') and type(plugin.init) == 'function' then
    --           plugin.init()
    --         end
    --       end
    --     end, function(err) print(err) end)
    --   end
    -- end
  },
}