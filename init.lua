local user_default_config = vim.api.nvim_create_augroup("UserConfig", { clear = true })
local util = require("util")

-- Basic settings
-- {{{

vim.g.slash = vim.fn.has('win32') and '\\' or '/'
vim.g.mapleader = " "
vim.g.health = { style = "float" }
vim.o.winborder = "rounded"
vim.o.foldmethod = "expr"
vim.o.foldexpr = "v:lua.vim.treesitter.foldexpr()"

vim.o.cmdheight = 0
require('vim._core.ui2').enable({
  enable = true,
  msg = { timeout = 2500 },
})

if util.is_gui() then
  vim.o.pumblend = 20

  if vim.g.neovide then
    vim.g.neovide_theme = "auto"
    vim.g.neovide_remember_window_size = true
    vim.g.neovide_hide_mouse_when_typing = true
    vim.g.neovide_input_macos_option_key_is_meta = "both"
    vim.g.neovide_text_gamma = 1.2
    vim.g.neovide_floating_shadow = false
    vim.g.neovide_floating_corner_radius = 0.4
    vim.g.experimental_layer_grouping = true

  -- HACK neovide/neovide#3125: Needed to remove buggy extra window when ui2 is enabled.
    vim.api.nvim_create_autocmd('FocusGained', { group = user_default_config, pattern = '*', once = true, callback = function ()
      vim.cmd([[new | close]])
    end })
  end
end

-- }}}

-- Load custom settings.
-- {{{

local custom_init = vim.fn.stdpath("config") .. "/init.custom.vim"
---@diagnostic disable-next-line: undefined-field
if vim.uv.fs_stat(custom_init) then
  vim.fn.execute("source " .. custom_init)
end

-- }}}

-- Keymaps
-- {{{

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

util.keymap("[VLine block insert]", {
  { "I", "Insert", opts = { modes = "x", expr = true }, function () return vim.fn.mode() == "V" and "^<C-v>I" or "I" end },
  { "A", "Append", opts = { modes = "x", expr = true }, function () return vim.fn.mode() == "V" and "$<C-v>A" or "A" end },
})

util.keymap("[Term scroll]", {
  { "<ScrollWheelUp>",    "Up",    opts = { modes = "t" }, "<up><up><up>",          },
  { "<ScrollWheelDown>",  "Down",  opts = { modes = "t" }, "<down><down><down>",    },
  { "<ScrollWheelLeft>",  "Left",  opts = { modes = "t" }, "<left><left><left>",    },
  { "<ScrollWheelRight>", "Right", opts = { modes = "t" }, "<right><right><right>", },
})

---Generate comment-and-paste keybinding opfunc.
---@param paste? boolean Iff true, paste yanked text immediately
---@param op? string Operatorfunc mode
local function gen_comment_and_yank(paste, op)
  local operator = "g@" .. (op or "")
  local func = "v:lua.comment_and_yank" if paste then func = "v:lua.comment_and_paste" end
  return function () vim.opt.operatorfunc = func return operator end
end

util.keymap("[Yank-and-comment]", {
  { "yc",  "Yank",        opts = { expr = true },              gen_comment_and_yank(false)      },
  { "yC",  "Paste",       opts = { expr = true },              gen_comment_and_yank(true)       },
  { "ycc", "Yank line",   opts = { expr = true },              gen_comment_and_yank(false, "_") },
  { "ycC", "Paste line",  opts = { expr = true },              gen_comment_and_yank(true,  "_") },
  { "gc",  "Yank lines",  opts = { modes = "x", expr = true }, gen_comment_and_yank(false, "_") },
  { "gC",  "Paste lines", opts = { modes = "x", expr = true }, gen_comment_and_yank(true,  "_") },
})

vim.api.nvim_create_autocmd("TextYankPost", {
  group = user_default_config,
  callback = function () vim.hl.on_yank({ higroup="Visual", timeout=300 }) end,
  desc = "Highlight on yank",
})

-- }}}

-- Add gitignore values to wildignore, if present.
-- {{{

local function read_gitignore()
  local gitignore_path = vim.fs.find(".gitignore", { upward = true, type = "file" })
  if #gitignore_path == 0 then return end

  local current_ignores = {}
  vim.iter(vim.fn.split(vim.o.wildignore, ",", false))
    :each(function --[[@param x string]] (x) current_ignores[x] = true end)

  local gitignore_lines = vim.fn.readfile(gitignore_path[1])
  vim.iter(gitignore_lines)
    :map   (function --[[@param x string]] (x) return x:gsub("%s*#.*", "") end)
    :filter(function --[[@param x string]] (x) return not x:match("^%s*$") end)
    :map   (function --[[@param x string]] (x) return x:match("/$") and x.."**" or x end)
    :map   (function --[[@param x string]] (x) return x:match("^/.*[^/]$") and x.."/**" or x end)
    :map   (function --[[@param x string]] (x) return x:match("^[^/.*]*$") and x.."/**" or x end)
    :map   (function --[[@param x string]] (x) return x:match("^[^/]*/%*%*$") and "**/"..x or x end)
    :each  (function --[[@param x string]] (x) current_ignores[x] = true end)
  vim.o.wildignore = table.concat(vim.tbl_keys(current_ignores), ",")
end
_G.read_gitignore = read_gitignore

vim.api.nvim_create_autocmd("User", {
  group = user_default_config,
  desc = "Add gitignore to wildignore",
  pattern = "RooterChDir",
  callback = read_gitignore,
})

-- }}}

-- Install plugins.
-- {{{

local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
vim.opt.rtp:prepend(lazypath)
if not vim.uv.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable",
    lazypath,
  })
end

-- Load mise dependencies first, so they can be used by plugins like copilot.
util.load_mise_deps()
require("lazy").setup("plugins", {
  dev = { path = "~/Code/nvim" },
  ui = { border = vim.o.winborder },
  change_detection = { notify = false },
})

-- }}}

-- Persist/theme colorschemes.
-- {{{

local user_colorscheme_config = vim.api.nvim_create_augroup("UserColorschemeConfig", { clear = true })

---Get the current colorscheme config, optionally for a specific background type.
---Stores/retrieves colorscheme info in ShaDa.
---@param background? 'dark'|'light'
---@return string colorscheme
---@return string config_key
local function get_colorscheme_config(background)
  local b = background or vim.o.background
  local config_key = b == "light" and "DAY_THEME" or "NIGHT_THEME"
  local colorscheme = util.get_setting(config_key, vim.g.colors_name or "catppuccin")
  if util.is_gui() then
    config_key = b == "light" and "GUI_DAY_THEME" or "GUI_NIGHT_THEME"
    colorscheme = util.get_setting(config_key, colorscheme)
  end
  return colorscheme, config_key
end

vim.api.nvim_create_autocmd("VimEnter", {
  desc = "[UI] Retrieve colorscheme from ShaDa",
  group = user_colorscheme_config,
  nested = true,
  callback = function()
    local _, config_key = get_colorscheme_config()
    pcall(vim.cmd.colorscheme, vim.g[config_key])
  end,
})

vim.api.nvim_create_autocmd("OptionSet", {
  pattern = "background",
  desc = "[UI] Update colorscheme on theme change",
  group = user_colorscheme_config,
  callback = function()
    local colorscheme = get_colorscheme_config(vim.o.background)
    vim.cmd.colorscheme(colorscheme)
  end,
})

vim.api.nvim_create_autocmd("ColorScheme", {
  desc = "[UI] Store colorscheme to ShaDa",
  group = user_colorscheme_config,
  callback = function(params)
    local _, config_key = get_colorscheme_config()
    vim.g[config_key] = params.match
  end,
})

-- }}}

-- Load classic vim settings.
-- {{{

local vimrc = vim.fn.stdpath("config") .. "/vimrc"
---@diagnostic disable-next-line: undefined-field
if vim.uv.fs_stat(vimrc) then
  vim.fn.execute("source " .. vimrc)
end

-- }}}

-- vim: foldmethod=marker