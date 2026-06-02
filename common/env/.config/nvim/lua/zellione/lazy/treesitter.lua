return {
	"nvim-treesitter/nvim-treesitter",
	branch = "main",
	build = ":TSUpdate",
	opts = {
		ensure_installed = {
			"bash",
			"cpp",
			"html",
			"rust",
			"javascript",
			"typescript",
			"jsdoc",
			"go",
		},
	},
	config = function(_, opts)
		require("nvim-treesitter").setup(opts)
		vim.api.nvim_create_autocmd("FileType", {
			callback = function(ev)
				pcall(vim.treesitter.start, ev.buf)
			end,
		})
	end,
}
