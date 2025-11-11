
return {
  ---@type LspClientEventHandler
  should_attach = function (bufnr)
    return require("util").buf_is_ai_allowed(bufnr)
  end,
}