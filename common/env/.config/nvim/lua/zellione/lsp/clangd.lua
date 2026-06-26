return {
	cmd = {
		"clangd",
		"--background-index",
		"--clang-tidy",
		"--header-insertion=never",
	},
	root_markers = { "compile_commands.json", "compile_flags.txt", ".git" },
}
