local M = {}

M.dirs = {
  home = vim.fn.expand('$HOME'),
  code = vim.fn.expand('$HOME/Code'),
  work = vim.fn.expand('$HOME/Code/work'),
}

---List of kind icons for LSP/file/etc icons.
M.kind_icons     = {
  Error             = '',
  Warn              = '',
  Info              = '',
  Hint              = '',

  NeoVim            = '',
  Copilot           = '',

  Collapsed         = '',
  Delete            = '󰩺',
  Folder            = '',
  Terminal          = '',
  Unknown           = '',

  Array             = '',
  Boolean           = '󰨙',
  Null              = '',
  Number            = '󰎠',
  Object            = '',
  String            = '',
  Text              = '󰉿',
  Type              = '',

  Class             = '',
  Constant          = '',
  Control           = '',
  Element           = '󰅩',
  Enum              = '',
  EnumMember        = '',
  Identifier        = '󰀫',
  Interface         = '',
  Key               = '',
  Keyword           = '',
  List              = '󰅪',
  Module            = '󰅩',
  Package           = '',
  Struct            = '',
  Value             = '󰦨',

  BreakStatement    = '󰙧',
  Call              = '󰃷',
  CaseStatement     = '󱃙',
  Constructor       = '󰒓',
  ContinueStatement = '→',
  Declaration       = '󰙠',
  DoStatement       = '󰑖',
  Field             = '',
  ForStatement      = '󰑖',
  Function          = '󰊕',
  GotoStatement     = '󰁔',
  IfStatement       = '󰇉',
  Method            = '󰊕',
  Namespace         = '󰦮',
  Pair              = '󰅪',
  Property          = '',
  RuleSet           = '󰅩',
  Scope             = '󰅩',
  Statement         = '󰅩',
  SwitchStatement   = '󰺟',
  Table             = '󰅩',
  Variable          = '',
  WhileStatement    = '󰑖',

  Color             = '󰏘',
  Event             = '',
  File              = '',
  Log               = '󰦪',
  Lsp               = '',
  Macro             = '󰁌',
  Operator          = '',
  Reference         = '',
  Regex             = '',
  Repeat            = '󰑖',
  Return            = '󰌑',
  Snippet           = '󱄽',
  Specifier         = '󰦪',
  TypeParameter     = '',
  Unit              = '󰪚',

  H1Marker          = '󰉫',
  H2Marker          = '󰉬',
  H3Marker          = '󰉭',
  H4Marker          = '󰉮',
  H5Marker          = '󰉯',
  H6Marker          = '󰉰',
  MarkdownH1        = '󰉫',
  MarkdownH2        = '󰉬',
  MarkdownH3        = '󰉭',
  MarkdownH4        = '󰉮',
  MarkdownH5        = '󰉯',
  MarkdownH6        = '󰉰',
}

M.diagnostic_icons = {
  [vim.diagnostic.severity.ERROR] = M.kind_icons.Error,
  [vim.diagnostic.severity.WARN] = M.kind_icons.Warn,
  [vim.diagnostic.severity.INFO] = M.kind_icons.Info,
  [vim.diagnostic.severity.HINT] = M.kind_icons.Hint,
}

M.kind_names = {
  ['Lua Diagnostics.'] = 'lua',
  ['Lua Syntax Check.'] = 'lua',
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
function M.get_special_types(flag)
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
function M.maybe_pcall(maybe_func, ...)
  if type(maybe_func) == 'function' then return pcall(maybe_func, ...) end
  return (maybe_func and true or false), maybe_func
end

---Wrap vim.fn.expandedcmd with a pcall to return safely on error.
---@param string string
---@param table opts?
---@return any
---@see vim.fn.expandcmd
function M.safe_expandcmd(string, opts)
  local ok, res = pcall(vim.fn.expandcmd, string, opts)
  return ok and res or string
end

---Fast implementation to check if a table is a list
---@param t table
function M.is_list(t)
  local i = 0
  ---@diagnostic disable-next-line: no-unknown
  for _ in pairs(t) do
    i = i + 1
    if t[i] == nil then
      return false
    end
  end
  return true
end

---Check if the value is a table that can be merged (i.e. not a list).
---@param value any
---@return boolean
function M.can_merge(value)
  return type(value) == "table" and (vim.tbl_isempty(value) or not M.is_list(value))
end

---Merges the values similar to vim.tbl_deep_extend with the **force** behavior,
---but the values can be any type, in which case they override the values on the left.
---Values will me merged in-place in the first left-most table. If you want the result to be in
---a new table, then simply pass an empty table as the first argument `vim.merge({}, ...)`
---Supports clearing values by setting a key to `vim.NIL`
---@generic T
---@param ... T
---@return T
function M.merge(...)
  local ret = select(1, ...)
  if ret == vim.NIL then
    ret = nil
  end
  for i = 2, select("#", ...) do
    local value = select(i, ...)
    if M.can_merge(ret) and M.can_merge(value) then
      for k, v in pairs(value) do
        ret[k] = M.merge(ret[k], v)
      end
    elseif value == vim.NIL then
      ret = nil
    elseif value ~= nil then
      ret = value
    end
  end
  return ret
end

---Create a copy of a table.
---@param table table
---@return table table The copy
function M.tbl_copy(table)
  return M.merge({}, table)
end

--- Removes empty lines from the beginning and end.
---@param lines table list of lines to trim
---@return table trimmed list of lines
function M.trim_empty_lines(lines)
  local start = 1
  for i = 1, #lines do
    if lines[i] ~= nil and #lines[i] > 0 then
      start = i
      break
    end
  end
  local finish = 1
  for i = #lines, 1, -1 do
    if lines[i] ~= nil and #lines[i] > 0 then
      finish = i
      break
    end
  end
  return vim.list_slice(lines, start, finish)
end

---@type table<string, boolean>
local queried_settings = {}

---Get the value for the given setting with the narrowest context.
---Checks: window -> tab -> buffer -> global -> provided default
---@generic T : any
---@param key string The setting to check
---@param default T The default value, if the setting is undefined in all contexts
---@param buf? number If provided, use the given buffer number instead of checking current
---@param tab? number If provided, use the given tab number instead of checking current
---@param win? number If provided, use the given window number instead of checking current
---@return T
function M.get_setting(key, default, buf, tab, win)
  queried_settings[key] = true -- Set key for reporting

  local win_value = vim.tbl_get(vim.w, win or 0, key)
  if win_value ~= nil then return win_value end

  local tab_value = vim.tbl_get(vim.t, tab or 0, key)
  if tab_value ~= nil then return tab_value end

  local buf_value = vim.tbl_get(vim.b, buf or 0, key)
  if buf_value ~= nil then return buf_value end

  local global_value = vim.tbl_get(vim.g, key)
  if global_value ~= nil then return global_value end

  return default
end

---Get a list of all settings tracked by get_setting in the current environment.
---@return table<integer, string> settings Table of all tracked settings
function M.get_settings()
  local settings = {}
  for key, _ in pairs(queried_settings) do
    settings[#settings] = key
  end
  return settings
end

---Composable to keep track of a setting.
---@see M.get_setting
---@return {
---  get: fun(buf?: number, tab?: number, win?: number),
---  set: fun(value, ctx?: string, ctx_id?: number),
---}
function M.use_setting(key, default)
  return {
    get = function (buf, tab, win) return M.get_setting(key, default, buf, tab, win) end,
    set = function (value, ctx, ctx_id)
      if not ctx or ctx == 'g' then
        vim.g[key] = value
      else
        vim[ctx][ctx_id or 0][key] = value
      end
      return value
    end,
  }
end

---Check if table has a value for the given key.
---@param obj table|any The table to check
---@param key string|number The key to check
---@return boolean True iff the table has a value for the key
function M.has_key(obj, key)
  if type(obj) == 'table' then
    return obj[key] ~= nil
  else
    return false
  end
end

---Parse fargs from a command into a callable format for lua functions
---@param fargs string[]
---@return string name, table opts
function M.command_parse_fargs(fargs)
  local name, opts_parts = fargs[1], vim.tbl_map(M.safe_expandcmd, vim.list_slice(fargs, 2, #fargs))
  local tbl_string = string.format('{ %s }', table.concat(opts_parts, ', '))
  local lua_load = loadstring('return ' .. tbl_string)
  if lua_load == nil then error('Could not convert extra command arguments to table: ' .. tbl_string, 0) end
  return name, lua_load()
end

---Alias for vim.api.nvim_set_keymap with some better args and defaults.
---@param lhs string Left-hand side of the mapping
---@param desc string human-readable description
---@param rhs string|function Right-hand side of the mapping, can be a Lua function
---@param mode? string|string[] Mode "short-name", or a list thereof
---@param buffer? number Buffer number, otherwise mapping is global
---@param opts? table Table of :map-arguments
---@see vim.keymap.set
function M.keymap(lhs, desc, rhs, mode, buffer, opts)
  vim.keymap.set(mode or 'n', lhs, rhs, vim.tbl_extend(
    'force',
    { noremap = true },
    desc and { desc = desc } or {},
    buffer ~= nil and { buffer = buffer } or {},
    opts or {}
  ))
end

---Check if the given buffer is empty.
---@param buffer? number Buffer number, or current buffer
---@return boolean True iff the current buffer is empty
function M.buf_is_empty(buffer)
  local buf = buffer or vim.api.nvim_get_current_buf()
  return vim.api.nvim_buf_get_name(buf) == '' and vim.bo[buf].filetype == ''
end

---Checks for when at least one of the following is true:
--- - There are files in arguments (like `nvim foo.txt` with new file).
--- - Several buffers are listed (like session with placeholder buffers).
---   (That means unlisted buffers (like from `nvim-tree`) don't affect decision.)
--- - Current buffer is meant to show something else
--- - Current buffer has any lines (something opened explicitly).
---@see mini.nvim.is_something_shown https://github.com/echasnovski/mini.nvim/blob/main/lua/mini/starter.lua
---@return boolean True iff nvim is "empty" on open
function M.nvim_is_empty_on_open()
  if vim.fn.argc() > 0 then return false end
  if vim.bo.filetype ~= '' then return false end

  local listed_buffers = vim.tbl_filter(
    function(buf_id) return vim.fn.buflisted(buf_id) == 1 end,
    vim.api.nvim_list_bufs()
  )
  if #listed_buffers > 1 then return false end

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

return M