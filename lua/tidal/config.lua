local M = {}

local default = {
	tidal_boot = nil,
	postwin = {
		oscdump = true,
		interpreter = true,
		win = {
			split = "right",
			width = math.floor(vim.o.columns / 2),
		},
	},
    osc = {
        address = "127.0.0.1",
        port = 6013,
    }
}

setmetatable(M, {
	__index = function(self, key)
		local config = rawget(self, "config")
		if config then
			return config[key]
		end
		return default[key]
	end,
})

--- Merge the user configuration with the default values.
---@param user_config {} The user configuration
function M.merge_with(user_config)
	user_config = user_config or {}
	M.config = vim.tbl_deep_extend("keep", user_config, default)
end

return M
