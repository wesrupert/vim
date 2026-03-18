return {
  {
    "chrishrb/gx.nvim",
    keys = { { "gx", "<cmd>Browse<cr>", desc = "[GX] Opens filepath or URI under cursor with the system handler", mode = { "n", "x" } } },
    cmd = { "Browse" },
    init = function ()
      vim.g.netrw_nogx = 1 -- disable netrw gx
    end,
    opts = { plugin = true, github = true, package_json = true },
  },
  {
    "chrisgrieser/nvim-spider",
    config = function (_, opts)
      local spider = require("spider")
      spider.setup(opts)
      require("util").keymap("[Spider]", {
        { "w",  "Word",                                       function () spider.motion("w") end  },
        { "o",  "Word", opts = { modes = { "o", "x" } },      function () spider.motion("w") end  },
        { "e",  "End",  opts = { modes = { "n", "o", "x" } }, function () spider.motion("e") end  },
        { "b",  "Back",                                       function () spider.motion("b") end  },
        { "ge", "BEnd", opts = { modes = { "n", "o", "x" } }, function () spider.motion("ge") end },
      })
    end,
  },
  { "chentoast/marks.nvim", event = "VeryLazy", config = true },
  { "glts/vim-textobj-comment", dependencies = { "kana/vim-textobj-user" } },
  { "julienvincent/hunk.nvim", cmd = { "DiffEditor" }, config = true },
  {
    "nvim-mini/mini.ai",
    dependencies = { "nvim-mini/mini.extra", "nvim-mini/mini.icons" },
    opts = function ()
      local gen_ts_spec = require("mini.ai").gen_spec.treesitter
      local gen_ai_spec = require("mini.extra").gen_ai_spec
      return {
        mappings = {
          goto_left = "<leader>k",
          goto_right = "<leader>j",
        },
        custom_textobjects = {
          ["_"] = { "%b__", '^.().*().$' }, -- The 'abc' in 'xyz_abc_123'.
          ["l"] = gen_ai_spec.line(),
          ["n"] = gen_ai_spec.number(),
          ["d"] = gen_ai_spec.diagnostic(),
          ["s"] = { { "%b()", "%b[]", "%b{}" }, "^.().*().$" }, -- Relocate default "b" alias.
          ["b"] = gen_ts_spec({ a = "@block.outer", i = "@block.inner" }),
          ["f"] = gen_ts_spec({ a = "@function.outer", i = "@function.inner" }),
          ["a"] = gen_ts_spec({ a = "@parameter.outer", i = "@parameter.inner" }),
          ["r"] = gen_ts_spec({ a = "@return.outer", i = "@return.inner" }),
          [";"] = gen_ts_spec({ a = "@statement.outer", i = "@statement.inner" }),
          ["="] = gen_ts_spec({
            a = { "@assignment.lhs", "@assignment.outer" },
            i = { "@assignment.rhs", "@assignment.inner" },
          }),
          ["-"] = gen_ts_spec({
            a = { "@regex.outer", "@call.outer", "@conditional.outer", "@loop.outer", "@class.outer" },
            i = { "@regex.inner", "@call.inner", "@conditional.inner", "@loop.inner", "@class.inner" },
          }),
        },
      }
    end,
  },
  { "nvim-mini/mini.align", config = true },
  { "nvim-mini/mini.bracketed", opts = { treesitter = { suffix = "" --[[Let TreeWalker manage treesitter motions]] } } },
  { "nvim-mini/mini.jump", config = true },
  { "nvim-mini/mini.jump2d", config = true },
  { "nvim-mini/mini.move", config = true },
  {
    "nvim-mini/mini.operators",
    opts = {
      evaluate = { prefix = "g=" },
      exchange = { prefix = "g<tab>" },
      multiply = { prefix = "g+" },
      replace  = { prefix = "gor" },
      sort     = { prefix = "gos" },
    },
  },
  {
    "nvim-mini/mini.splitjoin",
    config = function ()
      local splitjoin = require("mini.splitjoin")
      local hook_opts = { brackets = { "%b{}" } }
      splitjoin.setup({
        split = {
          hooks_post = { splitjoin.gen_hook.add_trailing_separator(hook_opts) },
        },
        join = {
          hooks_post= {
            splitjoin.gen_hook.del_trailing_separator(hook_opts),
            splitjoin.gen_hook.pad_brackets(hook_opts),
          },
        },
      })
    end,
  },
  { "nvim-mini/mini.surround", opts = { search_method = "cover_or_next" }, config = true },
}