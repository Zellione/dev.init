return {
	"nvim-treesitter/nvim-treesitter",
	build = ":TSUpdate",
	config = function()
		require("nvim-treesitter.configs").setup({
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
			auto_install = true,
			highlight = {
				enable = true,
			},
			indent = {
				enable = true,
			},
			incremental_selection = {
				enable = true,
				keymaps = {
					init_selection = "<C-Space>",
					node_incremental = "<C-Space>",
					scope_incremental = false,
					node_decremental = "<bs>",
				},
			},
		})
	end,
}
