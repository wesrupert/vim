local util = require('util')

local function is_in_start_tag()
  local ts_utils = require('nvim-treesitter.ts_utils')
  local node = ts_utils.get_node_at_cursor()
  if not node then
    return false
  end
  local node_to_check = { 'start_tag', 'self_closing_tag', 'directive_attribute' }
  return vim.tbl_contains(node_to_check, node:type())
end

return {
  {
    'zbirenbaum/copilot.lua',
    cond = util.not_vscode,
    cmd = 'Copilot',
    event = 'InsertEnter',
    opts = {
      filetypes = {
        lua = false,
        vim = false,
        sh = false,
        json = false,
        markdown = false,
      },
      suggestion = { enabled = false },
      panel = { enabled = false },
    },
  },
  {
    {
      'copilotc-nvim/copilotchat.nvim',
      dependencies = { 'zbirenbaum/copilot.lua', 'nvim-lua/plenary.nvim' },
      opts = {
        -- See Configuration section for options
      },
      init = function ()
        util.keymap('<a-c>', '[Copilot] Toggle chat', [[<cmd>CopilotChatToggle<cr>]])
      end,
    },
  },
  {
    'zbirenbaum/copilot-cmp',
    cond = util.not_vscode,
    dependencies = { 'zbirenbaum/copilot.lua' },
    event = 'InsertEnter',
    opts = {},
  },
  {
    'saghen/blink.cmp',
    version = 'v0.*',
    cond = util.not_vscode,
    dependencies = { 'giuxtaposition/blink-cmp-copilot' },
    lazy = false, -- lazy loading handled internally
    opts = {
      -- keymap = { preset = 'super-tab' },
      keymap = { preset = 'enter' },
      default = { 'lsp', 'path', 'snippets', 'buffer', 'copilot' },
      providers = {
        copilot = {
          name = 'copilot',
          module = 'blink-cmp-copilot',
          score_offset = 100,
          async = true,
        },
      },
      appearance = {
        use_nvim_cmp_as_default = true,
        nerd_font_variant = 'normal'
      },
      signature = { enabled = true } -- experimental, maybe disable
    },
    -- opts_extend = { 'sources.default' }
  },
  {
    'hrsh7th/nvim-cmp',
    -- cond = util.not_vscode,
    cond = false,
    dependencies = {
      'david-kunz/cmp-npm',
      'f3fora/cmp-spell',
      'hrsh7th/cmp-buffer',
      'hrsh7th/cmp-calc',
      'hrsh7th/cmp-cmdline',
      'hrsh7th/cmp-nvim-lsp',
      'hrsh7th/cmp-nvim-lsp-signature-help',
      'hrsh7th/cmp-omni',
      'hrsh7th/cmp-path',
      'onsails/lspkind.nvim',
      'lukas-reineke/cmp-rg',
      'zbirenbaum/copilot-cmp',
      { 'l3mon4d3/luasnip', build = 'make install_jsregexp' },
    },
    event = 'InsertEnter',
    opts = function()
      local cmp = require('cmp')
      local luasnip = require('luasnip')
      local lspkind = require('lspkind')

      local has_words_before = function()
        unpack = unpack or table.unpack
        local line, col = unpack(vim.api.nvim_win_get_cursor(0))
        return col ~= 0 and vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]:sub(col, col):match('%s') == nil
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
        completion = {
          completeopt = 'menu,menuone,noinsert',
        },
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
        formatting = {
          format = lspkind.cmp_format({
            mode = 'text',
            menu = {
              buffer = '[Buffer]',
              nvim_lsp = '[LSP]',
              luasnip = '[LuaSnip]',
              nvim_lua = '[Lua]',
              latex_symbols = '[Latex]',
              npm = '[NPM]',
              omni = '[Omnifunc]',
              treesitter = '[TS]',
              rg = '[Grep]',
              calc = '[Calc]',
              path = '[Dir]',
              spell = '[Spell]',
            }
          }),
        },
        window = {
          documentation = cmp.config.window.bordered(border_opts),
          completion = cmp.config.window.bordered(border_opts),
        },
        mapping = cmp.mapping.preset.insert {
          ['<c-b>'] = cmp.mapping.scroll_docs(-4),
          ['<c-f>'] = cmp.mapping.scroll_docs(4),
          ['<c-space>'] = cmp.mapping.complete(),
          ['<c-e>'] = cmp.mapping.abort(),
          ['<cr>'] = cmp.mapping.confirm({ select = true }),
          ['<tab>'] = cmp.mapping(function(fallback)
            if cmp.visible() then
              if #cmp.get_entries() == 1 then
                cmp.confirm({ select = true })
              else
                cmp.select_next_item()
              end
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
          { name = 'copilot', priority = 1000 },
          { name = 'nvim_lsp_signature_help', priority = 999 },
          {
            name = 'nvim_lsp',
            priority = 800,
            entry_filter = function(entry, ctx)
              if ctx.filetype == 'vue' then
                -- Add prop/emit completion to vue components

                -- Check that we're inside start tag (caching the result)
                local cached_is_in_start_tag = vim.b[ctx.bufnr]._vue_ts_cached_is_in_start_tag
                if cached_is_in_start_tag == nil then
                  vim.b[ctx.bufnr]._vue_ts_cached_is_in_start_tag = is_in_start_tag()
                end
                -- If not in start tag, return true
                if vim.b[ctx.bufnr]._vue_ts_cached_is_in_start_tag == false then
                  return true
                end
                -- rest of the code
                local cursor_before_line = ctx.cursor_before_line
                if cursor_before_line:sub(-1) == '@' then -- For events
                  return entry.completion_item.label:match('^@')
                elseif cursor_before_line:sub(-1) == ':' then -- For props also exclude events with `:on-` prefix
                  return entry.completion_item.label:match('^:') and not entry.completion_item.label:match('^:on%-')
                end
              end
              return true
            end,
          },
          { name = 'npm', priority = 400, keyword_length = 3 },
          { name = 'omni', priority = 400 },
          { name = 'treesitter', priority = 400 },
          { name = 'rg', priority = 400, keyword_length = 3 },
          { name = 'calc', priority = 400 },
          { name = 'path', priority = 400, keyword_length = 3 },
          { name = 'buffer', priority = 250, keyword_length = 3 },
          { name = 'spell', priority = 200, keyword_length = 3 },
        },
      }
    end,
    init = function()
      require('cmp').event:on('menu_closed', function()
        local bufnr = vim.api.nvim_get_current_buf()
        vim.b[bufnr]._vue_ts_cached_is_in_start_tag = nil
      end)
    end,
  }
}