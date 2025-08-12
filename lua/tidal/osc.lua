local postwin = require("tidal.postwin")
local osc = require("osc")
local M = {}

local server = nil
local plugin_name = "[tidal.nvim]"

function M.on_receive(data)
	postwin.post(vim.inspect(data) .. "\n")
end

function M.start_server()
	server = osc.new({
		transport = "udp",
		recvAddr = "127.0.0.1",
		recvPort = 6013,
	})
	server:add_handler("/editor/highlights", function(data)
		if data then
			M.on_receive(data)
		end
	end)
	server:open()
	postwin.post(plugin_name .. " listening for /editor/highlights messages" .. "\n")
end

function M.stop_server()
	if server then
		osc:close()
		server = nil
		postwin.post(plugin_name .. " stopped listening for /editor/highlights messages" .. "\n")
	end
end

return M
