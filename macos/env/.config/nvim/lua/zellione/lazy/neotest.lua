return {
    "nvim-neotest/neotest",
    dependencies = {
        "nvim-lua/plenary.nvim",
        "antoinemadec/FixCursorHold.nvim",
        "nvim-treesitter/nvim-treesitter",
        "rcasia/neotest-java",
    },
    config = function()
        require("neotest").setup({
            adapters = {
                require("neotest-java")({
                    ignore_wrapper = false
                })
            }
        })

        local neotest = require("neotest")
        vim.keymap.set("n", "<leader>tr", function() neotest.run.run() end, { desc = "Run the nearest test" })
        vim.keymap.set("n", "<leader>ts", function() neotest.summary.toggle() end, { desc = "Toggle test summaries" })
        vim.keymap.set("n", "<leader>to", function() neotest.output.open({ enter = true }) end,
            { desc = "Show test output" })
    end
}
