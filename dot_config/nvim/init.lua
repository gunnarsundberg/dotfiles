vim.o.number = true
vim.o.relativenumber = true
vim.o.wrap = false
vim.o.tabstop = 2
vim.o.shiftwidth = 2
vim.o.swapfile = false
vim.o.cursorcolumn = false
vim.o.ignorecase = true
vim.o.signcolumn = "yes"
vim.o.incsearch = true
vim.o.undofile = true
vim.o.smartindent = true

--
-- plugins
--
vim.pack.add({
	{ src = "https://github.com/gabfelix/mudworld" },
	{ src = "https://github.com/stevearc/oil.nvim" },
	{ src = "https://github.com/echasnovski/mini.pick" },
	{ src = "https://github.com/nvim-treesitter/nvim-treesitter" },
})

require "mini.pick".setup()
require "oil".setup()
require "nvim-treesitter.configs".setup({
	ensure_installed = {"go", "rust", "lua"},
	highlight = { enable = true }
})

--
-- vibes
--
vim.cmd("colorscheme mudworld")
vim.o.winborder = "rounded"

--
-- keymaps
--
local map = vim.keymap.set
vim.g.mapleader = " "

map({ 'n', 'v', 'x' }, '<leader>d', '"+d<CR>')
map({ 'n', 'v', 'x' }, '<leader>y', '"+y<CR>')
map({ 'n', 'v', 'x' }, '<leader>d', '"+d<CR>')
map('n', '<leader>cf', vim.lsp.buf.format)
map('n', '<leader>f', ":Pick files<CR>")
map('n', '<leader>h', ":Pick help<CR>")
map('n', '<leader>e', ":Oil<CR>")

--
-- lsp
--
vim.lsp.enable({ "lua_ls", "gopls" })
