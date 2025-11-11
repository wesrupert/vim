local util = require("util")
local css_config = require("lsp.css")

local tsserver_request = "tsserver/request"
vim.lsp.protocol.Methods.tsserver_request = "tsserver/request"

return {
  settings = util.merge(css_config.settings or {}, {
    vue = {
      inlayHints = {
        destructuredProps = true,
        inlineHandlerLeading = true,
        missingProps = true,
        optionsWrapper = true,
        vBindShorthand = true,
      },
    },
  }),
  on_init = function (client)
    client.handlers[tsserver_request] = function (_, result, context)
      local bufnr = context.bufnr
      local clients = vim.lsp.get_clients({ bufnr = bufnr, name = "vtsls" })
      if #clients == 0 then
        vim.notify("LSP server vue_ls requires vtsls, please install and restart.", vim.log.levels.ERROR)
        return
      end
      local ts_client = clients[1]
      local id, command, payload = unpack(unpack(result))
      ts_client:exec_cmd(
        {
          title = "vue_request_forward",
          command = "typescript.tsserverRequest",
          arguments = { command, payload },
        },
        { bufnr = bufnr },
        function (_, response) client:notify("tsserver/response", { { id, response.body } }) end
      )
    end
  end,
}