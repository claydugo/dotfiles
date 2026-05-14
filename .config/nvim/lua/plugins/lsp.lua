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

  if #vim.api.nvim_list_uis() > 0 then
    vim.defer_fn(function()
      local packages = require("packages")
      local mason_packages = vim.list_extend({}, packages.mason)

      if vim.fn.executable("javac") == 1 then
        vim.list_extend(mason_packages, packages.mason_java)
      end

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
  end

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
    root_markers = { ".git" },
    capabilities = capabilities,
    on_attach = on_attach,
    settings = {
      ["harper-ls"] = {
        userDictPath = vim.fn.stdpath("config") .. "/spell/en.utf-8.add",
        diagnosticSeverity = "hint",
        linters = {
          SpellCheck = true,
          SentenceCapitalization = true,
          LongSentences = true,
          SpelledNumbers = true,
          PossessiveNoun = true,
          NoOxfordComma = true,
          BoringWords = false,
          UseGenitive = true,
          -- OrthographicConsistency = false,
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
    settings = {
      bashIde = {
        shellcheckArguments = { "-e", "SC1090", "-e", "SC1091" },
      },
    },
  })

  vim.lsp.config("emmylua_ls", {
    cmd = { "emmylua_ls" },
    filetypes = { "lua" },
    root_markers = {
      ".emmyrc.json",
      ".emmyrc.lua",
      ".luarc.json",
      ".luarc.jsonc",
      ".luacheckrc",
      ".stylua.toml",
      "stylua.toml",
      "selene.toml",
      "selene.yml",
      ".git",
    },
    workspace_required = false,
    settings = {
      codeLens = { enable = true },
      hint = { enable = true },
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

  vim.lsp.config("wgsl_analyzer", {
    cmd = { "wgsl-analyzer" },
    filetypes = { "wgsl" },
    root_markers = { ".git" },
    capabilities = capabilities,
    on_attach = on_attach,
  })

  local clangd_capabilities = vim.tbl_deep_extend("force", capabilities, {
    textDocument = { completion = { editsNearCursor = true } },
    offsetEncoding = { "utf-8", "utf-16" },
  })
  vim.lsp.config("clangd", {
    cmd = { "clangd" },
    filetypes = { "c", "cpp", "objc", "objcpp", "cuda" },
    root_markers = {
      ".clangd",
      ".clang-tidy",
      ".clang-format",
      "compile_commands.json",
      "compile_flags.txt",
      "configure.ac",
      ".git",
    },
    get_language_id = function(_, ftype)
      local t = { objc = "objective-c", objcpp = "objective-cpp", cuda = "cuda-cpp" }
      return t[ftype] or ftype
    end,
    capabilities = clangd_capabilities,
    on_init = function(client, init_result)
      if init_result.offsetEncoding then
        client.offset_encoding = init_result.offsetEncoding
      end
    end,
    on_attach = on_attach,
  })

  vim.lsp.config("taplo", {
    cmd = { "taplo", "lsp", "stdio" },
    filetypes = { "toml" },
    root_markers = { ".taplo.toml", "taplo.toml", ".git" },
    capabilities = capabilities,
    on_attach = on_attach,
  })

  vim.lsp.config("yamlls", {
    cmd = { "yaml-language-server", "--stdio" },
    filetypes = { "yaml", "yaml.docker-compose", "yaml.gitlab", "yaml.helm-values" },
    root_markers = { ".git" },
    settings = {
      redhat = { telemetry = { enabled = false } },
      yaml = { format = { enable = true } },
    },
    on_init = function(client)
      client.server_capabilities.documentFormattingProvider = true
    end,
    capabilities = capabilities,
    on_attach = on_attach,
  })

  -- Gate by executable: on a fresh install mason hasn't finished by the time
  -- this runs, and enabling a server whose binary doesn't exist surfaces a
  -- noisy "command not found" the first time a matching filetype opens.
  local servers = {
    ty = "ty",
    ruff = "ruff",
    biome = "biome",
    harper_ls = "harper-ls",
    bashls = "bash-language-server",
    emmylua_ls = "emmylua_ls",
    rust_analyzer = "rust-analyzer",
    wgsl_analyzer = "wgsl-analyzer",
    clangd = "clangd",
    taplo = "taplo",
    yamlls = "yaml-language-server",
  }
  for name, cmd in pairs(servers) do
    if vim.fn.executable(cmd) == 1 then
      vim.lsp.enable(name)
    end
  end

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

  vim.keymap.set("v", "<leader>r", function()
    vim.lsp.buf.format()
  end, { desc = "Format selection" })
end

return M
