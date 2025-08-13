local M = {}

M.registered = {}

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

local function parse_line(line)
	local comment = line:match("[-]+")
	if comment then
		return
	end
	return line
end

function M.parse(text)
	local lines = vim.split(text, "\n")
	for i, line in ipairs(lines) do
		print(parse_line(line))
	end
end

-- function M.register(paragraph)
-- 	local ids = M.get_ids(paragraph)
-- 	if #ids > 0 then
-- 		for _, id in ipairs(ids) do
-- 			M.registered[id] = {
-- 				expression = paragraph,
-- 			}
-- 		end
-- 	end
-- end

return M
