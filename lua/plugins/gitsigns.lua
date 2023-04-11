return {
  {
    'lewis6991/gitsigns.nvim',
    opts = function()
      return {
        current_line_blame = vim.g.vscode ~= 1,
        on_attach = function(bufnr)
          local gs = package.loaded.gitsigns

          local function map(mode, l, r, opts)
            opts = opts or {}
            opts.buffer = bufnr
            vim.keymap.set(mode, l, r, opts)
          end

          -- Navigation
          map('n', ']c', function()
            if vim.wo.diff then return ']c' end
            vim.schedule(function() gs.next_hunk() end)
            return '<Ignore>'
          end, {expr=true})

          map('n', '[c', function()
            if vim.wo.diff then return '[c' end
            vim.schedule(function() gs.prev_hunk() end)
            return '<Ignore>'
          end, {expr=true})

          -- Views
          if vim.g.vscode ~= 1 then
            map('n', '<leader>hp', gs.preview_hunk)
            map('n', '<leader>hb', function() gs.blame_line{full=true} end)
            map('n', '<leader>hd', gs.diffthis)
            map('n', '<leader>hD', function() gs.diffthis('~') end)
            map('n', '<leader>htb', gs.toggle_current_line_blame)
            map('n', '<leader>htd', gs.toggle_deleted)
          end

          -- Actions
          map({'n', 'v'}, '<leader>hs', '<cmd>Gitsigns stage_hunk<cr>')
          map({'n', 'v'}, '<leader>hr', '<cmd>Gitsigns reset_hunk<cr>')
          map('n', '<leader>hS', gs.stage_buffer)
          map('n', '<leader>hu', gs.undo_stage_hunk)
          map('n', '<leader>hR', gs.reset_buffer)

          -- Text object
          map({'o', 'x'}, 'ah', ':<c-U>Gitsigns select_hunk<cr>')
        end,
      }
    end,
  },
}