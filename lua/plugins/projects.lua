local util = require("util")

return {
  {
    "nvim-mini/mini.sessions",
    opts = {
      autoread = true,
      autowrite = true,
      hooks = {
        post = {
          read = function (ev)
            vim.g.mini_sessions_current = ev
            if vim.o.sessionoptions:find("globals") then -- Load session settings.
              if vim.g.PROJECT_tsc_makeprg then
                vim.g.tsc_makeprg = vim.g.PROJECT_tsc_makeprg
                vim.cmd.compiler('tsc')
              end
            end
          end,
          write = function (ev)
            vim.g.mini_sessions_current = ev
          end,
          delete = function (ev)
            if vim.g.mini_sessions_current.path == ev.path then
              vim.g.mini_sessions_current = nil
            end
          end
        },
      },
    },
    init = function ()
      ---@class MiniSessions.Session Session information
      ---@field modify_time number Modification time (see |getftime()|) of session file
      ---@field name string Name of session (should be equal to table key)
      ---@field path string Full path to session file
      ---@field type "global" | "local" Type of session
      vim.g.mini_sessions_current = nil
    end,
    config = function(_, opts)
      local sessions = require("mini.sessions")
      sessions.setup(opts)

      -- Use custom autoread that supports command line session name
      if opts and opts.autoread then
        vim.api.nvim_create_autocmd("VimEnter", {
          desc = "[MiniSessions] Autoread environment session",
          group = vim.api.nvim_create_augroup("UserMiniSessionsConfig", { clear = true }),
          nested = true,
          once = true,
          callback = function ()
            local init_session = vim.g.init_session
            if init_session and init_session ~= "" then
              sessions.read(init_session)
            end
          end,
        })
      end

      ---@param session? string
      local function write_session(session)
        ---@type string|nil
        local n = session or ""
        if n == "" then n = vim.fn.input("Session Name: ", vim.fn.fnamemodify(vim.fn.getcwd(), ":p:h:t")) end
        if n == "" then n = nil end
        sessions.write(n)
      end

      util.keymap("[Mini:sessions]", {
        { "<leader>so", "Select",         sessions.select                                            },
        { "<leader>sl", "Write (local)",  function () sessions.write(sessions.config.file) end       },
        { "<leader>sg", "Write (global)", function () write_session() end                            },
        { "<leader>su", "Update",         function () write_session(vim.g.mini_sessions_current) end },
      })
    end,
  },
  {
    "stevearc/overseer.nvim",
    config = function (_, opts)
      local overseer = require("overseer")
      overseer.setup(opts or {})
      util._keymap("gol", "[Overseer] Toggle",      [[<cmd>OverseerToggle<cr>]])
      util._keymap("goo", "[Overseer] Run",         [[<cmd>OverseerRun<cr>]])
      util._keymap("goa", "[Overseer] Modify Task", [[<cmd>OverseerTaskAction<cr>]])
    end,
  },
}