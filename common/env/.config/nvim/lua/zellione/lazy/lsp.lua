return {
	"neovim/nvim-lspconfig",
	dependencies = {
		"williamboman/mason.nvim",
		"whoIsSethDaniel/mason-tool-installer.nvim",
		{ "j-hui/fidget.nvim", tag = "v1.6.1", opts = {} },
		"folke/snacks.nvim",
	},
	config = function()
		require("zellione.lsp").setup()
	end,
}
