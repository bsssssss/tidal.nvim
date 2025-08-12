local postwin = require("tidal.postwin")
local M = {}

local function get_ids(expression)
	local ids = {}

	-- match on `p <number>`
	for id in expression:gmatch("p%s+(%d+)") do
		table.insert(ids, id)
	end

	-- match on `p <string>`
	for id in expression:gmatch('p%s+"([^"]*)"') do
		table.insert(ids, id)
	end

	-- match on `p d<number>`
	for id in expression:gmatch("d(%d+)") do
		table.insert(ids, id)
	end

	return ids
end

M.active = {}

function M.store(expression)
	local ids = get_ids(expression)

	if #ids > 0 then
		for _, id in ipairs(ids) do
			M.active[id] = {
				expression = expression,
			}
		end
	end
	postwin.post("\n stored patterns: " .. vim.inspect(M.active) .. "\n")
end

return M
