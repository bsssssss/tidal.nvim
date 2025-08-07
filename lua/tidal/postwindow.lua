local config = require("tidal.config")

local M = {}

M.bufnr = nil
M.win_id = nil
M.job_id = nil

function M.create()
	local window_id = vim.api.nvim_get_current_win()
	if not M.bufnr then
		M.bufnr = vim.api.nvim_create_buf(false, true)
		vim.api.nvim_buf_set_name(M.bufnr, "GHCI")
		M.open()
		if M.win_id then
			vim.api.nvim_set_current_win(M.win_id)
			M.job_id = vim.fn.termopen(vim.o.shell)
			vim.cmd("normal! G")
			vim.api.nvim_set_current_win(window_id)
		else
			error("Cannot start ghci", vim.log.levels.ERROR)
		end
	end
end

function M.open()
	local postwin_config = vim.tbl_deep_extend("force", config.post_window, { win = 0 })
	if M.bufnr and not M.win_id then
		M.win_id = vim.api.nvim_open_win(M.bufnr, false, postwin_config)
	else
		error("[tidal.nvim] cannot open post window")
	end
end

function M.close()
	if M.win_id and vim.api.nvim_win_is_valid(M.win_id) then
		vim.api.nvim_win_close(M.win_id, true)
		M.win_id = nil
	end
end

function M.toggle()
	if M.win_id and vim.api.nvim_win_is_valid(M.win_id) then
		M.close()
	elseif M.bufnr then
		local window_id = vim.api.nvim_get_current_win()
		M.open()
		if M.win_id then
			vim.api.nvim_set_current_win(M.win_id)
			vim.cmd("normal! G")
			vim.api.nvim_set_current_win(window_id)
		else
			print("no window ID")
		end
	end
end

return M
