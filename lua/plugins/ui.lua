local util = require("util")

return {
  {
    "rachartier/tiny-cmdline.nvim",
    opts = function ()
      return {
        position = { y = "10%" },
        on_reposition = require("tiny-cmdline").adapters.blink,
      }
    end,
  },
  {
    "nvim-lualine/lualine.nvim",
    dependencies = {
      "nvim-tree/nvim-web-devicons",
      "yavorski/lualine-macro-recording.nvim",
      "wesrupert/altfile-lualine",
      "wesrupert/visual-lualine",
      "andrem222/copilot-lualine",
    },
    opts = function (_, opts)
      local function mini_sessions_name()
        local s = vim.g.mini_sessions_current
        if not s then return "" end
        return s.type == "global" and s.name or vim.fn.fnamemodify(s.path, ":p:h:t")
      end

      local function overseer_component()
        local overseer = require("overseer")
        local STATUS = overseer.STATUS

        local tasks = overseer.list_tasks()
        local running = 0
        local success = 0
        local failure = 0

        for _, task in ipairs(tasks) do
          if task.status == STATUS.RUNNING then
            running = running + 1
          elseif task.status == STATUS.SUCCESS then
            success = success + 1
          elseif task.status == STATUS.FAILURE then
            failure = failure + 1
          end
        end

        local parts = {}
        if running > 0 then
          table.insert(parts, string.format("⚙ %d", running))
        end
        if failure > 0 then
          table.insert(parts, string.format("✗ %d", failure))
        end
        if success > 0 then
          table.insert(parts, string.format("✓ %d", success))
        end

        if #parts == 0 then
          return ""
        end
        return table.concat(parts, " ")
      end

      -- Prepend opts to merge overridden specs properly.
      return util.merge({
        sections = {
          lualine_a = { "mode", "macro_recording" },
          lualine_c = { "%n", "filename" },
          lualine_x = { "filetype" },
          lualine_z = { "location", "visual" },
        },
        inactive_sections = {
          lualine_c = { "%n", "filename" },
          lualine_x = {},
        },
        tabline = {
          lualine_a = { "require'util'.kind_icons.NeoVim", mini_sessions_name, overseer_component },
          lualine_b = { { "tabs", mode = 2, use_mode_colors = true } },
          lualine_x = { { "altfile", path = 1, symbols = { separator = "󰘵 " } } },
          lualine_z = { { "filename", path = 1 } },
        },
      }, opts or {})
    end,
  },
  {
    "bekaboo/dropbar.nvim",
    dependencies = {
      "nvim-telescope/telescope-fzf-native.nvim",
      build = "make",
    },
    opts = {
      bar = {
        sources = function(buf, _)
          local sources = require("dropbar.sources")
          local utils = require("dropbar.utils")
          if vim.bo[buf].ft == "markdown" then
            return { sources.markdown }
          elseif vim.bo[buf].ft == "vue" then
            return { sources.lsp } -- Treesitter messes up the script/style tag symbols
          elseif vim.bo[buf].buftype == "terminal" then
            return { sources.terminal }
          end
          return { utils.source.fallback({ sources.lsp, sources.treesitter }) }
        end,
      },
      icons = { kinds = { symbols = vim.tbl_map(function (v) return v .. " " end, util.kind_icons) } },
    },
    config = function (_, opts)
      local dropbar = require("dropbar")
      local dropbar_api = require("dropbar.api")
      dropbar.setup(opts)

      util.keymap({
        { "g;", desc = "[TreeWalker] Pick symbol",   dropbar_api.pick                },
        { "[;", desc = "[TreeWalker] Context start", dropbar_api.goto_context_start  },
        { "];", desc = "[TreeWalker] Next context",  dropbar_api.select_next_context },
      })
    end,
  },
  {
    "folke/which-key.nvim",
    event = "VeryLazy",
    opts = {
      preset = "helix",
      sort = { "icase", "alphanum" },
    },
    config = function (_, opts)
      local which_key = require("which-key")
      local which_key_extras = require("which-key.extras")
      which_key.setup(opts)

      util.keymap({
        { "<leader>w", desc = "[WhichKey] Show keymaps",          which_key.show                                     },
        { "<leader>W", desc = "[WhichKey] Show keymaps (buffer)", function () which_key.show({ global = false }) end },
      })

      which_key.add({
        { "gb", group = "Buffers", expand = which_key_extras.expand.buf },
        { "gh", group = "History" },
        { "go", group = "Operate" },
        { "gr", group = "LSP" },
        { "gs", group = "Swap" },
      })

      which_key.add({
        { "]]", group = "[Mini.ai] Next" },
        { "[[", group = "[Mini.ai] Previous" },
      })
    end,
  },
  {
    "tummetott/reticle.nvim",
    event = "VeryLazy",
    opts = {
      always_highlight_number = true,
    },
  },
  { "axkirillov/hbac.nvim", config = true },
  {
    "folke/zen-mode.nvim",
    cmd = "ZenMode",
    keys = {
      { "gz", desc = "[Zen] Toggle", [[<cmd>ZenMode<cr>]] },
    },
    opts = { window = { width = 0.8, height = 0.9 } },
  },
  {
    "airblade/vim-rooter",
    init = function ()
      vim.g.rooter_cd_cmd = "lcd"
      vim.g.rooter_silent_chdir = 1
      vim.api.nvim_create_autocmd("User", {
        group = vim.api.nvim_create_augroup("UserRooter", { clear = true }),
        desc = "[Rooter] start in src when present",
        pattern = "RooterChDir",
        callback = function () pcall(vim.cmd.cd, "./src") end,
      })
    end,
  },
  { "conormcd/matchindent.vim" },
  {
    "alexghergh/nvim-tmux-navigation",
    opts = {
      disable_when_zoomed = true,
      keybindings = {
        left = "<c-h>",
        down = "<c-j>",
        up = "<c-k>",
        right = "<c-l>",
        last_active = "<c-\\>",
      },
    },
  },
}