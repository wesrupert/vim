local util = require("util")
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
vim.opt.rtp:prepend(lazypath)

if vim.fn.executable("mise") then
  local vim_tools = {
    node = "latest",
    python = "latest",
    ruby = "latest",
  }
  for tool, version in pairs(vim_tools) do
    ---@param cmd string[]
    ---@return boolean success, any result, ...any
     local get_mise_output = function (cmd) return pcall(function () return vim.system(cmd):wait().stdout:gsub("\n$", "") end) end
    local version_ok, latest_version = get_mise_output({ "mise", "latest", "-i", tool.."@"..version })
    if version_ok and latest_version then
      local path_ok, tool_path = get_mise_output({ "mise", "where", tool.."@"..latest_version })
      if path_ok and tool_path then vim.env.PATH =  tool_path .. "/bin:" .. vim.env.PATH end
    end
  end
end

local user_config_group = vim.api.nvim_create_augroup("UserConfig", { clear = false })

vim.g.mapleader = " "
vim.g.health = { style = "float" }
vim.o.winborder = "rounded"
vim.o.foldmethod = "expr"
vim.o.foldexpr = "v:lua.vim.treesitter.foldexpr()"

-- vim.g.node_host_prg = vim.fn.expand("$HOME/.local/share/mise/installs/node/22.14.0")


---Comment out selection, yank into the yank register, and optionally paste immediately.
---@param _ string Operatorfunc mode. Unused.
---@param paste? boolean Iff true, paste yanked text immediately
function _G.comment_and_yank(_, paste)
  -- NOTE: `nvim_buf_get_mark()` is 1-indexed, but `nvim_buf_get_lines()` is 0-indexed.
  -- TODO: If neovim/neovim #22297 is implemented, respect charwise selections.
  -- https://github.com/neovim/neovim/issues/22297
  local start_line, end_line = vim.api.nvim_buf_get_mark(0, "[")[1], vim.api.nvim_buf_get_mark(0, "]")[1]
  local delta_line = end_line - start_line
  local lines = vim.api.nvim_buf_get_lines(0, start_line - 1, end_line, false)
  vim.fn.setreg('"', lines, "l")
  local cursor = vim.api.nvim_win_get_cursor(0)
  vim.cmd.normal({ start_line.."G" })
  if delta_line == 0 then
    vim.cmd.normal({ "gcc", range = { start_line, end_line } })
  else
    vim.cmd.normal({ "gc"..delta_line.."j" })
  end
  if paste == true then
    vim.api.nvim_buf_set_lines(0, end_line, end_line, false, lines)
    vim.api.nvim_win_set_cursor(0, { end_line + 1, cursor[2] })
  end
end
function _G.comment_and_paste(kind) _G.comment_and_yank(kind, true) end

local gen_comment_and_yank = function (paste, op)
  local operator = "g@" .. (op or "")
  local func = "v:lua.comment_and_yank" if paste then func = "v:lua.comment_and_paste" end
  return function () vim.opt.operatorfunc = func return operator end
end

--- Keymaps

-- Block insert in line visual mode
util.keymap("I", "VLine block insert", function() return vim.fn.mode() == "V" and "^<C-v>I" or "I" end, "x", nil, { expr = true })
util.keymap("A", "VLine block append", function() return vim.fn.mode() == "V" and "$<C-v>A" or "A" end, "x", nil, { expr = true })

-- Comment and yank
util.keymap("yc",  "Comment and yank",        gen_comment_and_yank(false),      "n", nil, { expr = true })
util.keymap("yC",  "Comment and paste",       gen_comment_and_yank(true),       "n", nil, { expr = true })
util.keymap("ycc", "Comment and yank line",   gen_comment_and_yank(false, "_"), "n", nil, { expr = true })
util.keymap("ycC", "Comment and paste line",  gen_comment_and_yank(true,  "_"), "n", nil, { expr = true })
util.keymap("gc",  "Comment and yank lines",  gen_comment_and_yank(false, "_"), "x", nil, { expr = true })
util.keymap("gC",  "Comment and paste lines", gen_comment_and_yank(true,  "_"), "x", nil, { expr = true })

vim.api.nvim_create_autocmd("TextYankPost", {
  group = user_config_group,
  callback = function () vim.hl.on_yank({ higroup="Visual", timeout=300 }) end,
  desc = "Highlight on yank",
})

-- Set up additional config and plugins
require("lsp")
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable",
    lazypath,
  })
end
require("lazy").setup("plugins",{
  ui = { border = vim.o.winborder },
  change_detection = { notify = false },
})

if vim.g.neovide ~= nil then
  vim.g.neovide_theme = "auto"
  vim.g.neovide_hide_mouse_when_typing = true
  vim.g.neovide_cursor_animate_command_line = false
  vim.o.pumblend = 30
end

local vimrc = vim.fn.stdpath("config") .. "/vimrc"
if vim.loop.fs_stat(vimrc) then
  vim.fn.execute("source " .. vimrc)
end