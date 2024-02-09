local vimdir = '~/.config/nvim'
local lazypath = vim.fn.stdpath('data') .. '/lazy/lazy.nvim'
vim.opt.rtp:prepend(vimdir)
vim.opt.rtp:prepend(lazypath)
vim.g.mapleader = ','

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

local vimrc = vim.fn.expand(vimdir) .. '/vimrc'
if vim.loop.fs_stat(vimrc) then
  vim.fn.execute('source ' .. vimrc)
end