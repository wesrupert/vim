return {
  "folke/snacks.nvim",
  priority = 1000,
  lazy = false,
  ---@module "snacks"
  ---@type snacks.Config
  opts = {
    bufdelete = { enabled = true },
    git = { enabled = true },
    gitbrowse = { enabled = true },
    statuscolumn = { enabled = true },
    terminal = {
      enabled = true,
      win = {
        backdrop = false,
      },
    },
    notifier = { enabled = false },
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
    util._keymap("<leader>m",  "[Snacks] Show messages",         snacks.notifier.show_history)
    util._keymap("[g",         "[Snacks] Blame current line",    snacks.git.blame_line)
    util._keymap("<leader>ss", "[Snacks] Scratch buffer",        function () snacks.scratch() end)
    util._keymap("<leader>sS", "[Snacks] Pick Scratch buffer",   snacks.scratch.select)
    util._keymap("gox",        "[Snacks] Open on remote",        snacks.gitbrowse.open)
    util._keymap("goX",        "[Snacks] Open branch on remote", function ()
      vim.ui.input({ prompt = "Choose a branch: ", default = "master" }, function (branch) snacks.gitbrowse.open({ branch = branch }) end)
    end)

    util._keymap("<c-`>", "[Snacks] Toggle terminal",       snacks.terminal.toggle, { "n", "i", "t" })
    vim.api.nvim_create_user_command("Terminal", function (ev) snacks.terminal.toggle(ev.args) end, { nargs = "*" })

    util._keymap ("<leader>bd", "[Snacks] Delete buffer", function () snacks.bufdelete() end)
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
          local prefix_from, prefix_to, prefix = string.find(line, "^%S+%s+(%S*)")
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

  -- Helper for 'diff-pr' util
  vim.api.nvim_create_user_command(
    "DiffPr",
    function (args)
      snacks.terminal.toggle("zsh -i -c 'diff-pr "..args.args.."'", {
        interactive = true,
        start_insert = true,
        cwd = vim.fn.getcwd(),
        win = {
          style = "terminal",
          position = "right",
          height = 0.4,
          width = 0.4,
          enter = true,
          fixbuf = true,
          keys = {
            gf = function (self)
              local r = vim.fn.expand("<cfile>")
              local p = vim.fn.substitute(r, "^[ab]/", "", "")
              local f = vim.fn.findfile(p, "**")
              if f == "" then
                Snacks.notify.warn("No file under cursor")
              else
                self:hide()
                vim.schedule(function()
                  vim.cmd("e " .. f)
                end)
              end
            end,
          },
        },
      })
    end,
    { nargs = "*", desc = "Open a diff-pr session" }
  )

    util._keymap("<c-p>", "[Snacks] Files (cwd)",   snacks.picker.smart)
    util._keymap("<a-p>", "[Snacks] Recent files",  snacks.picker.recent)
    util._keymap("<c-;>", "[Snacks] Commands",      snacks.picker.command_history)
    util._keymap("<a-e>", "[Snacks] Explorer",      snacks.picker.explorer)
    util._keymap("<a-b>", "[Snacks] Buffers",       snacks.picker.buffers)
    util._keymap("<a-/>", "[Snacks] Find",          snacks.picker.grep)
    util._keymap("<a-\\>","[Snacks] Searches",      snacks.picker.search_history)
    util._keymap("<c-g>", "[Snacks] Git hunks",     snacks.picker.git_diff)
    util._keymap("<a-g>", "[Snacks] Git branches",  snacks.picker.git_branches)
    util._keymap("<a-t>", "[Snacks] Treesitter",    snacks.picker.treesitter)
    util._keymap("<a-o>", "[Snacks] Jumplist",      snacks.picker.jumps)
    util._keymap("<a-q>", "[Snacks] Location list", snacks.picker.loclist)
    util._keymap("<a-q>", "[Snacks] Quickfix",      snacks.picker.qflist)
    util._keymap("<a-k>", "[Snacks] Keymaps",       snacks.picker.keymaps)
    util._keymap("<a-w>", "[Snacks] Workspaces",    snacks.picker.projects)
    util._keymap("z=",    "[Snacks] Spellcheck",    snacks.picker.spelling)

    require("util.lsp").on_attach(function (bufnr)
      util._keymap("gd",  "[Snacks] Definition",        snacks.picker.lsp_definitions,       nil, bufnr)
      util._keymap("grr", "[Snacks] References",        snacks.picker.lsp_references,        nil, bufnr)
      util._keymap("gO",  "[Snacks] Symbols",           snacks.picker.lsp_symbols,           nil, bufnr)
      util._keymap("gr/", "[Snacks] Workspace Symbols", snacks.picker.lsp_workspace_symbols, nil, bufnr)
    end)
  end,
}