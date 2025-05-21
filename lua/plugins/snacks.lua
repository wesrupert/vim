local util = require('util')
return {
  'folke/snacks.nvim',
  priority = 1000,
  lazy = false,
  opts = {
    bufdelete = { enabled = true },
    git = { enabled = true },
    gitbrowse = { enabled = true },
    statuscolumn = { enabled = true },
    terminal = { enabled = true },
    notifier = { enabled = false, style = 'fancy' },
    picker = {
      matcher = {
        cwd_bonus = true,
        frecency = true,
        history_bonus = true,
      },
      jump = { reuse_win = true },
      kind_icons = vim.tbl_map(function (v) return v .. ' ' end, util.kind_icons),
    },
  },
  config = function (_, opts)
    local snacks = require('snacks')
    snacks.setup(opts)

    local user_snacks_group = vim.api.nvim_create_augroup('UserSnacksConfig', { clear = true })

    vim.print = snacks.debug.inspect -- Override print to use snacks for `:=` command
    util.keymap('<leader>m', '[Snacks] Show messages',     snacks.notifier.show_history)
    util.keymap('<c-`>', '[Snacks] Toggle terminal',       snacks.terminal.toggle)
    util.keymap('<c-`>', '[Snacks] Toggle terminal',       snacks.terminal.toggle, { 't' })
    util.keymap('[g',    '[Snacks] Blame current line',    snacks.git.blame_line)
    util.keymap('gss',   '[Snacks] Scratch buffer',        function () snacks.scratch() end)
    util.keymap('gsS',   '[Snacks] Pick Scratch buffer',   snacks.scratch.select)
    util.keymap('gol',   '[Snacks] Open lazygit',          snacks.lazygit.open)
    util.keymap('gox',   '[Snacks] Open on remote',        snacks.gitbrowse.open)
    util.keymap('goX',   '[Snacks] Open branch on remote', function ()
      vim.ui.input({ prompt = 'Choose a branch: ', default = 'master' }, function(branch)
        snacks.gitbrowse.open({
          url_patterns = { ['github.com'] = { branch = '/tree/'..branch, file = '/blob/'..branch..'/{file}#L{line}' } }
        })
      end)
    end)

    util.keymap ('<leader>bd', '[Snacks] Delete buffer', function () snacks.bufdelete() end)
    vim.api.nvim_create_user_command('BD', function () snacks.bufdelete() end, {})
    vim.api.nvim_create_user_command('BOnly', snacks.bufdelete.other, {})

    util.keymap('<c-p>', '[Snacks] Files (cwd)',   snacks.picker.smart)
    util.keymap('<a-p>', '[Snacks] Recent files',  snacks.picker.recent)
    util.keymap('<c-;>', '[Snacks] Commands',      snacks.picker.command_history)
    util.keymap('<a-e>', '[Snacks] Explorer',      snacks.picker.explorer)
    util.keymap('<a-b>', '[Snacks] Buffers',       snacks.picker.buffers)
    util.keymap('<c-/>', '[Snacks] Find',          snacks.picker.grep)
    util.keymap('<a-/>', '[Snacks] Searches',      snacks.picker.search_history)
    util.keymap('<c-g>', '[Snacks] Git hunks',     snacks.picker.git_diff)
    util.keymap('<a-g>', '[Snacks] Git branches',  snacks.picker.git_branches)
    util.keymap('<a-t>', '[Snacks] Treesitter',    snacks.picker.treesitter)
    util.keymap('<a-o>', '[Snacks] Jumplist',      snacks.picker.jumps)
    util.keymap('<a-u>', '[Snacks] Changelist',    snacks.picker.undo)
    util.keymap('<a-q>', '[Snacks] Location list', snacks.picker.loclist)
    util.keymap('<c-q>', '[Snacks] Quickfix',      snacks.picker.qflist)
    util.keymap('<c-k>', '[Snacks] Keymaps',       snacks.picker.keymaps)
    util.keymap("<c-'>", '[Snacks] Marks',         snacks.picker.marks)
    util.keymap('z=',    '[Snacks] Spellcheck',    snacks.picker.spelling)

    vim.api.nvim_create_autocmd('LspAttach', {
      group = user_snacks_group,
      callback = function(ev)
        util.keymap('gd',  '[Snacks] Definition',      snacks.picker.lsp_definitions,       nil, ev.buf)
        util.keymap('grc', '[Snacks] LSP Config',      snacks.picker.lsp_config,            nil, ev.buf)
        util.keymap('grr', '[Snacks] References',      snacks.picker.lsp_references,        nil, ev.buf)
        util.keymap('gO',  '[Snacks] Symbols',         snacks.picker.lsp_symbols,           nil, ev.buf)
        util.keymap('gri', '[Snacks] Implementations', snacks.picker.lsp_implementations,   nil, ev.buf)
        util.keymap('gr/', '[Snacks] Symbols',         snacks.picker.lsp_workspace_symbols, nil, ev.buf)
      end,
    })
  end,
}