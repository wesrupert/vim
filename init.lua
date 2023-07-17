local vimdir = vim.fn.has('win32') == 1 and '$HOME/vimfiles' or '~/.vim'
local lazypath = vim.fn.stdpath('data') .. '/lazy/lazy.nvim'
vim.opt.rtp:prepend('~/.config/nvim')
vim.opt.rtp:prepend(vimdir)
vim.opt.rtp:prepend(lazypath)
vim.g.mapleader = ','

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

local vimrc = vim.fn.expand(vimdir) .. '/vimrc'
if vim.loop.fs_stat(vimrc) then
  vim.fn.execute('source ' .. vimrc)
end