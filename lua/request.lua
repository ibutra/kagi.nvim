local M = {}

local fidgetAvailable, fidgetprogress = pcall(require, "fidget.progress")

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
  local progressHandle = nil
  if fidgetAvailable then
    progressHandle = fidgetprogress.handle.create({
      title = "Fetching Answer",
      lsp_client = {name = "Kagi"}
    })
  end
  vim.system(cmd, {}, vim.schedule_wrap(function(result)
    if progressHandle then
      progressHandle:finish()
    end
    if result.code ~= 0 then
      vim.notify(result.stderr, vim.log.levels.ERROR)
      return
    end
    local decoded = vim.json.decode(result.stdout, {object=true, array=true})
    if decoded.error ~= nil then
      vim.notify(decoded.error[1].msg, vim.log.levels.ERROR)
      vim.notify("Prompt:" .. prompt)
      return
    end
    result_cb(decoded)
  end))
end

return M
