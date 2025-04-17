return {
	"serenevoid/kiwi.nvim",
	depedencies = {
		"nvim-lua/plenary.nvim",
	},
	opts = {
		{
			name = "work",
			path = vim.fn.expand('$HOME/wiki/work'),
		},
		{
			name = "personal",
			path = vim.fn.expand('$HOME/wiki/personal'),
		},
	},
	keys = {
		{ "<leader>ww", ':lua require("kiwi").open_wiki_index("work")<cr>', desc = "Open work wiki index" },
		{
			"<leader>wp",
			':lua require("kiwi").open_wiki_index("personal")<cr>',
			desc = "Open index of personal wiki",
		},
		{ "T", ':lua require("kiwi").todo.toggle()<cr>', desc = "Toggle Markdown Task" },
	},
	lazy = true,
}
