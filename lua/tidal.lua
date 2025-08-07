local config = require("tidal.config")
local editor = require("tidal.editor")

local M = {}

M.setup = function(opts)
	opts = opts or {}
	config.resolve(opts)
	editor.setup()
end

return M
