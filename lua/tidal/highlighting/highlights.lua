local Highlights = {}

local Marker = require("tidal.highlighting.marker")

function Highlights.addHighlight(buf, markerId, row, colStart, colEnd)
  local extMark = vim.api.nvim_buf_get_extmark_by_id(buf, Marker.ns, markerId, {})

  if extMark[2] > 0 then
    -- Create Highlight
    vim.api.nvim_buf_set_extmark(buf, Marker.ns, row, colStart, {
      end_col = colEnd,
      id = markerId,
      hl_group = "CodeHighlight",
    })
  end
end

function Highlights.addAllHighlights()
  for _, markers in pairs(Marker.extMarks) do
    for _, marker in pairs(markers) do
      local oldMarker = vim.api.nvim_buf_get_extmark_by_id(marker.buf, Marker.ns, marker.markerId, {})

      if oldMarker[2] > 0 then
        -- Create Highlight
        vim.api.nvim_buf_set_extmark(marker.buf, Marker.ns, oldMarker[1], oldMarker[2], {
          end_col = marker.colEnd,
          id = marker.markerId,
          hl_group = "CodeHighlight",
        })
      end
    end
  end
end

function Highlights.removeHighlight(buf, markerId, row, colStart, colEnd)
  local extMark = vim.api.nvim_buf_get_extmark_by_id(buf, Marker.ns, markerId, {})

  if extMark[2] > 0 then
    -- Create Highlight
    vim.api.nvim_buf_set_extmark(buf, Marker.ns, row, colStart, {
      end_col = colEnd,
      id = markerId,
      hl_group = nil,
    })
  end
end

function Highlights.removeAllHighlights()
  for _, markers in pairs(Marker.extMarks.eventid) do
    for _, marker in pairs(markers) do
      local oldMarker = vim.api.nvim_buf_get_extmark_by_id(marker.buf, Marker.ns, marker.markerId, {})

      -- Delete Highlight
      vim.api.nvim_buf_set_extmark(marker.buf, Marker.ns, oldMarker[1], oldMarker[2], {
        end_col = marker.colEnd,
        id = marker.markerId,
        hl_group = nil,
      })
    end
  end
end

return Highlights
