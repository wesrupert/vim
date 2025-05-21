local util = require('util')
local lsp_util = require('util.lsp')

local methods = vim.lsp.protocol.Methods
local user_lsp_config_group = vim.api.nvim_create_augroup('UserLspConfig', { clear = true })
local user_lsp_inlay_hints_group = vim.api.nvim_create_augroup('UserLspInlayHintsConfig', { clear = true })
local user_lsp_cursor_highlights_group = vim.api.nvim_create_augroup('UserLspCursorHighlightsConfig', { clear = true })

lsp_util.on_attach(function (client, bufnr)
  util.keymap('grn', '[LSP] Rename',                  vim.lsp.buf.rename, nil, bufnr)
  util.keymap('gra', '[LSP] Show code actions',       vim.lsp.buf.code_action, nil, bufnr)
  util.keymap('zg',  '[LSP] Show code actions',       vim.lsp.buf.code_action, nil, bufnr)
  util.keymap('zG',  '[LSP] Show code actions',       vim.lsp.buf.code_action, nil, bufnr)
  util.keymap('grw', '[LSP] Add workspace folder',    vim.lsp.buf.add_workspace_folder, nil, bufnr)
  util.keymap('grW', '[LSP] Remove workspace folder', vim.lsp.buf.remove_workspace_folder, nil, bufnr)
  util.keymap('[e',  '[LSP] Previous error',          function () vim.diagnostic.jump({ count = -1, severity = vim.diagnostic.severity.ERROR }) end, nil, bufnr)
  util.keymap(']e',  '[LSP] Previous error',          function () vim.diagnostic.jump({ count = 1, severity = vim.diagnostic.severity.ERROR }) end, nil, bufnr)
  util.keymap('grq', '[LSP] Workspace info',          function ()
    print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
  end, nil, bufnr)

  if client:supports_method(methods.textDocument_definition, bufnr) then
    util.keymap('gd', '[LSP] Go to definition', vim.lsp.buf.definition, nil, bufnr)
  end
end)

lsp_util.on_supports_method(methods.textDocument_documentHighlight, function (_, bufnr)
  local document_highlight = util.use_setting('lsp_document_highlight_enabled', true)
  vim.api.nvim_create_autocmd({ 'CursorHold', 'InsertLeave' }, {
    group = user_lsp_cursor_highlights_group,
    desc = '[LSP] Highlight references under the cursor',
    buffer = bufnr,
    callback = function (ev) if document_highlight.get(ev.buf) then vim.lsp.buf.document_highlight() end end,
  })
  vim.api.nvim_create_autocmd({ 'CursorMoved', 'InsertEnter', 'BufLeave' }, {
    group = user_lsp_cursor_highlights_group,
    desc = '[LSP] Clear highlight references',
    buffer = bufnr,
    callback = vim.lsp.buf.clear_references,
  })
end)

-- Automatic inlay hints / InsertEnter inlay hint toggle.
lsp_util.on_supports_method(methods.textDocument_inlayHint, function (_, bufnr)
  local inlay_hints = util.use_setting('inlay_hints', true)

  -- Automatically enable inlay hints.
  if inlay_hints.get(bufnr) then
    vim.defer_fn(function ()
      local mode = vim.api.nvim_get_mode().mode
      local enabled = inlay_hints.set(mode == 'n' or mode == 'v', 'b', bufnr)
      vim.lsp.inlay_hint.enable(enabled, { bufnr = bufnr })
    end, 500)
  end

  util.keymap('grh', '[LSP] Toggle inlay hints', function ()
    local enabled = inlay_hints.set(not vim.lsp.inlay_hint.is_enabled({ bufnr = 0 }), 'b', bufnr)
    vim.lsp.inlay_hint.enable(enabled, { bufnr = 0 })
    print('[LSP] Inlay hints ' .. (enabled and 'enabled' or 'disabled'))
  end, nil, bufnr)

  vim.api.nvim_create_autocmd('InsertEnter', {
    group = user_lsp_inlay_hints_group,
    desc = '[LSP] Insert-only inlay hints',
    buffer = bufnr,
    callback = function () vim.lsp.inlay_hint.enable(false, { bufnr = bufnr }) end,
  })
  vim.api.nvim_create_autocmd('InsertLeave', {
    group = user_lsp_inlay_hints_group,
    desc = '[LSP] Insert-only inlay hints',
    buffer = bufnr,
    callback = function ()
      if inlay_hints.get() then
        vim.lsp.inlay_hint.enable(true, { bufnr = bufnr })
      end
    end,
  })
end)

-- ESlint 'Fix All' command/ 'Fix on save' autocommand.
lsp_util.on_attach(function (client, bufnr)
  if client.name ~= 'eslint' then return end
  _G.eslint_fix_all = function ()
    client:request(methods.workspace_executeCommand, {
      command = 'eslint.applyAllFixes',
      arguments = { { uri = vim.uri_from_bufnr(bufnr), version = vim.lsp.util.buf_versions[bufnr] } },
    }, nil, bufnr)
  end
  util.keymap('gre', '[LSP:eslint] Fix all', eslint_fix_all, nil, bufnr)

  vim.api.nvim_create_autocmd('BufWritePre', {
    group = user_lsp_config_group,
    desc = '[LSP:eslint] Fix on save',
    buffer = bufnr,
    callback = function () if util.get_setting('eslint_run_on_save', true, bufnr) then eslint_fix_all() end end,
  })
end)

-- LSP foldexpr support.
vim.api.nvim_create_autocmd('BufWinEnter', {
  group = user_lsp_config_group,
  desc = '[LSP] Enable foldexpr',
  callback = function (ev)
    if not util.get_setting('use_lsp_foldexpr', true) then return end
    for _, client in ipairs(vim.lsp.get_clients({ bufnr = ev.buf })) do
      if client and client:supports_method(methods.textDocument_foldingRange, ev.buf) then
        local win = vim.api.nvim_get_current_win()
        vim.wo[win][0].foldexpr = 'v:lua.vim.lsp.foldexpr()'
        return
      end
    end
  end,
})

vim.diagnostic.config({
  signs = {
    severity = { min = vim.diagnostic.severity.WARN },
    text = {
      [vim.diagnostic.severity.ERROR] = util.kind_icons.Error,
      [vim.diagnostic.severity.WARN] = util.kind_icons.Warn,
      [vim.diagnostic.severity.INFO] = util.kind_icons.Info,
    },
  },
  virtual_text = {
    prefix = '',
    spacing = 2,
    format = function (d)
      local message = util.diagnostic_icons[d.severity]
      if d.source then message = string.format('%s %s', message, util.kind_names[d.source] or d.source) end
      if d.code then message = string.format('%s[%s]', message, d.code) end
      return message .. ' '
    end,
  },
})

-- Set up LSP servers.
vim.api.nvim_create_autocmd({ 'BufReadPre', 'BufNewFile' }, {
  group = user_lsp_config_group,
  once = true,
  callback = function ()
    -- Use stdpath instead of rtp to skip definitions only in nvim-lspconfig.
    local lsp_dir = vim.fn.stdpath('config') .. '/after/lsp'
    if not vim.fn.isdirectory(lsp_dir) then return end
    local lsp_servers = {}
    for _, file in ipairs(vim.fn.readdir(lsp_dir)) do
      table.insert(lsp_servers, vim.fn.fnamemodify(file, ":t:r"))
    end
    vim.lsp.enable(lsp_servers)
  end,
})