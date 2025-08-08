local postwin = require("tidal.postwindow")
local config = require("tidal.config")
local M = {}

M.proc = nil

function M.is_running()
	return M.proc ~= nil
end

function M.start()
	if M.proc then
		return M.proc
	end
	if not config.tidal_boot then
		error(
			"[tidal.nvim] Cannot start ghci, you should set `tidal_boot` to your `BootFile.hs` path",
			vim.log.levels.ERROR
		)
	end
	if not postwin.buf_is_valid() then
		postwin.create_buf()
	end

	local args = "-ghci-script=" .. config.tidal_boot
	local proc = vim.system({ "ghci", args }, {
		text = true,
		stdin = true,
		stdout = function(err, data)
			postwin.post(data)
		end,
		stderr = function(err, data)
			postwin.post(data)
		end,
	})
	M.proc = proc
end

function M.send(command)
	if not M.proc then
		error("[tidal.nvim] cannot send command, ghci not started", vim.log.levels.ERROR)
	end
	M.proc:write(command .. "\n")
end

function M.hush()
	M.send("hush")
end

function M.on_close()
	if M.is_running() then
		M.proc:kill("KILL")
	end
end

return M
