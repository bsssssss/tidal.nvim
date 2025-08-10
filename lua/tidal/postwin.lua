local config = require("tidal.config")
local api = vim.api
local M = {}

M.buf = nil
M.win = nil

function M.buf_is_valid()
	return M.buf ~= nil and vim.api.nvim_buf_is_loaded(M.buf)
end

function M.create_buf()
	if M.buf_is_valid() then
		return M.buf
	end

	local buf = vim.api.nvim_create_buf(true, true)
	api.nvim_buf_set_name(buf, "[tidal - ghci]")
	api.nvim_set_option_value("filetype", "tidal_post", {
		buf = buf,
		scope = "local",
	})
	M.buf = buf
	M.open()
	return buf
end

function M.destroy_buf()
	if M.buf_is_valid() then
		api.nvim_buf_delete(M.buf, { force = true })
	end
	if M.is_open() then
		M.close()
	end
end

local function set_win_options()
	vim.opt_local.buftype = "nofile"
	vim.opt_local.bufhidden = "hide"
	vim.opt_local.swapfile = false
	vim.opt_local.colorcolumn = ""
	vim.opt_local.foldcolumn = "0"
	vim.opt_local.winfixwidth = true
	vim.opt_local.tabstop = 4
	vim.opt_local.wrap = true
	vim.opt_local.linebreak = true

	local decorations = {
		"number",
		"relativenumber",
		"modeline",
		"cursorline",
		"cursorcolumn",
		"foldenable",
		"list",
	}
	for _, s in ipairs(decorations) do
		vim.opt_local[s] = false
	end
end

function M.is_open()
	return M.win ~= nil and api.nvim_win_is_valid(M.win)
end

function M.open()
	vim.schedule(function()
		if M.is_open() then
			return
		end

		if not M.buf_is_valid() then
			M.create_buf()
		end

		local postwin_config = vim.tbl_deep_extend("force", config.post_window, { win = 0 })
		local win = api.nvim_open_win(M.buf, false, postwin_config)

		local previous_win = vim.api.nvim_get_current_win()
		vim.api.nvim_set_current_win(win)
		set_win_options()
		vim.api.nvim_set_current_win(previous_win)

		M.win = win
	end)
end

function M.close()
	if M.is_open() then
		vim.api.nvim_win_close(M.win, true)
		M.win = nil
	end
end

function M.toggle()
	if M.is_open() then
		M.close()
	else
		M.open()
	end
end

function M.post(data)
	vim.schedule(function()
		if not M.buf_is_valid() then
			error("[tidal.nvim] cannot write to post window, buffer doesn't exist or is invalid", vim.log.levels.ERROR)
		end

        if not data then
            return
        end

		local lines = vim.api.nvim_buf_get_lines(M.buf, -2, -1, false)
		local last_line = lines[1] or ""
		local appended = last_line .. data
		local split = vim.split(appended, "\n", { plain = true })

		vim.api.nvim_buf_set_lines(M.buf, -2, -1, false, split)
		if M.is_open() then
			local line_count = vim.api.nvim_buf_line_count(M.buf)
			vim.api.nvim_win_set_cursor(M.win, { line_count, 0 })
		end
	end)
end

function M.clear()
	if M.buf_is_valid() then
		api.nvim_buf_set_lines(M.buf, 0, -1, false, {})
	end
end

return M
