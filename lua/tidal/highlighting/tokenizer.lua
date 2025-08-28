local Tokenizer = {}

package.loaded["tidal.highlighting.textprocessor"] = nil
local marker = require("tidal.highlighting.marker")
local textProcessor = require("tidal.highlighting.textprocessor")

local lastEventId = 0

local function addDeltaContext(line, eventId)
  local result = line:gsub(textProcessor.controlPatternsRegex(), function(startPos, content, _)
    local before = line:sub(1, startPos - 1)

    if before:match(textProcessor.exceptedFunctionPatterns()) then
      return '"' .. content .. '"'
    end

    return string.format('(deltaContext %d %d "%s")', startPos - 1, eventId, content)
  end)
  return result
end

local function findReplacementRanges(line)
  local replacements = {}
  textProcessor.findTidalWordRanges(line, function(replacement)
    table.insert(replacements, replacement)
  end)

  return replacements
end

local function updateEventId()
  lastEventId = lastEventId + 1
end

function Tokenizer.addMetadata(line, lineNumber)
  local replacements = findReplacementRanges(line)

  if #replacements > 0 then
    -- 1. cleanUpMarkers
    -- 2. updateEventId
    -- 3. create position markers
    -- 4. addDeltaContext
    --
    updateEventId()
    marker.createMarkers(replacements, lineNumber, lastEventId)
    return addDeltaContext(line, lastEventId)
  else
    return line
  end
end

return Tokenizer
