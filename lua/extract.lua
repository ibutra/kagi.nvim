local M = {}

--- Extract only the first code example from a response.
---@param response string The response from which to extract the code
function M.code(response)
  local lines = {}
  local gatherLines = false
  for line in response:gmatch("([^\n]*)\n?") do
    if line:match("^```") then
      if gatherLines then
        return lines
      end
      gatherLines = true
    elseif gatherLines then
      table.insert(lines, line)
    end
  end
end

return M
