return {
  {
    "chrishrb/gx.nvim",
    keys = {
      { "gx", desc = "[GX] Open external", mode = { "n", "x" }, "<cmd>Browse<cr>" },
    },
    cmd = { "Browse" },
    init = function ()
      vim.g.netrw_nogx = 1 -- disable netrw gx
    end,
    opts = {
      plugin = true,
      github = true,
      package_json = true,
    },
  },
  {
    "chrisgrieser/nvim-spider",
    keys = {
      { "w",  desc = "[Spider] Word",                            function () require("spider").motion("w") end  },
      { "o",  desc = "[Spider] Word", mode = { "o", "x" },      function () require("spider").motion("w") end  },
      { "e",  desc = "[Spider] End",  mode = { "n", "o", "x" }, function () require("spider").motion("e") end  },
      { "b",  desc = "[Spider] Back",                            function () require("spider").motion("b") end  },
      { "ge", desc = "[Spider] BEnd", mode = { "n", "o", "x" }, function () require("spider").motion("ge") end },
    },
    config = true,
  },
  { "chentoast/marks.nvim", event = "VeryLazy", config = true },
  { "glts/vim-textobj-comment", dependencies = { "kana/vim-textobj-user" } },
  { "julienvincent/hunk.nvim", cmd = { "DiffEditor" }, config = true },
  {
    "nvim-mini/mini.ai",
    dependencies = { "nvim-mini/mini.extra", "nvim-mini/mini.icons" },
    event = "VeryLazy",
    opts = function ()
      local gen_ts_spec = require("mini.ai").gen_spec.treesitter
      local gen_ai_spec = require("mini.extra").gen_ai_spec
      return {
        mappings = {
          goto_left = "<leader>h",
          goto_right = "<leader>l",
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
  { "nvim-mini/mini.align", event = "VeryLazy", config = true },
  { "nvim-mini/mini.bracketed", event = "VeryLazy", opts = { treesitter = { suffix = "" --[[Let TreeWalker manage treesitter motions]] } } },
  { "nvim-mini/mini.jump", event = "VeryLazy", opts = { mappings = { repeat_jump = "" } } },
  { "nvim-mini/mini.jump2d", event = "VeryLazy", config = true },
  { "nvim-mini/mini.move", event = "VeryLazy", opts = { mappings = { line_left = "", line_right = "" } } },
  {
    "nvim-mini/mini.operators",
    event = "VeryLazy",
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
  {
    "magicduck/grug-far.nvim",
    lazy = false,
    keys = {
      { "<c-f>", desc = "[GrugFAR] Open", "<cmd>GrugFar<cr>" },
      { "g/",    desc = "[GrugFAR] Open", "<cmd>GrugFar<cr>" },
    },
    opts = {
      engines = {
        ripgrep = {
          extraArgs = "--smart-case",
        },
      },
      keymaps = {
        help = { n = "g?" },
        close = { n = "q" },
        replace = { n = "gsr" },
        qflist = { n = "gsq" },
        syncLocations = { n = "gss" },
        syncLine = { n = "gsl" },
        historyOpen = { n = "gst" },
        historyAdd = { n = "gsa" },
        refresh = { n = "gsf" },
        openLocation = { n = "gso" },
        openNextLocation = { n = "<tab>" },
        openPrevLocation = { n = "<s-tab>" },
        gotoLocation = { n = "<enter>" },
        pickHistoryEntry = { n = "<enter>" },
        abort = { n = "gsb" },
        toggleShowCommand = { n = "gsw" },
        swapEngine = { n = "gse" },
        previewLocation = { n = "gsi" },
        swapReplacementInterpreter = { n = "gsx" },
        applyNext = { n = "gsj" },
        applyPrev = { n = "gsk" },
        syncNext = { n = "gsn" },
        syncPrev = { n = "gsp" },
        syncFile = { n = "gsv" },
        nextInput = { n = "<down>" },
        prevInput = { n = "<up>" },
      },
    },
  },
}