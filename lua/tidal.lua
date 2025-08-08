-- TODO:
-- Post window colors
-- Add keymapping utilities
-- Figure out why `#` char reset indentation
-- Write the api annotations and documentation
-- Pattern highlights !

local config = require("tidal.config")
local editor = require("tidal.editor")

local M = {}

M.setup = function(opts)
	opts = opts or {}
	config.resolve(opts)
	editor.setup()
end

return M
