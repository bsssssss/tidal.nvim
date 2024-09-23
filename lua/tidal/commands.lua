vim.api.nvim_create_augroup("Tidal", {
	clear = true,
})
vim.api.nvim_create_user_command("TidalStart", require("tidal").tidal_start(), {})
vim.api.nvim_create_user_command("TidalSend", require("tidal").tidal_send(), {})
vim.api.nvim_create_autocmd("FileType", {
	pattern = "tidal",
	group = "Tidal",
	callback = function()
		vim.keymap.set({ "n", "i" }, "<D-e>", "<cmd>TidalSend<CR>", { desc = "Send to tidal" })
	end,
})
