local tidal = require("tidal")

local function add_command(name, fn, desc)
	vim.api.nvim_buf_create_user_command(0, name, fn, { desc = desc })
end

return function()
	add_command("TidalStart", tidal.tidal_start(), "Start a ghci session - Load tidal")
	add_command("TidalSend", tidal.tidal_send, "Send paragraph at cursor position")
end
