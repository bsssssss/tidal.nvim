package.loaded["tidal.highlighting.marker"] = nil
package.loaded["tidal.highlighting.highlights"] = nil
package.loaded["tidal.highlighting.tokenizer"] = nil

local highlights = require("tidal.highlighting.highlights")
local marker = require("tidal.highlighting.marker")
local osc = require("tidal.highlighting.osc")
local tokenizer = require("tidal.highlighting.tokenizer")

local multiLineExample = [[
:{
  do
    d4 $ s "sally" <| note "c'maj'8"
    d2 $ while "t*2 t" (# silence) $ s "fbass"
    d3 $ s "sally" <| note "c'maj'8"
    d1 $ s "superpiano" <| note "c a f e"
    d5 $ s "bubu" # speed "-1.0"
:}
]]

local bg = "#7eaefc"
vim.api.nvim_set_hl(0, "CodeHighlight", { bg = bg, foreground = "#000000" })

local initRow = 11
local rowIndex = 0
local _, newlines = multiLineExample:gsub("\n", "")

marker.cleanUpMarkers(initRow, initRow + newlines - 1)

for line in multiLineExample:gmatch("[^\r\n]+") do
  tokenizer.addMetadata(line, initRow + rowIndex)
  rowIndex = rowIndex + 1
end

for _, markers in pairs(marker.extMarks) do
  for _, extmark in pairs(markers) do
    highlights.addHighlight(extmark.buf, extmark.markerId, extmark.row, extmark.colStart, extmark.colEnd)
  end
end

local prevEvents = {
  { buf = 1, markerId = 101, colStart = 0, colEnd = 5, row = 1 },
  { buf = 1, markerId = 102, colStart = 6, colEnd = 10, row = 1 },
  { buf = 2, markerId = 201, colStart = 0, colEnd = 3, row = 2 },
  { buf = 2, markerId = 202, colStart = 4, colEnd = 7, row = 2 },
}

local currentEvents = {
  { buf = 1, markerId = 101, colStart = 0, colEnd = 5, row = 1 }, -- same as before → active
  { buf = 1, markerId = 102, colStart = 8, colEnd = 12, row = 1 }, -- buf+markerId same, but position changed → active
  { buf = 3, markerId = 301, colStart = 0, colEnd = 4, row = 3 }, -- new → added
  { buf = 2, markerId = 203, colStart = 8, colEnd = 10, row = 2 }, -- new → added
} -- marker.deleteAllMarkers()

local function printEvents(label, events)
  print(label .. ":")
  for _, e in ipairs(events) do
    print(
      string.format(
        "  buf=%d, markerId=%d, colStart=%d, colEnd=%d, row=%d",
        e.buf,
        e.markerId,
        e.colStart,
        e.colEnd,
        e.row
      )
    )
  end
end

-- Run diff
local diff = osc.diffEventLists(prevEvents, currentEvents)

printEvents("Removed", diff.removed)
printEvents("Added", diff.added)
printEvents("Active", diff.active)

-- for _, markers in pairs(marker.extMarks) do
--   for _, extmark in pairs(markers) do
--     highlights.removeHighlight(extmark.buf, extmark.markerId, extmark.row, extmark.colStart, extmark.colEnd)
--   end
-- end
-- local singleLine = [[d4 $ s "sally" <| note "c'maj'8"]]
--
-- local bg = "#7eaefc"
-- vim.api.nvim_set_hl(0, "CodeHighlight", { bg = bg, foreground = "#000000" })
--
-- local initRow = 43
--
-- print(marker.count())
--
-- tokenizer.addMetadata(singleLine, initRow)
--
-- print(marker.count())
--
-- marker.cleanUpMarkers(initRow, initRow)
--
-- marker.addAllHighlights()
--
-- marker.cleanUpMarkers(initRow, initRow)
--
-- print(marker.count())
