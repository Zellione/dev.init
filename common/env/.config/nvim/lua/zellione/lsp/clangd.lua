return {
	cmd = {
		"clangd",
		"--background-index",
		"--clang-tidy",
		"-header-insertion=never",
	},
	root_dir = function(fname)
		local util = require("lspconfig.util")
		return util.root_pattern("compile_commands.json", "compile_flags.txt", ".git")(fname)
	end,
}
