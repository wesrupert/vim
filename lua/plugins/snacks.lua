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

    util.keymap({
      { "<leader>m",  desc = "[Snacks] Show messages",       snacks.notifier.show_history       },
      { "[g",         desc = "[Snacks] Blame current line",  snacks.git.blame_line              },
      { "<leader>ss", desc = "[Snacks] Scratch buffer",      function () snacks.scratch() end   },
      { "<leader>sS", desc = "[Snacks] Pick Scratch buffer", snacks.scratch.select              },
      { "gox",        desc = "[Snacks] Open on remote",      snacks.gitbrowse.open              },
      { "<leader>bd", desc = "[Snacks] Delete buffer",       function () snacks.bufdelete() end },
      { "<c-p>",      desc = "[Snacks] Files (cwd)",         snacks.picker.smart                },
      { "<a-p>",      desc = "[Snacks] Recent files",        snacks.picker.recent               },
      { "<c-;>",      desc = "[Snacks] Commands",            snacks.picker.command_history      },
      { "<a-e>",      desc = "[Snacks] Explorer",            snacks.picker.explorer             },
      { "<a-b>",      desc = "[Snacks] Buffers",             snacks.picker.buffers              },
      { "<a-/>",      desc = "[Snacks] Find",                snacks.picker.grep                 },
      { "<a-\\>",     desc = "[Snacks] Searches",            snacks.picker.search_history       },
      { "<c-g>",      desc = "[Snacks] Git hunks",           snacks.picker.git_diff             },
      { "<a-g>",      desc = "[Snacks] Git branches",        snacks.picker.git_branches         },
      { "<a-t>",      desc = "[Snacks] Treesitter",          snacks.picker.treesitter           },
      { "<a-o>",      desc = "[Snacks] Jumplist",            snacks.picker.jumps                },
      { "<a-q>",      desc = "[Snacks] Location list",       snacks.picker.loclist              },
      { "<a-q>",      desc = "[Snacks] Quickfix",            snacks.picker.qflist               },
      { "<a-k>",      desc = "[Snacks] Keymaps",             snacks.picker.keymaps              },
      { "<a-w>",      desc = "[Snacks] Workspaces",          snacks.picker.projects             },
      { "z=",         desc = "[Snacks] Spellcheck",          snacks.picker.spelling             },
      { "<c-`>",      desc = "[Snacks] Toggle terminal",     snacks.terminal.toggle, mode = { "n", "i", "t" } },
      {
        "goX",        desc = "[Snacks] Open branch on remote",
        function ()
          vim.ui.input(
            { prompt = "Choose a branch: ", default = "master" },
            function (branch) snacks.gitbrowse.open({ branch = branch }) end
          )
        end,
      },
    })

    require("util.lsp").on_attach(function (bufnr)
      util.keymap({
        { "gd",  desc = "[LSP:snacks] Definition",        snacks.picker.lsp_definitions       },
        { "grr", desc = "[LSP:snacks] References",        snacks.picker.lsp_references        },
        { "gO",  desc = "[LSP:snacks] Symbols",           snacks.picker.lsp_symbols           },
        { "gr/", desc = "[LSP:snacks] Workspace Symbols", snacks.picker.lsp_workspace_symbols },
      }, bufnr)
    end)

    vim.api.nvim_create_user_command("Terminal", function (ev) snacks.terminal.toggle(ev.args) end, { nargs = "*" })
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

    -- Helper for at-a-glance diff of current work
    vim.api.nvim_create_user_command(
      "DiffWorkspace",
      function (args)
        snacks.terminal.toggle("zsh -i -c 'jj diff "..args.args.."'", {
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
  end,
}
