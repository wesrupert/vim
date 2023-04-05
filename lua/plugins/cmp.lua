local has_vscode = vim.fn.has('vscode')
if has_vscode == 1 then return end

local cmp_status_ok, cmp = pcall(require, 'cmp')
if not cmp_status_ok then return end

local function has_words_before()
  local line, col = unpack(vim.api.nvim_win_get_cursor(0))
  return col ~= 0 and vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]:sub(col, col):match "%s" == nil
end

cmp.setup {
  window = {
    completion = cmp.config.window.bordered(),
    documentation = cmp.config.window.bordered(),
  },
  mapping = cmp.mapping.preset.insert {
    ['<C-b>'] = cmp.mapping.scroll_docs(-4),
    ['<C-f>'] = cmp.mapping.scroll_docs(4),
    ['<C-Space>'] = cmp.mapping.complete(),
    ['<C-e>'] = cmp.mapping.abort(),
    ['<CR>'] = cmp.mapping.confirm({ select = true }),
    ["<Tab>"] = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.select_next_item()
      elseif has_words_before() then
        cmp.complete()
      else
        fallback()
      end
    end, { "i", "s" }),
    ["<S-Tab>"] = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.select_prev_item()
      else
        fallback()
      end
    end, { "i", "s" }),
  },
  sources = {
    { name = 'nvim_lsp' },
    { name = 'omni' },
    { name = 'treesitter' },
    { name = 'rg' },
    { name = 'buffer' },
    { name = 'path' },
    { name = 'calc' },
    { name = 'spell' },
  },
}

cmp.setup.filetype({ 'javascript', 'typescript', 'vue' }, {
  sources = {
    { name = 'nvim_lsp' },
    { name = 'npm', keyword_length = 3 },
    { name = 'omni' },
    { name = 'treesitter' },
    { name = 'rg' },
    { name = 'buffer' },
    { name = 'path' },
    { name = 'calc' },
    { name = 'spell' },
  }
})

cmp.setup.cmdline({ '/', '?' }, {
  mapping = cmp.mapping.preset.cmdline(),
  sources = {
    { name = 'buffer' }
  }
})

cmp.setup.cmdline(':', {
  mapping = cmp.mapping.preset.cmdline(),
  sources = cmp.config.sources({
    { name = 'cmdline' },
  })
})
