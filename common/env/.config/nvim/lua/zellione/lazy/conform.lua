return {
	"stevearc/conform.nvim",
	opts = {
		notify_on_error = false,
		format_on_save = {
			-- timeout_ms = 1500,
			lsp_format = "fallback",
		},
		formatters_by_ft = {
			lua = { "trim_whitespace", "stylua" },
			python = { "trim_whitespace", "isort", "black" },
			javascript = { "trim_whitespace", "prettierd", "prettier", stop_after_first = true },
			typescript = { "trim_whitespace", "prettierd", "prettier", stop_after_first = true },
			html = { "trim_whitespace", "prettierd", "prettier", stop_after_first = true },
			scss = { "trim_whitespace", "prettierd", "prettier", stop_after_first = true },
			json = { "trim_whitespace", "jq" },
			go = { "trim_whitespace", "goimports", "gofmt" },
		},
		formatters = {
			trim_whitespace = {
				meta = {
					description = "Trim trailing whitespace (tabs/spaces at end of line)",
					require_solution = false,
				},
				command = "perl",
				args = { "-pi", "-e", [[s/[ \t]+$//]] },
			},
		},
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
