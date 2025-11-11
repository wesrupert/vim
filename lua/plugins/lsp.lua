local util = require("util")
local lsp_util = require("util.lsp")

local methods = vim.lsp.protocol.Methods
local user_lsp_config_group = vim.api.nvim_create_augroup("UserLspConfig", { clear = true })

-- LSP Keymaps
lsp_util.on_attach(function (bufnr)
  util.keymap("grn", "[LSP] Rename",               vim.lsp.buf.rename, nil, bufnr)
  util.keymap("gra", "[LSP] Show code actions",    vim.lsp.buf.code_action, nil, bufnr)
  util.keymap("grw", "[LSP] Add workspace folder", vim.lsp.buf.add_workspace_folder, nil, bufnr)
  util.keymap("grW", "[LSP] Del workspace folder", vim.lsp.buf.remove_workspace_folder, nil, bufnr)
  util.keymap("[e",  "[LSP] Previous error",       function () vim.diagnostic.jump({ count = -1, severity = vim.diagnostic.severity.ERROR }) end, nil, bufnr)
  util.keymap("]e",  "[LSP] Previous error",       function () vim.diagnostic.jump({ count = 1, severity = vim.diagnostic.severity.ERROR }) end, nil, bufnr)
  util.keymap("goq", "[LSP] Workspace info",       function () print("Workspace folders: " .. vim.inspect(vim.lsp.buf.list_workspace_folders())) end, nil, bufnr)
end)
lsp_util.on_supports_method(methods.textDocument_definition, function (bufnr)
  util.keymap("gd", "[LSP] Go to definition", vim.lsp.buf.definition, nil, bufnr)
end)
lsp_util.on_attach_client("null-ls", function (bufnr)
  util.keymap("zg", "[LSP] Show code actions", vim.lsp.buf.code_action, nil, bufnr)
  util.keymap("zG", "[LSP] Show code actions", vim.lsp.buf.code_action, nil, bufnr)
  util.keymap("[s", "[LSP] Previous info",     function () vim.diagnostic.jump({ count = -1, severity = vim.diagnostic.severity.INFO }) end, nil, bufnr)
  util.keymap("]s", "[LSP] Previous info",     function () vim.diagnostic.jump({ count = 1, severity = vim.diagnostic.severity.INFO }) end, nil, bufnr)
end)

-- "Organize Imports" mapping.
lsp_util.on_attach_client("vtsls", function (bufnr)
  local organize_imports = function ()
    vim.lsp.buf.code_action({
      context = { only = { "source.organizeImports" }, diagnostics = {} },
      apply = true,
    })
  end
  util.keymap("gsi", "[LSP:vtsls] Organize imports", organize_imports, nil, bufnr)
  vim.api.nvim_buf_create_user_command(bufnr, "OrganizeImports", organize_imports, { desc = "[LSP:vtsls] Organize imports" })
end)

-- Document highlight
lsp_util.on_supports_method(methods.textDocument_documentHighlight, function (bufnr)
  local lsp_document_highlight_enabled = util.use_setting("lsp_document_highlight_enabled", true)
  local user_lsp_cursor_highlights_group = vim.api.nvim_create_augroup("UserLspCursorHighlightsConfig", { clear = true })
  vim.api.nvim_create_autocmd({ "CursorHold", "InsertLeave" }, {
    group = user_lsp_cursor_highlights_group,
    desc = "[LSP] Highlight references under the cursor",
    buffer = bufnr,
    callback = function (ev)
      if lsp_document_highlight_enabled.get(ev.buf) then vim.lsp.buf.document_highlight() end
    end,
  })
  vim.api.nvim_create_autocmd({ "CursorMoved", "InsertEnter", "BufLeave" }, {
    group = user_lsp_cursor_highlights_group,
    desc = "[LSP] Clear highlight references",
    buffer = bufnr,
    callback = vim.lsp.buf.clear_references,
  })
end)

-- Automatic inlay hints / InsertEnter inlay hint toggle.
lsp_util.on_supports_method(methods.textDocument_inlayHint, function (bufnr)
  local user_lsp_inlay_hints_group = vim.api.nvim_create_augroup("UserLspInlayHintsConfig", { clear = true })
  local lsp_inlay_hints_enabled = util.use_setting("lsp_inlay_hints_enabled", true)

  -- Automatically enable inlay hints.
  if lsp_inlay_hints_enabled.get(bufnr) then
    vim.defer_fn(function ()
      local mode = vim.api.nvim_get_mode().mode
      local enabled = lsp_inlay_hints_enabled.set(mode == "n" or mode == "v", "b", bufnr)
      vim.lsp.inlay_hint.enable(enabled, { bufnr = bufnr })
    end, 500)
  end

  util.keymap("grh", "[LSP] Toggle inlay hints (buffer)", function ()
    local enabled = lsp_inlay_hints_enabled.set(not vim.lsp.inlay_hint.is_enabled({ bufnr = 0 }), "b", bufnr)
    vim.lsp.inlay_hint.enable(enabled, { bufnr = 0 })
    print("[LSP] Inlay hints " .. (enabled and "enabled" or "disabled"))
  end, nil, bufnr)

  util.keymap("grH", "[LSP] Toggle inlay hints", function ()
    local enabled = lsp_inlay_hints_enabled.set(not vim.lsp.inlay_hint.is_enabled({ bufnr = 0 }), "g")
    vim.lsp.inlay_hint.enable(enabled)
    print("[LSP] Inlay hints " .. (enabled and "enabled" or "disabled"))
  end, nil, bufnr)

  vim.api.nvim_create_autocmd("InsertEnter", {
    group = user_lsp_inlay_hints_group,
    desc = "[LSP] Insert-only inlay hints",
    buffer = bufnr,
    callback = function () vim.lsp.inlay_hint.enable(false, { bufnr = bufnr }) end,
  })
  vim.api.nvim_create_autocmd("InsertLeave", {
    group = user_lsp_inlay_hints_group,
    desc = "[LSP] Insert-only inlay hints",
    buffer = bufnr,
    callback = function ()
      if lsp_inlay_hints_enabled.get() then
        vim.lsp.inlay_hint.enable(true, { bufnr = bufnr })
      end
    end,
  })
end)

-- ESlint "Fix All" command/ "Fix on save" autocommand.
lsp_util.on_attach(function (bufnr, client)
  if client.name ~= "eslint" then return end
  _G.eslint_fix_all = function ()
    client:request(methods.workspace_executeCommand, {
      command = "eslint.applyAllFixes",
      arguments = { { uri = vim.uri_from_bufnr(bufnr), version = vim.lsp.util.buf_versions[bufnr] } },
    }, nil, bufnr)
  end
  util.keymap("gre", "[LSP:eslint] Fix all", eslint_fix_all, nil, bufnr)

  vim.api.nvim_create_autocmd("BufWritePre", {
    group = user_lsp_config_group,
    desc = "[LSP:eslint] Fix on save",
    buffer = bufnr,
    callback = function () if util.get_setting("eslint_run_on_save", true, bufnr) then eslint_fix_all() end end,
  })
end)

-- LSP foldexpr support.
vim.api.nvim_create_autocmd("BufWinEnter", {
  group = user_lsp_config_group,
  desc = "[LSP] Enable foldexpr",
  callback = function (ev)
    if not util.get_setting("use_lsp_foldexpr", true) then return end
    for _, client in ipairs(vim.lsp.get_clients({ bufnr = ev.buf })) do
      if client and client:supports_method(methods.textDocument_foldingRange, ev.buf) then
        local win = vim.api.nvim_get_current_win()
        vim.wo[win][0].foldexpr = "v:lua.vim.lsp.foldexpr()"
        return
      end
    end
  end,
})

---@class vim.lsp.ClientConfig
---@field should_attach? LspClientEventHandler

-- LSP should_attach support.
lsp_util.on_attach(function (bufnr, client)
  local should_attach = client and client.config and client.config.should_attach or nil
  if not should_attach then return end
  if type(should_attach) ~= 'function' then return end
  if should_attach(bufnr, client) ~= false then return end

  -- Detach client from this buffer. Ideally, we'd never attach at all,
  -- but vim.lsp doesn't support this.
  -- NOTE: LspAttach happens before the buffer is actually marked as attached!
  -- See: https://github.com/neovim/nvim-lspconfig/issues/2508
  vim.defer_fn(function ()
    if not vim.lsp.buf_is_attached(bufnr, client.id) then
      vim.notify(
        'Tried to detach ' .. client.name .. ' from buffer ' .. bufnr .. ' before it was attached!',
        vim.log.levels.ERROR
      )
      return
    end
    vim.lsp.buf_detach_client(bufnr, client.id)
  end, 10)
end)

vim.diagnostic.config({
  signs = {
    severity = { min = vim.diagnostic.severity.WARN },
    text = {
      [vim.diagnostic.severity.ERROR] = util.kind_icons.Error,
      [vim.diagnostic.severity.WARN] = util.kind_icons.Warn,
      [vim.diagnostic.severity.INFO] = util.kind_icons.Info,
    },
  },
  virtual_text = {
    prefix = "",
    spacing = 2,
    format = function (d)
      local message = util.diagnostic_icons[d.severity]
      if d.source then message = string.format("%s %s", message, util.kind_names[d.source] or d.source) end
      if d.code then message = string.format("%s[%s]", message, d.code) end
      return message .. " "
    end,
  },
})

return {
  {
    "rachartier/tiny-inline-diagnostic.nvim",
    event = "LspAttach",
    priority = 1001, -- Must run before other lsp plugins!
    opts = {
      preset = "powerline",
      options = { show_source = { enabled = true } },
    },
    init = function ()
      vim.diagnostic.config({ virtual_text = false })
    end,
  },
  {
    "neovim/nvim-lspconfig",
    init = function () lsp_util.setup_lsp_servers() end,
  },
  { "mason-org/mason.nvim", build = ":MasonUpdate", config = true },
  { "folke/lsp-colors.nvim" },
  {
    "mason-org/mason-lspconfig.nvim",
    dependencies = { "mason-org/mason.nvim", "pmizio/typescript-tools.nvim" },
    config = true,
  },
  {
    "nvimtools/none-ls.nvim",
    dependencies = {
      "mason.nvim",
      "nvimtools/none-ls-extras.nvim",
      "davidmh/cspell.nvim",
    },
    opts = {
      config_file_preferred_name = "cspell.json",
      cspell_config_dirs = { "~/.config/" },
    },
    config = function (_, opts)
      local none_ls = require("null-ls")
      local cspell = require("cspell")
      none_ls.setup({
        sources = {
          cspell.diagnostics.with({
            config = opts,
            diagnostics_postprocess = function (event)
              event.severity = vim.diagnostic.severity.INFO
            end,
          }),
          cspell.code_actions.with({ config = opts }),
        },
      })
    end,
  },
  {
    "chaitanyabsprip/fastaction.nvim",
    opts = {
      dismiss_keys = { "q", "<esc>", "<c-c>" },
      popup = {
        title = false,
      },
      priority = {
        -- NOTE: The patterns should be tested against the raw messages;
        -- fastaction only makes them title case after pattern matching is complete!
        eslint = {
          { key = "f", order = 1, pattern = "fix this" },
          { key = "a", order = 2, pattern = "fix all" },
        },
        ["null-ls"] = {
          { key = "=", order = 3, pattern = "^fix: " },
          -- Definition order is swapped since #4 will grab anything from #5 as well.
          { key = "d", order = 5, pattern = "add.*to.*~/%.config/cspell%.json" },
          { key = "s", order = 4, pattern = "add.*to.*cspell%.json" },
        },
      },
    },
    config = function (_, opts)
      local fastaction = require("fastaction")
      fastaction.setup(opts)

      lsp_util.on_attach(function (bufnr, client)
        util.keymap("gra", "[LSP] Show code actions", fastaction.code_action, { "n", "x" }, bufnr)
        if client.name == 'null-ls' then
          util.keymap("zg",  "[LSP] Show code actions", fastaction.code_action, { "n", "x" }, bufnr)
          util.keymap("zG",  "[LSP] Show code actions", fastaction.code_action, { "n", "x" }, bufnr)
        end
      end)
    end,
  },
  { "yioneko/nvim-vtsls" },
}