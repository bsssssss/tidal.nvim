local ghci = require("tidal.ghci")
local postwin = require("tidal.postwindow")
local format = require("tidal.format")
local M = {}

local function create_user_commands()
	vim.api.nvim_buf_create_user_command(0, "TidalStart", ghci.start, {})
	vim.api.nvim_buf_create_user_command(0, "TidalEval", M.eval, {})
	vim.api.nvim_buf_create_user_command(0, "TidalHush", ghci.hush, {})
	vim.api.nvim_buf_create_user_command(0, "TidalPost", postwin.toggle, {})
	vim.api.nvim_buf_create_user_command(0, "TidalClear", postwin.clear, {})
	vim.api.nvim_buf_create_user_command(0, "TidalStop", ghci.terminate, {})
end

local function create_autocmds()
	local id = vim.api.nvim_create_augroup("tidal_editor", {})
	vim.api.nvim_create_autocmd("FileType", {
		group = id,
		pattern = { "tidal", "tidal_post" },
		callback = function()
			create_user_commands()
		end,
	})
	---@diagnostic disable-next-line: param-type-mismatch
	vim.api.nvim_create_autocmd("VimLeavePre", {
		group = id,
		pattern = { "tidal", "tidal_post" },
		callback = function()
			ghci.terminate()
		end,
	})
end

M.setup = function()
	vim.bo.commentstring = "-- %s"
	vim.bo.smartindent = false -- prevent de-indentation on '#' char
	create_autocmds()
end

local function get_paragraph()
	local cursor_pos = vim.api.nvim_win_get_cursor(0)
	vim.cmd('normal! vip"ty')
	vim.api.nvim_win_set_cursor(0, cursor_pos)
	local expression = vim.fn.getreg("t")
	return vim.trim(expression)
end

function M.eval()
	local paragraph = get_paragraph()
	local expression = format.format_expression(paragraph)
	ghci.send(expression)
end

return M
