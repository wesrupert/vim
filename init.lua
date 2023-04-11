local vimdir = vim.fn.has('win32') == 1 and '$HOME/vimfiles' or '~/.vim'
local lazypath = vim.fn.stdpath('data') .. '/lazy/lazy.nvim'
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

vim.keymap.set('n', '[d', vim.diagnostic.goto_prev)
vim.keymap.set('n', ']d', vim.diagnostic.goto_next)
vim.keymap.set('n', 'K', vim.lsp.buf.hover, opts)
vim.keymap.set('n', '<leader>de', vim.diagnostic.open_float)
vim.keymap.set('n', '<leader>dq', vim.diagnostic.setloclist)

vim.keymap.set({ 'n', 'v' }, '<leader>da', vim.lsp.buf.code_action, opts)
vim.keymap.set('n', '<leader>df', function() vim.lsp.buf.format { async = true } end, opts)

vim.keymap.set('n', '<leader>dd', vim.lsp.buf.definition, opts)
vim.keymap.set('n', '<leader>dD', vim.lsp.buf.declaration, opts)
vim.keymap.set('n', '<leader>di', vim.lsp.buf.implementation, opts)
vim.keymap.set('n', '<leader>dr', vim.lsp.buf.references, opts)
vim.keymap.set('n', '<leader>dt', vim.lsp.buf.type_definition, opts)
vim.keymap.set('n', '<leader>dk', vim.lsp.buf.signature_help, opts)

vim.keymap.set('n', '<leader>wl', function() print(vim.inspect(vim.lsp.buf.list_workspace_folders())) end, opts)
vim.keymap.set('n', '<leader>wa', vim.lsp.buf.add_workspace_folder, opts)
vim.keymap.set('n', '<leader>wx', vim.lsp.buf.remove_workspace_folder, opts)
vim.keymap.set('n', '<leader>wr', vim.lsp.buf.rename, opts)

local vimrc = vim.fn.expand(vimdir) .. '/vimrc'
if vim.loop.fs_stat(vimrc) then
  vim.fn.execute('source ' .. vimrc)
end