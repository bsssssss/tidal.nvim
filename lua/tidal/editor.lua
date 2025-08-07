local ghci = require("tidal.ghci")
local postwin = require("tidal.postwindow")
local M = {}

local function add_filetype()
	vim.filetype.add({
		extension = {
			tidal = "tidal",
		},
	})
end

local function create_autocmds()
	local id = vim.api.nvim_create_augroup("tidal_editor", {})
	vim.api.nvim_create_autocmd("FileType", {
		group = id,
		pattern = "tidal",
		callback = require("tidal.commands"),
	})
end

M.setup = function()
	add_filetype()
	create_autocmds()
end

function M.get_paragraph()
	local cursor_pos = vim.api.nvim_win_get_cursor(0)
	vim.cmd('normal! vip"ty')
	vim.api.nvim_win_set_cursor(0, cursor_pos)
	local expression = vim.fn.getreg("t")
	return expression
end

function M.eval()
	local paragraph = M.get_paragraph()
	local expression = require("tidal.format").format_expression(paragraph)
	if not postwin.bufnr then
		ghci.start()
	end
	ghci.send(expression)
end

return M
