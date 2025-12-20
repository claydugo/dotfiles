if vim.fn.executable("javac") == 0 then
  return
end

vim.opt_local.tabstop = 4
vim.opt_local.shiftwidth = 4
vim.opt_local.expandtab = false

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
map("n", "<leader>tl", gradlew_cmd("./gradlew tasks"), "List gradle tasks")
