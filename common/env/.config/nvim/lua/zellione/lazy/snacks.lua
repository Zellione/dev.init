return {
	"folke/snacks.nvim",
	priority = 1000,
	lazy = false,
	opts = {
		-- Enable the input UI replacement
		input = {
			enabled = true,
			win = { style = "input" },
		},
		-- Enable the picker (which overrides vim.ui.select automatically)
		picker = {
			enabled = true,
		},
		-- ... your other snacks configs (dashboard, notifier, etc.)
	},
}
