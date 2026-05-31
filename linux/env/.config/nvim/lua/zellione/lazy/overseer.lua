return {
	"stevearc/overseer.nvim",
	dependencies = {
		"nvim-telescope/telescope.nvim",
		"stevearc/dressing.nvim",
		"rcarriga/nvim-notify",
	},
	opts = {},
	config = function(_, opts)
		require("overseer").setup(opts)

		vim.keymap.set("n", "<leader>or", "<CMD>OverseerRun<cr>")
		vim.keymap.set("n", "<leader>ot", "<CMD>OverseerToggle<cr>")
	end,
}
