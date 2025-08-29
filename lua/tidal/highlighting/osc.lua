local OSC = {}

local losc = require("losc")
local pluginLibUv = require("losc.src.losc.plugins.udp-libuv")

local highlight = require("tidal.highlighting.highlights")
local marker = require("tidal.highlighting.marker")

OSC.messageBuffer = {}
OSC.activeMessages = {}

local function buildMap(events)
  local map = {}
  for _, evt in ipairs(events) do
    local key = evt.buf .. ":" .. evt.markerId
    map[key] = evt
  end
  return map
end

function OSC.diffEventLists(prevEvents, currentEvents)
  local removed = {}
  local added = {}
  local active = {}

  local prevMap = buildMap(prevEvents)
  local currMap = buildMap(currentEvents)

  -- Check removed and active
  for key, prevEvt in pairs(prevMap) do
    local currEvt = currMap[key]
    if currEvt then
      table.insert(active, prevEvt) -- still valid
    else
      table.insert(removed, prevEvt)
    end
  end

  -- Check added
  for key, currEvt in pairs(currMap) do
    if not prevMap[key] then
      table.insert(added, currEvt)
    end
  end

  return {
    removed = removed,
    added = added,
    active = active,
  }
end

local function startServer(host, port)
  local transport = pluginLibUv.new({ recvAddr = host, recvPort = port })
  local osc = losc.new({ plugin = transport })

  osc:add_handler("/editor/highlights", function(data)
    vim.schedule(function()
      local msg = data.message
      local id = msg[1]
      local colStart = msg[4] + 1
      local eventId = msg[5] - 1
      if marker.extMarks[eventId] and marker.extMarks[eventId][colStart] then
        local extmark = marker.extMarks[eventId][colStart]
        extmark.id = id
        table.insert(OSC.messageBuffer, extmark)
      else
        -- Drops -> Maybe count them?
        -- print(string.format("No extmark found at colStart=%s eventId=%s", tostring(colStart), tostring(eventId)))
      end
    end)
  end)

  osc:open()
end

local function startStyleServer(host, port)
  print("OSC Server was created: " .. host .. " | " .. port)
  local transport = pluginLibUv.new({ recvAddr = host, recvPort = port })
  local osc = losc.new({ plugin = transport })

  osc:add_handler("/neovim/eventhighlighting/addstyle", function(data)
    vim.schedule(function()
      local msg = data.message
      local id = msg[1]
      local color = msg[2]
      print("id: " .. id .. " | color: " .. color)
      highlight.addHl(id, color)
    end)
  end)

  osc:open()
end

function OSC.launch()
  startServer("127.0.0.1", 6013)
  startStyleServer("127.0.0.1", 3335)
end

return OSC
