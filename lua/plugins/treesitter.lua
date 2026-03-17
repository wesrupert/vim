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
    config = function (_, opts)
      local tree_walker = require("treewalker")
      tree_walker.setup(opts or {})

      util.keymap("]n", "[TreeWalker] Move to next sibling", tree_walker.move_down, { "n", "v" }, nil, { silent = true })
      util.keymap("[n", "[TreeWalker] Move to prev sibling", tree_walker.move_up, { "n", "v" }, nil, { silent = true })
      util.keymap("]N", "[TreeWalker] Move to child", tree_walker.move_in, { "n", "v" }, nil, { silent = true })
      util.keymap("[N", "[TreeWalker] Move to parent", tree_walker.move_out, { "n", "v" }, nil, { silent = true })

      util.keymap("gsh", "[TreeWalker] Swap left", tree_walker.swap_left, "n", nil, { silent = true })
      util.keymap("gsj", "[TreeWalker] Swap down", tree_walker.swap_down, "n", nil, { silent = true })
      util.keymap("gsk", "[TreeWalker] Swap up", tree_walker.swap_up, "n", nil, { silent = true })
      util.keymap("gsl", "[TreeWalker] Swap right", tree_walker.swap_right, "n", nil, { silent = true })
    end,
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
      vim.iter({
        ["@statement.outer"]  = { n = "s", p = "S" },
        ["@block.inner"]      = { n = "b", p = "B" },
        ["@assignment.inner"] = { n = "=", p = "?" },
        ["@parameter.inner"]  = { n = "a", p = "A" },
      }):each(function (query, query_opts)
        util.keymap(
          "gs" .. query_opts.n,
          "[TreeSitter] Swap " .. query .. " forward",
          function () ts_to_swap.swap_next(query, query_opts.group) end
        )
        util.keymap(
          "gs" .. query_opts.p,
          "[TreeSitter] Swap " .. query .. " backward",
          function () ts_to_swap.swap_previous(query, query_opts.group) end
        )
      end)
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
    config = function (_, opts)
      local context = require("treesitter-context")
      context.setup(opts)
      local function go_to_context() context.go_to_context(vim.v.count1) end
      util.keymap("['", "[TreeSitter] Jump to context start", go_to_context, nil, nil, { silent = true })
    end,
    init = function ()
      vim.api.nvim_set_hl(0, "TreesitterContextBottom", { underline = true, sp = "Grey" })
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