local core = require("core")
local bufnr
local winnr

local split_win = function(output)
	if not bufnr or not vim.api.nvim_buf_is_valid(bufnr) or not vim.api.nvim_buf_is_loaded(bufnr) then
		bufnr = vim.api.nvim_create_buf(false, false)
	end
	local handle
	if not winnr or not vim.api.nvim_win_is_valid(winnr) then
		handle = core.win.split_win(bufnr, {
			direction = "hb",
			size = 20,
			enter = false,
		})
		winnr = handle.winnr
		vim.api.nvim_set_option_value("number", false, {
			win = handle.winnr,
		})
		vim.api.nvim_set_option_value("relativenumber", false, {
			win = handle.winnr,
		})
		vim.api.nvim_set_option_value("winfixwidth", true, {
			win = handle.winnr,
		})
		vim.api.nvim_set_option_value("list", false, {
			win = handle.winnr,
		})
		vim.api.nvim_set_option_value("wrap", true, {
			win = handle.winnr,
		})
		vim.api.nvim_set_option_value("linebreak", true, {
			win = handle.winnr,
		})
		vim.api.nvim_set_option_value("breakindent", true, {
			win = handle.winnr,
		})
		vim.api.nvim_set_option_value("showbreak", "      ", {
			win = handle.winnr,
		})
	end

	vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, core.lua.string.split(output, "\n"))
end

return {
	split_win = split_win,
}
