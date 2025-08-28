local OSC = {}

local losc = require("losc")
local pluginLibUv = require("losc.src.losc.plugins.udp-libuv")

local highlights = require("tidal.highlighting.highlights")
local marker = require("tidal.highlighting.marker")

local function startServer(host, port)
  local transport = pluginLibUv.new({ recvAddr = host, recvPort = port })
  local osc = losc.new({ plugin = transport })

  osc:add_handler("/editor/highlights", function(data)
    vim.schedule(function()
      local msg = data.message
      local colStart = msg[4] + 1
      local eventId = msg[5] - 1
      if marker.extMarks[eventId] and marker.extMarks[eventId][colStart] then
        local extmark = marker.extMarks[eventId][colStart]
        highlights.addHighlight(extmark.buf, extmark.markerId, extmark.row, extmark.colStart, extmark.colEnd)
      else
        print(string.format("No extmark found at colStart=%s eventId=%s", tostring(colStart), tostring(eventId)))
      end
    end)
  end)

  osc:open()
end

function OSC.launch()
  startServer("127.0.0.1", 6013)
end

return OSC
