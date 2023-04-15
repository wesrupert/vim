return {
  {
    'williamboman/mason.nvim',
    dependencies = {
      {
        'neovim/nvim-lspconfig',
        dependencies = {
          {
            'smiteshp/nvim-navbuddy',
            dependencies = {
              'smiteshp/nvim-navic',
              'muniftanjim/nui.nvim'
            },
            opts = { lsp = { auto_attach = true } },
            init = function()
              vim.keymap.set('n', '<leader>n', function() require('nvim-navbuddy').open() end)
            end,
          }
        },
      },
    },
    build = ':MasonUpdate',
    opts = {},
  },
  {
    'williamboman/mason-lspconfig.nvim',
    config = function(_, opts)
      require('mason-lspconfig').setup(opts)
      require('mason-lspconfig').setup_handlers({
        function (server_name)
          require('lspconfig')[server_name].setup({})
        end,
        ['lua_ls'] = function(server_name)
          require('lspconfig')[server_name].setup({
            settings = { Lua = { diagnostics = { globals = { 'vim' } } } },
          })
        end,
        ['vimls'] = function(server_name)
          require('lspconfig')[server_name].setup({
            settings = { Lua = { diagnostics = { globals = { 'vim' } } } },
          })
        end,
      })
    end,
    init = function()
      vim.api.nvim_create_autocmd('LspAttach', {
        group = vim.api.nvim_create_augroup('UserLspConfig', { clear = true }),
        callback = function(ev)
          local opts = { buffer = ev.buf }
          vim.keymap.set('n', '[d', vim.diagnostic.goto_prev)
          vim.keymap.set('n', ']d', vim.diagnostic.goto_next)
          vim.keymap.set('n', 'K', vim.lsp.buf.hover, opts)
          vim.keymap.set('n', '<leader>de', vim.diagnostic.open_float)
          vim.keymap.set('n', '<leader>dq', vim.diagnostic.setloclist)

          vim.keymap.set({ 'n', 'v' }, '<leader>da', vim.lsp.buf.code_action, opts)
          vim.keymap.set('n', '<leader>df', function() vim.lsp.buf.format { async = true } end, opts)

          vim.keymap.set('n', '<leader>dd', vim.lsp.buf.definition, opts)
          vim.keymap.set('n', '<leader>dD', vim.lsp.buf.declaration, opts)
          vim.keymap.set('n', '<leader>di', vim.lsp.buf.implementation, opts)
          vim.keymap.set('n', '<leader>dr', vim.lsp.buf.references, opts)
          vim.keymap.set('n', '<leader>dt', vim.lsp.buf.type_definition, opts)
          vim.keymap.set('n', '<leader>dk', vim.lsp.buf.signature_help, opts)

          vim.keymap.set('n', '<leader>wl', function() print(vim.inspect(vim.lsp.buf.list_workspace_folders())) end, opts)
          vim.keymap.set('n', '<leader>wa', vim.lsp.buf.add_workspace_folder, opts)
          vim.keymap.set('n', '<leader>wx', vim.lsp.buf.remove_workspace_folder, opts)
          vim.keymap.set('n', '<leader>wr', vim.lsp.buf.rename, opts)
        end,
      })
    end,
  }
}