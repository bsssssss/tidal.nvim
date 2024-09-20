local M = {}

local ghci_bufnr = nil
local ghci_win_id = nil
local ghci_job_id = nil

local config = {
	tidal_boot = nil,
}

local function open_postwin()
	-- store original window id
	local window_id = vim.api.nvim_get_current_win()

	-- create buffer
	if not ghci_bufnr then
		ghci_bufnr = vim.api.nvim_create_buf(false, true)
		vim.api.nvim_buf_set_name(ghci_bufnr, "Ghci - Tidal")
	end

	-- open post window
	ghci_win_id = vim.api.nvim_open_win(ghci_bufnr, false, {
		split = "below",
		height = 15,
		win = 0,
	})

	-- focus post window
	vim.api.nvim_set_current_win(ghci_win_id)

	-- enter the shell
	ghci_job_id = vim.fn.termopen(vim.o.shell)

	-- focus back
	vim.api.nvim_set_current_win(window_id)
end

local function get_paragraph()
	-- store cursor position
	local cursor_pos = vim.api.nvim_win_get_cursor(0)
	vim.cmd('normal! vip"ty')
	-- reset cursor
	vim.api.nvim_win_set_cursor(0, cursor_pos)
	-- get paragraph
	local expression = vim.fn.getreg("t")
	return expression
end

local function send_ghci(text)
	if ghci_job_id then
		vim.api.nvim_chan_send(ghci_job_id, text .. "\n")
	end
end

-- Public Functions

M.tidal_start = function()
	if config.tidal_boot then
		local command = "ghci -ghci-script=" .. config.tidal_boot
		open_postwin()
		send_ghci(command)
	else
		print("No Bootfile !")
	end
end

M.tidal_send = function()
	local paragraph = get_paragraph()
	local expression = require("tidal.format").format_expression(paragraph)
	if not ghci_bufnr then
		M.tidal_start()
	end
	send_ghci(expression)
end

M.setup = function(opts)
	config = vim.tbl_deep_extend("force", config, opts or {})
end

return M
