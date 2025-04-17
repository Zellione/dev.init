return {
	"nvim-telescope/telescope-dap.nvim",
	dependencies = {
		{ "nvim-telescope/telescope.nvim" },
		{ "mfussenegger/nvim-dap" },
	},
	config = function()
		local telescope = require("telescope")
		telescope.load_extension("dap")
		vim.keymap.set("n", "<F3>", telescope.extensions.dap.list_breakpoints, {})
		vim.keymap.set("n", "<F4>", telescope.extensions.dap.variables, {})
		vim.keymap.set("n", "<F2>", telescope.extensions.dap.commands, {})
	end,
}
