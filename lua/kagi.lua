local M = {}

--- Replace the currently selected text with the first code answer from Kagi
function M.replaceSelectionOrCurrentLine()
  local req = require("request")
  local extract = require("extract")
  local buffer = vim.api.nvim_get_current_buf()
  local startline = vim.fn.getpos("'<")[2] - 1
  local endline = vim.fn.getpos("'>")[2]
  local currentMode = vim.api.nvim_get_mode().mode
  if currentMode ~= "v" and currentMode ~= "V" then
    endline = vim.fn.getpos(".")[2]
    startline = endline - 1
  end
  local selectedText = table.concat(vim.api.nvim_buf_get_lines(buffer, startline, endline, false), " ")
  if selectedText == "" then
    return
  end
  local query = selectedText .. " Please give an example in " .. vim.api.nvim_get_option_value("filetype", {buf=buffer})
  req.perform(query, function(result)
    --Extract code
    local newText = extract.code(result.data.output)
    local tokens = result.data.tokens
    local balance = result.meta.api_balance
    vim.notify("Tokens: " .. tokens .. " Balance: " .. balance .. "$", vim.log.levels.INFO)
    vim.api.nvim_buf_set_lines(buffer, startline, endline, false, newText)
  end)
end

return M
