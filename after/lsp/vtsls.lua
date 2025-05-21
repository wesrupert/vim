local js_settings = {
  preferences = {
    importModuleSpecifier = "non-relative",
  },
  suggest = { completeFunctionCalls = true },
  inlayHints = {
    enumMemberValues = { enabled = true },
    functionLikeReturnTypes = { enabled = true },
    functionParameterTypes = { enabled = true },
    propertyDeclarationTypes = { enabled = true },
    variableTypes = { enabled = true, suppressWhenArgumentMatchesName = false },
    parameterNames = { enabled = "literals", suppressWhenArgumentMatchesName = false },
  },
}

local ts_settings = vim.tbl_deep_extend("force", {}, js_settings, {
  preferences = {
    preferTypeOnlyAutoImports = true,
  },
})

return {
  filetypes = { "javascript", "javascriptreact", "javascript.jsx", "typescript", "typescriptreact", "typescript.tsx", "vue" },
  settings = {
    typescript = js_settings,
    javascript = ts_settings,
    vtsls = {
      -- Make sure to use the one matching vue-language-server!
      -- autoUseWorkspaceTsdk = false,
      -- typescript = { globalTsdk = global_tsdk },
      tsserver = { globalPlugins = {} },
      experimental = {
        maxInlayHintLength = 30,
        completion = { enableServerSideFuzzyMatch = true },
      },
    },
  },
  before_init = function(params, config)
    local result = vim.system({ "npm", "query", "#vue" }, { cwd = params.workspaceFolders[1].name, text = true }):wait()
    if result.stdout == "[]" then return end
    local root = vim.fn.expand("$MASON/packages/vue-language-server")
    config.settings.autoUseWorkspaceTsdk = false
    config.settings.typescript.globalTsdk = root .. "/node_modules/typescript/lib"
    table.insert(config.settings.vtsls.tsserver.globalPlugins, {
      name = "@vue/typescript-plugin",
      location = root .. "/node_modules/@vue/language-server",
      languages = { "vue" },
      configNamespace = "typescript",
    })
  end,
}