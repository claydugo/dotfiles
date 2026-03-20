if vim.fn.executable("javac") == 0 then
  return
end

-- Attach treesitter when plugin is loaded (avoids race condition)
vim.api.nvim_create_autocmd("User", {
  pattern = "LazyLoad",
  once = true,
  callback = function(args)
    if args.data == "nvim-treesitter" then
      local ok, ts_highlight = pcall(require, "nvim-treesitter.highlight")
      if ok then
        ts_highlight.attach(vim.api.nvim_get_current_buf(), "java")
      end
    end
  end,
})

vim.opt_local.tabstop = 4
vim.opt_local.shiftwidth = 4
vim.opt_local.expandtab = false

vim.opt_local.suffixesadd:append(".java")
vim.opt_local.path:append("src/main/java/**")
vim.opt_local.path:append("src/test/java/**")

local function map(mode, lhs, rhs, desc)
  vim.keymap.set(mode, lhs, rhs, { buffer = true, noremap = true, silent = true, desc = desc })
end

local function gradlew_cmd(cmd)
  return function()
    if vim.fn.filereadable("./gradlew") == 0 then
      vim.notify("gradlew not found in current directory", vim.log.levels.WARN)
      return
    end
    vim.cmd("!" .. cmd)
  end
end

map("n", "<leader>b", gradlew_cmd("./gradlew build"), "Gradle build")
map("n", "<leader>tt", gradlew_cmd("./gradlew test"), "Gradle test")
map("n", "<leader>tc", gradlew_cmd("./gradlew clean build"), "Gradle clean build")
map("n", "<leader>tj", gradlew_cmd("./gradlew shadowJar"), "Build JAR")

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
local launcher_jar = nil
local handle = vim.uv.fs_scandir(launcher_path)
if handle then
  while true do
    local name, type = vim.uv.fs_scandir_next(handle)
    if not name then
      break
    end
    if type == "file" and name:match("^org%.eclipse%.equinox%.launcher_.*%.jar$") then
      launcher_jar = launcher_path .. name
      break
    end
  end
end

if not launcher_jar or vim.fn.filereadable(launcher_jar) == 0 then
  return
end

local java_path = vim.fn.exepath("java")
if java_path == "" then
  vim.notify("java not found in PATH", vim.log.levels.WARN)
  return
end

local config = {
  cmd = {
    java_path,
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

map("n", "<leader>d", "<Cmd>lua vim.lsp.buf.type_definition()<CR>", "Go to type definition")
map("n", "gd", "<Cmd>lua vim.lsp.buf.definition()<CR>", "Go to definition")
map("n", "gD", "<Cmd>lua vim.lsp.buf.type_definition()<CR>", "Go to type definition")
map("n", "gi", "<Cmd>lua vim.lsp.buf.implementation()<CR>", "Go to implementation")
map("n", "<leader>oi", '<Cmd>lua require"jdtls".organize_imports()<CR>', "Organize imports")
map("n", "<leader>ev", '<Cmd>lua require"jdtls".extract_variable()<CR>', "Extract variable")
map("n", "<leader>ec", '<Cmd>lua require"jdtls".extract_constant()<CR>', "Extract constant")
map("v", "<leader>em", '<Esc><Cmd>lua require"jdtls".extract_method(true)<CR>', "Extract method")
