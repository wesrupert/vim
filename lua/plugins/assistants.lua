local util = require("util")

return {
  {
    "folke/sidekick.nvim",
    opts = {
      cli = {
        mux = {
          backend = "zellij",
          enabled = true,
        },
      },
    },
    config = function (opts)
      local sidekick = require("sidekick")
      local sidekick_cli = require("sidekick.cli")

      sidekick.setup(opts)

      local function sidekick_cli_send(msg) return function () sidekick_cli.send({ msg = msg }) end end
      local function sidekick_cli_toggle(include_uninstalled)
        return include_uninstalled
          and function () sidekick_cli.toggle() end
          or function () sidekick_cli.toggle({ filter = { installed = true } }) end
      end

      util.on_buf_is_ai_allowed("[Sidekick] Create user mappings", function (bufnr)
        util.keymap({
          { "<a-l>", desc = "[Sidekick] Toggle",         mode = { "t", "i", "n", "x" }, sidekick_cli_toggle()  },
          { "gll",   desc = "[Sidekick] Toggle",         mode = { "n", "x" }, sidekick_cli_toggle()            },
          { "glL",   desc = "[Sidekick] Select prompt",  mode = { "n", "x" }, sidekick_cli.prompt              },
          { "glc",   desc = "[Sidekick] Select CLI",                          sidekick_cli_toggle(true),       },
          { "glx",   desc = "[Sidekick] Detach CLI",                          sidekick_cli.close,              },
          { "glg",   desc = "[Sidekick] Send this",                           sidekick_cli_send("{this}")      },
          { "glg",   desc = "[Sidekick] Send selection", mode = "x",          sidekick_cli_send("{selection}") },
          { "glf",   desc = "[Sidekick] Send file",                           sidekick_cli_send("{file}")      },
          { "<tab>", desc = "[Sidekick] Goto/Apply NES", expr = true,         function ()
            if sidekick.nes_jump_or_apply() then return end
            if vim.lsp.inline_completion.get() then return end
            return "<tab>"
          end },
        }, bufnr)
      end)
    end,
    specs = {
      {
        "saghen/blink.cmp",
        optional = true,
        ---@module "blink.cmp"
        ---@type blink.cmp.Config
        opts = {
          keymap = {
            ["<tab>"] = {
              "snippet_forward",
              function () return require("sidekick").nes_jump_or_apply() end,
              function () return vim.lsp.inline_completion.get() end,
              "fallback",
            },
          },
        },
      },
      {
        "folke/snacks.nvim",
        optional = true,
        opts = {
          picker = {
            actions = {
              sidekick_send = function (...) return require("sidekick.cli.picker.snacks").send(...) end,
            },
            win = {
              input = {
                keys = {
                  ["<a-a>"] = { "sidekick_send", mode = { "n", "i" } },
                },
              },
            },
          },
        },
      },
      {
        "nvim-lualine/lualine.nvim",
        optional = true,
        dependencies = { "andrem222/copilot-lualine" },
        opts = function (_, opts)
          opts.sections = opts.sections or {}
          opts.sections.lualine_x = opts.sections.lualine_x or { "filetype" }

          -- Copilot status
          table.insert(opts.sections.lualine_x, 1, {
            "copilot",
            symbols = { spinners = "dots" },
            color = function ()
              local status = require("sidekick.status").get()
              if not status then return nil end
              if status.kind == "Error" then return "DiagnosticError" end
              if status.busy then return "DiagnosticWarn" end
              return "Special"
            end,
            cond = function () return #require("sidekick.status").cli() == 0 end,
          })

          -- CLI session status
          table.insert(opts.sections.lualine_x, 1, {
            function ()
              local status = require("sidekick.status").cli()
              return " " .. (#status > 1 and #status or "")
            end,
            cond = function () return #require("sidekick.status").cli() > 0 end,
            color = function () return "Special" end,
          })
        end,
      },
    },
  },
  {
    "zbirenbaum/copilot.lua",
    event = "InsertEnter",
    opts = function ()
      return {
        copilot_node_command = util.tools.node.path ~= ""
          and vim.fs.find("node", { type = "file", path = util.tools.node.path })
          or "node",
        suggestion = { enabled = false },
        panel = { enabled = false },
        ---@module "copilot"
        ---@type ShouldAttachFunc
        should_attach = function (bufnr, bufname)
          local should_attach_default = require("copilot.config.should_attach").default
          if should_attach_default(bufnr, bufname) == false then return false end
          return util.buf_is_ai_allowed(bufnr, bufname)
        end,
      }
    end,
    specs = {
      {
        "saghen/blink.cmp",
        optional = true,
        dependencies = { "giuxtaposition/blink-cmp-copilot" },
        ---@type fun(_, opts?: blink.cmp.Config): blink.cmp.Config
        opts = function (_, opts)
          local sources_default = vim.tbl_get(opts or {}, "sources", "default") or {}
          local completion_draw = vim.tbl_get(opts or {}, "completion", "menu", "draw", "treesitter") or {}
          table.insert(sources_default, 1, "copilot")
          table.insert(completion_draw, 1, "copilot")
          return util.merge(opts or {}, {
            sources = {
              default = sources_default,
              providers = { copilot = { name = "Copilot", module = "blink-cmp-copilot", async = true, score_offset = 100 } },
            },
            completion = { menu = { draw = { treesitter = completion_draw } } },
          })
        end,
      },
    },
  },
}