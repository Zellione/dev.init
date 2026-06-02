return {
	"nvim-treesitter/nvim-treesitter",
	branch = "main",
	build = ":TSUpdate",
	config = function()
		require("nvim-treesitter.install").install({
			"bash",
			"cpp",
			"html",
			"rust",
			"javascript",
			"typescript",
			"jsdoc",
			"go",
			"json",
		})
		vim.api.nvim_create_autocmd("FileType", {
			callback = function(ev)
				pcall(vim.treesitter.start, ev.buf)
			end,
		})
	end,
}
