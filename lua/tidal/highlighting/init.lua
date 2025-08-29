local EventHighlights = {}

local highlights = require("tidal.highlighting.highlights")
local osc = require("tidal.highlighting.osc")

local uv = vim.uv

EventHighlights.timer = nil

local function merge_arrays_of_tables(t1, t2)
  local res = {}
  for _, v in ipairs(t1) do
    table.insert(res, v)
  end
  for _, v in ipairs(t2) do
    table.insert(res, v)
  end
  return res
end

local function handleMessages()
  local diff = osc.diffEventLists(osc.activeMessages, osc.messageBuffer)

  for _, evt in ipairs(diff.added) do
    highlights.addHighlight(evt.buf, evt.markerId, evt.row, evt.colStart, evt.colEnd)
  end

  for _, evt in ipairs(diff.removed) do
    highlights.removeHighlight(evt.buf, evt.markerId, evt.row, evt.colStart, evt.colEnd)
  end

  osc.activeMessages = merge_arrays_of_tables(diff.active, diff.added)
  osc.messageBuffer = {}
end

local function setInterval(interval, callback)
  EventHighlights.timer = uv.new_timer()
  EventHighlights.timer:start(interval, interval, function()
    vim.schedule(callback)
  end)
end

-- And clearInterval
local function clearInterval()
  EventHighlights.timer:stop()
  EventHighlights.timer:close()
  EventHighlights.timer = nil
end

function EventHighlights.start(fps)
  osc.launch()

  setInterval(fps, handleMessages)
end

function EventHighlights.stop()
  clearInterval()
end

return EventHighlights
