local M = {}

local default = {
	tidal_boot = nil,
    post_window = {
        split = "right",
        width = math.floor(vim.o.columns / 3),
    }
}

setmetatable(M, {
  __index = function(self, key)
    local config = rawget(self, 'config')
    if config then
      return config[key]
    end
    return default[key]
  end,
})

--- Merge the user configuration with the default values.
---@param config {} The user configuration
function M.resolve(config)
  config = config or {}
  M.config = vim.tbl_deep_extend('keep', config, default)
end

return M
