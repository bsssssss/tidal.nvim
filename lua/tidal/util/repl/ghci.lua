local Repl = require("tidal.util.repl.repl")

---@class Ghci : Repl
local Ghci = Repl:new()
Ghci.__index = Ghci

--- Send multi-line text to GHCi
---@param lines string[]
function Ghci:send_multiline(lines)
  return self:send_line(":{\n" .. table.concat(lines, "\n") .. "\n:}")
end

return Ghci
