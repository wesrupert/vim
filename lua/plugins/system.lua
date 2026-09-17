local util = require("util")

---@type string[]
local close_diff_editor_cmds = {}

local function close_diff_editors()
  for _, cmd in ipairs(close_diff_editor_cmds) do
    vim.cmd(cmd)
  end
end

return {
  { "tpope/vim-repeat", lazy = false, priority = 999 },
  { "Zeioth/garbage-day.nvim", event = "VeryLazy" },
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
  { "rafikdraoui/jj-diffconflicts" },
  {
    "janbuchar/difftsigns.nvim",
    dependencies = {
      {
        "lewis6991/gitsigns.nvim",
        opts = {
          on_attach = function (bufnr)
            local gitsigns = require("gitsigns")
            util.keymap({
              { "]]", desc = "[GitSigns] Next hunk", function () gitsigns.nav_hunk("next") end },
              { "[[", desc = "[GitSigns] Prev hunk", function () gitsigns.nav_hunk("prev") end },
              { "ghr", desc = "[GitSigns] Reset hunk", mode = "x", function () gitsigns.reset_hunk({ vim.fn.line("."), vim.fn.line("v") }) end },
              { '<leader>db', desc = "[GitSigns] Toggle blame", gitsigns.toggle_current_line_blame },
              { '<leader>dw', desc = "[GitSigns] Toggle word diff",gitsigns.toggle_word_diff },
              { 'ah', desc = "[GitSigns] Hunk Textobject", mode = {'o', 'x'}, gitsigns.select_hunk },
            }, bufnr)
          end,
        },
      },
    },
    event = "VeryLazy",
    keys = { ---@type KeysSpec[]
      { "<leader>dk", desc = "[Difft] Preview Hunk", function () require("difftsigns").preview() end },
      { "]g", desc = "[Difft] Preview Hunk", function () require("difftsigns").preview() end },
      { "<leader>dK", desc = "[Difft] Hunk Status", function () require("difftsigns").status() end },
    },
  },
  {
    "plomp4/draven.nvim",
    cmd = { "Draven", "DravenToggle", "DravenStatus" },
    keys = { ---@type KeysSpec[]
      { "<leader>dr", desc = "[Draven] Open review", [[<cmd>Draven<cr>]] },
    },
    opts = {
      keymaps = {
        next_hunk       = "]]",
        prev_hunk       = "[[",
        mark_hunk       = "ghg",
        unmark_hunk     = "ghu",
        comment         = "ghc",
        toggle_resolved = "ght",
        toggle_finding  = "ghv",
        delete_finding  = "ghx",
        list_findings   = "ghq",
        toggle_panel    = "<a-e>",
        export          = "<leader>dy",
        delta           = "<leader>dd",
        refresh         = "<leader>dR",
      },
    },
    config = function (_, opts)
      require("draven").setup(opts)
      table.insert(close_diff_editor_cmds, "DravenClose")

      util.keymap({
        { "<leader>dX", desc = "[Draven] Reset", [[<cmd>DravenReset<cr>]] },
        { "<leader>dx", desc = "[Diff] Close", close_diff_editors },
        { "ZD",         desc = "[Diff] Close", close_diff_editors },
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
      table.insert(close_diff_editor_cmds, "DiffviewClose")

      util.keymap({
        { "<leader>dR", desc = "[DiffView] Refresh", [[<cmd>DiffviewRefresh<cr>]] },
        { "<leader>dx", desc = "[Diff] Close", close_diff_editors },
        { "ZD",         desc = "[Diff] Close", close_diff_editors },
      })
    end,
  },
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