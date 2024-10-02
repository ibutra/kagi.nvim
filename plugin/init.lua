local kagi = require("kagi")

vim.api.nvim_create_user_command("Kagi", kagi.replaceSelectionOrCurrentLine, {range=true})
