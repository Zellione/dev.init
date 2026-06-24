return {
	"stevearc/overseer.nvim",
	dependencies = {
		"nvim-telescope/telescope.nvim",
		"folke/snacks.nvim",
	},
	opts = {},
	config = function(_, opts)
		require("overseer").setup(opts)

		vim.keymap.set("n", "<leader>or", "<CMD>OverseerRun<cr>")
		vim.keymap.set("n", "<leader>ot", "<CMD>OverseerToggle<cr>")
	end,
}
