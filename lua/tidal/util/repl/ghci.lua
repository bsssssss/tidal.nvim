local Repl = require("tidal.util.repl.repl")
local marker = require("tidal.highlighting.marker")

---@class Ghci : Repl
local Ghci = Repl:new()
Ghci.__index = Ghci

--- Send multi-line text to GHCi
---@param lines string[]
function Ghci:send_multiline(lines, start)
  marker.cleanUpMarkers(start[1], start[1] + #lines)

  return self:send_line(":{\n" .. table.concat(lines, "\n") .. "\n:}", start)
end

return Ghci
