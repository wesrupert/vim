if vim.g.obsidian_workspaces == nil then
  vim.g.obsidian_workspaces = {
    { name = "personal", path = "~/Notes/Personal" },
    { name = "work", path = "~/Notes/Work" },
  }
end

function CreateBufEvents()
  local event = {}
  for _,v in ipairs(vim.g.obsidian_workspaces) do
    event[#event+1] = "BufReadPre " .. v.path .. "/" .. "*/*.md"
    event[#event+1] = "BufNewFile " .. v.path .. "/" .. "*/*.md"
    event[#event+1] = "BufReadPre " .. vim.fn.expand(v.path .. "/") .. "*\\*.md"
    event[#event+1] = "BufNewFile " .. vim.fn.expand(v.path .. "/") .. "*\\*.md"
  end
  return event
end

return {
  "epwalsh/obsidian.nvim",
  version = "*",
  lazy = true,
  ft = "markdown",
  -- event = CreateBufEvents(),
  dependencies = {
    "nvim-lua/plenary.nvim",
  },
  opts = {
    workspaces = vim.g.obsidian_workspaces,
  },
}