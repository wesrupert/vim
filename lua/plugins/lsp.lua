local notvscode = vim.g.vscode ~= 1

-- TODO: Fix incompatibility with breadcrumb
function WinHasPopups(winnr)
  local tabnr = winnr and vim.api.nvim_win_get_tabpage(winnr) or 0
  for _, winid in pairs(vim.api.nvim_tabpage_list_wins(tabnr)) do
    if vim.api.nvim_win_get_config(winid).zindex then
      return true
    end
  end
  return false
end

function WinClosePopups(winnr)
  local tabnr = winnr and vim.api.nvim_win_get_tabpage(winnr) or 0
  for _, winid in pairs(vim.api.nvim_tabpage_list_wins(tabnr)) do
    local config = vim.api.nvim_win_get_config(winid)
    if (config.relative ~= '' and config.win == winnr) then
      vim.api.nvim_win_close(winid, false)
    end
  end
  return false
end

function CodeActionMakeParams(kind)
  local params = vim.lsp.util.make_range_params()
  params.context = {}
  params.context.diagnostics = vim.lsp.diagnostic.get_line_diagnostics()
  params.context.triggerKind = vim.lsp.protocol.CodeActionTriggerKind.Invoked
  if kind then params.context.only = { kind } end
  return params
end

function CodeActionGetAvailable()
  local buf = vim.api.nvim_get_current_buf()
  local params = CodeActionMakeParams()
  print(params)
  local response = vim.lsp.buf_request_sync(buf, 'textDocument/codeAction', params, 3000)
  local code_actions = {}
  local code_actions_hash = {}
  for _, client_response in pairs(response or {}) do
    for _, action in pairs(client_response.result or {}) do
      local kind = action.command and ':' .. action.command or action.kind
      if kind and not code_actions_hash[kind] then
        code_actions_hash[kind] = true
        table.insert(code_actions, kind)
      end
    end
  end
  return code_actions
end

function CodeActionExecute(cmdargs, silent)
  local action_name = cmdargs and cmdargs.args or cmdargs
  if not (action_name) then
    vim.notify('No code action specified', vim.log.levels.ERROR)
    return
  end
  local buf = vim.api.nvim_get_current_buf()

  local is_command = string.sub(action_name, 1, 1) == ':'
  if is_command then action_name = string.sub(action_name, 2) end

  local params = CodeActionMakeParams((not is_command) and action_name or nil)
  print(params)
  local response = vim.lsp.buf_request_sync(buf, 'textDocument/codeAction', params, 3000)

  -- Find appropriate code action, and ensure there are not multiple commands that may be ambiguous
  local code_action
  for _, client_response in pairs(response or {}) do
    for _, action in pairs(client_response.result or {}) do
      if is_command then
        if action.command == action_name then
          if code_action then
            vim.notify('Multiple code actions found, please specify one', vim.log.levels.WARN)
            return
          end
          code_action = action
        end
      elseif action.edit then
        if code_action then
          vim.notify('Multiple code actions found, please specify one', vim.log.levels.WARN)
          return
        end
        code_action = action.edit
      end
    end
  end

  if not code_action then
    vim.notify('No code action ' .. (is_command and 'command' or 'edit') .. ' found that matches "' .. action_name .. '"', vim.log.levels.ERROR)
    return
  end

  if is_command then
    vim.lsp.buf_request(buf, 'workspace/executeCommand', code_action)
  else
    vim.lsp.util.apply_workspace_edit(code_action, vim.bo[buf].fileencoding)
  end

  if not silent then vim.notify('Applied "' .. action_name .. '" code action', vim.log.levels.INFO) end
end

return {
  { 'neovim/nvim-lspconfig' },
  {
    'williamboman/mason.nvim',
    enabled = notvscode,
    dependencies = { 'neovim/nvim-lspconfig' },
    build = ':MasonUpdate',
    opts = {},
  },
  {
    'williamboman/mason-lspconfig.nvim',
    enabled = notvscode,
    dependencies = { 'williamboman/mason.nvim', 'pmizio/typescript-tools.nvim' },
    opts = {
      handlers = {
        eslint = function(server_name)
          require('lspconfig')[server_name].setup({})
        end,
        typos_lsp = function (server_name)
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
      local user_lsp_config_group = vim.api.nvim_create_augroup('UserLspConfig', { clear = true })

      vim.api.nvim_create_autocmd('LspAttach', {
        group = user_lsp_config_group,
        callback = function(ev)
          vim.keymap.set('n', '[d', vim.diagnostic.goto_prev, { desc = '[LSP] Previous issue' })
          vim.keymap.set('n', ']d', vim.diagnostic.goto_next, { desc = '[LSP] Next issue' })
          vim.keymap.set('n', 'K', vim.lsp.buf.hover, { buffer = ev.buf, desc = '[LSP] Hover information' })
          vim.keymap.set('n', '<leader>de', vim.diagnostic.open_float, { desc = '[LSP] Issue details' })
          vim.keymap.set('n', '<leader>dq', vim.diagnostic.setloclist, { desc = '[LSP] Open issues' })

          vim.keymap.set({ 'n', 'v' }, '<leader>da', vim.lsp.buf.code_action, { buffer = ev.buf, desc = '[LSP] Show code actions' })
          vim.keymap.set('n', '<leader>df', function() vim.lsp.buf.format { async = true } end, { buffer = ev.buf, desc = '[LSP] Format current line' })
          vim.keymap.set('n', '<leader>dh', function()
            local should_enable = not vim.lsp.inlay_hint.is_enabled({ bufnr = ev.buf })
            vim.lsp.inlay_hint.enable(should_enable, { bufnr = ev.buf })
            print('[LSP] Inlay hints ' .. (should_enable and 'enabled' or 'disabled'))
          end, { buffer = ev.buf, desc = '[LSP] Toggle inlay hints' })

          vim.keymap.set('n', 'gd', vim.lsp.buf.definition, { buffer = ev.buf, desc = '[LSP] Go to definition' })
          vim.keymap.set('n', '<leader>dD', vim.lsp.buf.declaration, { buffer = ev.buf, desc = '[LSP] Go to declaration' })
          vim.keymap.set('n', '<leader>di', vim.lsp.buf.implementation, { buffer = ev.buf, desc = '[LSP] Go to implementation' })
          vim.keymap.set('n', '<leader>dr', vim.lsp.buf.references, { buffer = ev.buf, desc = '[LSP] Go to references' })
          vim.keymap.set('n', '<leader>dt', vim.lsp.buf.type_definition, { buffer = ev.buf, desc = '[LSP] Go to type' })
          vim.keymap.set('n', '<leader>dk', vim.lsp.buf.signature_help, { buffer = ev.buf, desc = '[LSP] Show signature_help' })

          vim.keymap.set('n', '<leader>wl', function() print(vim.inspect(vim.lsp.buf.list_workspace_folders())) end, { buffer = ev.buf, desc = '[LSP] Workspace info' })
          vim.keymap.set('n', '<leader>wa', vim.lsp.buf.add_workspace_folder, { buffer = ev.buf, desc = '[LSP] Add folder to workspace' })
          vim.keymap.set('n', '<leader>wx', vim.lsp.buf.remove_workspace_folder, { buffer = ev.buf, desc = '[LSP] Remove folder from workspace' })
          vim.keymap.set('n', '<leader>wr', vim.lsp.buf.rename, { buffer = ev.buf, desc = '[LSP] Rename workspace' })
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

      -- Code action quick command
      vim.api.nvim_create_autocmd('LspAttach', {
        group = user_lsp_config_group,
        callback = function(ev)
          local client = vim.lsp.get_client_by_id(ev.data.client_id)
          if client.supports_method('textDocument/codeAction') then
            -- Add CodeAction command if it hasn't been added by another LSP.
            if not vim.api.nvim_buf_get_commands(ev.buf, {}).CodeAction then
              vim.api.nvim_buf_create_user_command(ev.buf, 'CodeAction', CodeActionExecute, {
                desc = 'Execute code action by name',
                nargs = 1,
                complete = CodeActionGetAvailable,
              })
            end
          end
        end,
      })

      -- -- Automatic inlay hints
      -- vim.api.nvim_create_autocmd('LspAttach', {
      --   group = user_lsp_config_group,
      --   callback = function(ev)
      --     local client = vim.lsp.get_client_by_id(ev.data.client_id)
      --     if client.supports_method('textDocument/hover') then
      --       vim.lsp.inlay_hint.enable(true, { bufnr = ev.buf })
      --     end
      --   end,
      -- })

      -- -- Hover information on cursor hold
      -- local user_lsp_hover_group = vim.api.nvim_create_augroup('UserLspHover', { clear = true })
      -- vim.api.nvim_create_autocmd('LspAttach', {
      --   group = user_lsp_config_group,
      --   callback = function(ev)
      --     local client = vim.lsp.get_client_by_id(ev.data.client_id)
      --     if client.supports_method('textDocument/hover') then
      --       vim.api.nvim_create_autocmd('CursorHold', {
      --         desc = '[LSP] Hover information',
      --         buffer = ev.buf,
      --         group = user_lsp_hover_group,
      --         callback = function ()
      --           local winnr = vim.api.nvim_get_current_win()
      --           local cur_pos = vim.api.nvim_win_get_cursor(winnr)
      --           local last_pos = vim.w[winnr]._lsp_auto_hover_last_pos
      --           if (last_pos ~= nil and cur_pos[1] == last_pos[1] and cur_pos[2] == last_pos[2]) then return end
      --           -- if (WinHasPopups(winnr)) then return end
      --           vim.w[winnr]._lsp_auto_hover_last_pos = cur_pos
      --           pcall(vim.lsp.buf.hover)
      --         end,
      --       })
      --       vim.api.nvim_create_autocmd('CursorMoved', {
      --         desc = '[LSP] Hover information clear anchor',
      --         buffer = ev.buf,
      --         group = user_lsp_hover_group,
      --         callback = function ()
      --           local winnr = vim.api.nvim_get_current_win()
      --           vim.w[winnr]._lsp_auto_hover_last_pos = nil
      --         end,
      --       })
      --       vim.keymap.set('n', '<esc>', function ()
      --         local winnr = vim.api.nvim_get_current_win()
      --         WinClosePopups(winnr)
      --       end, { buffer = ev.buf, desc = '[LSP] Dismiss hover' })
      --     end
      --   end,
      -- })
    end,
  },
  {
    'pmizio/typescript-tools.nvim',
    dependencies = { 'nvim-lua/plenary.nvim', 'neovim/nvim-lspconfig', 'williamboman/mason.nvim' },
    config = function()
      local registry = require('mason-registry')
      local root = registry.get_package('vue-language-server'):get_install_path()
      require('typescript-tools').setup({
        filetypes = {'javascript', 'javascriptreact', 'typescript', 'typescriptreact', 'vue'},
        settings = {
          tsserver_path = root .. '/node_modules/typescript/lib',
          tsserver_plugins = {
            '@vue/typescript-plugin',
          },
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
      })
    end,
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