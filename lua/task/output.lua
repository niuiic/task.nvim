local core = require("core")

---@param option {direction: 'hb'|'ht'|'vl'|'vr', size: number, enter: boolean} | nil
local use_split_win = function(option)
	option = option or {
		direction = "hb",
		size = 20,
		enter = false,
	}
	local bufnr
	local winnr

	local split_win = function(output)
		if not bufnr or not vim.api.nvim_buf_is_valid(bufnr) or not vim.api.nvim_buf_is_loaded(bufnr) then
			bufnr = vim.api.nvim_create_buf(false, false)
			vim.api.nvim_set_option_value("filetype", "terminal", {
				buf = bufnr,
			})
			vim.api.nvim_set_option_value("modifiable", false, {
				buf = bufnr,
			})
		end
		local handle
		if not winnr or not vim.api.nvim_win_is_valid(winnr) then
			handle = core.win.split_win(bufnr, option)
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

		vim.api.nvim_set_option_value("modifiable", true, {
			buf = bufnr,
		})
		vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, core.lua.string.split(output, "\n"))
		vim.api.nvim_set_option_value("modifiable", false, {
			buf = bufnr,
		})
	end

	return split_win
end

---@param option {enter: boolean, relative: 'editor'|'win'|'cursor'|'mouse', win?: number, anchor?: 'NW'|'NE'|'SW'|'SE', width: number, height: number, bufpos?: number[], row?: number, col?: number, style?: 'minimal', border: 'none'|'single'|'double'|'rounded'|'solid'|'shadow'|string[], title?: string, title_pos?: 'left'|'center'|'right', noautocmd?: boolean} | nil
local use_float_win = function(option)
	local size = core.win.proportional_size(0.6, 0.6)
	option = option
		or {
			enter = true,
			relative = "editor",
			width = size.width,
			height = size.height,
			row = size.row,
			col = size.col,
			style = "minimal",
			border = "rounded",
			title_pos = "center",
		}
	local bufnr
	local win_handle

	local float_win = function(output, task_name)
		option.title = task_name

		if not bufnr or not vim.api.nvim_buf_is_valid(bufnr) or not vim.api.nvim_buf_is_loaded(bufnr) then
			bufnr = vim.api.nvim_create_buf(false, false)
			vim.api.nvim_set_option_value("filetype", "terminal", {
				buf = bufnr,
			})
			vim.api.nvim_set_option_value("modifiable", false, {
				buf = bufnr,
			})
			core.lua.list.each({ "q", "<esc>" }, function(key)
				vim.keymap.set("n", key, function()
					if win_handle and win_handle.win_opening() then
						win_handle.close_win()
					end
				end, { buffer = bufnr })
			end)
		end

		if not win_handle or not vim.api.nvim_win_is_valid(win_handle.winnr) then
			---@diagnostic disable-next-line: param-type-mismatch
			win_handle = core.win.open_float(bufnr, option)
		end

		vim.api.nvim_set_option_value("modifiable", true, {
			buf = bufnr,
		})
		vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, core.lua.string.split(output, "\n"))
		vim.api.nvim_set_option_value("modifiable", false, {
			buf = bufnr,
		})
	end

	return float_win
end

local notify = function(output, task_name)
	vim.notify(output, vim.log.levels.INFO, {
		title = string.format("Task %s", task_name),
	})
end

local notify_done = function(_, task_name)
	vim.notify(string.format("Task %s done", task_name), vim.log.levels.OFF, {
		title = "Task",
	})
end

return {
	use_split_win = use_split_win,
	use_float_win = use_float_win,
	notify = notify,
	notify_done = notify_done,
}
