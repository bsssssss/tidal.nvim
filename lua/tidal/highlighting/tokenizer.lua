local Tokenizer = {}

local lineProcessor = require("tidal.highlighting.lineprocessor")
local marker = require("tidal.highlighting.marker")

Tokenizer.lastEventId = 0

local function addDeltaContext(line)
  local result = line:gsub(lineProcessor.controlPatternsRegex(), function(startPos, content, _)
    local before = line:sub(1, startPos - 1)

    if before:match(lineProcessor.exceptedFunctionPatterns()) then
      return '"' .. content .. '"'
    end

    return string.format('(deltaContext %i %i "%s")', startPos - 1, Tokenizer.lastEventId, content)
  end)

  return result
end

local function findReplacementRanges(line)
  local replacements = {}
  lineProcessor.findTidalWordRanges(line, function(replacement)
    table.insert(replacements, replacement)
  end)

  return replacements
end

local function updateEventId()
  Tokenizer.lastEventId = Tokenizer.lastEventId + 1
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
    marker.createMarkers(replacements, lineNumber, Tokenizer.lastEventId)
    return addDeltaContext(line)
  else
    return line
  end
end

return Tokenizer
