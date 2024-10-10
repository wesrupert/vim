local notvscode = vim.g.vscode ~= 1
return {
  {
    'williamboman/mason.nvim',
    enabled = notvscode,
    dependencies = { 'neovim/nvim-lspconfig' },
    build = ':MasonUpdate',
    opts = {},
  },
  {
    'rmagatti/goto-preview',
    event = 'BufEnter',
    opts = {
      default_mappings = true,
      post_open_hook = function ()
        vim.keymap.set('n', 'q', ':q<cr>', { noremap = true, buffer = true, desc = 'Quick exit' })
      end,
    },
    config = function(_, opts)
      require('goto-preview').setup(opts)
    end,
  },
  {
    'williamboman/mason-lspconfig.nvim',
    enabled = notvscode,
    dependencies = { 'williamboman/mason.nvim' },
    opts = {
      handlers = {
        vimls = function(server_name)
          require('lspconfig')[server_name].setup({
            settings = {
              Lua = {
                diagnostics = {
                  globals = {
                    'vim',
                  },
                },
              },
            },
          })
        end,
        lua_ls = function(server_name)
          require('lspconfig')[server_name].setup({
            settings = {
              Lua = {
                diagnostics = {
                  globals = {
                    'vim',
                  },
                },
              },
            },
          })
        end,
        ts_ls = function (server_name)
          local registry = require('mason-registry')
          local root = registry.get_package('vue-language-server'):get_install_path()
          require('lspconfig')[server_name].setup({
            log = 'verbose',
            filetypes = {
              'javascript',
              'javascriptreact',
              'javascript.jsx',
              'typescript',
              'typescriptreact',
              'typescript.tsx',
              'vue',
            },
            init_options = {
              plugins = {
                {
                  name = '@vue/typescript-plugin',
                  location = root .. '/node_modules/@vue/language-server',
                  languages = { 'javascript', 'typescript', 'vue' },
                },
              },
              javascript = {
                preferences = {
                  importModuleSpecifier = 'non-relative',
                },
                inlayHints = {
                  enumMemberValues = { enabled = true },
                  functionLikeReturnTypes = { enabled = true },
                  parameterNames = { enabled = 'literals' },
                  parameterTypes = { enabled = true },
                  propertyDeclarationTypes = { enabled = true },
                  variableTypes = { enabled = true },
                },
              },
            },
            typescript = {
              preferGoToSourceDefinition = true,
              preferences = {
                importModuleSpecifier = 'non-relative',
              },
              inlayHints = {
                enumMemberValues = { enabled = true },
                functionLikeReturnTypes = { enabled = true },
                parameterNames = { enabled = 'literals' },
                parameterTypes = { enabled = true },
                propertyDeclarationTypes = { enabled = true },
                variableTypes = { enabled = true },
              },
            },
          })
        end,
        volar = function (server_name)
          require('lspconfig')[server_name].setup({
            init_options = {
              vue = {
                hybridMode = true,
                complete = {
                  casing = {
                    status = false,
                  },
                },
                inlayHints = {
                  inlineHandlerLeading = true,
                  missingProps = true,
                  optionsWrapper = true,
                },
                updateImportsOnFileMove = {
                  enabled = true,
                },
                server = {
                  maxOldSpaceSize = 8096,
                },
              },
            },
          })
        end
      },
    },
    config = function(_, opts)
      require('mason-lspconfig').setup(opts)
    end,
    init = function()
      vim.api.nvim_create_autocmd('LspAttach', {
        group = vim.api.nvim_create_augroup('UserLspConfig', { clear = true }),
        callback = function(ev)
          vim.keymap.set('n', '[d', vim.diagnostic.goto_prev, { desc = 'LSP: Previous issue' })
          vim.keymap.set('n', ']d', vim.diagnostic.goto_next, { desc = 'LSP: Next issue' })
          vim.keymap.set('n', 'K', vim.lsp.buf.hover, { buffer = ev.buf, desc = 'LSP: Hover information' })
          vim.keymap.set('n', '<leader>de', vim.diagnostic.open_float, { desc = 'LSP: Issue details' })
          vim.keymap.set('n', '<leader>dq', vim.diagnostic.setloclist, { desc = 'LSP: Open issues' })

          vim.keymap.set({ 'n', 'v' }, '<leader>da', vim.lsp.buf.code_action, { buffer = ev.buf, desc = 'LSP: Show code actions' })
          vim.keymap.set('n', '<leader>df', function() vim.lsp.buf.format { async = true } end, { buffer = ev.buf, desc = 'LSP: Format current line' })

          vim.keymap.set('n', '<leader>dd', vim.lsp.buf.definition, { buffer = ev.buf, desc = 'LSP: Go to definition' })
          vim.keymap.set('n', '<leader>dD', vim.lsp.buf.declaration, { buffer = ev.buf, desc = 'LSP: Go to declaration' })
          vim.keymap.set('n', '<leader>di', vim.lsp.buf.implementation, { buffer = ev.buf, desc = 'LSP: Go to implementation' })
          vim.keymap.set('n', '<leader>dr', vim.lsp.buf.references, { buffer = ev.buf, desc = 'LSP: Go to references' })
          vim.keymap.set('n', '<leader>dt', vim.lsp.buf.type_definition, { buffer = ev.buf, desc = 'LSP: Go to type' })
          vim.keymap.set('n', '<leader>dk', vim.lsp.buf.signature_help, { buffer = ev.buf, desc = 'LSP: Show signature_help' })

          vim.keymap.set('n', '<leader>wl', function() print(vim.inspect(vim.lsp.buf.list_workspace_folders())) end, { buffer = ev.buf, desc = 'LSP: Workspace info' })
          vim.keymap.set('n', '<leader>wa', vim.lsp.buf.add_workspace_folder, { buffer = ev.buf, desc = 'LSP: Add folder to workspace' })
          vim.keymap.set('n', '<leader>wx', vim.lsp.buf.remove_workspace_folder, { buffer = ev.buf, desc = 'LSP: Remove folder from workspace' })
          vim.keymap.set('n', '<leader>wr', vim.lsp.buf.rename, { buffer = ev.buf, desc = 'LSP: Rename workspace' })
        end,
      })
    end,
  },
  {
    'neovim/nvim-lspconfig',
    dependencies = { 'smiteshp/nvim-navbuddy' },
  },
  {
    'smiteshp/nvim-navbuddy',
    dependencies = {
      'smiteshp/nvim-navic',
      'muniftanjim/nui.nvim'
    },
    opts = { lsp = { auto_attach = true } },
    init = function()
      vim.keymap.set('n', '<leader>n', function() require('nvim-navbuddy').open() end, { desc = 'Open navbuddy' })
    end,
  },
}