local cwd = vim.uv.cwd()
local venv_paths = {
	cwd .. "/.venv",
	cwd .. "/venv",
	cwd .. "/venv_robot",
	vim.env.VIRTUAL_ENV,
}

local active_venv = nil
for _, path in ipairs(venv_paths) do
	if path and vim.fn.isdirectory(path) == 1 then
		active_venv = path
		break
	end
end

-- Find site-packages paths to inject into the LSP environment process
local python_path_env = nil
if active_venv then
	local site_pkgs = vim.fn.glob(active_venv .. "/lib/python*/site-packages")
	if site_pkgs ~= "" then
		-- Format paths cleanly for the shell path string separator
		python_path_env = string.gsub(site_pkgs, "\n", ":")
	end
end

return {
	-- We pass the path to your venv's python packages directly into the LSP environment
	cmd_env = python_path_env and { PYTHONPATH = python_path_env } or nil,
	settings = {
		robotcode = {
			-- Any optional robotcode specific configurations can go here
		},
	},
}
