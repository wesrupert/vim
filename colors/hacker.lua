vim.cmd.hi("clear")
local fg = "#00ff00"
local bg = "#000000"
local bg_selected = "#222222"
local bg_cursorline = "#002200"

for hl_group, attrs in pairs(vim.api.nvim_get_hl(0, { })) do
  if attrs.fg then attrs.fg = fg end
  if attrs.bg then attrs.bg = bg end
  vim.api.nvim_set_hl(0, hl_group, attrs)
end

vim.api.nvim_set_hl(0, "Visual", { bg = bg_selected })
vim.api.nvim_set_hl(0, "CursorLine", { bg = bg_cursorline })