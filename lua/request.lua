local M = {}

--- Perform a request to the KAGI FastGPT api and return the result
---@param prompt string The prompt to send to KAGI
---@param result_cb fun(result: table) Function which is called when the result is ready. result has the fields:
---   - data:
---     - output: The actual response
---     - tokens: The number of used tokens
---     - references: Table of references
---     - references_text: Text for references
---   - meta:
---     - id: An id
---     - node: which node handled the request
---     - api_balance: how much money is left
---     - ms: time the response took to generate
function M.perform(prompt, result_cb)
  local token = os.getenv("KAGI_API_TOKEN") --TODO: make this configurable
  local cmd = {'curl', '-H', 'Authorization: Bot ' .. token, '-H', 'Content-Type: application/json', '-d', '{"query": "' .. prompt ..'"}', 'https://kagi.com/api/v0/fastgpt'}
  vim.system(cmd, {}, vim.schedule_wrap(function(result)
    if result.code ~= 0 then
      vim.notify(result.stderr)
      return
    end
    result_cb(vim.json.decode(result.stdout, {object=true, array=true}))
  end))
end

M.perform("A go function which returns a slice of lines of a file", function(result)
  print(vim.inspect(result))
end)

return M
