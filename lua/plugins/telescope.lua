return {
  {
    'nvim-telescope/telescope.nvim',
    event = "VeryLazy",
    enabled = vim.g.vscode ~= 1,
    opts = function()
      local telescope_config = require('telescope.config')
      local vimgrep_arguments = { unpack(telescope_config.values.vimgrep_arguments) }
      table.insert(vimgrep_arguments, '--hidden')
      table.insert(vimgrep_arguments, '--glob')
      table.insert(vimgrep_arguments, '!.git/*')
      require'telescope'.setup {
        defaults = {
          vimgrep_arguments = vimgrep_arguments,
        },
        pickers = {
          find_files = {
            find_command = { 'rg', '--files', '--hidden', '--glob', '!.git/*' },
          },
        },
      }
    end,
  },
}