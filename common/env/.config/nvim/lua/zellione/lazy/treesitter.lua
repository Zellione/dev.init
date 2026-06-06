return {
	"nvim-treesitter/nvim-treesitter",
    branch = "main",
	lazy = false,
    build = ":TSUpdate",
	config = function()
		require("nvim-treesitter").setup {
			install_dir = vim.fn.stdpath("data") .. "/site",
            auto_install = true,
            highlight = {
                enable = true,
            }
		}

		local ensure_installed = {
			"bash",
			"c",
			"cpp",
			"html",
			"lua",
			"markdown",
			"markdown_inline",
			"vim",
			"vimdoc",
			"rust",
			"javascript",
			"typescript",
			"jsdoc",
			"go",
		}

		local installed = require("nvim-treesitter.config").get_installed()
		local to_install = vim.iter(ensure_installed)
			:filter(function(parser)
				return not vim.tbl_contains(installed, parser)
			end)
			:totable()

		if #to_install > 0 then
			require("nvim-treesitter").install(to_install)
		end

		vim.api.nvim_create_autocmd("FileType", {
			callback = function()
				pcall(vim.treesitter.start)
				vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
			end,
		})

		pcall(vim.treesitter.language.register, "markdown", "markdown_inline")
	end,
}
