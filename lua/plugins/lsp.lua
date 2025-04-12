local util = require('util')
local user_lsp_config_group = vim.api.nvim_create_augroup('UserLspConfig', { clear = true })

return {
  {
    'neovim/nvim-lspconfig',
    opts = {
      inlay_hints = { pad = true, max_length = 32 },
      servers = {
        clangd = {},
        eslint = {},
        html = {},
        jsonls = {},
        tailwindcss = {},
        lua_ls = {
          settings = {
            Lua = { diagnostics = { globals = { 'vim' } } },
          },
        },
        vimls = {
          settings = {
            Lua = { diagnostics = { globals = { 'vim' } } },
          },
        },
        volar = {
          init_options = {
            vue = {
              server = { maxOldSpaceSize = 8096 },
              complete = {
                casing = { status = false },
              },
              inlayHints = {
                destructuredProps = true,
                inlineHandlerLeading = true,
                missingProps = true,
                optionsWrapper = true,
                vBindShorthand = true,
              },
              updateImportsOnFileMove = { enabled = true },
            },
          },
        },
      },
    },
    config = function (_, opts)
      if opts.inlay_hints and opts.inlay_hints.max_length then
        -- HACK: Workaround for truncating long LSP (ahem, *TypeScript*) inlay hints.
        -- TODO: Remove this if https://github.com/neovim/neovim/issues/27240 gets addressed.
        -- @see https://github.com/MariaSolOs/dotfiles/blob/88646ab9/.config/nvim/lua/lsp.lua#L275-L292
        local max_length = opts.inlay_hints.max_length
        local overflow_char = opts.inlay_hints.overflow_char or '… '
        local overflow_pad = opts.inlay_hints.pad
        local overflow_length =  overflow_char:len()
        local inlay_hint_protocol = vim.lsp.protocol.Methods.textDocument_inlayHint
        local trim_label = function (label)
          if label:len() <= max_length then return label end
          local trimmed = label:sub(1, max_length - overflow_length) .. overflow_char
          return overflow_pad and (' ' .. trimmed .. ' ') or trimmed
        end
        local inlay_hint_handler = vim.lsp.handlers[inlay_hint_protocol]
        vim.lsp.handlers[inlay_hint_protocol] = function (err, result, ctx)
          if vim.islist(result) then
            result = vim.iter(result)
              :map(function (hint)
                if vim.islist(hint.label) then
                  vim.iter(hint.label):each(function (item) item.value = trim_label(item.value) end)
                else
                  -- TODO: Remove if new syntax is made permanent after nightly
                  hint.label = trim_label(hint.label)
                end
                return hint
              end)
              :totable()
          end
          inlay_hint_handler(err, result, ctx)
        end
      end

      local lspconfig = require('lspconfig')
      local blink_ok, blink = pcall(require, 'blink.cmp')
      for server, config in pairs(opts.servers) do
        if blink_ok then config.capabilities = blink.get_lsp_capabilities(config.capabilities) end
        lspconfig[server].setup(config)
      end

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
          if client and client.name == 'eslint' then
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
      vim.api.nvim_create_autocmd({ 'BufNew', 'BufRead', 'Filetype' }, {
        group = user_lsp_config_group,
        callback = function (ev)
          local disabled_filetypes = opts.inlay_hints.disabled_filetypes
          if disabled_filetypes and vim.tbl_contains(disabled_filetypes, vim.bo.filetype) then
            vim.b.inlay_hint_enabled = false
            vim.lsp.inlay_hint.enable(false, { bufnr = ev.buf })
          end
        end,
      })
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
          cspell.diagnostics.with({
            config = opts,
            diagnostics_postprocess = function (event)
              event.severity = vim.diagnostic.severity.INFO
            end,
          }),
          cspell.code_actions.with({ config = opts }),
        },
      })
    end,
  },
  {
    'pmizio/typescript-tools.nvim',
    dependencies = { 'nvim-lua/plenary.nvim', 'neovim/nvim-lspconfig', 'williamboman/mason.nvim' },
    cond = util.not_vscode,
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
    'folke/lazydev.nvim',
    ft = 'lua',
    config = true,
  },
  {
    'wesrupert/lspsaga.nvim',
    branch = 'fix/codeaction/home',
    -- cond = util.not_vscode,
    cond = false and util.not_vscode,
    dependencies = { 'neovim/nvim-lspconfig' },
    opts = {
      diagnostic = {
        auto_preview = true,
        diagnostic_only_current = false,
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

      vim.api.nvim_create_autocmd('LspAttach', {
        group = user_lsp_config_group,
        callback = function(ev)
          util.keymap('[d',         '[LSP+] Previous issue',        lspsaga_call('diagnostic_jump_prev'),      nil, ev.buf)
          util.keymap(']d',         '[LSP+] Next issue',            lspsaga_call('diagnostic_jump_next'),      nil, ev.buf)
          util.keymap('K',          '[LSP+] Hover information',     lspsaga_call('hover_doc'),                 nil, ev.buf)
          util.keymap('gD',         '[LSP+] Peek definition',       lspsaga_call('peek_definition'),           nil, ev.buf)
          util.keymap('grr',        '[LSP+] Find references',       lspsaga_call('finder', 'tyd+ref+def+imp'), nil, ev.buf)
          util.keymap('gra',        '[LSP+] Show code actions',     lspsaga_call('code_action'),               nil, ev.buf)
          util.keymap('gO',         '[LSP+] Toggle outline',        lspsaga_call('outline'),                   nil, ev.buf)
          util.keymap('<c-`>',      '[LSP+] Toggle terminal',       lspsaga_call('term_toggle'),               nil, ev.buf)
        end,
      })

      -- Add to term mapping outside of LspAttach, since it is a separate buffer
      util.keymap('<c-`>', '[LSP+] Toggle terminal', lspsaga_call('term_toggle'), { 't' })

      vim.api.nvim_create_autocmd('LspAttach', {
        group = user_lsp_config_group,
        callback = function(ev)
          local client = vim.lsp.get_client_by_id(ev.data.client_id)
          if client and client.name == 'null-ls' then
            util.keymap('zg', '[Lsp+] Show code actions', lspsaga_call('code_action'))
            util.keymap('zG', '[Lsp+] Show code actions', lspsaga_call('code_action'))
          end
        end,
      })
    end
  },
  {
    'williamboman/mason.nvim',
    cond = util.not_vscode,
    dependencies = { 'neovim/nvim-lspconfig' },
    build = ':MasonUpdate',
    config = true,
  },
  {
    'williamboman/mason-lspconfig.nvim',
    cond = util.not_vscode,
    dependencies = { 'williamboman/mason.nvim', 'pmizio/typescript-tools.nvim', 'saghen/blink.cmp' },
    config = true,
  },
  {
    'rachartier/tiny-inline-diagnostic.nvim',
    event = 'LspAttach',
    priority = 1000,
    opts = {
      preset = 'powerline',
      options = {
        multiple_diag_under_cursor = true,
        format = function (d)
          if type(d) ~= 'table' then return d end
          if not d.message or not d.source then return d end
          return ' ' .. d.message .. ' │ ' .. d.source
        end
      },
    },
    config = true,
    init = function ()
      vim.diagnostic.config({ virtual_text = false })
    end,
  },
  {
    'catgoose/vue-goto-definition.nvim',
    event = 'BufReadPre',
    ft = { 'vue', 'typescript' },
    config = true,
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