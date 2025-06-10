return {
  "folke/snacks.nvim",
  priority = 1000,
  lazy = false,
  opts = {
    bufdelete = { enabled = true },
    git = { enabled = true },
    gitbrowse = { enabled = true },
    statuscolumn = { enabled = true },
    terminal = { enabled = true },
    notifier = { enabled = false, style = "fancy" },
    picker = {
      matcher = {
        cwd_bonus = true,
        frecency = true,
        history_bonus = true,
      },
      jump = { reuse_win = true },
    },
  },
  config = function (_, opts)
    local snacks = require("snacks")
    local util = require("util")

    opts.picker.kind_icons = vim.tbl_map(function (v) return v .. " " end, util.kind_icons)
    snacks.setup(opts)

    vim.print = snacks.debug.inspect -- Override print to use snacks for `:=` command
    util.keymap("<leader>m", "[Snacks] Show messages",     snacks.notifier.show_history)
    util.keymap("<c-`>", "[Snacks] Toggle terminal",       snacks.terminal.toggle)
    util.keymap("<c-`>", "[Snacks] Toggle terminal",       snacks.terminal.toggle, { "t" })
    util.keymap("[g",    "[Snacks] Blame current line",    snacks.git.blame_line)
    util.keymap("gss",   "[Snacks] Scratch buffer",        function () snacks.scratch() end)
    util.keymap("gsS",   "[Snacks] Pick Scratch buffer",   snacks.scratch.select)
    util.keymap("gol",   "[Snacks] Open lazygit",          snacks.lazygit.open)
    util.keymap("gox",   "[Snacks] Open on remote",        snacks.gitbrowse.open)
    util.keymap("goX",   "[Snacks] Open branch on remote", function ()
      vim.ui.input({ prompt = "Choose a branch: ", default = "master" }, function(branch)
        snacks.gitbrowse.open({
          url_patterns = { ["github.com"] = { branch = "/tree/"..branch, file = "/blob/"..branch.."/{file}#L{line}" } }
        })
      end)
    end)

    util.keymap ("<leader>bd", "[Snacks] Delete buffer", function () snacks.bufdelete() end)
    vim.api.nvim_create_user_command("BD", function () snacks.bufdelete() end, {})
    vim.api.nvim_create_user_command("BOnly", snacks.bufdelete.other, {})

    vim.api.nvim_create_user_command(
      "Pick",
      function (input)
        local name, local_opts = util.command_parse_fargs(input.fargs)
        local f = snacks.picker[name or "pickers"]
        if f == nil then error('There is no Snacks picker named "' .. name .. '%s".', 0) end
        f(local_opts)
      end,
      {
        desc = "Open picker",
        nargs = "*",
        complete = function(_, line, col)
          local prefix_from, prefix_to, prefix = string.find(line, '^%S+%s+(%S*)')
          if col < prefix_from or prefix_to < col then return {} end
          local candidates = vim.tbl_filter(
            function(x) return tostring(x):find(prefix, 1, true) ~= nil end,
            vim.tbl_keys(snacks.picker)
          )
          table.sort(candidates)
          return candidates
        end,
      }
    )

    util.keymap("<c-p>", "[Snacks] Files (cwd)",   snacks.picker.smart)
    util.keymap("<a-p>", "[Snacks] Recent files",  snacks.picker.recent)
    util.keymap("<c-;>", "[Snacks] Commands",      snacks.picker.command_history)
    util.keymap("<a-e>", "[Snacks] Explorer",      snacks.picker.explorer)
    util.keymap("<a-b>", "[Snacks] Buffers",       snacks.picker.buffers)
    util.keymap("<c-/>", "[Snacks] Find",          snacks.picker.grep)
    util.keymap("<a-/>", "[Snacks] Searches",      snacks.picker.search_history)
    util.keymap("<c-g>", "[Snacks] Git hunks",     snacks.picker.git_diff)
    util.keymap("<a-g>", "[Snacks] Git branches",  snacks.picker.git_branches)
    util.keymap("<a-t>", "[Snacks] Treesitter",    snacks.picker.treesitter)
    util.keymap("<a-o>", "[Snacks] Jumplist",      snacks.picker.jumps)
    util.keymap("<a-u>", "[Snacks] Changelist",    snacks.picker.undo)
    util.keymap("<a-q>", "[Snacks] Location list", snacks.picker.loclist)
    util.keymap("<c-q>", "[Snacks] Quickfix",      snacks.picker.qflist)
    util.keymap("<c-k>", "[Snacks] Keymaps",       snacks.picker.keymaps)
    util.keymap("<a-w>", "[Snacks] Workspaces",    snacks.picker.projects)
    util.keymap('<c-">', "[Snacks] Marks",         snacks.picker.marks)
    util.keymap("z=",    "[Snacks] Spellcheck",    snacks.picker.spelling)

    require("util.lsp").on_attach(function (_, bufnr)
      util.keymap("gd",  "[Snacks] Definition",      snacks.picker.lsp_definitions,       nil, bufnr)
      util.keymap("grc", "[Snacks] LSP Config",      snacks.picker.lsp_config,            nil, bufnr)
      util.keymap("grr", "[Snacks] References",      snacks.picker.lsp_references,        nil, bufnr)
      util.keymap("gO",  "[Snacks] Symbols",         snacks.picker.lsp_symbols,           nil, bufnr)
      util.keymap("gri", "[Snacks] Implementations", snacks.picker.lsp_implementations,   nil, bufnr)
      util.keymap("gr/", "[Snacks] Symbols",         snacks.picker.lsp_workspace_symbols, nil, bufnr)
    end)
  end,
}