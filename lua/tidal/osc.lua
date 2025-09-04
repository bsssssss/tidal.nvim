local postwin = require("tidal.postwin")
local config = require("tidal.config")
local osc = require("osc")
local M = {}

local server = nil

function M.on_receive(data)
	if config.postwin.oscdump == true then
		postwin.post(vim.inspect(data) .. "\n")
	end
end

function M.start_server()
	server = osc.new({
		transport = "udp",
		recvAddr = config.osc.address,
		recvPort = config.osc.port,
	})
	server:add_handler("/editor/highlights", function(data)
		if data then
			M.on_receive(data)
		end
	end)
	server:open()
	vim.notify("Listening for external messages on port " .. config.osc.port, vim.log.levels.INFO)
end

function M.stop_server()
	if server then
		osc:close()
		server = nil
		vim.notify("Stopped listening for external messages on port " .. config.osc.port)
	end
end

return M
