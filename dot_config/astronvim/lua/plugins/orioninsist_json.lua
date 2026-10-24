return {
  {
    "AstroNvim/astrolsp",
    opts = function(_, opts)
      opts.servers = opts.servers or {}
      if not vim.tbl_contains(opts.servers, "jsonls") then
        table.insert(opts.servers, "jsonls")
      end

      opts.config = opts.config or {}
      opts.config.jsonls = vim.tbl_deep_extend("force", opts.config.jsonls or {}, {
        cmd = {
          vim.fn.expand(
            "~/.local/share/orioninsist-json-lsp/node_modules/.bin/vscode-json-language-server"
          ),
          "--stdio",
        },
        settings = {
          json = {
            validate = { enable = true },
            format = { enable = true },
          },
        },
      })
    end,
  },
}
