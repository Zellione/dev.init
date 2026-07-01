-- 1. Grab the active root directory safely
local root = vim.fn.fnamemodify(vim.uv.cwd(), ":p")

local venv_paths = {
	root .. ".venv",
	root .. "venv",
	root .. "venv_robot",
}

if vim.env.VIRTUAL_ENV then
	table.insert(venv_paths, vim.env.VIRTUAL_ENV)
end

local active_venv = nil
for _, path in ipairs(venv_paths) do
	if vim.fn.isdirectory(path) == 1 then
		active_venv = path
		break
	end
end

-- 2. Build our standard native configuration object
local config = {
	root_markers = { ".git", "pyproject.toml", "setup.py", "requirements.txt" },

	on_init = function(client)
		-- Instantly kill the instance if it catches Homebrew's root .git directory
		if client.root_dir and client.root_dir:match("^/opt/homebrew") then
			client:stop(true)
		end
	end,
}

-- 3. Hard-inject options directly as top-level keys if a valid venv is found
if active_venv then
	config.init_options = {
		workspace = {
			environmentPath = active_venv,
		},
	}
	config.cmd_env = {
		VIRTUAL_ENV = active_venv,
		PATH = active_venv .. "/bin:" .. (vim.env.PATH or ""),
	}
end

return config
