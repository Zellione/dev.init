-- stop_after_first applies to the WHOLE formatters_by_ft list, not just a
-- sub-group, so it can't be combined with a leading always-run formatter
-- like trim_whitespace (it would stop right there and skip prettier
-- entirely). Use conform's documented `first()` recipe instead.
local function first(bufnr, ...)
	local conform = require("conform")
	for i = 1, select("#", ...) do
		local formatter = select(i, ...)
		if conform.get_formatter_info(formatter, bufnr).available then
			return formatter
		end
	end
	return select(1, ...)
end

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
			javascript = function(bufnr)
				return { "trim_whitespace", first(bufnr, "prettierd", "prettier") }
			end,
			typescript = function(bufnr)
				return { "trim_whitespace", first(bufnr, "prettierd", "prettier") }
			end,
			html = function(bufnr)
				return { "trim_whitespace", first(bufnr, "prettierd", "prettier") }
			end,
			scss = function(bufnr)
				return { "trim_whitespace", first(bufnr, "prettierd", "prettier") }
			end,
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
			prettier = {
				prepend_args = function(_, ctx)
					local config_names = {
						".prettierrc",
						".prettierrc.json",
						".prettierrc.yml",
						".prettierrc.yaml",
						".prettierrc.js",
						".prettierrc.cjs",
						".prettierrc.mjs",
						"prettier.config.js",
						"prettier.config.cjs",
						"prettier.config.mjs",
					}
					local found = vim.fs.find(config_names, {
						upward = true,
						path = vim.fs.dirname(ctx.filename),
					})
					if #found > 0 then
						return {}
					end
					return {
						"--no-semi",
						"--single-quote",
						"--no-bracket-spacing",
					}
				end,
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
