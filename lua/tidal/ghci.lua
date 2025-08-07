local postwin = require("tidal.postwindow")
local config = require("tidal.config")

local M = {}

function M.start()
	if config.tidal_boot then
		local command = "ghci -ghci-script=" .. config.tidal_boot
		postwin.create()
		M.send(command)
	else
		error("[tidal.nvim] No Bootfile !", vim.log.levels.ERROR)
	end
end

function M.send(command)
	if postwin.job_id then
		vim.api.nvim_chan_send(postwin.job_id, command .. "\n")
	end
end

function M.hush()
	M.send("hush")
end

return M
