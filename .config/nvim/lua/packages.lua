local M = {}

M.treesitter = {
  "python",
  "lua",
  "wgsl",
  "cuda",
  "rust",
  "c",
  "bash",
  "html",
  "markdown",
  "markdown_inline",
  "json",
  "toml",
  "yaml",
  "qmldir",
  "luadoc",
  "desktop",
  "tmux",
  "ssh_config",
  "git_config",
  "git_rebase",
  "gitattributes",
  "gitcommit",
  "gitignore",
}

M.mason = {
  "biome",
  "harper-ls",
  "bash-language-server",
  "emmylua_ls",
  "rust-analyzer",
  "shellcheck",
  "wgsl-analyzer",
  "clangd",
  "taplo",
  "yaml-language-server",
}

M.treesitter_java = { "java", "groovy" }
M.mason_java = { "jdtls" }

return M
