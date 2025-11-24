if vim.fn.executable("javac") == 0 then
  return
end

vim.defer_fn(function()
  local ok, ts_highlight = pcall(require, "nvim-treesitter.highlight")
  if ok then
    ts_highlight.attach(vim.api.nvim_get_current_buf(), "java")
  end
end, 100)

vim.opt_local.tabstop = 4
vim.opt_local.shiftwidth = 4
vim.opt_local.expandtab = false

vim.opt_local.suffixesadd:append(".java")
vim.opt_local.path:append("src/main/java/**")
vim.opt_local.path:append("src/test/java/**")

local opts = { buffer = true, noremap = true, silent = true }
vim.keymap.set("n", "<leader>b", ":!./gradlew build<CR>", vim.tbl_extend("force", opts, { desc = "Gradle build" }))
vim.keymap.set("n", "<leader>tt", ":!./gradlew test<CR>", vim.tbl_extend("force", opts, { desc = "Gradle test" }))
vim.keymap.set(
  "n",
  "<leader>tc",
  ":!./gradlew clean build<CR>",
  vim.tbl_extend("force", opts, { desc = "Gradle clean build" })
)
vim.keymap.set("n", "<leader>tj", ":!./gradlew shadowJar<CR>", vim.tbl_extend("force", opts, { desc = "Build JAR" }))

local jdtls_ok, jdtls = pcall(require, "jdtls")
if not jdtls_ok then
  return
end

local root_markers = { "gradlew", ".git", "mvnw", "build.gradle" }
local root_dir = require("jdtls.setup").find_root(root_markers)
if not root_dir then
  return
end

local project_name = vim.fn.fnamemodify(root_dir, ":p:h:t")
local workspace_dir = vim.fn.stdpath("cache") .. "/jdtls-workspace/" .. project_name

local lombok_path = vim.fn.stdpath("cache") .. "/lombok.jar"

if vim.fn.filereadable(lombok_path) == 0 then
  vim.fn.system({
    "curl",
    "-L",
    "-o",
    lombok_path,
    "https://projectlombok.org/downloads/lombok.jar",
  })
end

local jdtls_path = vim.fn.stdpath("data") .. "/mason/packages/jdtls"

if vim.fn.isdirectory(jdtls_path) == 0 then
  return
end

local launcher_path = jdtls_path .. "/plugins/"
local launcher_jar =
  vim.fn.system("find " .. launcher_path .. ' -name "org.eclipse.equinox.launcher_*.jar" | head -1'):gsub("\n", "")

if launcher_jar == "" or vim.fn.filereadable(launcher_jar) == 0 then
  return
end

local config = {
  cmd = {
    "/usr/lib/jvm/java-21-openjdk-amd64/bin/java",
    "-Declipse.application=org.eclipse.jdt.ls.core.id1",
    "-Dosgi.bundles.defaultStartLevel=4",
    "-Declipse.product=org.eclipse.jdt.ls.core.product",
    "-Dlog.protocol=true",
    "-Dlog.level=ALL",
    "-Xmx1g",
    "--add-modules=ALL-SYSTEM",
    "--add-opens",
    "java.base/java.util=ALL-UNNAMED",
    "--add-opens",
    "java.base/java.lang=ALL-UNNAMED",
    "-javaagent:" .. lombok_path,
    "-jar",
    launcher_jar,
    "-configuration",
    jdtls_path .. "/config_linux",
    "-data",
    workspace_dir,
  },
  root_dir = root_dir,
  settings = {
    java = {
      signatureHelp = { enabled = true },
      contentProvider = { preferred = "fernflower" },
      eclipse = {
        downloadSources = true,
      },
      maven = {
        downloadSources = true,
      },
      completion = {
        favoriteStaticMembers = {
          "org.junit.Assert.*",
          "org.junit.jupiter.api.Assertions.*",
        },
      },
      sources = {
        organizeImports = {
          starThreshold = 9999,
          staticStarThreshold = 9999,
        },
      },
      configuration = {
        runtimes = {
          {
            name = "JavaSE-11",
            path = "/usr/lib/jvm/java-11-openjdk-amd64",
          },
        },
      },
      project = {
        referencedLibraries = {
          vim.fn.expand("~/git/forks/claydugo/runelite-api/src/main/java/**/*.java"),
          vim.fn.expand("~/git/forks/claydugo/runelite-client/src/main/java/**/*.java"),
        },
      },
      referencesCodeLens = {
        enabled = true,
      },
      implementationsCodeLens = {
        enabled = true,
      },
    },
  },
  capabilities = require("blink.cmp").get_lsp_capabilities(),
  init_options = {
    bundles = {},
  },
}

jdtls.start_or_attach(config)

vim.keymap.set(
  "n",
  "<leader>d",
  "<Cmd>lua vim.lsp.buf.type_definition()<CR>",
  vim.tbl_extend("force", opts, { desc = "Go to type definition" })
)

vim.keymap.set(
  "n",
  "gd",
  "<Cmd>lua vim.lsp.buf.definition()<CR>",
  vim.tbl_extend("force", opts, { desc = "Go to definition" })
)
vim.keymap.set(
  "n",
  "gD",
  "<Cmd>lua vim.lsp.buf.type_definition()<CR>",
  vim.tbl_extend("force", opts, { desc = "Go to type definition" })
)
vim.keymap.set(
  "n",
  "gi",
  "<Cmd>lua vim.lsp.buf.implementation()<CR>",
  vim.tbl_extend("force", opts, { desc = "Go to implementation" })
)

vim.keymap.set(
  "n",
  "<leader>oi",
  '<Cmd>lua require"jdtls".organize_imports()<CR>',
  vim.tbl_extend("force", opts, { desc = "Organize imports" })
)
vim.keymap.set(
  "n",
  "<leader>ev",
  '<Cmd>lua require"jdtls".extract_variable()<CR>',
  vim.tbl_extend("force", opts, { desc = "Extract variable" })
)
vim.keymap.set(
  "n",
  "<leader>ec",
  '<Cmd>lua require"jdtls".extract_constant()<CR>',
  vim.tbl_extend("force", opts, { desc = "Extract constant" })
)
vim.keymap.set(
  "v",
  "<leader>em",
  '<Esc><Cmd>lua require"jdtls".extract_method(true)<CR>',
  vim.tbl_extend("force", opts, { desc = "Extract method" })
)
