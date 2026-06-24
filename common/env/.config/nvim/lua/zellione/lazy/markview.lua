return {
    "OXY2DEV/markview.nvim",
    lazy = false,

    -- Completion for `blink.cmp`
    -- dependencies = { "saghen/blink.cmp" },
	keys = {
		{
			"<leader>mw",
            "<CMD>Markview splitToggle<CR>",
			mode = "",
			desc = "Toggles `splitview` for current buffer.",
		},
	},
};
