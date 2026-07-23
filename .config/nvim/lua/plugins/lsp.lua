local M = {
  specs = {
    { src = "https://github.com/mason-org/mason.nvim" },
    { src = "https://github.com/neovim/nvim-lspconfig" },
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
    jump = {
      on_jump = function(_, bufnr)
        vim.diagnostic.open_float({ bufnr = bufnr, scope = "cursor", focus = false })
      end,
    },
    float = {
      source = true,
      header = "",
      prefix = "",
    },
  })

  if #vim.api.nvim_list_uis() > 0 then
    vim.defer_fn(function()
      local ok, registry = pcall(require, "mason-registry")
      if not ok then
        return
      end
      local missing = {}
      for _, pkg_name in ipairs(require("packages").mason) do
        local pkg_ok, package = pcall(registry.get_package, pkg_name)
        if not pkg_ok or not package:is_installed() then
          table.insert(missing, pkg_name)
        end
      end
      if #missing == 0 then
        return
      end
      registry.refresh(function()
        for _, pkg_name in ipairs(missing) do
          local pkg_ok, package = pcall(registry.get_package, pkg_name)
          if pkg_ok and not package:is_installed() then
            package:install()
          end
        end
      end)
    end, 100)
  end

  vim.lsp.config("*", {
    capabilities = require("blink.cmp").get_lsp_capabilities({
      general = { positionEncodings = { "utf-16" } },
    }),
  })

  vim.api.nvim_create_autocmd("LspAttach", {
    group = vim.api.nvim_create_augroup("lsp_attach_tweaks", { clear = true }),
    callback = function(args)
      local client = assert(vim.lsp.get_client_by_id(args.data.client_id))
      if client.name == "ty" then
        client.server_capabilities.semanticTokensProvider = nil
      elseif client.name == "ruff" then
        client.server_capabilities.hoverProvider = false
        client.server_capabilities.semanticTokensProvider = nil
      end
    end,
  })

  local harper_filetypes = vim.deepcopy(vim.lsp.config.harper_ls.filetypes or {})
  vim.list_extend(harper_filetypes, { "jj", "text" })
  vim.lsp.config("harper_ls", {
    filetypes = harper_filetypes,
    settings = {
      ["harper-ls"] = {
        userDictPath = vim.o.spellfile,
        diagnosticSeverity = "hint",
        linters = {
          SpellCheck = true,
          SentenceCapitalization = true,
          LongSentences = true,
          SpelledNumbers = true,
          PossessiveNoun = true,
          NoOxfordComma = false,
          BoringWords = false,
          UseGenitive = true,
          OxfordComma = false,
        },
      },
    },
  })

  -- conda recipe meta.yaml files use ft yaml.jinja (see options.lua)
  local yamlls_filetypes = vim.deepcopy(vim.lsp.config.yamlls.filetypes or {})
  vim.list_extend(yamlls_filetypes, { "yaml.jinja" })
  vim.lsp.config("yamlls", {
    filetypes = yamlls_filetypes,
  })

  vim.lsp.config("bashls", {
    settings = {
      bashIde = {
        shellcheckArguments = { "-e", "SC1090", "-e", "SC1091" },
        globPattern = "**/*@(.sh|.inc|.bash|.command)",
      },
    },
  })

  vim.lsp.config("biome", {
    workspace_required = false,
    root_dir = function(bufnr, on_dir)
      on_dir(vim.fs.root(bufnr, { "biome.json", "biome.jsonc", ".git" }))
    end,
  })

  -- lspconfig sends the full nightly version string ("0.13.0-dev+g..."),
  -- which the Copilot API has been observed to intermittently reject with
  -- "Contact Support" popups; send the plain major.minor.patch a release
  -- build would send instead
  local v = vim.version()
  local editor_version = string.format("%d.%d.%d", v.major, v.minor, v.patch)
  vim.lsp.config("copilot", {
    init_options = {
      editorInfo = { name = "Neovim", version = editor_version },
      editorPluginInfo = { name = "Neovim", version = editor_version },
    },
    settings = {
      telemetry = { telemetryLevel = "off" },
    },
    root_dir = function(bufnr, on_dir)
      if vim.tbl_contains({ "gitcommit", "gitrebase", "jj" }, vim.bo[bufnr].filetype) then
        return
      end
      on_dir(vim.fs.root(bufnr, ".git") or vim.uv.cwd())
    end,
  })

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
    copilot = "copilot-language-server",
  }
  for name, cmd in pairs(servers) do
    if vim.fn.executable(cmd) == 1 then
      vim.lsp.enable(name)
    end
  end

  vim.lsp.inline_completion.enable()

  vim.keymap.set("n", "<leader>e", vim.diagnostic.open_float, { desc = "Show diagnostic" })

  vim.keymap.set("n", "<leader>ih", function()
    vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled())
  end, { desc = "Toggle inlay hints" })

  vim.keymap.set("v", "<leader>r", function()
    vim.lsp.buf.format()
  end, { desc = "Format selection" })
end

return M
