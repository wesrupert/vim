local methods = vim.lsp.protocol.Methods
local augroup_lsp_event_handler = vim.api.nvim_create_augroup("LspEventHandlerConfig", { clear = true })

---@alias LspClientEventHandler fun(bufnr: integer, client: vim.lsp.Client): boolean|nil

local M = {}
local m = {}

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
    group = augroup_lsp_event_handler,
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
    group = augroup_lsp_event_handler,
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

  local register_capability = vim.lsp.handlers[methods.client_registerCapability]
  vim.lsp.handlers[methods.client_registerCapability] = function (err, res, ctx)
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
end

_G._util_lsp = m
return M