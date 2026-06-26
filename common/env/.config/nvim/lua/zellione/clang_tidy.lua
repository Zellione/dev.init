-- Whole-project C/C++ diagnostics.
--
-- clangd only reports diagnostics for OPEN files (it advertises no
-- diagnosticProvider, so workspace/diagnostic is impossible). To populate the
-- Snacks diagnostics picker for the entire project we run `run-clang-tidy`
-- across the compile database and push the results into vim.diagnostic under a
-- dedicated namespace. run-clang-tidy honours the project's .clang-tidy config,
-- so this matches the inline tidy diagnostics clangd shows for open buffers.

local M = {}

local ns = vim.api.nvim_create_namespace("zellione.clang_tidy")

local severity_map = {
	error = vim.diagnostic.severity.ERROR,
	warning = vim.diagnostic.severity.WARN,
}

-- Directory containing compile_commands.json (cwd, then ./build).
local function find_compile_db()
	local cwd = vim.uv.cwd()
	for _, dir in ipairs({ cwd, cwd .. "/build" }) do
		if vim.uv.fs_stat(dir .. "/compile_commands.json") then
			return dir
		end
	end
	return nil
end

-- run-clang-tidy emits paths relative to the compile-db directory; turn them
-- back into absolute, normalized paths so they map to the right buffers.
local function resolve_path(file, db_dir)
	if file:sub(1, 1) == "/" then
		return vim.fs.normalize(file)
	end
	for _, base in ipairs({ db_dir, vim.uv.cwd() }) do
		local p = base .. "/" .. file
		if vim.uv.fs_stat(p) then
			return vim.fs.normalize(p)
		end
	end
	return vim.fs.normalize(db_dir .. "/" .. file)
end

-- Parse clang-tidy text output into a map of absolute path -> diagnostics.
local function parse(output, db_dir)
	local by_file = {}
	local seen = {}
	for line in vim.gsplit(output, "\n", { plain = true }) do
		local file, lnum, col, sev, rest = line:match("^(.-):(%d+):(%d+):%s+(%a+):%s+(.*)$")
		if file and severity_map[sev] and not seen[line] then
			seen[line] = true
			local code = rest:match("%[([%w%-%.,]+)%]%s*$")
			local message = rest:gsub("%s*%[[%w%-%.,]+%]%s*$", "")
			local path = resolve_path(file, db_dir)
			by_file[path] = by_file[path] or {}
			table.insert(by_file[path], {
				lnum = tonumber(lnum) - 1,
				col = tonumber(col) - 1,
				severity = severity_map[sev],
				message = message,
				code = code,
				source = "clang-tidy",
			})
		end
	end
	return by_file
end

local running = false

function M.run()
	if running then
		vim.notify("clang-tidy: scan already in progress", vim.log.levels.WARN)
		return
	end
	local db_dir = find_compile_db()
	if not db_dir then
		vim.notify("clang-tidy: no compile_commands.json found (cwd or ./build)", vim.log.levels.ERROR)
		return
	end

	running = true
	vim.notify("clang-tidy: scanning project…", vim.log.levels.INFO)

	vim.system({ "run-clang-tidy", "-p", db_dir, "-quiet" }, { text = true }, function(obj)
		vim.schedule(function()
			running = false
			local by_file = parse((obj.stdout or "") .. "\n" .. (obj.stderr or ""), db_dir)

			vim.diagnostic.reset(ns)
			local total, files = 0, 0
			for path, diags in pairs(by_file) do
				vim.diagnostic.set(ns, vim.fn.bufadd(path), diags)
				total = total + #diags
				files = files + 1
			end

			if total == 0 then
				vim.notify("clang-tidy: no issues found", vim.log.levels.INFO)
			else
				vim.notify(
					("clang-tidy: %d issue(s) across %d file(s)"):format(total, files),
					vim.log.levels.WARN
				)
			end
		end)
	end)
end

function M.clear()
	vim.diagnostic.reset(ns)
end

function M.setup()
	vim.api.nvim_create_user_command("ClangTidyProject", M.run, {
		desc = "Run clang-tidy across the project and populate diagnostics",
	})
	vim.api.nvim_create_user_command("ClangTidyClear", M.clear, {
		desc = "Clear clang-tidy project diagnostics",
	})

	vim.api.nvim_create_autocmd("FileType", {
		pattern = { "c", "cpp", "objc", "objcpp", "cuda" },
		group = vim.api.nvim_create_augroup("zellione-clang-tidy", { clear = true }),
		callback = function(ev)
			vim.keymap.set("n", "<leader>xt", M.run, {
				buffer = ev.buf,
				desc = "Clang-[T]idy project diagnostics",
			})
		end,
	})
end

return M
