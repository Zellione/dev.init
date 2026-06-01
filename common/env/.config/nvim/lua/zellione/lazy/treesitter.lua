return {
	"nvim-treesitter/nvim-treesitter",
	build = ":TSUpdate",
	opts = {
		ensure_installed = {
			"bash",
			"c",
			"cpp",
			"html",
			"lua",
			"markdown",
			"markdown_inline",
			"vim",
			"vimdoc",
			"rust",
			"javascript",
			"typescript",
			"jsdoc",
			"go",
			"gomod",
			"gosum",
			"gotmpl",
		},
		highlight = { enable = true },
		indent = { enable = true },
	},
	config = function(_, opts)
		-- nvim-treesitter v1.0+ removed the `nvim-treesitter.configs` module.
		-- Setup now lives on the top-level module.
		require("nvim-treesitter").setup(opts)

		-- Register markdown_inline as an embedded language of markdown so
		-- treesitter-context (and highlighting) follow it inside markdown files.
		pcall(vim.treesitter.language.register, "markdown", "markdown_inline")
	end,
}
