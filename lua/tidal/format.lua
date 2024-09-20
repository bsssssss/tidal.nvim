local M = {}

local function indent_string()
	return string.rep(" ", 4)
end

local function tab_to_space(text)
	return text:gsub("\t", indent_string())
end

local function wrap_multi(lines)
	if #lines > 1 then
		table.insert(lines, 1, ":{")
		table.insert(lines, ":}")
	end
	return lines
end

M.format_expression = function(text)
	local lines = vim.split(tab_to_space(text), "\n")
	lines = wrap_multi(lines)
	return table.concat(lines, "\n")
end

return M
