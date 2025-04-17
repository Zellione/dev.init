return {
	"rcarriga/nvim-dap-ui",
	dependencies = {
		"mfussenegger/nvim-dap",
		"nvim-neotest/nvim-nio",
	},
	config = function()
		local dap = require("dap")

		require("dap").adapters["pwa-node"] = {
			type = "server",
			host = "localhost",
			port = "${port}",
			executable = {
				command = "node",
				-- 💀 Make sure to update this path to point to your installation
				args = { os.getenv("HOME") .. "/tools/vscode-js-debug/out/src/vsDebugServer.js", "${port}" },
			},
		}
		dap.adapters.gdb = {
			type = "executable",
			command = "gdb",
			args = { "-i", "dap" },
		}

		dap.adapters.lldb = {
			type = "executable",
			command = "/usr/bin/lldb-vscode", -- adjust as needed, must be absolute path
			name = "lldb",
		}

		dap.adapters.chrome = {
			type = "executable",
			command = "node",
			args = {
				os.getenv("HOME") .. "/.local/share/nvim/lsp-debuggers/vscode-chrome-debug/out/src/chromeDebug.js",
			},
		}

		dap.configurations.typescript = {
			{
				name = "Debug ConfigServer",
				type = "pwa-node",
				request = "attach",
				address = "localhost",
				port = 9002,
				-- resolveSourceMapLocations = {
				-- 	"${workspaceFolder}/dist/apps/charybdis/**",
				-- },
				outFiles = { "${workspaceFolder}/dist/apps/config-server/**" },
				localRoot = "${workspaceFolder}/apps/config-server",
				remoteRoot = "/Users/sna06/projects/nh-storefront/apps/config-server",
				cwd = "${workspaceFolder}/apps/config-server",
				-- rootPath = "${workspaceFolder}/apps/charybdis/src",
				-- sourceMaps = true,
				restart = true,
				-- protocol = "inspector",
				-- trace = true,
				skipFiles = { "<node_internals>/**", "node_modules/**" },
			},
			{
				name = "Debug Charybdis",
				type = "pwa-node",
				request = "attach",
				address = "localhost",
				port = "9001",
				-- resolveSourceMapLocations = {
				-- 	"${workspaceFolder}/dist/apps/charybdis/**",
				-- },
				outFiles = { "${workspaceFolder}/dist/apps/charybdis/**" },
				localRoot = "${workspaceFolder}/apps/charybdis",
				remoteRoot = "/Users/sna06/projects/nh-storefront/apps/charybdis",
				cwd = "${workspaceFolder}/apps/charybdis",
				-- rootPath = "${workspaceFolder}/apps/charybdis/src",
				-- sourceMaps = true,
				restart = true,
				-- protocol = "inspector",
				-- trace = true,
				skipFiles = { "<node_internals>/**", "node_modules/**" },
			},
			-- {
			-- 	name = "Debug (Launch) DeichShaper",
			-- 	type = "pwa-chrome",
			-- 	request = "launch",
			-- 	url = "http://localhost:4715",
			-- 	sourceMaps = true,
			-- 	webRoot = "${workspaceFolder}/apps/deich-shaper/src",
			-- },
			{
				name = "Debug (Attach) DeichShaper",
				type = "chrome",
				request = "attach",
				program = "${file}",
				cwd = "${workspaceFolder}",
				sourceMaps = true,
				protocol = "inspector",
				port = 9222,
				webRoot = "${workspaceFolder}",
			},
			{
				type = "chrome",
				request = "launch",
				name = "Debug (Launch) DeichShaper (?)",
				url = "http://localhost:4715",
				protocol = "inspector",
				webRoot = "${workspaceFolder}",
				userDataDir = "${workspaceFolder}/.vscode/vscode-chrome-debug-userdatadir",
			},
			{
				type = "pwa-chrome",
				request = "launch",
				name = "Debug (Launch) DeichShaper (SLOW)",
				url = "http://localhost:4715",
				webRoot = "${workspaceFolder}",
				protocol = "inspector",
				userDataDir = "${workspaceFolder}/.vscode/vscode-chrome-debug-userdatadir",
			},
			{
				type = "pwa-node",
				request = "attach",
				name = "Attach",
				processId = require("dap.utils").pick_process,
				cwd = "${workspaceFolder}",
			},
		}

		dap.configurations.cpp = {
			{
				name = "Launch",
				type = "lldb",
				request = "launch",
				program = function()
					return vim.fn.input("Path to executable: ", vim.fn.getcwd() .. "/", "file")
				end,
				cwd = "${workspaceFolder}",
				stopOnEntry = false,
				args = {},

				-- 💀
				-- if you change `runInTerminal` to true, you might need to change the yama/ptrace_scope setting:
				--
				--    echo 0 | sudo tee /proc/sys/kernel/yama/ptrace_scope
				--
				-- Otherwise you might get the following error:
				--
				--    Error on launch: Failed to attach to the target process
				--
				-- But you should be aware of the implications:
				-- https://www.kernel.org/doc/html/latest/admin-guide/LSM/Yama.html
				-- runInTerminal = false,
			},
			{
				-- If you get an "Operation not permitted" error using this, try disabling YAMA:
				--  echo 0 | sudo tee /proc/sys/kernel/yama/ptrace_scope
				name = "Attach to process",
				type = "cpp", -- Adjust this to match your adapter name (`dap.adapters.<name>`)
				request = "attach",
				pid = require("dap.utils").pick_process,
				args = {},
			},
		}

		-- If you want to use this for Rust and C, add something like this:
		dap.configurations.c = dap.configurations.cpp
		dap.configurations.rust = dap.configurations.cpp

		-- use same configuration for javascript
		dap.configurations.javascript = dap.configurations.typescript
		dap.configurations.typescriptreact = dap.configurations.typescript
		dap.configurations.javascriptreact = dap.configurations.typescript

		local dapui = require("dapui")
		dap.listeners.after.event_initialized["dapui_config"] = function()
			dapui.open()
		end
		dap.listeners.before.event_terminated["dapui_config"] = function()
			dapui.close()
		end
		dap.listeners.before.event_exited["dapui_config"] = function()
			dapui.close()
		end

		vim.fn.sign_define("DapBreakpoint", { text = "🟥", texthl = "", linehl = "", numhl = "" })
		vim.fn.sign_define("DapStopped", { text = "->", texthl = "", linehl = "", numhl = "" })

		vim.keymap.set("n", "<F5>", require("dap").continue)
		vim.keymap.set("n", "<F6>", require("dap").step_over)
		vim.keymap.set("n", "<F7>", require("dap").step_into)
		vim.keymap.set("n", "<F8>", require("dap").step_out)
		vim.keymap.set("n", "<F1>", function()
			dapui.open()
		end)
		vim.keymap.set("n", "<F2>", function()
			dapui.close()
		end)
		vim.keymap.set("n", "<leader>b", require("dap").toggle_breakpoint)

		dapui.setup()
	end,
}
