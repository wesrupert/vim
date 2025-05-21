local util = require('util')
return {
  'folke/trouble.nvim',
  dependencies = { 'folke/snacks.nvim' },
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
    local trouble_close_on_leave = util.use_setting('trouble_close_on_leave', false).get
    local trouble_quickfix_takeover = util.use_setting('trouble_quickfix_takeover', true).get
    local trouble_toggle_sidebar = function (mode, opts)
      trouble.toggle(vim.tbl_deep_extend('keep', { mode = mode }, opts or {}, { win = { position = 'right' }, focus = false }))
    end

    util.keymap('grx', '[Trouble] Close',                trouble.close)
    util.keymap('grO', '[Trouble] Symbols',              function () trouble_toggle_sidebar('symbols') end)
    util.keymap('grq', '[Trouble] Quickfix List',        function () trouble.toggle('qflist') end)
    util.keymap('grQ', '[Trouble] Location List',        function () trouble.toggle('loclist') end)
    util.keymap('grD', '[Trouble] Diagnostics',          function () trouble.toggle('diagnostics') end)
    util.keymap('grd', '[Trouble] Diagnostics (buffer)', function () trouble.open({ mode = 'diagnostics', filter = { buf = 0 } }) end)

    vim.api.nvim_create_autocmd('LspAttach', {
      group = user_trouble_config_group,
      callback = function(ev)
        util.keymap('grR', '[Trouble] References',      function () trouble_toggle_sidebar('lsp') end)
        util.keymap('grI', '[Trouble] Implementations', function () trouble_toggle_sidebar('lsp_implementations') end)
      end,
    })

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
}