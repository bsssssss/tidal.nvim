-- line_processor.lua

local TextProcessor = {}

-- private constants
local DIGIT_MIN = 48
local DIGIT_MAX = 57
local UPPERCASE_MIN = 65
local UPPERCASE_MAX = 90
local LOWERCASE_MIN = 97
local LOWERCASE_MAX = 122
local DOT = 46
local MINUS = 45
local COLON = 58
local QUOTATION_MARK = 34

-- helper: get char code (Lua doesn't have charCodeAt)
local function charCodeAt(str, idx)
  return string.byte(str, idx, idx)
end

-- Valid TidalCycles word chars
function TextProcessor.isValidTidalWordChar(character)
  local code = charCodeAt(character, 1)
  return (code >= DIGIT_MIN and code <= DIGIT_MAX)
    or (code >= UPPERCASE_MIN and code <= UPPERCASE_MAX)
    or (code >= LOWERCASE_MIN and code <= LOWERCASE_MAX)
    or (code == DOT)
    or (code == MINUS)
    or (code == COLON)
end

function TextProcessor.isQuotationMark(character)
  return charCodeAt(character, 1) == QUOTATION_MARK
end

-- Find tidal word ranges inside quotes
function TextProcessor.findTidalWordRanges(line, callback)
  local insideQuotes = false
  local startPos = nil
  local endPos = nil

  for i = 1, #line do
    local char = string.sub(line, i, i)

    if TextProcessor.isQuotationMark(char) then
      insideQuotes = not insideQuotes
    end

    if insideQuotes and TextProcessor.isValidTidalWordChar(char) then
      if startPos == nil then
        startPos = i
        endPos = i
      else
        endPos = i
      end
    else
      if startPos ~= nil and endPos ~= nil then
        callback({ range_start = startPos, range_end = endPos })
        startPos = nil
        endPos = nil
      end
    end
  end
end

-- Regex patterns (Lua style)
function TextProcessor.controlPatternsRegex()
  return '()"([^"]-)"()'
  -- return [["([^"]*)"]] -- matches quoted text
end

function TextProcessor.exceptedFunctionPatterns()
  return [[numerals%s*=.*$|p%s.*$]]
end

return TextProcessor
