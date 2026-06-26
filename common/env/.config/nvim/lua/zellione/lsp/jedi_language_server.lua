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

local extra_paths = {}
if active_venv then
	-- Dynamically locate the site-packages inside the virtual environment
	local site_pkgs = vim.fn.glob(active_venv .. "/lib/python*/site-packages", false, true)
	for _, pkg_path in ipairs(site_pkgs) do
		table.insert(extra_paths, pkg_path)
	end
end

return {
	settings = {
		jedi = {
			workspace = {
				extraPaths = extra_paths,
			},
		},
	},
}
