local postwin = require("tidal.postwin")
local config = require("tidal.config")
local M = {}

M.proc = nil

function M.is_running()
	return M.proc ~= nil
end

local function on_stdout(data)
	if config.post_window.interpreter then
		postwin.post(data)
	end
end

local function on_stderr(data)
	if config.post_window.interpreter then
		postwin.post(data)
		postwin.open()
	end
end

function M.start()
	if M.is_running() then
		return
	end
	if not config.tidal_boot then
		error("[tidal.nvim] 'tidal_boot' not configured", vim.log.levels.ERROR)
	end

	local args = "-ghci-script=" .. config.tidal_boot
	local proc = vim.system({ "ghci", args }, {
		text = true,
		stdin = true,
		stdout = function(err, data)
			on_stdout(data)
		end,
		stderr = function(err, data)
			on_stderr(data)
		end,
	})
	M.proc = proc
end

function M.send(command)
	if not M.is_running() then
		M.start()
	end
	M.proc:write(command .. "\n")
end

function M.hush()
	M.send("hush")
end

function M.terminate()
	if M.is_running() then
		M.send(":quit")
		-- M.proc:kill("TERM")
		M.proc = nil
	end
end

function M.restart()
	if M.is_running() then
		M.terminate()
	end
	M.start()
end

return M
