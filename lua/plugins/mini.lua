local plugins = {
  align = {
    config = function ()
      require('mini.align').setup()
    end,
  },

  comment = {
    config = function ()
      require('mini.comment').setup({
        mappings = {
          comment = '<leader>cs',
          comment_line = '<leader>cc',
          textobject = 'gc',
        }
      })
    end,
  },

  indentscope = {
    config = function ()
      require('mini.indentscope').setup()
    end,
  },

  sessions = {
    enabled = vim.g.vscode ~= 1,
    config = function ()
      require('mini.sessions').setup()
    end,
    init = function ()
      vim.keymap.set('n', '<leader>ss', '<cmd>lua MiniSessions.select()<cr>', { desc = 'MiniSession-select' })
      vim.keymap.set('n', '<leader>sw', '<cmd>lua MiniSessions.write(vim.fn.input("Session Name > "))<cr>', { desc = 'MiniSession-write' })
    end,
  },

  splitjoin = {
    config = function ()
      require('mini.splitjoin').setup()
    end,
  },

  starter = {
    enabled = vim.g.vscode ~= 1,
    config = function ()
      local starter = require('mini.starter')
      starter.setup({
        header = function()
          local hour = tonumber(vim.fn.strftime('%H'))
          local day_part = 'evening'
          if 9 <= hour and hour < 12 then
            day_part = 'morning'
          elseif 12 <= hour and hour < 17 then
            day_part = 'afternoon'
          end
          local username = vim.loop.os_get_passwd()['username'] or 'USERNAME'
          return ('Good %s, %s'):format(day_part, username)
        end,
        items = {
          { section = 'Commands', name = 'Files',   action = 'Telescope find_files', },
          { section = 'Commands', name = 'Recent',  action = 'Telescope oldfiles',   },
          { section = 'Commands', name = 'Branches', action = 'Telescope git_branches',  },
          { section = 'Commands', name = 'Changed', action = 'Telescope git_status',  },
          { section = 'Commands', name = 'Grep',    action = 'Telescope live_grep',  },
          starter.sections.sessions(5, true),
          starter.sections.recent_files(10, false),
        },
        content_hooks = {
          starter.gen_hook.aligning('center', 'center'),
          starter.gen_hook.adding_bullet(),
          starter.gen_hook.indexing('all', { 'Sessions', 'Recent files' }),
        },
      })
    end,
  },
}

return {
  {
    'echasnovski/mini.nvim',
    config = function()
      for _, plugin in pairs(plugins) do
        pcall(function ()
          if plugin.enabled ~= false and plugin.config ~= nil then
            plugin.config()
          end
        end)
      end
    end,
    init = function ()
      for _, plugin in pairs(plugins) do
        pcall(function ()
          if plugin.enabled ~= false and plugin.init ~= nil then
            plugin.init()
          end
        end)
      end
    end
  },
}