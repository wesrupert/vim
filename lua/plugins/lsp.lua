local util = require('util')
local user_lsp_config_group = vim.api.nvim_create_augroup('UserLspConfig', { clear = true })

return {
  {
    'neovim/nvim-lspconfig',
    dependencies = { 'saghen/blink.cmp' },
    config = function(_, opts)
      local blink = require('blink.cmp')
      local lspconfig = require('lspconfig')
      for server, config in pairs(opts.servers) do
        config.capabilities = blink.get_lsp_capabilities(config.capabilities)
        lspconfig[server].setup(config)
      end
    end,
  },
  {
    'nvimdev/lspsaga.nvim',
    cond = util.not_vscode,
    dependencies = { 'neovim/nvim-lspconfig' },
    opts = {
      diagnostic = {
        auto_preview = true,
        diagnostic_only_current = true,
      },
      code_action = {
        show_server_name = true,
      },
      lightbulb = {
        sign = false,
      },
      scroll_preview = {
        scroll_down = '<c-j>',
        scroll_up = '<c-k>',
      },
      symbol_in_winbar = {
        show_file = false,
      },
      outline = {
        auto_close = false,
        keys = {
          jump = '<cr>',
          toggle_or_jump = '<space>',
          quit = 'q',
        },
      },
    },
    init = function ()
      local lspsaga_command = require('lspsaga.command')
      local lspsaga_call = function (cmd, args) return function () lspsaga_command.load_command(cmd, { args }) end end

      vim.diagnostic.config({ virtual_text = false })

      vim.api.nvim_create_autocmd('LspAttach', {
        group = user_lsp_config_group,
        callback = function(ev)
          util.keymap('gD',         '[LSP+] Peek definition',       lspsaga_call('peek_definition'),           nil, ev.buf)
          util.keymap('[d',         '[LSP+] Previous issue',        lspsaga_call('diagnostic_jump_prev'),      nil, ev.buf)
          util.keymap(']d',         '[LSP+] Next issue',            lspsaga_call('diagnostic_jump_next'),      nil, ev.buf)
          util.keymap('K',          '[LSP+] Hover information',     lspsaga_call('hover_doc'),                 nil, ev.buf)
          util.keymap('<leader>gd', '[LSP+] Find references',       lspsaga_call('finder', 'tyd+ref+def+imp'), nil, ev.buf)
          util.keymap('<leader>de', '[LSP+] Diagnostics at cursor', lspsaga_call('show_cursor_diagnostics'),   nil, ev.buf)
          util.keymap('<leader>do', '[LSP+] Toggle outline',        lspsaga_call('outline'),                   nil, ev.buf)
          util.keymap('<c-`>',      '[LSP+] Toggle terminal',       lspsaga_call('term_toggle'),               nil, ev.buf)
          util.keymap('<leader>da', '[LSP+] Show code actions',     lspsaga_call('code_action'),               { 'n', 'v' }, ev.buf)
        end,
      })

      -- Add to term mapping outside of LspAttach, since it is a separate buffer
      util.keymap('<c-`>', '[LSP+] Toggle terminal', lspsaga_call('term_toggle'), { 't' })

      vim.api.nvim_create_autocmd('LspAttach', {
        group = user_lsp_config_group,
        callback = function(ev)
          local client = vim.lsp.get_client_by_id(ev.data.client_id)
          if client.name == 'null-ls' then
            util.keymap('zg', '[CSpell] Add to user dictionary', lspsaga_call('code_action'))
            util.keymap('zG', '[CSpell] Add to local dictionary', lspsaga_call('code_action'))
          end
        end,
      })
    end,
  },
  {
    'williamboman/mason.nvim',
    cond = util.not_vscode,
    dependencies = { 'neovim/nvim-lspconfig' },
    build = ':MasonUpdate',
    opts = {},
  },
  {
    'williamboman/mason-lspconfig.nvim',
    cond = util.not_vscode,
    dependencies = { 'williamboman/mason.nvim', 'pmizio/typescript-tools.nvim' },
    opts = {
      handlers = {
        eslint = function(server_name)
          require('lspconfig')[server_name].setup({})
        end,
        typos_lsp = function(server_name)
          require('lspconfig')[server_name].setup({
            init_options = {
              diagnosticSeverity = "Info",
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
        volar = function(server_name)
          require('lspconfig')[server_name].setup({
            init_options = {
              vue = {
                complete = {
                  casing = {
                    status = false,
                  },
                },
                inlayHints = {
                  destructuredProps = true,
                  inlineHandlerLeading = true,
                  missingProps = true,
                  optionsWrapper = true,
                  vBindShorthand = true,
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
        end,
      },
    },
    config = function(_, opts)
      require('mason-lspconfig').setup(opts)
    end,
    init = function()
      util.keymap('<leader>dh', '[LSP] Toggle inlay hints', function ()
        vim.b.inlay_hint_enabled = not vim.lsp.inlay_hint.is_enabled({ bufnr = 0 })
        vim.lsp.inlay_hint.enable(vim.b.inlay_hint_enabled, { bufnr = 0 })
        print('[LSP] Inlay hints ' .. (vim.b.inlay_hint_enabled and 'enabled' or 'disabled'))
      end)

      vim.api.nvim_create_autocmd('LspAttach', {
        group = user_lsp_config_group,
        callback = function(ev)
          util.keymap('gd', '[LSP] Go to definition', vim.lsp.buf.definition, nil, ev.buf)
          util.keymap('<leader>wl', '[LSP] Workspace info',
            function() print(vim.inspect(vim.lsp.buf.list_workspace_folders())) end, nil, ev.buf)
          util.keymap('<leader>wa', '[LSP] Add folder to workspace', vim.lsp.buf.add_workspace_folder, nil, ev.buf)
          util.keymap('<leader>wx', '[LSP] Remove folder from workspace', vim.lsp.buf.remove_workspace_folder, nil,
            ev.buf)
          util.keymap('<leader>wr', '[LSP] Rename workspace', vim.lsp.buf.rename, nil, ev.buf)
        end,
      })

      -- Format on save
      vim.api.nvim_create_autocmd('LspAttach', {
        group = user_lsp_config_group,
        callback = function(ev)
          local client = vim.lsp.get_client_by_id(ev.data.client_id)
          if client.name == 'eslint' then
            vim.api.nvim_create_autocmd('BufWritePre', {
              group = user_lsp_config_group,
              buffer = ev.buf,
              command = 'silent! EslintFixAll',
              desc = '[eslint] Format on save',
            })
          end
        end,
      })

      -- Automatic inlay hints
      -- Enable inlay hints for the given client/buffer, unless an inlay_hint_enabled env variable is false.
      -- TODO: Figure out why the hell some servers don't automatically reload hints on workspace load
      vim.api.nvim_create_autocmd('LspAttach', {
        group = user_lsp_config_group,
        callback = function (ev)
          if not util.get_setting('inlay_hint_enabled', true, ev.buf) then return end
          if vim.lsp.inlay_hint.is_enabled({ bufnr = ev.buf }) then return end
          local client = vim.lsp.get_client_by_id(ev.data.client_id)
          if not client.supports_method('textDocument/inlayHint') and not client.server_capabilities.inlayHintProvider then return end
          vim.b[ev.buf].inlay_hint_enabled = true
          vim.lsp.inlay_hint.enable(true, { bufnr = ev.buf })
        end,
      })
    end,
  },
  {
    'nvimtools/none-ls.nvim',
    dependencies = {
      'mason.nvim',
      'nvimtools/none-ls-extras.nvim',
      'davidmh/cspell.nvim',
    },
    opts = {
      config_file_preferred_name = 'cspell.json',
      cspell_config_dirs = { '~/.config/' },
    },
    config = function (_, opts)
      local none_ls = require('null-ls')
      local cspell = require('cspell')
      none_ls.setup({
        sources = {
          cspell.diagnostics.with({ config = opts }),
          cspell.code_actions.with({ config = opts }),
        },
      })
    end,
  },
  {
    'pmizio/typescript-tools.nvim',
    dependencies = { 'nvim-lua/plenary.nvim', 'neovim/nvim-lspconfig', 'williamboman/mason.nvim' },
    config = function()
      local api = require('typescript-tools.api')
      local registry = require('mason-registry')
      local root = registry.get_package('vue-language-server'):get_install_path()
      require('typescript-tools').setup({
        filetypes = {'javascript', 'javascriptreact', 'typescript', 'typescriptreact', 'vue'},
        settings = {
          tsserver_path = root .. '/node_modules/typescript/lib',
          tsserver_plugins = {
            '@vue/typescript-plugin',
          },
          expose_as_code_action = 'all',
          tsserver_max_memory = 8096,
          tsserver_file_preferences = {
            importModuleSpecifierPreference = 'non-relative',
            includeInlayParameterNameHints = 'literals',
            includeInlayParameterNameHintsWhenArgumentMatchesName = true,
            includeInlayFunctionParameterTypeHints = true,
            includeInlayVariableTypeHints = true,
            includeInlayVariableTypeHintsWhenTypeMatchesName = true,
            includeInlayPropertyDeclarationTypeHints = true,
            includeInlayFunctionLikeReturnTypeHints = true,
            includeInlayEnumMemberValueHints = true,
          },
        },
        handlers = {
          ['textDocument/publishDiagnostics'] = api.filter_diagnostics({
            7016, -- TS7016: 'Could not find a declaration file for module'
          }),
        },
      })
    end,
  },
  {
    'smiteshp/nvim-navbuddy',
    dependencies = {
      'smiteshp/nvim-navic',
      'muniftanjim/nui.nvim'
    },
    opts = { lsp = { auto_attach = true } },
    init = function()
      vim.keymap.set('n', '<c-n>', function() require('nvim-navbuddy').open() end, { desc = 'Open navbuddy' })
    end,
  },
}