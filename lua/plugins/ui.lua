local util = require("util")

return {
  {
    "oxy2dev/ui.nvim",
    priority = 1000,
    lazy = false,
    opts = {
      popupmenu = { enabled = false },
      message = {
        ignore = function (kind, content)
          local ui_utils = require("ui.utils");
          local lines = ui_utils.process_content(content);

          -- Ignore the first message after :w
          if kind == "bufwrite" and string.match(lines[#lines], "written$") == nil then return true end

          -- Ignore inlay hint errors when deleting lines of text
          if string.match(lines[2], 'inlay_hint.*"col": out of range') then return true end

          -- Ignore vtsls inlay hints due to syntax tree errors
          -- HACK: See https://github.com/yioneko/vtsls/issues/159
          if string.match(lines[1], "textDocument/inlayHint failed.*TypeScript Server Error") then return true end

          return false
        end,
      },
    },
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
          lualine_a = { function () return util.kind_icons.NeoVim .. "  ".. (vim.g.mini_sessions_current or "") end },
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

      vim.ui.select = require("dropbar.utils.menu").select
      util.keymap("g;", "[Dropbar] Pick symbols in winbar", dropbar_api.pick)
      util.keymap("[;", "[Dropbar] Go to start of current context", dropbar_api.goto_context_start)
      util.keymap("];", "[Dropbar] Select next context", dropbar_api.select_next_context)
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

      util.keymap("<leader>w", "[Which-Key] Show keymaps", which_key.show)
      util.keymap("<leader>W", "[Which-Key] Show keymaps for buffer", function () which_key.show({ global = false }) end)

      which_key.add({
        { "gb", group = "Buffers", expand = which_key_extras.expand.buf },
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
  {
    "axkirillov/hbac.nvim",
    config = function (_, opts)
      local hbac = require("hbac")
      hbac.setup(opts)
      util.keymap("<leader>bp", "[Bufclose] Pin/Unpin", hbac.toggle_pin)
      util.keymap("<leader>bo", "[Bufclose] Close unpinned", hbac.close_unpinned)
      util.keymap("<leader>ba", "[Bufclose] Toggle autoclose", hbac.toggle_autoclose)
    end
  },
  {
    "folke/zen-mode.nvim",
    opts = { window = { width = 0.8, height = 0.9 } },
    config = function (_, opts)
      local zen_mode = require("zen-mode")
      zen_mode.setup(opts)
      util.keymap("gz", "[Zen mode] Toggle", zen_mode.toggle)
    end,
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