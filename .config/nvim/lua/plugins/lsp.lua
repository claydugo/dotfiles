local M = {
  "williamboman/mason.nvim",
  cmd = "Mason",
  build = ":MasonUpdate",
  lazy = false,
  dependencies = {
    -- TODO: Revert to RRethy/vim-illuminate after PR #250 is merged
    { "claydugo/vim-illuminate", branch = "fixup_supports_method" },
  },
}

function M.config()
  require("mason").setup()

  vim.diagnostic.config({
    virtual_text = { spacing = 4, prefix = "●" },
    signs = true,
    underline = true,
    update_in_insert = false,
    severity_sort = true,
    float = {
      border = "rounded",
      source = true,
      header = "",
      prefix = "",
    },
  })

  vim.defer_fn(function()
    local mason_packages = {
      "ty",
      "ruff",
      "biome",
      "harper-ls",
      "bash-language-server",
      "lua-language-server",
      "rust-analyzer",
    }

    local ok, registry = pcall(require, "mason-registry")
    if not ok then
      return
    end

    registry.refresh(function()
      for _, pkg_name in ipairs(mason_packages) do
        local pkg_ok, package = pcall(registry.get_package, pkg_name)
        if pkg_ok and not package:is_installed() then
          package:install()
        end
      end
    end)
  end, 100)

  local capabilities = require("blink.cmp").get_lsp_capabilities()
  capabilities.general = capabilities.general or {}
  capabilities.general.positionEncodings = { "utf-16" }

  local illuminate = require("illuminate")
  -- local on_attach = function(client, bufnr)
  local on_attach = function(client)
    illuminate.on_attach(client)

    -- if client.server_capabilities.inlayHintProvider then
    --   vim.lsp.inlay_hint.enable(true, { bufnr = bufnr })
    -- end

    if client.name == "ty" then
      client.server_capabilities.semanticTokensProvider = nil
    end

    if client.name == "ruff" then
      client.server_capabilities.hoverProvider = false
      client.server_capabilities.semanticTokensProvider = nil
    end
  end

  vim.lsp.config("ty", {
    cmd = { "ty", "server" },
    filetypes = { "python" },
    root_markers = { "pyproject.toml", "setup.py", ".git" },
    capabilities = capabilities,
    on_attach = on_attach,
  })

  vim.lsp.config("ruff", {
    cmd = { "ruff", "server" },
    filetypes = { "python" },
    root_markers = { "pyproject.toml", "ruff.toml", ".git" },
    capabilities = capabilities,
    on_attach = on_attach,
  })

  vim.lsp.config("biome", {
    cmd = { "biome", "lsp-proxy" },
    filetypes = {
      "javascript",
      "javascriptreact",
      "json",
      "jsonc",
      "typescript",
      "typescript.tsx",
      "typescriptreact",
    },
    root_markers = { "biome.json", "biome.jsonc", ".git" },
    capabilities = capabilities,
    on_attach = on_attach,
  })

  vim.lsp.config("harper_ls", {
    cmd = { "harper-ls", "--stdio" },
    filetypes = { "markdown", "text", "gitcommit" },
    root_markers = { ".git" },
    capabilities = capabilities,
    on_attach = on_attach,
    settings = {
      ["harper-ls"] = {
        userDictPath = vim.fn.stdpath("config") .. "/spell/en.utf-8.add",
        diagnosticSeverity = "hint",
        linters = {
          SentenceCapitalization = true,
          LongSentences = true,
        },
      },
    },
  })

  vim.lsp.config("bashls", {
    cmd = { "bash-language-server", "start" },
    filetypes = { "sh", "bash" },
    root_markers = { ".git" },
    capabilities = capabilities,
    on_attach = on_attach,
  })

  vim.lsp.config("lua_ls", {
    cmd = { "lua-language-server" },
    filetypes = { "lua" },
    root_markers = {
      ".luarc.json",
      ".luarc.jsonc",
      ".luacheckrc",
      ".stylua.toml",
      "stylua.toml",
      "selene.toml",
      "selene.yml",
      ".git",
    },
    capabilities = capabilities,
    on_attach = on_attach,
  })

  vim.lsp.config("rust_analyzer", {
    cmd = { "rust-analyzer" },
    filetypes = { "rust" },
    root_markers = { "Cargo.toml", "rust-project.json", ".git" },
    capabilities = capabilities,
    on_attach = on_attach,
  })

  vim.lsp.enable("ty")
  vim.lsp.enable("ruff")
  vim.lsp.enable("biome")
  vim.lsp.enable("harper_ls")
  vim.lsp.enable("bashls")
  vim.lsp.enable("lua_ls")
  vim.lsp.enable("rust_analyzer")

  vim.keymap.set("n", "<leader>e", vim.diagnostic.open_float, { desc = "Show diagnostic" })
  vim.keymap.set("n", "<leader>eq", function()
    vim.diagnostic.jump({
      count = -1,
      on_jump = function()
        vim.diagnostic.open_float()
      end,
    })
  end, { desc = "Previous diagnostic" })
  vim.keymap.set("n", "<leader>ee", function()
    vim.diagnostic.jump({
      count = 1,
      on_jump = function()
        vim.diagnostic.open_float()
      end,
    })
  end, { desc = "Next diagnostic" })

  vim.keymap.set("n", "<leader>ih", function()
    vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled())
  end, { desc = "Toggle inlay hints" })

  -- https://github.com/wgsl-analyzer/wgsl-analyzer
  vim.api.nvim_create_autocmd({ "BufNewFile", "BufRead" }, {
    pattern = "*.wgsl",
    callback = function()
      vim.bo.filetype = "wgsl"
    end,
  })
end

return M
