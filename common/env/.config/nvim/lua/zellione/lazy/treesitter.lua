return {
	"nvim-treesitter/nvim-treesitter",
	lazy = false,
	build = ":TSUpdate",
	config = function()
		require("nvim-treesitter").setup {
			install_dir = vim.fn.stdpath("data") .. "/site",
		}

		require("nvim-treesitter").install {
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
		}

		-- Register markdown_inline as an embedded language of markdown so
		-- treesitter-context (and highlighting) follow it inside markdown files.
		pcall(vim.treesitter.language.register, "markdown", "markdown_inline")
	end,
}
