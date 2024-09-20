require("tidal").setup()

vim.keymap.set({ "n", "i" }, "<D-e>", ":TidalSend<CR>", { desc = "Send to tidal" })
