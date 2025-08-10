# tidal.nvim

Experimental [Tidal Cycles](<>) plugin for Neovim.

## Installation

Using lazy.nvim:

```lua
	{
		"bsssssss/tidal.nvim",
		ft = "tidal",
		config = function()
			require("tidal").setup({
        -- set the path to the boot script file to launch ghci with
				tidal_boot = "path/to/bootfile",
        -- configure the post window
        post_window = {
          split = "right",
          width = math.floor(vim.o.columns / 2),
	},
			})
      -- This plugin does not set keymaps by default !
			vim.api.nvim_create_autocmd("FileType", {
				pattern = "tidal",
				callback = function()
					vim.keymap.set(
						{ "n", "i" },
						"<C-e>",
						"<cmd>TidalEval<CR>",
						{ desc = "Send to tidal" }
					)
					vim.keymap.set(
						{ "n", "i" },
						"<C-.>",
						"<cmd>TidalHush<CR>",
						{ desc = "Hush tidal" }
					)
					vim.keymap.set(
						"n",
						"<CR>",
						"<cmd>TidalPostWindowToggle<CR>",
						{ desc = "Toggle tidal post window" }
					)
				end,
			})
		end,
	},
```

## User Commands

- TidalEval: Sends a paragraph to Tidal.

- TidalHush: Sends hush message to Tidal.

- TidalStart: Starts the ghci process and open the post window.

- TidalRestart: Quit and start the interpreter.

- TidalTerminate: Quit ghci interpreter.

- TidalPostWindowOpen: Open the post window.

- TidalPostWindowClear: Clears the post window.

- TidalPostWindowClose: Close the post window.

- TidalPostWindowToggle: Toggle between close and open the post window.
