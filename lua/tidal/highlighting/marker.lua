local Marker = {}

Marker.extMarks = {} -- eventId -> col -> ExtMark

Marker.ns = vim.api.nvim_create_namespace("tidalEventHighlighting")

local bg = "#7eaefc"
vim.api.nvim_set_hl(0, "CodeHighlight", { bg = bg, foreground = "#000000" })

function Marker.createMarkers(ranges, lineNumber, eventId)
  local curr_buf = vim.api.nvim_get_current_buf()
  for _, value in ipairs(ranges) do
    Marker.extMarks = Marker.extMarks or {}
    Marker.extMarks[eventId] = Marker.extMarks[eventId] or {}

    if value.range_start > 0 then
      local line_text = vim.api.nvim_buf_get_lines(curr_buf, lineNumber - 1, lineNumber, false)[1] or ""
      local line_len = #line_text
      local safe_end_col = math.min(value.range_end, line_len)

      local markerId = vim.api.nvim_buf_set_extmark(curr_buf, Marker.ns, lineNumber - 1, value.range_start - 1, {
        end_col = safe_end_col, -- until EOL
      })

      Marker.extMarks[eventId][value.range_start] = {
        buf = curr_buf,
        markerId = markerId,
        colStart = value.range_start - 1,
        colEnd = value.range_end,
        row = lineNumber - 1,
      } -- extmark
    end
  end
end

function Marker.count()
  local count = 0
  if Marker.extMarks then
    for _, markers in pairs(Marker.extMarks) do
      for _, _ in pairs(markers) do
        count = count + 1
      end
    end
  end

  return count
end

function Marker.print()
  if Marker.extMarks then
    for eventId, markers in pairs(Marker.extMarks) do
      for col, extmark in pairs(markers) do
        print(
          "MarkerId: "
            .. extmark.markerId
            .. " | eventId: "
            .. eventId
            .. " | Row: "
            .. extmark.row
            .. " | colStart: "
            .. extmark.colStart
            .. " | colEnd: "
            .. extmark.colEnd
            .. " | looCol: "
            .. col
        )
      end
    end
  end
end

function Marker.cleanUpMarkers(startRow, endRow)
  for eventId, markers in pairs(Marker.extMarks) do
    for col, extmark in pairs(markers) do
      local oldMarker = vim.api.nvim_buf_get_extmark_by_id(extmark.buf, Marker.ns, extmark.markerId, {})
      local row = oldMarker[1] + 1

      if row >= startRow and row <= endRow then
        vim.api.nvim_buf_del_extmark(extmark.buf, Marker.ns, extmark.markerId)
        Marker.extMarks[eventId][col] = nil
      end
    end
  end
end

function Marker.addAllHighlights()
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

function Marker.removeAllHighlights()
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

return Marker
