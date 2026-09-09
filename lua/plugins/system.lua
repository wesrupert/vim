local util = require("util")

return {
  { "tpope/vim-repeat", lazy = false, priority = 999 },
  {
    "wesrupert/filler-begone.nvim",
    dev = true,
    init = function ()
      -- Only enable in floating windows
      vim.api.nvim_create_autocmd({ "WinNew", "BufNew", "BufWinEnter" }, {
        pattern = "*",
        group = vim.api.nvim_create_augroup("UserFillerBegoneConfig", { clear = true }),
        desc = "[FillerBegone] Only enable for some window types",
        callback = function ()
          -- Enable in floating windows
          local winnr = vim.api.nvim_get_current_win()
          local win_config = vim.api.nvim_win_get_config(winnr)
          if win_config.relative ~= "" or win_config.external then return end

          -- Enable in terminal buffers
          local bufnr = vim.api.nvim_win_get_buf(winnr)
          if vim.bo[bufnr].buftype == "terminal" then return end

          vim.w[winnr].filler_begone = false
        end,
      })
    end,
  },
  { "nvim-mini/mini.trailspace", config = true },
  {
    "nvim-mini/mini.visits",
    config = function(_, opts)
      local visits = require("mini.visits")
      visits.setup(opts)
      util.keymap({
        { "gov", desc = "[Mini:visits] Add label",    visits.add_label    },
        { "goV", desc = "[Mini:visits] Remove label", visits.remove_label },
      })
    end,
  },
  {
    "nvim-mini/mini.bufremove",
    config = function(_, opts)
      local bufremove = require("mini.bufremove")
      bufremove.setup(opts)
      util.keymap({
        { "<leader>zq", desc = "[Mini:bufremove] Close buffer",          bufremove.delete                                     },
        { "<leader>zz", desc = "[Mini:bufremove] Save and close buffer", function () vim.cmd("write") bufremove.delete() end, }
      })
    end,
  },
  {
    "nvim-mini/mini.diff",
    dependencies = { "https://tangled.org/ronshavit.com/mini.diff.jj" },
    lazy = false,
    keys = { ---@type KeysSpec[]
      { "]g", desc = "[Mini:diff] Toggle overlay", function () require("mini.diff").toggle_overlay(0) end },
    },
    opts = function ()
      return {
        view = {
          signs = { add = "┃", change = "┃", delete = "┃" },
        },
        mappings = {
          textobject = "ah",
          apply = "gha",
          reset = "ghr",
          goto_first = "ghg",
          goto_last = "ghG",
        },
        options = {
          wrap_goto = true,
        },
        sources = { require("mini.diff.jj") }
      }
    end,
    init = function ()
      vim.api.nvim_create_autocmd({ "BufReadPre", "BufWrite" }, {
        group = vim.api.nvim_create_augroup("UserMiniDiffConfig", { clear = true }),
        callback = function (ev)
          local path = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(ev.buf), ":p")
          if vim.fs.find(".jj", { upward = true, type = "directory", path = path }) then
            -- Let jujutsu.nvim handle diff, it's better at it
            vim.b[ev.buf].minidiff_disable = true
          end
        end,
      })
    end,
  },
  {
    "sindrets/diffview.nvim",
    cmd = "DiffviewOpen",
    keys = { ---@type KeysSpec[]
      { "<leader>do", desc = "[DiffView] Open", [[<cmd>DiffviewOpen<cr>]] },
      { "<leader>dh", desc = "[DiffView] History", [[<cmd>DiffviewFileHistory<cr>]] },
    },
    opts = {
      keymaps = {
        view = {
          { "n", "<tab>",   false },
          { "n", "<s-tab>", false },
          { "n", "]f",    function () require("diffview.actions").select_next_entry() end, { desc = "[DiffView] Next file"     } },
          { "n", "[f",    function () require("diffview.actions").select_prev_entry() end, { desc = "[DiffView] Previous file" } },
          { "n", "<a-e>", function () vim.cmd([[DiffviewToggleFiles]]) end,                { desc = "[DiffView] Toggle files"  } },
          { "n", "<c-e>", function () vim.cmd([[DiffviewFocusFiles]]) end,                 { desc = "[DiffView] Focus files"   } },
        },
      },
      hooks = {
        ---@module "diffview"
        ---@type ListenerCallback
        view_opened = function (view)
          if(view.class:name() == "DiffView") then
            vim.schedule(function ()
              vim.cmd("wincmd l")
              vim.cmd("wincmd L")
            end)
          end
        end,
      },
    },
    config = function (_, opts)
      require("diffview").setup(opts)
      util.keymap({
        { "<leader>dr", desc = "[DiffView] Refresh", [[<cmd>DiffviewRefresh<cr>]] },
        { "<leader>dx", desc = "[DiffView] Close",   [[<cmd>DiffviewClose<cr>]] },
        { "ZD",         desc = "[DiffView] Close",   [[<cmd>DiffviewClose<cr>]] },
      })
    end,
    specs = {
      {
        "yannvanhalewyn/jujutsu.nvim",
        optional = true,
        opts = function (_, opts) return util.merge(opts or {}, { diff_preset = "diffview" }) end,
      },
    },
  },
  { "rafikdraoui/jj-diffconflicts" },
  {
    "nvim-mini/mini.indentscope",
    opts = {
      symbol = "│",
      options = { try_as_border = true },
    },
    init = function ()
      local ignore_buftypes, ignore_filetypes = util.get_special_types("indent")
      local user_mini_indent_scope_config = vim.api.nvim_create_augroup("UserMiniIndentScopeConfig", { clear = true })
      vim.api.nvim_create_autocmd({ "BufNew", "BufRead", "TermEnter", "FileType" }, {
        group = user_mini_indent_scope_config,
        callback = function ()
          if vim.tbl_contains(ignore_buftypes, vim.bo.buftype)
            or vim.tbl_contains(ignore_filetypes, vim.bo.filetype) then
            vim.b.miniindentscope_disable = true
          end
        end,
      })
      vim.api.nvim_create_autocmd("ColorScheme", {
        group = user_mini_indent_scope_config,
        callback = function ()
          vim.api.nvim_set_hl(0, "MiniIndentscopeSymbol", { link = "Comment", force = true })
        end,
      })
    end,
  },
}