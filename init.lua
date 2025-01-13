local vimdir = '~/.config/nvim'
local lazypath = vim.fn.stdpath('data') .. '/lazy/lazy.nvim'
vim.env.PATH = vim.env.HOME .. '/.local/share/mise/shims:' .. vim.env.PATH
vim.opt.rtp:prepend(vimdir)
vim.opt.rtp:prepend(lazypath)

vim.g.mapleader = ','
vim.g.health = { style = 'float' }

if vim.g.neovide ~= nil then
  vim.g.neovide_theme = 'auto'
  vim.g.neovide_hide_mouse_when_typing = true
  vim.g.neovide_cursor_animate_command_line = false

  vim.g.neovide_floating_corner_radius = 0.25
  vim.g.neovide_floating_shadow = true
  vim.g.neovide_floating_z_height = 3
  vim.g.neovide_light_angle_degrees = 45
  vim.g.neovide_light_radius = 3
  vim.g.neovide_floating_blur_amount_x = 5.0
  vim.g.neovide_floating_blur_amount_y = 5.0
  vim.o.winblend = 30
  vim.o.pumblend = vim.o.winblend
end

vim.g.skip_ts_context_commentstring_module = true

if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    'git',
    'clone',
    '--filter=blob:none',
    'https://github.com/folke/lazy.nvim.git',
    '--branch=stable',
    lazypath,
  })
end
require('lazy').setup('plugins')

vim.diagnostic.config({
  signs = {
    text = {
      [vim.diagnostic.severity.ERROR] = '',
      [vim.diagnostic.severity.WARN] = '',
      [vim.diagnostic.severity.INFO] = '',
      [vim.diagnostic.severity.HINT] = '',
    },
  },
})

local vimrc = vim.fn.expand(vimdir) .. '/vimrc'
if vim.loop.fs_stat(vimrc) then
  vim.fn.execute('source ' .. vimrc)
end