local util = require("util")

---@alias LspClientEventHandler fun(bufnr: integer, client: vim.lsp.Client): boolean|nil

local M = {}
M.quick_actions = { "source", "refactor", "quickfix" }
M.user_lsp_config_group = vim.api.nvim_create_augroup("UserLspConfig", { clear = true })
M.augroup_lsp_event_handler = vim.api.nvim_create_augroup("LspEventHandlerConfig", { clear = true })

local m = {}
m.code_action_fun = vim.lsp.buf.code_action

---Helper function to handle code action calls via plugin.
---@param callback? fun(opts?: vim.lsp.buf.code_action.Opts)
function M.register_code_action_fun(callback)
  m.code_action_fun = callback
end

---Helper function to handle code action calls via plugin.
---@param opts? vim.lsp.buf.code_action.Opts
function M.do_code_action(opts)
  return m.code_action_fun(opts)
end

---@param client_opts? vim.lsp.get_clients.Filter
---@param filter? fun(client: vim.lsp.Client): boolean
function M.get_clients(client_opts, filter)
  local result = vim.lsp.get_clients(client_opts)
  return filter and vim.tbl_filter(filter, result) or result
end

---Set up LSP keymaps and autocommands for when an LSP attaches or updates capabilities for the current buffer.
---@param callback LspClientEventHandler The callback to invoke
---@return number handle Handle to unregister on_attach listeners
function M.on_attach(callback)
  return vim.api.nvim_create_autocmd("LspAttach", {
    desc = "[LSP] Setup on_attach handler",
    group = M.augroup_lsp_event_handler,
    callback = function (ev)
      local client = vim.lsp.get_client_by_id(ev.data.client_id)
      if client then return callback(ev.buf, client) end
    end,
  })
end

---Set up LSP keymaps and autocommands for when the named LSP attaches or updates capabilities for the current buffer.
---@param name string The client name
---@param callback LspClientEventHandler The callback to invoke
---@return number handle Handle to unregister on_attach listeners
function M.on_attach_client(name, callback)
  return vim.api.nvim_create_autocmd("LspAttach", {
    desc = "[LSP] Setup on_attach handler for " .. name,
    group = M.augroup_lsp_event_handler,
    callback = function (ev)
      local client = vim.lsp.get_client_by_id(ev.data.client_id)
      if client and client.name == name then return callback(ev.buf, client) end
    end,
  })
end

---@type boolean
m.setup_dynamic_capability_complete = false
---@type table<string, LspClientEventHandler>
m.on_dynamic_capability = {}
---@type table<string, table<vim.lsp.Client, table<number, boolean>>>
m.on_supports_method = {}

function m.setup_dynamic_capability()
  if m.setup_dynamic_capability_complete then return end
  m.setup_dynamic_capability_complete = true

  local register_capability = vim.lsp.handlers[vim.lsp.protocol.Methods.client_registerCapability]
  vim.lsp.handlers[vim.lsp.protocol.Methods.client_registerCapability] = function (err, res, ctx)
    local result = register_capability(err, res, ctx)
    local client = vim.lsp.get_client_by_id(ctx.client_id)
    if client then
      local bufnr = vim.api.nvim_get_current_buf()
      m.on_dynamic_capability = vim.tbl_filter(
        ---@param handler LspClientEventHandler
        function (handler) return handler(bufnr, client) ~= false end,
        m.on_dynamic_capability
      )
    end
    return result
  end
end

---@param callback LspClientEventHandler The callback to invoke
function M.on_dynamic_capability(callback)
  table.insert(m.on_dynamic_capability, callback)
end

---@param method vim.lsp.protocol.Method
---@param callback LspClientEventHandler The callback to invoke
function M.on_supports_method(method, callback)
  m.on_supports_method[method] = m.on_supports_method[method] or setmetatable({}, { __mode = "k" })

  ---Wrapper fn to deduplicate dynamic capabilities from the server.
  ---@type LspClientEventHandler
  local function callback_once_per_method_client_buffer(bufnr, client)
    m.on_supports_method[method][client] = m.on_supports_method[method][client] or {}
    if m.on_supports_method[method][client][bufnr] then
      return
    end
    ---@diagnostic disable-next-line: param-type-mismatch
    if client:supports_method(method, bufnr) then
      m.on_supports_method[method][client][bufnr] = true
      callback(bufnr, client)
    end
  end
  M.on_attach(callback_once_per_method_client_buffer)
  M.on_dynamic_capability(callback_once_per_method_client_buffer)
end


-- Set up LSP servers.
function M.setup_lsp_servers()
  -- Use stdpath instead of rtp to skip definitions only in nvim-lspconfig.
  local lsp_dir = vim.fn.stdpath("config") .. "/after/lsp"
  if not vim.fn.isdirectory(lsp_dir) then return end
  local lsp_servers = {}
  for _, file in ipairs(vim.fn.readdir(lsp_dir)) do
    table.insert(lsp_servers, vim.fn.fnamemodify(file, ":t:r"))
  end
  vim.lsp.enable(lsp_servers)
  vim.lsp.inline_completion.enable(true)
end

---Set up LSP config, attaching capability handlers and keymaps.
function M.setup()
  -- LSP Keymaps
  M.on_attach(function (bufnr)
    local function gen_jump(forward, severity)
      local count = forward and 1 or -1
      return function () vim.diagnostic.jump({ count = count, severity = severity }) end
    end
    util.keymap({
      { "goq", desc = "[LSP] Workspace info",       function () print("Workspace folders: " .. vim.inspect(vim.lsp.buf.list_workspace_folders())) end },
      { "grw", desc = "[LSP] Add workspace folder", vim.lsp.buf.add_workspace_folder    },
      { "grW", desc = "[LSP] Del workspace folder", vim.lsp.buf.remove_workspace_folder },

      { "grn",   desc = "[LSP] Rename",            vim.lsp.buf.rename      },
      { "gra",   desc = "[LSP] Show code actions", M.do_code_action },
      { "<c-,>", desc = "[LSP] Show code actions", M.do_code_action },

      ---@diagnostic disable-next-line: missing-fields
      { "gre", desc = "[LSP] Show quick edits", function () return M.do_code_action({ context = { only = M.quick_actions } }) end },

      { "[e",  desc = "[LSP] Previous error", gen_jump(false, vim.diagnostic.severity.ERROR) },
      { "]e",  desc = "[LSP] Previous error", gen_jump(true,  vim.diagnostic.severity.ERROR) },
      { "[s",  desc = "[LSP] Previous info",  gen_jump(false, vim.diagnostic.severity.INFO)  },
      { "]s",  desc = "[LSP] Previous info",  gen_jump(true,  vim.diagnostic.severity.INFO)  },
    }, bufnr)
  end)

  M.on_supports_method("textDocument/definition", function (bufnr)
    util.keymap({ { "gd", desc = "[LSP] Go to definition", buf = bufnr, vim.lsp.buf.definition } })
  end)

  -- Loading progress notifications
  vim.api.nvim_create_autocmd("LspProgress", {
    group = M.user_lsp_config_group,
    callback = function (ev)
      local value = ev.data.params.value
      vim.api.nvim_echo({ { value.message or "done" } }, false, {
        id = "lsp." .. ev.data.client_id,
        kind = "progress",
        source = "vim.lsp",
        title = value.title,
        status = value.kind ~= "end" and "running" or "success",
        percent = value.percentage,
      })
    end,
  })

  -- Document highlight
  M.on_supports_method("textDocument/documentHighlight", function (bufnr)
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
  M.on_supports_method("textDocument/inlayHint", function (bufnr)
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

  -- Eslint "Fix All" command/ "Fix on save" autocommand.
  M.on_attach(function (bufnr, client)
    if client.name ~= "eslint" then return end
    _G.eslint_fix_all = function ()
      client:request("workspace/executeCommand", {
        command = "eslint.applyAllFixes",
        arguments = { { uri = vim.uri_from_bufnr(bufnr), version = vim.lsp.util.buf_versions[bufnr] } },
      }, nil, bufnr)
    end
    util.keymap({ { "gre", desc = "[LSP:eslint] Fix all", buf = bufnr, eslint_fix_all } })

    vim.api.nvim_create_autocmd("BufWritePre", {
      group = M.user_lsp_config_group,
      desc = "[LSP:eslint] Fix on save",
      buffer = bufnr,
      callback = function () if util.get_setting("ESLINT_RUN_ON_SAVE", true, bufnr) then eslint_fix_all() end end,
    })
  end)

  -- LSP foldexpr support.
  vim.api.nvim_create_autocmd("BufWinEnter", {
    group = M.user_lsp_config_group,
    desc = "[LSP] Enable foldexpr",
    callback = function (ev)
      if not util.get_setting("use_lsp_foldexpr", true) then return end
      for _, client in ipairs(vim.lsp.get_clients({ bufnr = ev.buf })) do
        if client and client:supports_method("textDocument/foldingRange", ev.buf) then
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
  M.on_attach(function (bufnr, client)
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
        if retry and retry <= 10 then
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
end

return M