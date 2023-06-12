local util = require("tidal.util")

local M = {}

---@class TextRange
---@field lines string[] lines of text in the range
---@field start { [1]: integer, [2]: integer } Start position {line, col} (zero-indexed)
---@field finish { [1]: integer, [2]: integer } Finish position {line, col} (zero-indexed)

--- Get a range from either the 'visual' or 'motion' marks
---@param mode "visual" | "motion"
---@return TextRange
local function get_mark(mode)
  local start_char, end_char = unpack(({
    visual = { "<", ">" },
    motion = { "[", "]" },
  })[mode])

  -- Get the start and the end of the selection
  local start_line, start_col = unpack(vim.api.nvim_buf_get_mark(0, start_char))
  local end_line, end_col = unpack(vim.api.nvim_buf_get_mark(0, end_char))
  local selected_lines = vim.api.nvim_buf_get_lines(0, start_line - 1, end_line, false)
  return {
    start = { start_line - 1, start_col },
    finish = { end_line - 1, end_col },
    lines = selected_lines,
  }
end

--- Get the last visual selection
---@return TextRange | nil
function M.get_visual()
  local mode = vim.fn.visualmode()
  local range = get_mark("visual")
  -- line-wise visual
  if mode == "V" then
    return range
  end

  if mode == "v" then
    -- character-wise visual
    -- return the buffer text encompassed by the selection
    local start_line, start_col = unpack(range.start)
    local finish_line, finish_col = unpack(range.finish)
    -- exclude the last char in text if "selection" is set to "exclusive"
    if vim.opt.selection:get() == "exclusive" then
      finish_col = finish_col - 1
    end
    return {
      lines = vim.api.nvim_buf_get_text(0, start_line, start_col, finish_line, finish_col + 1, {}),
      start = { start_line, start_col },
      finish = { finish_line, finish_col },
    }
  end

  -- block-wise visual
  -- return the lines encompassed by the selection, each truncated by the start and end columns
  if mode == "\x16" then
    error("Blockwise visual selection not implemented", vim.log.levels.ERROR)
    -- local _, start_col = unpack(range.start)
    -- local _, end_col = unpack(range.finish)
    -- -- exclude the last col of the block if "selection" is set to "exclusive"
    -- if vim.opt.selection:get() == "exclusive" then
    --   end_col = end_col - 1
    -- end
    -- -- exchange start and end columns for proper substring indexing if needed
    -- -- e.g. instead of str:sub(10, 5), do str:sub(5, 10)
    -- if start_col > end_col then
    --   start_col, end_col = end_col, start_col
    -- end
    -- -- iterate over lines, truncating each one
    -- return {
    --   start = range.start,
    --   finish = range.finish,
    --   lines = vim.tbl_map(function(line)
    --     return line:sub(start_col, end_col)
    --   end, range.lines),
    -- }
  end
end

--- Get the current line
---@return TextRange
function M.get_current_line()
  local line = unpack(vim.api.nvim_win_get_cursor(0), 1) - 1
  local text = vim.api.nvim_get_current_line()
  return {
    lines = { line },
    start = { line, 0 },
    finish = { line, #text },
  }
end

--- Get contiguous block of non-blank lines
---@return TextRange
function M.get_block()
  -- row is 1-indexed
  local row, _ = unpack(vim.api.nvim_win_get_cursor(0))

  -- block_start is zero indexed
  local block_start = row - 1
  while block_start > 0 and not util.line_empty(block_start - 1) do
    block_start = block_start - 1
  end

  -- Block end is zero indexed
  local block_end = row
  local n_lines = vim.api.nvim_buf_line_count(0)
  while block_end < n_lines - 1 and not util.line_empty(block_end) do
    block_end = block_end + 1
  end
  local lines = vim.api.nvim_buf_get_lines(0, block_start, block_end, true)
  return {
    lines = lines,
    start = { block_start, 0 },
    finish = { block_end, #lines[#lines] },
  }
end

return M
