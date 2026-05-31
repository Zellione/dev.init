return {
	"stevearc/conform.nvim",
	opts = {
		notify_on_error = false,
		format_on_save = {
			-- timeout_ms = 1500,
			lsp_format = "fallback",
		},
		formatters_by_ft = {
			lua = { "stylua" },
			-- Conform can also run multiple formatters sequentially
			-- python = { "isort", "black" },
			--
			-- You can use a sub-list to tell conform to run *until* a formatter
			-- is found.
			javascript = { "prettierd", "prettier", stop_after_first = true },
			typescript = { "prettierd", "prettier", stop_after_first = true },
			html = { "prettierd", "prettier", stop_after_first = true },
			scss = { "prettierd", "prettier", stop_after_first = true },
			json = { "jq" },
			go = { "goimports", "gofmt" },
		},
		-- formatters = {
		-- 	shfmt = {
		-- 		prepend_args = { "-i", "2" },
		-- 	},
		-- },
	},
	keys = {
		{
			"<leader>f",
			function()
				require("conform").format({ lsp_format = "fallback" })
			end,
			mode = "",
			desc = "Format code",
		},
	},
	config = function(_, opts)
		require("conform").setup(opts)
	end,
}
