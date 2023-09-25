return {
  {
    'nvim-telescope/telescope.nvim',
    event = 'VeryLazy',
    enabled = vim.g.vscode ~= 1,
    dependencies = { 'nvim-telescope/telescope-ui-select.nvim' },
    config = function (_, opts)
      local telescope = require('telescope')
      telescope.setup(opts)
      telescope.load_extension('ui-select')
    end,
    opts = function()
      local telescope_config = require('telescope.config')
      local vimgrep_arguments = { unpack(telescope_config.values.vimgrep_arguments) }
      table.insert(vimgrep_arguments, '--hidden')
      table.insert(vimgrep_arguments, '--glob')
      table.insert(vimgrep_arguments, '!.git/*')
      return {
        defaults = { vimgrep_arguments = vimgrep_arguments },
        pickers = {
          find_files = {
            find_command = { 'rg', '--files', '--hidden', '--glob', '!.git/*' },
          },
        },
      }
    end,
    init = function ()
      vim.keymap.set('n', 'g/', require('telescope.builtin').grep_string)
      vim.keymap.set('n', 'gP', require('telescope.builtin').git_status)
      vim.keymap.set('n', 'gb', require('telescope.builtin').buffers)
      vim.keymap.set('n', 'gc', require('telescope.builtin').git_bcommits)
      vim.keymap.set('n', 'gC', function() require('telescope.builtin').colorscheme({ enable_preview = true }) end)
      vim.keymap.set('n', 'gh', '<cmd>Telescope<cr>')
      vim.keymap.set('n', 'gp', require('telescope.builtin').find_files)
      vim.keymap.set('n', 'z/', require('telescope.builtin').search_history)
      vim.keymap.set('n', 'z;', require('telescope.builtin').command_history)
      vim.keymap.set('n', 'zp', require('telescope.builtin').oldfiles)
    end,
  },
}