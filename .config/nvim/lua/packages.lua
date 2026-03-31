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
  "json",
  "toml",
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
  "lua-language-server",
  "rust-analyzer",
  "shellcheck",
}

M.treesitter_java = { "java", "groovy" }
M.mason_java = { "jdtls" }

return M
