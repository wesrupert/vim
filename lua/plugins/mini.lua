local plugins = {
  align = true,
  pairs = true,
  splitjoin = true,
  statusline = true,
  indentscope = {
    enabled = vim.g.vscode ~= 1,
  },

  comment = {
    opts = {
      mappings = {
        comment = '<leader>c',
        comment_line = '<leader>cc',
      },
    },
    init = function ()
      vim.keymap.set('o', 'ac', require('mini.comment').textobject, { desc = 'MiniSession-select' })
    end,
  },

  sessions = {
    enabled = vim.g.vscode ~= 1,
    init = function ()
      vim.keymap.set('n', '<leader>ss', require('mini.sessions').select, { desc = 'MiniSession-select' })
      vim.keymap.set('n', '<leader>sw', function() require('mini.sessions').write(vim.fn.input('Session Name > ')) end, { desc = 'MiniSession-write' })
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
          { section = 'Commands', name = 'Quit',    action = 'qall',  },
          starter.sections.sessions(5, true),
          starter.sections.recent_files(10, false),
        },
        content_hooks = {
          starter.gen_hook.aligning('center', 'center'),
          starter.gen_hook.adding_bullet(),
        },
      })
    end,
  },
}

local function hasKey(obj, key)
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
        pcall(function ()
          if not hasKey(plugin, 'enabled') or plugin.enabled ~= false then
            if hasKey(plugin, 'config') and type(plugin.config) == 'function' then
              plugin.config()
            else
              local sok, module = pcall(require, 'mini.' .. k)
              if sok then
                local opts = nil
                if hasKey(plugin, 'opts') then opts = plugin.opts end
                module.setup(opts)
              end
            end
          end
        end)
      end
    end,
    init = function ()
      for _, plugin in pairs(plugins) do
        pcall(function ()
          if not hasKey(plugin, 'enabled') or plugin.enabled ~= false then
            if hasKey(plugin, 'init') and type(plugin.init) == 'function' then
              plugin.init()
            end
          end
        end)
      end
    end
  },
}