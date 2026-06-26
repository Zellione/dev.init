return {
	"folke/snacks.nvim",
	priority = 1000,
	lazy = false,
	opts = {
		-- Enable Notifier
		notifier = {
			enabled = true,
			timeout = 3000,
		},
		-- Enable the input UI replacement
		input = {
			enabled = true,
			win = { style = "input" },
		},
		-- Enable the picker (which overrides vim.ui.select automatically)
		picker = {
			enabled = true,
		},
		-- ... your other snacks configs (dashboard, notifier, etc.)
	},
	init = function()
		vim.api.nvim_create_autocmd("User", {
			pattern = "VeryLazy",
			callback = function()
				-- 3. Override Neovim's default print/notify with Snacks
				---@diagnostic disable: duplicate-set-field
				_G.dd = function(...)
					Snacks.debug.inspect(...)
				end
				_G.bt = function()
					Snacks.debug.backtrace()
				end
				---@diagnostic enable: duplicate-set-field
				vim.print = _G.dd -- Override print to use snacks preview

				-- Create a smooth transition for any standard vim.notify calls
				Snacks.toggle.profiler():map("<leader>dpp")
			end,
		})
	end,
	keys = {
		-- Useful keymap to view your notification history
		{
			"<leader>nh",
			function()
				Snacks.notifier.show_history()
			end,
			desc = "Notification History",
		},
		-- Clear active notifications on screen
		{
			"<leader>nd",
			function()
				Snacks.notifier.hide()
			end,
			desc = "Dismiss Notifications",
		},
		{
			"<leader>xd",
			function()
				Snacks.picker.diagnostics()
			end,
			desc = "Project Diagnostics",
		},
		{
			"<leader>xD",
			function()
				Snacks.picker.diagnostics({ filter = { buf = 0 } })
			end,
			desc = "Buffer Diagnostics",
		},
	},
}
