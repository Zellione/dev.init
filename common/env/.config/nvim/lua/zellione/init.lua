vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

require("zellione.set")
require("zellione.remap")
require("zellione.lazy_init")

vim.notify = function(msg, opts)
	require("notify")(msg, opts)
end

local augroup = vim.api.nvim_create_augroup
local ZellioneGroup = augroup("Zellione", { clear = true })

local autocmd = vim.api.nvim_create_autocmd
local yank_group = augroup("HighlightYank", { clear = true })

autocmd("TextYankPost", {
	group = yank_group,
	pattern = "*",
	callback = function()
		vim.highlight.on_yank({
			higroup = "IncSearch",
			timeout = 40,
		})
	end,
})
