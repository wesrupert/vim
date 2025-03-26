local util = {}

---True iff vim is not running inside the VSCodeNeovim extension.
util.not_vscode = vim.g.vscode ~= 1

---List of kind icons for LSP/file/etc icons.
util.kind_icons = {
  NeoVim        = '',
  Copilot       = '',

  Array         = '',
  Boolean       = '󰨙',
  Null          = '',
  Number        = '󰎠',
  Object        = '',
  String        = '',
  Text          = '󰉿',

  Class         = '',
  Constant      = '',
  Control       = '',
  Enum          = '',
  EnumMember    = '',
  Interface     = '',
  Key           = '',
  Keyword       = '',
  Module        = '󰅩',
  Package       = '',
  Struct        = '',
  Value         = '󰦨',

  Constructor   = '󰒓',
  Field         = '',
  Function      = '󰊕',
  Method        = '󰊕',
  Namespace     = '󰦮',
  Property      = '',
  Variable      = '',

  Snippet       = '󱄽',
  Color         = '󰏘',
  File          = '',
  Reference     = '',
  Event         = '',
  Operator      = '',
  TypeParameter = '',
  Unit          = '󰪚',

  Folder        = '',
  Collapsed     = '',
  Unknown       = '',
}

---@alias SpecialFlag "indent"|"resize"

---@type table<string, SpecialFlag[]>
local special_buftypes  = {
  nofile                = { 'resize'  },
  nowrite               = { 'resize'  },
  prompt                = { 'resize', 'indent' },
  popup                 = { 'resize', 'indent' },
  terminal              = {           'indent' },
}

---@type table<string, SpecialFlag[]>
local special_filetypes = {
  snacks_picker_list    = { 'resize', 'indent' },
  TelescopePrompt       = { 'resize', 'indent' },
  toggleterm            = { 'resize', 'indent' },
  trouble               = { 'resize', 'indent' },
  undotree              = { 'resize', 'indent' },
  qf                    = { 'resize', 'indent' },
}

---Get special buffer and file types corresponding to the given flag.
---@param flag? SpecialFlag If provided, only return special values related to the given property
---@return string[] buftypes, string[] filetypes The special buftypes and filetypes matching the provided flag
function util.get_special_types(flag)
  local buftypes = {}
  for buftype, flags in pairs(special_buftypes) do
    for _, f in ipairs(flags) do
      if (not flag or flag == f) then table.insert(buftypes, buftype) end
    end
  end

  local filetypes = {}
  for filetype, flags in pairs(special_filetypes) do
    for _, f in ipairs(flags) do
      if (not flag or flag == f) then table.insert(filetypes, filetype) end
    end
  end

  return buftypes, filetypes
end

---Handle a value that may be a function, or return the value itself alongside its truthy state.
---@generic T
---@generic A
---@generic R
---@param maybe_func T|(fun(...: A): T, ...: R)
---@param ... A
---@return boolean success
---@return T result
---@return R ...
---@see pcall
function util.maybe_pcall(maybe_func, ...)
  if type(maybe_func) == 'function' then return pcall(maybe_func, ...) end
  return (maybe_func and true or false), maybe_func
end

---Create a copy of a table.
---@param table table
---@return table table The copy
function util.tbl_copy(table)
  return vim.tbl_extend('keep', {}, table)
end

---Get the value for the given setting with the narrowest context.
---Checks: window -> tab -> buffer -> global -> provided default
---@generic T : any
---@param key string The setting to check
---@param default T The default value, if the setting is undefined in all contexts
---@param buf? number If provided, use the given buffer number instead of checking current
---@param tab? number If provided, use the given tab number instead of checking current
---@param win? number If provided, use the given window number instead of checking current
---@return T
function util.get_setting(key, default, buf, tab, win)
  -- 1. Window
  local win_value = vim.tbl_get(vim.w, win or vim.api.nvim_get_current_win(), key)
  if win_value ~= nil then return win_value end

  -- 2. Tab
  local tab_value = vim.tbl_get(vim.t, tab or vim.api.nvim_get_current_tabpage(), key)
  if tab_value ~= nil then return tab_value end

  -- 3. Buf
  local buf_value = vim.tbl_get(vim.b, buf or vim.api.nvim_get_current_buf(), key)
  if buf_value ~= nil then return buf_value end

  -- 4. Global
  local global_value = vim.tbl_get(vim.g, key)
  if global_value ~= nil then return global_value end

  -- 5. Default
  return default
end

---Composable to keep track of a setting.
---@see util.get_setting
function util.use_get_setting(key, default)
  return function () return util.get_setting(key, default) end
end

---Check if table has a value for the given key.
---@param obj table|any The table to check
---@param key string|number The key to check
---@return boolean True iff the table has a value for the key
function util.has_key(obj, key)
  if type(obj) == 'table' then
    return obj[key] ~= nil
  else
    return false
  end
end

---Merge two or more tables into one.
---@param ... table[] List of tables to merge
---@return table table Merged table
---@note This function modifies the first table!
function util.table_merge(...)
    local tables = {...}
    local result = tables[1]
    for i = 2, #tables do
        for k, v in pairs(tables[i]) do result[k] = v end
    end
    return result
end

---Alias for vim.api.nvim_set_keymap with some better args and defaults.
---@param lhs string Left-hand side of the mapping
---@param desc string human-readable description
---@param rhs string|function Right-hand side of the mapping, can be a Lua function
---@param mode? string|string[] Mode "short-name", or a list thereof
---@param buffer? number Buffer number, otherwise mapping is global
---@param opts? table Table of :map-arguments
---@see vim.keymap.set
function util.keymap(lhs, desc, rhs, mode, buffer, opts)
  vim.keymap.set(mode or 'n', lhs, rhs, util.table_merge(
    { noremap = true },
    desc and { desc = desc } or {},
    buffer ~= nil and { buffer = buffer } or {},
    opts or {}
  ))
end

---Check if the given buffer is empty.
---@param buffer? number Buffer number, or current buffer
---@return boolean True iff the current buffer is empty
function util.buf_is_empty(buffer)
  local buf = buffer or vim.api.nvim_get_current_buf()
  return vim.api.nvim_buf_get_name(buf) == '' and vim.bo[buf].filetype == ''
end


function util.nvim_is_empty_on_open()
  -- Taken from mini.nvim `is_something_shown`.
  -- See: https://github.com/echasnovski/mini.nvim/blob/main/lua/mini/starter.lua
  -- Checks for when at least one of the following is true:

  -- There are files in arguments (like `nvim foo.txt` with new file).
  if vim.fn.argc() > 0 then return false end

  -- Several buffers are listed (like session with placeholder buffers).
  -- That means unlisted buffers (like from `nvim-tree`) don't affect decision.
  local listed_buffers = vim.tbl_filter(
    function(buf_id) return vim.fn.buflisted(buf_id) == 1 end,
    vim.api.nvim_list_bufs()
  )
  if #listed_buffers > 1 then return false end

  -- Current buffer is meant to show something else
  if vim.bo.filetype ~= '' then return false end

  -- - Current buffer has any lines (something opened explicitly).
  -- NOTE: Usage of `line2byte(line('$') + 1) < 0` seemed to be fine, but it
  -- doesn't work if some automated changed was made to buffer while leaving it
  -- empty (returns 2 instead of -1). This was also the reason of not being
  -- able to test with child Neovim process from 'tests/helpers'.
  local n_lines = vim.api.nvim_buf_line_count(0)
  if n_lines > 1 then return false end
  local first_line = vim.api.nvim_buf_get_lines(0, 0, 1, true)[1]
  if string.len(first_line) > 0 then return false end

  return true
end

return util