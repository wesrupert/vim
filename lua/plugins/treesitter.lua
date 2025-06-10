local util = require("util")
local user_treesitter_config = vim.api.nvim_create_augroup("UserTreesitterConfig", { clear = true })

local setup_treesitter_plugin = function (name)
  return function (_, opts)
      ---@diagnostic disable-next-line: missing-fields
      require("nvim-treesitter.configs").setup({ [name] = opts })
    end
end

return {
  {
    "nvim-treesitter/nvim-treesitter",
    -- TODO: Update when the following issues are closed:
    -- - https://github.com/andymass/vim-matchup/pull/390
    -- branch = "main",
    cmd = {
      "TSBufDisable", "TSBufEnable", "TSBufToggle", "TSDisable", "TSEnable", "TSToggle",
      "TSInstall", "TSInstallInfo", "TSInstallSync", "TSModuleInfo", "TSUninstall", "TSUpdate", "TSUpdateSync",
    },
    build = function() require("nvim-treesitter.install").update({ with_sync = true }) end,
    opts = {
      sync_install = false,
      compilers = { "clang" },
      highlight = { enable = true }, -- TODO: Remove when updated to main branch
      indent = { enable = true }, -- TODO: Remove when updated to main branch
    },
    config = function (_, opts)
      local treesitter = require("nvim-treesitter")
      local treesitter_install = require("nvim-treesitter.install")
      local treesitter_parsers = require("nvim-treesitter.parsers").list
      local treesitter_query = require("vim.treesitter.query")

      treesitter.setup()
      require("nvim-treesitter.configs").setup(opts) -- TODO: Remove when updated to main branch

      -- Override toml parser when in mise configs to add injected language support.
      treesitter_query.add_predicate("is-mise?", function(_, _, bufnr, _)
        local filepath = vim.api.nvim_buf_get_name(tonumber(bufnr) or 0)
        local filename = vim.fn.fnamemodify(filepath, ":t")
        return string.match(filename, ".*mise.*%.toml$") ~= nil
      end, { force = true, all = false })

      -- Enable fold/indent expressions
      vim.o.foldlevelstart = 999
      vim.api.nvim_create_autocmd("FileType", {
        group = user_treesitter_config,
        callback = function (ev)
          local bufnr = ev.buf
          if not pcall(vim.treesitter.start, bufnr) then return end
          vim.bo[ev.buf].syntax = "off"
          vim.wo.foldlevel = 999
          vim.wo.foldmethod = "expr"
          vim.wo.foldexpr = "v:lua.vim.treesitter.foldexpr()"
          -- vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
        end,
      })

      -- Enable additional syntax highlighting for some filetypes.
      vim.api.nvim_create_autocmd("FileType", {
        group = user_treesitter_config,
        pattern = { "markdown" },
        callback = function (ev) vim.bo[ev.buf].syntax = "on" end,
      })

      -- Auto-install and start treesitter parser for any buffer with a registered filetype.
      local parser_install_attempted = {}
      vim.api.nvim_create_autocmd("BufWinEnter", {
        group = user_treesitter_config,
        callback = function (ev)
          local bufnr = ev.buf
          local filetype = vim.api.nvim_get_option_value("filetype", { buf = bufnr })
          if filetype == "" then return end

          -- Check if parser was already auto-installed to short-circuit additional checks
          if parser_install_attempted[filetype] ~= nil then return end

          -- Check if parser can be inferred and is available to install
          local parser_name = vim.treesitter.language.get_lang(filetype)
          if parser_name == nil then return end
          if not treesitter_parsers[parser_name] then return end

          local parser_installed = pcall(vim.treesitter.get_parser, bufnr, parser_name)
          if not parser_installed then
            vim.notify("Installing " .. parser_name .. " treesitter grammar for...")
            -- TODO: Use this version when updated to main branch
            -- treesitter.install({ parser_name }):wait(30000)
            treesitter_install.ensure_installed_sync(parser_name)
            parser_installed = pcall(vim.treesitter.get_parser, bufnr, parser_name)
            if parser_installed then vim.notify(parser_name .. " treesitter grammar installed!") end
          end

          if parser_installed then
            vim.treesitter.start(bufnr, parser_name)
          else
            vim.notify("Error installing " .. parser_name .. " treesitter grammar!", vim.diagnostic.severity.ERROR)
          end

          -- Either we installed it, or encountered an error trying.
          -- Either way, don't try again for this filetype this session.
          parser_install_attempted[filetype] = true
        end,
      })
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
      min_window_height = 20,
      max_lines = 5,
      line_numbers = false,
    },
    config = function (_, opts)
      local context = require("treesitter-context")
      context.setup(opts)
      local go_to_context = function () context.go_to_context(vim.v.count1) end
      util.keymap("['", "[TreeSitter] Jump to context start", go_to_context, nil, nil, { silent = true })
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
      util.keymap("],",  "[TreeSitter] Next sibling",   tree_climber.goto_next,   { "n", "v", "o" })
      util.keymap("[,",  "[TreeSitter] Prev sibling",   tree_climber.goto_prev,   { "n", "v", "o" })
      util.keymap("].",  "[TreeSitter] Jump child",     tree_climber.goto_child,  { "n", "v", "o" })
      util.keymap("[.",  "[TreeSitter] Jump parent",    tree_climber.goto_parent, { "n", "v", "o" })
      util.keymap("a.",  "[TreeSitter] Select node",    tree_climber.select_node, { "v", "o" })
      util.keymap("i.",  "[TreeSitter] Select inner",   tree_climber.select_node, { "v", "o" })
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