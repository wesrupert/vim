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
      -- Careful not to collide with the pickers in mini.pick!
      local builtin = require('telescope.builtin')
      vim.keymap.set('n', 'gob', builtin.buffers, { desc = '[Telescope] Buffers' })
    end,
  },
}