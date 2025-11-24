-- Java LSP support via nvim-jdtls
-- Only activates for .java files (see ftplugin/java.lua)
return {
  "mfussenegger/nvim-jdtls",
  ft = "java", -- Only load for Java files
  dependencies = {
    "williamboman/mason.nvim",
  },
}
