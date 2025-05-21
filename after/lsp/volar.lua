return {
  init_options = {
    vue = {
      hybridMode = true,
      server = { maxOldSpaceSize = 8096 },
      complete = {
        casing = { status = false },
      },
      inlayHints = {
        destructuredProps = true,
        inlineHandlerLeading = true,
        missingProps = true,
        optionsWrapper = true,
        vBindShorthand = true,
      },
      updateImportsOnFileMove = { enabled = true },
    },
  },
}