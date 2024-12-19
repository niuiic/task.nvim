---@class task.Task
---@field name string
---@field run fun()
---@field is_enabled (fun(context: task.Context): boolean) | nil

---@class task.Context
---@field selection string[] | nil
---@field selected_area omega.Area

local M = {
	_tasks = {},
}

-- % register_task %
function M.register_task(task)
	M._tasks[task.name] = task
end

-- % run_task %
function M.run_task()
	---@type task.Context
	local context = {
		selection = require("omega").get_selection(),
		selected_area = require("omega").get_selected_area(),
	}

	local tasks = vim.iter(vim.tbl_values(M._tasks))
		:filter(function(task)
			return not task.is_enabled or task.is_enabled()
		end)
		:totable()

	if #tasks == 0 then
		vim.notify("No tasks registered", vim.log.levels.WARN, { title = "Task" })
		return
	end

	local task_names = vim.iter(tasks)
		:map(function(task)
			return task.name
		end)
		:totable()
	if #task_names == 1 then
		M._tasks[task_names[1]].run(context)
		return
	end

	vim.ui.select(task_names, {
		prompt = "Select a task to run",
	}, function(choice)
		if not choice then
			return
		end

		M._tasks[choice].run(context)
	end)
end

return M
