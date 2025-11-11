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
      tsserver = { globalPlugins = {} },
      experimental = {
        maxInlayHintLength = 30,
        completion = { enableServerSideFuzzyMatch = true },
      },
    },
  },
  before_init = function(params, config)
    -- Check for presence of vue language tools before adding @vue/typescript-plugin.
    local result = vim.system({ "npm", "query", "#vue" }, { cwd = params.workspaceFolders[1].name, text = true }):wait()
    if result.stdout ~= "[]" then
      print("Injecting vue language tools")
      local vue_ls_root = vim.fn.expand("$MASON/packages/vue-language-server")
      table.insert(config.settings.vtsls.tsserver.globalPlugins, {
        name = "@vue/typescript-plugin",
        location = vue_ls_root .. "/node_modules/@vue/language-server/node_modules",
        languages = { "vue" },
        configNamespace = "typescript",
      })
    end
  end,
}