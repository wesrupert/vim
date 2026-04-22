local util = require("util")
local lsp_util = require("util.lsp")

local methods = vim.lsp.protocol.Methods
local user_lsp_config_group = vim.api.nvim_create_augroup("UserLspConfig", { clear = true })

local quick_actions = { "source", "refactor", "quickfix" }

-- LSP Keymaps
lsp_util.on_attach(function (bufnr)
  local function gen_jump(forward, severity)
    local count = forward and 1 or -1
    return function () vim.diagnostic.jump({ count = count, severity = severity }) end
  end
  util.keymap({
    { "goq", desc = "[LSP] Workspace info",       function () print("Workspace folders: " .. vim.inspect(vim.lsp.buf.list_workspace_folders())) end },
    { "grw", desc = "[LSP] Add workspace folder", vim.lsp.buf.add_workspace_folder    },
    { "grW", desc = "[LSP] Del workspace folder", vim.lsp.buf.remove_workspace_folder },

    { "grn",   desc = "[LSP] Rename",            vim.lsp.buf.rename      },
    { "gra",   desc = "[LSP] Show code actions", lsp_util.do_code_action },
    { "<c-,>", desc = "[LSP] Show code actions", lsp_util.do_code_action },

    ---@diagnostic disable-next-line: missing-fields
    { "gre", desc = "[LSP] Show quick edits", function () return lsp_util.do_code_action({ context = { only = quick_actions } }) end },

    { "[e",  desc = "[LSP] Previous error", gen_jump(false, vim.diagnostic.severity.ERROR) },
    { "]e",  desc = "[LSP] Previous error", gen_jump(true,  vim.diagnostic.severity.ERROR) },
    { "[s",  desc = "[LSP] Previous info",  gen_jump(false, vim.diagnostic.severity.INFO)  },
    { "]s",  desc = "[LSP] Previous info",  gen_jump(true,  vim.diagnostic.severity.INFO)  },
  }, bufnr)
end)

lsp_util.on_supports_method(methods.textDocument_definition, function (bufnr)
  util.keymap({ { "gd", desc = "[LSP] Go to definition", buf = bufnr, vim.lsp.buf.definition } })
end)

-- Loading progress notifications
vim.api.nvim_create_autocmd('LspProgress', {
  group = user_lsp_config_group,
  callback = function (ev)
    local value = ev.data.params.value
    vim.api.nvim_echo({ { value.message or 'done' } }, false, {
      id = 'lsp.' .. ev.data.client_id,
      kind = 'progress',
      source = 'vim.lsp',
      title = value.title,
      status = value.kind ~= 'end' and 'running' or 'success',
      percent = value.percentage,
    })
  end,
})

-- Document highlight
lsp_util.on_supports_method(methods.textDocument_documentHighlight, function (bufnr)
  local lsp_document_highlight_enabled = util.use_setting("lsp_document_highlight_enabled", true)
  local user_lsp_cursor_highlights_group = vim.api.nvim_create_augroup("UserLspCursorHighlightsConfig", { clear = true })
  vim.api.nvim_create_autocmd({ "CursorHold", "InsertLeave" }, {
    group = user_lsp_cursor_highlights_group,
    desc = "[LSP] Highlight references under the cursor",
    buffer = bufnr,
    callback = function (ev)
      if lsp_document_highlight_enabled.get(ev.buf) then vim.lsp.buf.document_highlight() end
    end,
  })
  vim.api.nvim_create_autocmd({ "CursorMoved", "InsertEnter", "BufLeave" }, {
    group = user_lsp_cursor_highlights_group,
    desc = "[LSP] Clear highlight references",
    buffer = bufnr,
    callback = vim.lsp.buf.clear_references,
  })
end)

-- Automatic inlay hints / InsertEnter inlay hint toggle.
lsp_util.on_supports_method(methods.textDocument_inlayHint, function (bufnr)
  local user_lsp_inlay_hints_group = vim.api.nvim_create_augroup("UserLspInlayHintsConfig", { clear = true })
  local lsp_inlay_hints_enabled = util.use_setting("LSP_INLAY_HINTS_ENABLED", true)

  -- Automatically enable inlay hints.
  if lsp_inlay_hints_enabled.get(bufnr) then
    vim.defer_fn(function ()
      local mode = vim.api.nvim_get_mode().mode
      local enabled = lsp_inlay_hints_enabled.set(mode == "n" or mode == "v", "b", bufnr)
      vim.lsp.inlay_hint.enable(enabled, { bufnr = bufnr })
    end, 500)
  end

  util.keymap({
    {
      "grh", desc = "[LSP] Toggle inlay hints (buffer)", buf = bufnr, function ()
        local enabled = lsp_inlay_hints_enabled.set(not vim.lsp.inlay_hint.is_enabled({ bufnr = 0 }), "b", bufnr)
        vim.lsp.inlay_hint.enable(enabled, { bufnr = 0 })
        print("[LSP] Inlay hints " .. (enabled and "enabled" or "disabled"))
      end,
    },
    {
      "grH", desc = "[LSP] Toggle inlay hints", buf = bufnr, function ()
        local enabled = lsp_inlay_hints_enabled.set(not vim.lsp.inlay_hint.is_enabled({ bufnr = 0 }), "g")
        vim.lsp.inlay_hint.enable(enabled)
        print("[LSP] Inlay hints " .. (enabled and "enabled" or "disabled"))
      end,
    },
  })

  vim.api.nvim_create_autocmd("InsertEnter", {
    group = user_lsp_inlay_hints_group,
    desc = "[LSP] Insert-only inlay hints",
    buffer = bufnr,
    callback = function ()
      vim.lsp.inlay_hint.enable(false, { bufnr = bufnr })
    end,
  })
  vim.api.nvim_create_autocmd("InsertLeave", {
    group = user_lsp_inlay_hints_group,
    desc = "[LSP] Insert-only inlay hints",
    buffer = bufnr,
    callback = function ()
      if lsp_inlay_hints_enabled.get(bufnr) then
        vim.lsp.inlay_hint.enable(true, { bufnr = bufnr })
      end
    end,
  })
end)

-- ESlint "Fix All" command/ "Fix on save" autocommand.
lsp_util.on_attach(function (bufnr, client)
  if client.name ~= "eslint" then return end
  _G.eslint_fix_all = function ()
    client:request(methods.workspace_executeCommand, {
      command = "eslint.applyAllFixes",
      arguments = { { uri = vim.uri_from_bufnr(bufnr), version = vim.lsp.util.buf_versions[bufnr] } },
    }, nil, bufnr)
  end
  util.keymap({ { "gre", desc = "[LSP:eslint] Fix all", buf = bufnr, eslint_fix_all } })

  vim.api.nvim_create_autocmd("BufWritePre", {
    group = user_lsp_config_group,
    desc = "[LSP:eslint] Fix on save",
    buffer = bufnr,
    callback = function () if util.get_setting("ESLINT_RUN_ON_SAVE", true, bufnr) then eslint_fix_all() end end,
  })
end)

-- LSP foldexpr support.
vim.api.nvim_create_autocmd("BufWinEnter", {
  group = user_lsp_config_group,
  desc = "[LSP] Enable foldexpr",
  callback = function (ev)
    if not util.get_setting("use_lsp_foldexpr", true) then return end
    for _, client in ipairs(vim.lsp.get_clients({ bufnr = ev.buf })) do
      if client and client:supports_method(methods.textDocument_foldingRange, ev.buf) then
        local win = vim.api.nvim_get_current_win()
        vim.wo[win][0].foldexpr = "v:lua.vim.lsp.foldexpr()"
        return
      end
    end
  end,
})

---@class vim.lsp.ClientConfig
---@field should_attach? LspClientEventHandler

-- LSP should_attach support.
lsp_util.on_attach(function (bufnr, client)
  local should_attach = client and client.config and client.config.should_attach or nil
  if not should_attach then return end
  if type(should_attach) ~= "function" then return end
  if should_attach(bufnr, client) then return end

  ---Detach client from this buffer.
  ---@param retry? number
  ---@note
  ---LspAttach happens before the buffer is actually marked as attached!
  ---See: https://github.com/neovim/nvim-lspconfig/issues/2508
  ---Ideally, we'd never attach at all, but vim.lsp doesn't support this...
  local function defer_detach(retry)
    vim.defer_fn(function ()
      if vim.lsp.buf_is_attached(bufnr, client.id) then
        vim.lsp.buf_detach_client(bufnr, client.id)
        return
      end
      if retry and retry < 10 then
        defer_detach(retry + 1)
        return
      end
      vim.notify(
        "Tried to detach " .. client.name .. " from buffer " .. bufnr .. " before it was attached!",
        vim.log.levels.ERROR
      )
    end, retry and retry * retry * 20 or 10)
  end
  defer_detach(0)
end)

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
    prefix = "",
    spacing = 2,
    format = function (d)
      local message = util.diagnostic_icons[d.severity]
      if d.source then message = string.format("%s %s", message, util.kind_names[d.source] or d.source) end
      if d.code then message = string.format("%s[%s]", message, d.code) end
      return message .. " "
    end,
  },
})

return {
  {
    "neovim/nvim-lspconfig",
    init = function () lsp_util.setup_lsp_servers() end,
  },
  {
    "rachartier/tiny-inline-diagnostic.nvim",
    event = "LspAttach",
    priority = 1001, -- Must run before other lsp plugins!
    opts = {
      preset = "powerline",
      options = {
        show_all_diags_on_cursorline = true,
        show_source = { enabled = true },
        multilines = {
          enabled = true,
          always_show = false,
          tabstop = 2,
          severity = { vim.diagnostic.severity.ERROR },
        },
        overflow = { padding = 4 },
        experimental = {
          -- Make diagnostics not mirror across windows containing the same buffer
          -- See: https://github.com/rachartier/tiny-inline-diagnostic.nvim/issues/127
          use_window_local_extmarks = true,
        },
      },
    },
    config = function (_, opts)
      local tiny = require("tiny-inline-diagnostic")
      tiny.setup(opts or {})

      vim.diagnostic.config({ virtual_text = false })

      local was_enabled = false
      vim.api.nvim_create_autocmd("User", {
        desc = "[TinyInlineDiagnostic] Toggle on NES",
        group = user_lsp_config_group,
        pattern = "SidekickNesHide",
        callback = function()
          if was_enabled and not tiny.enabled then
            tiny.enable()
          end
        end,
      })
      vim.api.nvim_create_autocmd("User", {
        desc = "[TinyInlineDiagnostic] Toggle on NES",
        group = user_lsp_config_group,
        pattern = "SidekickNesShow",
        callback = function()
          was_enabled = tiny.enabled
          tiny.disable()
        end,
      })
    end,
  },
  {
    "rachartier/tiny-code-action.nvim",
    dependencies = {"nvim-lua/plenary.nvim"},
    event = "LspAttach",
    opts = {
      backend = "difftastic",
      picker = {
        "buffer",
        opts = {
          hotkeys = true,
          hotkeys_mode = "text_diff_based",
          custom_keys = {
            { key = "ff", pattern = "Fix this prettier/.* problem" },
            { key = "fa", pattern = "Fix this prettier/prettier problems" },
            { key = "zg", pattern = "Add '[^']*' to dictionary" },
            { key = "zG", pattern = "Add '[^']*' to global dictionary" },
            { key = "zi", pattern = "Add current file to ignore list" },
          },
          keymaps = {
            preview = "-",
            preview_close = { "-", "q", "<esc>" },
            close = { "q", "<esc>" },
          },
        },
      },
    },
    config = function (_, opts)
      local tiny_code_action = require("tiny-code-action")
      tiny_code_action.setup(opts)
      lsp_util.register_code_action_fun(tiny_code_action.code_action)
    end,
  },
  { "mason-org/mason.nvim", build = ":MasonUpdate", config = true },
  { "folke/lsp-colors.nvim" },
  {
    "mason-org/mason-lspconfig.nvim",
    dependencies = { "mason-org/mason.nvim", "pmizio/typescript-tools.nvim" },
    config = true,
  },
  { "yioneko/nvim-vtsls" },
}