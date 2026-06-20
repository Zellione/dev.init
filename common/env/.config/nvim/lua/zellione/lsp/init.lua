local M = {}

M.setup = function()
	require("mason").setup()

	-- Maps lspconfig server name -> mason package name. They differ for several
	-- servers (lua_ls vs lua-language-server, etc.), so we maintain this table
	-- explicitly now that mason-lspconfig is no longer pulling the translations.
	local servers = {
		{ lsp = "lua_ls",               mason = "lua-language-server" },
		{ lsp = "ts_ls",                mason = "typescript-language-server" },
		{ lsp = "eslint",               mason = "eslint-lsp" },
		{ lsp = "clangd",               mason = "clangd" },
		{ lsp = "jedi_language_server", mason = "jedi-language-server" },
		{ lsp = "phpactor",             mason = "phpactor" },
		{ lsp = "zls",                  mason = "zls" },
		{ lsp = "gopls",                mason = "gopls" },
		{ lsp = "jdtls",                mason = "jdtls" },
		{ lsp = "robotcode",            mason = "robotcode" },
		{ lsp = "bashls",               mason = "bash-language-server" },
	}

	local mason_packages = vim.tbl_map(function(s)
		return s.mason
	end, servers)
	local lsp_names = vim.tbl_map(function(s)
		return s.lsp
	end, servers)

	require("mason-tool-installer").setup({
		ensure_installed = mason_packages,
	})

	for _, name in ipairs(lsp_names) do
		local ok, conf = pcall(require, "zellione.lsp." .. name)
		vim.lsp.config(name, ok and conf or {})
	end

	vim.lsp.enable(lsp_names)

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
