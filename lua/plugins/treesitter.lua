local util = require("util")
local setup_treesitter_plugin = function (name)
  return function (_, opts)
      ---@diagnostic disable-next-line: missing-fields
      require("nvim-treesitter.configs").setup({ [name] = opts })
    end
end

return {
  {
    "nvim-treesitter/nvim-treesitter",
    cmd = {
      "TSBufDisable", "TSBufEnable", "TSBufToggle", "TSDisable", "TSEnable", "TSToggle",
      "TSInstall", "TSInstallInfo", "TSInstallSync", "TSModuleInfo", "TSUninstall", "TSUpdate", "TSUpdateSync",
    },
    build = function() require("nvim-treesitter.install").update({ with_sync = true }) end,
    opts = {
      ensure_installed = {
        "c",
        "css",
        "html",
        "javascript",
        "jsdoc",
        "json",
        "lua",
        "markdown",
        "markdown_inline",
        "python",
        "query",
        "typescript",
        "vim",
        "vimdoc",
        "vue",
      },
      compilers = { "clang" },
      sync_install = false,
      auto_install = true,
      highlight = {
        enable = true,
        additional_vim_regex_highlighting = { "markdown" },
      },
      indent = { enable = true },
    },
    config = function (_, opts)
      require("nvim-treesitter.configs").setup(opts)
      require("vim.treesitter.query").add_predicate("is-mise?", function(_, _, bufnr, _)
        local filepath = vim.api.nvim_buf_get_name(tonumber(bufnr) or 0)
        local filename = vim.fn.fnamemodify(filepath, ":t")
        return string.match(filename, ".*mise.*%.toml$") ~= nil
      end, { force = true, all = false })

      vim.o.foldlevelstart = 999
      vim.o.foldlevel = 999
      vim.o.foldmethod = "expr"
      vim.o.foldexpr = "nvim_treesitter#foldexpr()"
    end,
  },
  {
    "nvim-treesitter/nvim-treesitter-textobjects",
    dependencies = { "nvim-treesitter/nvim-treesitter" },
    opts = {
      select = {
        enable = true,
        lookahead = true,
        keymaps = {
          ["if"] = "@function.inner",
          ["af"] = "@function.outer",
          ["ia"] = "@parameter.inner",
          ["aa"] = "@parameter.outer",
          ["is"] = "@block.outer",
          ["as"] = "@block.outer",
        },
        selection_modes = {
          ["@function.inner"] = "V", -- line-wise
          ["@function.outer"] = "V", -- line-wise
          ["@parameter.inner"] = "v", -- char-wise
          ["@parameter.outer"] = "v", -- char-wise
          ["@block.inner"] = "V", -- block-wise
          ["@block.outer"] = "V", -- block-wise
          ["@class.inner"] = "V", -- block-wise
          ["@class.outer"] = "V", -- block-wise
        },
      },
      move = {
        enable = true,
        set_jumps = true,
        goto_next_start = {
          ["]f"] = "@function.inner",
          ["]a"] = "@parameter.outer",
          ["]["] = "@block.inner",
        },
        goto_next_end = {
          ["]F"] = "@function.outer",
          ["]A"] = "@parameter.outer",
          ["]]"] = "@block.outer",
        },
        goto_previous_start = {
          ["[f"] = "@function.inner",
          ["[a"] = "@parameter.outer",
          ["[["] = "@block.inner",
        },
        goto_previous_end = {
          ["[F"] = "@function.outer",
          ["[A"] = "@parameter.outer",
          ["[]"] = "@block.outer",
        },
      },
      swap = {
        enable = true,
        swap_next = {
          ["gsf"] = "@function.outer",
          ["gsa"] = "@parameter.inner",
          ["gsb"] = "@block.inner",
        },
        swap_previous = {
          ["gsF"] = "@function.outer",
          ["gsA"] = "@parameter.inner",
          ["gsB"] = "@block.inner",
        },
      },
    },
    config = setup_treesitter_plugin("textobjects"),
  },
  {
    "nvim-treesitter/nvim-treesitter-context",
    dependencies = { "nvim-treesitter/nvim-treesitter" },
    opts = {
      multiwindow = true,
      max_lines = 3,
    },
    config = function (_, opts)
      local context = require("treesitter-context")
      context.setup(opts)
      local go_to_context = function () context.go_to_context(vim.v.count1) end
      util.keymap("[e", "[TreeSitter] Jump to context start", go_to_context, nil, nil, { silent = true })
    end,
    init = function ()
      vim.api.nvim_set_hl(0, "TreesitterContextBottom", { underline = true, sp = "Grey" })
    end,
  },
  {
    "drybalka/tree-climber.nvim",
    dependencies = { "nvim-treesitter/nvim-treesitter" },
    config = function ()
      local tree_climber = require("tree-climber")
      util.keymap("]n",  "[TreeSitter] Next sibling",   tree_climber.goto_next,   { "n", "v", "o" })
      util.keymap("[n",  "[TreeSitter] Prev sibling",   tree_climber.goto_prev,   { "n", "v", "o" })
      util.keymap("]N",  "[TreeSitter] Jump child",     tree_climber.goto_child,  { "n", "v", "o" })
      util.keymap("[N",  "[TreeSitter] Jump parent",    tree_climber.goto_parent, { "n", "v", "o" })
      util.keymap("an",  "[TreeSitter] Select node",    tree_climber.select_node, { "v", "o" })
      util.keymap("in",  "[TreeSitter] Select inner",   tree_climber.select_node, { "v", "o" })
      util.keymap("gss", "[TreeSitter] Swap next node", tree_climber.swap_next)
      util.keymap("gsS", "[TreeSitter] Swap prev node", tree_climber.swap_prev)
    end,
  },
  {
    "andymass/vim-matchup",
    dependencies = { "nvim-treesitter/nvim-treesitter" },
    opts = { enable = true },
    config = setup_treesitter_plugin("matchup"),
  },
  {
    "windwp/nvim-ts-autotag",
    dependencies = { "nvim-treesitter/nvim-treesitter" },
    opts = { enable = true },
    config = setup_treesitter_plugin("autotag"),
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
    spec = {
      {
        "numtostr/comment.nvim",
        opts = function ()
          return {
            -- Integrations module isn't created until plugin initialization, for some reason.
            -- Make sure to load it in a callback function, not a module-scoped object.
            -- See: https://github.com/JoosepAlviste/nvim-ts-context-commentstring/issues/58
            pre_hook = require("ts_context_commentstring.integrations.comment_nvim").create_pre_hook(),
          }
        end,
      },
    },
  },
}