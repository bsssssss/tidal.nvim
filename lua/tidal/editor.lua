local ghci = require("tidal.ghci")
local format = require("tidal.format")
local M = {}

local function add_filetype()
	vim.filetype.add({
		extension = {
			tidal = "tidal",
			tidal_post = "tidal_post",
		},
	})
end

local function create_autocmds()
	local id = vim.api.nvim_create_augroup("tidal_editor", {})
	vim.api.nvim_create_autocmd("FileType", {
		group = id,
		pattern = { "tidal", "tidal_post" },
		callback = require("tidal.commands"),
	})
	---@diagnostic disable-next-line: param-type-mismatch
	vim.api.nvim_create_autocmd("VimLeavePre", {
		group = id,
		pattern = { "tidal", "tidal_post" },
		callback = function()
			ghci.on_close()
		end,
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
	return vim.trim(expression)
end

function M.eval()
	local paragraph = M.get_paragraph()
	local expression = format.format_expression(paragraph)
	if not ghci.is_running() then
		ghci.start()
	end
	ghci.send(expression)
end

return M
