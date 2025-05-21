local util = require('util')
return {
  'folke/todo-comments.nvim',
  dependencies = { 'folke/trouble.nvim', 'nvim-lua/plenary.nvim' },
  opts = {
    -- TODO: Test text
    -- Test continuation
    -- Todo: Alt text
    -- todo: Alt text
    -- FIX: Test text
    -- Test continuation
    -- FIXME: Alt text
    -- BUG: Alt text
    -- FIXIT: Alt text
    -- ISSUE: Alt text
    -- HACK: Test text
    -- Test continuation
    -- WARN: Test text
    -- Test continuation
    -- PERF: Test text
    -- Test continuation
    -- NOTE: Test text
    -- Test continuation
    -- TEST: Test text
    -- Test continuation
    -- IMPL: Test text
    -- Test continuation
    -- NOCOMMIT: Alt text
    -- DON'T COMMIT: Alt text
    -- NOPUSH: Alt text
    -- DON'T PUSH: Alt text
    --
    -- TODO @tag: Test tag syntax
    -- Test continuation
    -- TODO: Test multiple colons: Test text
    -- Test continuation
    -- TODO @tag: Test multiple colons: Test text
    -- Test continuation
    -- TODO test tag: Test text
    -- Test continuation
    -- @todo Test @ syntax
    -- Test continuation
    -- @todo @test-tag Test @ syntax
    -- Test continuation
    --
    -- No continuation test
    -- tOdO: False positive test
    -- TODO False positive test
    -- @ TODO False positive test
    keywords = {
      TODO = { alt = { 'Todo', 'ToDo', 'todo' } },
      TEST = { icon = ' ' },
      IMPL = {
        icon = ' ',
        color = 'error',
        alt = { 'QWOP', 'qwop', 'FUCK', 'fuck', 'NOCOMMIT', "DON'T COMMIT", 'NOPUSH', "DON'T PUSH" },
      },
    },
    highlight = {
      pattern = {
        [[.*(<(KEYWORDS)>([^:]*)):]],
        [[.*(\@(KEYWORDS)>(\s+\@[A-Za-z0-9_-]+)*)]],
      },
    },
    search = {
      pattern = [[(\b(?:KEYWORDS)(?:\s+[^:\s]+)*\s*:)|(@(?:KEYWORDS)\b)]],
    },
  },
  init = function ()
    local trouble = require('trouble')
    local todo_comments = require('todo-comments')
    util.keymap(']t', '[Todos] Jump next', todo_comments.jump_next)
    util.keymap('[t', '[Todos] Jump prev', todo_comments.jump_prev)
    util.keymap('<leader>t', '[Trouble] Buffer todos', function () trouble.toggle({ mode = 'todo', filter = { buf = 0 } }) end)
    util.keymap('<leader>T', '[Trouble] Todos', function () trouble.toggle('todo') end)
  end
}