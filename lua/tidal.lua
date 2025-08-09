-- TODO:
-- Add keymapping utilities
-- Write the api annotations
-- Write documentation
-- Pattern highlights !

local config = require("tidal.config")
local editor = require("tidal.editor")

local M = {}

M.setup = function(opts)
	opts = opts or {}
	config.merge_with(opts)
	editor.setup()
end

return M
