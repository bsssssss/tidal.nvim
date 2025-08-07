local ghci = require("tidal.ghci")
local postwin = require("tidal.postwindow")
local editor = require("tidal.editor")

return function()
	vim.api.nvim_buf_create_user_command(0, "TidalStart", ghci.start, {})
	vim.api.nvim_buf_create_user_command(0, "TidalEval", editor.eval, {})
	vim.api.nvim_buf_create_user_command(0, "TidalHush", ghci.hush, {})
	vim.api.nvim_buf_create_user_command(0, "TidalPost", postwin.toggle, {})
end
