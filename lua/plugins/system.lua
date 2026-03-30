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
    opts = {
      view = {
        signs = { add = "┃", change = "┃", delete = "┃" },
      },
      mappings = {
        apply = "ghs",
        reset = "ghr",
        goto_first = "ghg",
        goto_last = "ghG",
      },
      options = {
        wrap_goto = true,
      },
    },
    config = function(_, opts)
      local diff = require("mini.diff")

      -- Jujutsu support
      -- See https://github.com/nvim-mini/mini.nvim/discussions/1783
      local jj_buffer_cache = {}

      local function get_jj_root(path)
        local result = vim.system(
          { "jj", "--ignore-working-copy", "root" },
          { cwd = vim.fs.dirname(path) }
        ):wait()
        if result.code ~= 0 then return nil end
        return vim.trim(result.stdout)
      end

      local function invalidate_cache(buf_id)
        local cache = jj_buffer_cache[buf_id]
        if cache == nil then return false end
        pcall(function ()
          cache.fs_event:stop()
          cache.timer:stop()
        end)
        jj_buffer_cache[buf_id] = nil
      end

      local function watch_jj_file(buf_id, path)
        local repo = get_jj_root(path)
        if repo == nil then return false end

        local function set_ref_text()
          vim.system(
            { "jj", "--ignore-working-copy", "file", "show", "-r", "@-", "\"" .. path .. "\"" },
            { cwd = vim.fs.dirname(path), text = true },
            vim.schedule_wrap(function (res) diff.set_ref_text(buf_id, res.stdout) end)
          )
        end

        ---@diagnostic disable-next-line: undefined-field
        local buf_fs_event, timer = vim.uv.new_fs_event(), vim.uv.new_timer()
        if not buf_fs_event or not timer then return false end
        buf_fs_event:start(
          repo .. vim.g.slash .. ".jj" .. vim.g.slash .. "working_copy",
          { recursive = true },
          function (_, filename, _)
            if filename ~= "checkout" then return end
            timer:stop()
            timer:start(50, 0, set_ref_text)
          end
        )

        invalidate_cache(buf_id)
        jj_buffer_cache[buf_id] = { fs_event = buf_fs_event, timer = timer }

        set_ref_text()
      end

      diff.setup(util.merge(opts or {}, {
        source = {
          name = "jj",
          attach = function (buf_id)
            if jj_buffer_cache[buf_id] ~= nil then return false end

            ---@diagnostic disable-next-line: undefined-field
            local path = vim.uv.fs_realpath(vim.api.nvim_buf_get_name(buf_id)) or ""
            if path == "" then return false end

            return watch_jj_file(buf_id, path)
          end,
          detach = function (buf_id)
            invalidate_cache(buf_id)
          end,
        }
      }))

      util.keymap({ { "]g", desc = "[Mini:diff] Toggle overlay", diff.toggle_overlay } })
    end,
  },
  {
    "sindrets/diffview.nvim",
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