local util = require("util")

return {
  {
    "nvim-treesitter/nvim-treesitter",
    branch = "main",
    lazy = false,
    build = function () require("nvim-treesitter.install").update({ with_sync = true }) end,
  },
  {
    "wesrupert/ts-auto-install.nvim",
    dev = true,
    dependencies = { "nvim-treesitter/nvim-treesitter" },
    opts = {
      skip_approval = true,
      disable = { tmux = true },
      fold = { enable = true, start_unfolded = true },
      indent = { enable = { javascriptreact = false, typescriptreact = false } },
      syntax = { enable = { javascriptreact = true,  typescriptreact = true, markdown = true } },
    },
  },
  {
    "aaronik/treewalker.nvim",
    keys = {
      { "]n",  desc = "[TreeWalker] Move to next sibling", mode = { "n", "v" },  function() require("treewalker").move_down() end  },
      { "[n",  desc = "[TreeWalker] Move to prev sibling", mode = { "n", "v" },  function() require("treewalker").move_up() end    },
      { "]c",  desc = "[TreeWalker] Move to child",        mode = { "n", "v" },  function() require("treewalker").move_in() end    },
      { "[c",  desc = "[TreeWalker] Move to parent",       mode = { "n", "v" },  function() require("treewalker").move_out() end   },
      { "gsh", desc = "[TreeWalker] Swap left",                                  function() require("treewalker").swap_left() end  },
      { "gsj", desc = "[TreeWalker] Swap down",                                  function() require("treewalker").swap_down() end  },
      { "gsk", desc = "[TreeWalker] Swap up",                                    function() require("treewalker").swap_up() end    },
      { "gsl", desc = "[TreeWalker] Swap right",                                 function() require("treewalker").swap_right() end },
    },
    config = true,
  },
  {
    "nvim-treesitter/nvim-treesitter-textobjects",
    branch = "main",
    dependencies = { "nvim-treesitter/nvim-treesitter" },
    ---@module "nvim-treesitter-textobjects"
    ---@param opts TSTextObjects.UserConfig
    config = function (_, opts)
      local treesitter_textobjects = require("nvim-treesitter-textobjects")
      local ts_to_swap = require("nvim-treesitter-textobjects.swap")
      treesitter_textobjects.setup(opts)

      -- Set up swap keymaps (select/move keymaps are handled by mini.ai).
      util.keymap(vim.iter({
        { "@statement.outer",  n = "s", p = "S" },
        { "@block.inner",      n = "b", p = "B" },
        { "@assignment.inner", n = "=", p = "?" },
        { "@parameter.inner",  n = "a", p = "A" },
      }):map(function (o) return {
        { "gs" .. o.n, desc = "[TreeSitter] Swap " .. o[1] .. " forward",  function () ts_to_swap.swap_next    (o[1], o.group) end },
        { "gs" .. o.p, desc = "[TreeSitter] Swap " .. o[1] .. " backward", function () ts_to_swap.swap_previous(o[1], o.group) end },
      } end):flatten():totable())
    end,
  },
  {
    "nvim-treesitter/nvim-treesitter-context",
    dependencies = { "nvim-treesitter/nvim-treesitter" },
    opts = {
      multiwindow = true,
      mode = "topline",
      min_window_height = 20,
      max_lines = 5,
      separator = "─"
    },
    init = function ()
      vim.api.nvim_set_hl(0, "TreesitterContextBottom", { underline = true, sp = "Grey" })
    end,
    config = function (_, opts)
      local context = require("treesitter-context")
      context.setup(opts)
      util.keymap({ { "['", desc = "[TreeSitter] Context start", silent = true, function () context.go_to_context(vim.v.count1) end } })
    end,
  },
  {
    "andymass/vim-matchup",
    dependencies = { "nvim-treesitter/nvim-treesitter" },
    opts = { enable = true },
  },
  {
    "windwp/nvim-ts-autotag",
    dependencies = { "nvim-treesitter/nvim-treesitter" },
    config = true,
  },
  {
    "joosepalviste/nvim-ts-context-commentstring",
    opts = {
      enable_autocmd = false,
    },
    config = function (_, opts)
      require("ts_context_commentstring").setup(opts)
      local get_option = vim.filetype.get_option
      local calculate_commentstring = require("ts_context_commentstring.internal").calculate_commentstring
      ---@diagnostic disable-next-line: duplicate-set-field
      vim.filetype.get_option = function (filetype, option)
        return option == "commentstring" and calculate_commentstring() or get_option(filetype, option)
      end
    end,
    specs = {
      {
        "numtostr/comment.nvim",
        optional = true,
        opts = function (_, opts)
          return util.merge(opts or {}, {
            -- Integrations module isn't created until plugin initialization, for some reason.
            -- Make sure to load it in a callback function, not a module-scoped object.
            -- See: https://github.com/JoosepAlviste/nvim-ts-context-commentstring/issues/58
            pre_hook = require("ts_context_commentstring.integrations.comment_nvim").create_pre_hook(),
          })
        end,
      },
    },
  },
}
