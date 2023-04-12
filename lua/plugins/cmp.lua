return {{
  'hrsh7th/nvim-cmp',
  enabled = vim.g.vscode ~= 1,
  dependencies = {
    'david-kunz/cmp-npm',
    'f3fora/cmp-spell',
    'hrsh7th/cmp-buffer',
    'hrsh7th/cmp-calc',
    'hrsh7th/cmp-cmdline',
    'hrsh7th/cmp-nvim-lsp',
    'hrsh7th/cmp-omni',
    'hrsh7th/cmp-path',
    'lukas-reineke/cmp-rg',
    { 'l3mon4d3/luasnip', build = 'make install_jsregexp' },
  },
  event = 'InsertEnter',
  opts = function()
    local cmp = require 'cmp'
    local luasnip = require 'luasnip'

    local has_words_before = function()
      unpack = unpack or table.unpack
      local line, col = unpack(vim.api.nvim_win_get_cursor(0))
      return col ~= 0 and vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]:sub(col, col):match("%s") == nil
    end
    local border_opts = {
      border = 'single',
      winhighlight = 'Normal:Normal,FloatBorder:FloatBorder,CursorLine:Visual,Search:None',
    }
    return {
      enabled = function()
        if vim.api.nvim_get_option_value('buftype', { buf = 0 }) == 'prompt' then return false end
        return true
      end,
      snippet = {
        expand = function(args) require('luasnip').lsp_expand(args.body) end,
      },
      duplicates = {
        nvim_lsp = 1,
        buffer = 1,
        path = 1,
      },
      confirm_opts = {
        behavior = cmp.ConfirmBehavior.Replace,
        select = false,
      },
      window = {
        completion = cmp.config.window.bordered(border_opts),
        documentation = cmp.config.window.bordered(border_opts),
      },
      mapping = cmp.mapping.preset.insert {
        ['<c-b>'] = cmp.mapping.scroll_docs(-4),
        ['<c-f>'] = cmp.mapping.scroll_docs(4),
        ['<c-space>'] = cmp.mapping.complete(),
        ['<c-e>'] = cmp.mapping.abort(),
        ['<cr>'] = cmp.mapping.confirm({ select = true }),
        ['<tab>'] = cmp.mapping(function(fallback)
          if cmp.visible() then
            cmp.select_next_item()
          elseif luasnip.expand_or_locally_jumpable() then
            luasnip.expand_or_jump()
          elseif has_words_before() then
            cmp.complete()
          else
            fallback()
          end
        end, { 'i', 's' }),
        ['<s-tab>'] = cmp.mapping(function(fallback)
          if cmp.visible() then
            cmp.select_prev_item()
          elseif luasnip.jumpable(-1) then
            luasnip.jump(-1)
          else
            fallback()
          end
        end, { 'i', 's' }),
      },
      sources = cmp.config.sources {
        { name = 'nvim_lsp' },
        { name = 'npm', keyword_length = 3 },
        { name = 'omni' },
        { name = 'treesitter' },
        { name = 'rg' },
        { name = 'buffer' },
        { name = 'path' },
        { name = 'calc' },
        { name = 'spell' },
      },
    }
  end,
}}