local methods = vim.lsp.protocol.Methods
local augroup_lsp_event_handler = vim.api.nvim_create_augroup('LspEventHandlerConfig', { clear = true })

local M = {}
local m = {}

---@param client_opts? vim.lsp.get_clients.Filter
---@param filter? fun(client: vim.lsp.Client): boolean
function M.get_clients(client_opts, filter)
  local result = vim.lsp.get_clients(client_opts)
  return filter and vim.tbl_filter(filter, result) or result
end

---Set up LSP keymaps and autocommands for when an LSP attaches
---or updates capabilities for the current buffer.
---@param on_attach fun(client:vim.lsp.Client, bufnr:integer) The callback to invoke
---@return number handle Handle to unregister on_attach listeners
function M.on_attach(on_attach)
  return vim.api.nvim_create_autocmd("LspAttach", {
    desc = '[LSP] Setup on_attach handler',
    group = augroup_lsp_event_handler,
    callback = function (ev)
      local client = vim.lsp.get_client_by_id(ev.data.client_id)
      if client then return on_attach(client, ev.buf) end
    end,
  })
end

---@type boolean
m.setup_dynamic_capability_complete = false
---@type fun(client: vim.lsp.Client, bufnr: number)[]
m.on_dynamic_capability = {}
---@type table<string,table<vim.lsp.Client, table<number,boolean>>>
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
      m.on_dynamic_capability = vim.tbl_filter(function (handler)
        return handler(client, bufnr) ~= false
      end, m.on_dynamic_capability)
    end
    return result
  end
end

---@param fn fun(client:vim.lsp.Client, bufnr: number)
function M.on_dynamic_capability(fn)
  table.insert(m.on_dynamic_capability, fn)
end


---@param method string
---@param fn fun(client:vim.lsp.Client, bufnr: number)
function M.on_supports_method(method, fn)
  m.on_supports_method[method] = m.on_supports_method[method] or setmetatable({}, { __mode = "k" })

  ---@param client vim.lsp.Client
  local function check(client, bufnr)
    m.on_supports_method[method][client] = m.on_supports_method[method][client] or {}
    if m.on_supports_method[method][client][bufnr] then
      return
    end
    if client:supports_method(method, bufnr) then
      m.on_supports_method[method][client][bufnr] = true
      fn(client, bufnr)
    end
  end
  M.on_attach(check)
  M.on_dynamic_capability(check)
end

return M