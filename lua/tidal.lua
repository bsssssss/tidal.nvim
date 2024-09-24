local M = {}

local ghci_bufnr = nil
local ghci_win_id = nil
local ghci_job_id = nil

local config = {
	tidal_boot = nil,
}

local function open_postwindow()
	if ghci_bufnr and not ghci_win_id then
		ghci_win_id = vim.api.nvim_open_win(ghci_bufnr, false, {
			split = "below",
			height = 15,
			win = 0,
		})
	else
		print("Cannot open post window: buffer is nil or post window is already open")
	end
end

local function close_postwindow()
	if ghci_win_id and vim.api.nvim_win_is_valid(ghci_win_id) then
		vim.api.nvim_win_close(ghci_win_id, true)
		ghci_win_id = nil
	end
end

local function start_ghci()
	-- store original window id
	local window_id = vim.api.nvim_get_current_win()

	-- create buffer
	if not ghci_bufnr then
		ghci_bufnr = vim.api.nvim_create_buf(false, true)
		vim.api.nvim_buf_set_name(ghci_bufnr, "Ghci - Tidal")

		open_postwindow()
		if ghci_win_id then
			vim.api.nvim_set_current_win(ghci_win_id)
			ghci_job_id = vim.fn.termopen(vim.o.shell)
			vim.cmd("normal! G")
			vim.api.nvim_set_current_win(window_id)
		else
			print("Cannot start ghci: no window ID")
		end
	end
end

local function toggle_ghci()
	if ghci_win_id and vim.api.nvim_win_is_valid(ghci_win_id) then
		close_postwindow()
	elseif ghci_bufnr then
		local window_id = vim.api.nvim_get_current_win()
		open_postwindow()
		if ghci_win_id then
			vim.api.nvim_set_current_win(ghci_win_id)
			vim.cmd("normal! G")
			vim.api.nvim_set_current_win(window_id)
		else
			print("no window ID")
		end
	end
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

M.toggle_ghci = toggle_ghci

M.tidal_start = function()
	if config.tidal_boot then
		local command = "ghci -ghci-script=" .. config.tidal_boot
		start_ghci()
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

M.tidal_hush = function()
	send_ghci("hush")
end

M.setup = function(opts)
	config = vim.tbl_deep_extend("force", config, opts or {})

	vim.api.nvim_create_user_command("TidalStart", M.tidal_start, {})
	vim.api.nvim_create_user_command("TidalSend", M.tidal_send, {})
	vim.api.nvim_create_user_command("TidalHush", M.tidal_hush, {})
	vim.api.nvim_create_user_command("TidalPost", M.toggle_ghci, {})

	vim.api.nvim_create_augroup("Tidal", { clear = true })
	vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
		group = "Tidal",
		pattern = "*.tidal",
		callback = function()
			print("entering a tidal file..")
			vim.keymap.set({ "n", "i" }, "<D-e>", "<cmd>TidalSend<CR>", { desc = "Send to tidal" })
			vim.keymap.set({ "n", "i" }, "<D-.>", "<cmd>TidalHush<CR>", { desc = "Silence tidal" })
			vim.keymap.set("n", "<CR>", "<cmd>TidalPost<CR>", { desc = "Toggle Postwindow" })
		end,
	})
end

return M
