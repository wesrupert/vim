local M = {}
M.augroup = vim.api.nvim_create_augroup("UserMulticursorConfig", { clear = true })
M.namespace = vim.api.nvim_create_namespace("nvim.multicursor")

function M.clear_cursors()
    vim.api.nvim_buf_clear_namespace(0, M.namespace, 0, -1)
end

--- Place a cursor and then perform a motion
--- @param opts { mapping: string, movement: string }
function M.add_cursor_and_move(opts)
  vim.api.nvim_feedkeys("2q=", "n", false)
  vim.api.nvim_feedkeys("1Q", "n", false)
  vim.api.nvim_feedkeys(opts.movement, "n", false)
  if vim.v.count1 > 1 then
    vim.api.nvim_feedkeys(
      vim.api.nvim_replace_termcodes((vim.v.count1 - 1) .. opts.mapping, true, false, true),
      "m",
      false
    )
  end
end

--- Place a cursor and then perform a motion
--- @param opts? { visual_mode?: boolean }
function M.select_all(opts)
  local lopts = opts or {}
  if lopts.visual_mode then
    local selection = vim.fn.getregion(vim.fn.getpos("v"), vim.fn.getpos("."))
    vim.fn.setreg("/", "\\V" .. table.concat(selection, "\\n"))
  else
    vim.fn.setreg("/", "\\V\\<" .. vim.fn.expand("<cword>") .. "\\>")
  end
  vim.schedule(function ()
    local pos = vim.api.nvim_win_get_cursor(0)
    vim.api.nvim_feedkeys("Valzqn", "n", false)
    vim.defer_fn(function ()
      vim.api.nvim_win_set_cursor(0, pos)
    end, 0)
  end)
end

--- Place a cursor and search/advance to the next entry
--- @param opts { mapping: string, forward_search?: boolean, visual_mode?: boolean, force?: boolean }
function M.search(opts)
  local lopts = opts or {}
  local ns = vim.api.nvim_create_namespace("nvim.multicursor")
  local marks = vim.api.nvim_buf_get_extmarks(0, ns, 0, -1)
  local search_next = lopts.forward_search and "n" or "N"
  if lopts.force or #marks == 0 then
    if lopts.visual_mode then
      local selection = vim.fn.getregion(vim.fn.getpos("v"), vim.fn.getpos("."))
      vim.fn.setreg("/", "\\V" .. table.concat(selection, "\\n"))
      vim.api.nvim_feedkeys("v`<", "n", false)
    else
      vim.api.nvim_feedkeys("wb", "n", false)
      vim.fn.setreg("/", "\\V\\<" .. vim.fn.expand("<cword>") .. "\\>")
    end
  end
  vim.schedule(function()
    M.add_cursor_and_move({ mapping = lopts.mapping, movement = search_next })
  end)
end

function M.setup()
  require("util").keymap({
    { "<m-z>",  desc = "[Multicursor] Toggle cursor",         [[Q]] },
    { "zu",     desc = "[Multicursor] Undo cursor",           [[[CQ]] },
    { "zy",     desc = "[Multicursor] Toggle following",      [[q=]] },
    { "zU",     desc = "[Multicursor] Clear cursors",         M.clear_cursors },
    { "z<esc>", desc = "[Multicursor] Clear cursors",         M.clear_cursors },
    { "zj",     desc = "[Multicursor] Place and move down",   function () M.add_cursor_and_move({ mapping = "TODO", movement = "j" }) end },
    { "zk",     desc = "[Multicursor] Place and move up",     function () M.add_cursor_and_move({ mapping = "TODO", movement = "k" }) end },
    { "z<cr>",  desc = "[Multicursor] Place at matches",                              M.select_all },
    { "z<cr>",  desc = "[Multicursor] Place at matches",      mode = "x", function () M.select_all({ visual_mode = true }) end },
    { "z*",     desc = "[Multicursor] Place and move next",               function () M.search({ mapping = "TODO", forward_search = true,  visual_mode = false }) end },
    { "z*",     desc = "[Multicursor] Place and move next",   mode = "x", function () M.search({ mapping = "TODO", forward_search = true,  visual_mode = true  }) end },
    { "z#",     desc = "[Multicursor] Place and move prev",               function () M.search({ mapping = "TODO", forward_search = false, visual_mode = false }) end },
    { "z#",     desc = "[Multicursor] Place and move prev",   mode = "x", function () M.search({ mapping = "TODO", forward_search = false, visual_mode = true  }) end },
    { "z/",     desc = "[Multicursor] Place and search next",             function () M.search({ mapping = "TODO", forward_search = true,  visual_mode = false, force = true }) end },
    { "z/",     desc = "[Multicursor] Place and search next", mode = "x", function () M.search({ mapping = "TODO", forward_search = true,  visual_mode = true,  force = true }) end },
    { "z?",     desc = "[Multicursor] Place and search prev",             function () M.search({ mapping = "TODO", forward_search = false, visual_mode = false, force = true }) end },
    { "z?",     desc = "[Multicursor] Place and search prev", mode = "x", function () M.search({ mapping = "TODO", forward_search = false, visual_mode = true,  force = true }) end },

    -- Remapped default bindings
    { "zJ", desc = "Move to next fold", [[zj]] },
    { "zK", desc = "Move to prev fold", [[zk]] },
  })
end

return M