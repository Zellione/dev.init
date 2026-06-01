local M = {}

M.setup = function()
	require("mason").setup()

	require("mason-tool-installer").setup({
		ensure_installed = {
			"lua_ls",
			"ts_ls",
			"eslint",
			"clangd",
			"jedi_language_server",
			"phpactor",
			"zls",
			"gopls",
			"jdtls",
			"robotcode",
		},
	})

	local servers = {
		"lua_ls",
		"ts_ls",
		"eslint",
		"clangd",
		"jedi_language_server",
		"phpactor",
		"zls",
		"gopls",
		"jdtls",
		"robotcode",
	}

	for _, name in ipairs(servers) do
		local ok, conf = pcall(require, "zellione.lsp." .. name)
		vim.lsp.config(name, ok and conf or {})
	end

	vim.lsp.enable(servers)

	local capabilities = vim.lsp.protocol.make_client_capabilities()
	capabilities = vim.tbl_deep_extend("force", capabilities, require("cmp_nvim_lsp").default_capabilities())

	vim.diagnostic.config({
		virtual_text = true,
		signs = true,
		update_in_insert = false,
		underline = true,
		severity_sort = true,
		float = true,
	})

	vim.api.nvim_create_autocmd("LspAttach", {
		group = vim.api.nvim_create_augroup("zellione-lsp-attach", { clear = true }),
		callback = function(event)
			local function map(keys, func, desc)
				vim.keymap.set("n", keys, func, { buffer = event.buf, desc = "LSP: " .. desc })
			end

			map("gd", require("telescope.builtin").lsp_definitions, "[G]oto [D]efinition")
			map("gr", require("telescope.builtin").lsp_references, "[G]oto [R]eferences")
			map("gI", require("telescope.builtin").lsp_implementations, "[G]oto [I]mplementation")
			map("<leader>D", require("telescope.builtin").lsp_type_definitions, "Type [D]efinition")
			map("<leader>ds", require("telescope.builtin").lsp_document_symbols, "[D]ocument [S]ymbols")
			map("<leader>ws", require("telescope.builtin").lsp_dynamic_workspace_symbols, "[W]orkspace [S]ymbols")
			map("<leader>rn", vim.lsp.buf.rename, "[R]e[n]ame")
			map("<leader>ca", vim.lsp.buf.code_action, "[C]ode [A]ction")
			map("K", vim.lsp.buf.hover, "Hover Documentation")
			map("gD", vim.lsp.buf.declaration, "[G]oto [D]eclaration")

			local client = vim.lsp.get_client_by_id(event.data.client_id)
			if client and client.server_capabilities.documentHighlightProvider then
				vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI" }, {
					buffer = event.buf,
					callback = vim.lsp.buf.document_highlight,
				})
				vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI" }, {
					buffer = event.buf,
					callback = vim.lsp.buf.clear_references,
				})
			end

			if client and client.server_capabilities.inlayHintProvider then
				vim.lsp.inlay_hint.enable(true, { bufnr = event.buf })
			end

			if client and client.server_capabilities.signatureHelpProvider then
				vim.lsp.buf.signature_help({ trigger = true })
			end
		end,
	})

	vim.api.nvim_create_autocmd("LspDetach", {
		group = vim.api.nvim_create_augroup("zellione-lsp-detach", { clear = true }),
		callback = function(event)
			vim.lsp.inlay_hint.enable(false, { bufnr = event.buf })
		end,
	})

	_G.__lsp_capabilities = capabilities
end

return M
