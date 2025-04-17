return {
	"polarmutex/git-worktree.nvim",
	dependencies = {
		"nvim-telescope/telescope.nvim",
	},
	config = function()
		require("telescope").load_extension("git_worktree")

		vim.keymap.set(
			"n",
			"<leader>st",
			":lua require('telescope').extensions.git_worktree.git_worktrees()<CR>",
			{ desc = "Search Worktrees", silent = true }
		)

		vim.keymap.set(
			"n",
			"<leader>sT",
			":lua require('telescope').extensions.git_worktree.create_git_worktree()<CR>",
			{ desc = "Create Worktree", silent = true }
		)
	end,
}
