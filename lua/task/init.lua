local static = require("task.static")
local core = require("core")

---@param name string
---@param on_job_exit fun(output) | nil
local run = function(name, on_job_exit)
	local get_config = static.tasks[name]
	if not get_config then
		vim.notify(string.format("Task %s not found", vim.log.levels.ERROR, {
			title = "Task",
		}))
		return
	end
	local config = get_config()

	local output = ""
	local on_exit = function()
		if not on_job_exit then
			vim.notify(output, vim.log.levels.INFO, {
				title = string.format("Task %s", name),
			})
		else
			on_job_exit(output)
		end
	end
	local on_output = function(_, data)
		output = output .. data
	end
	local on_err = function(_, data)
		output = output .. data
	end

	core.job.spawn(config.cmd, config.args, config.options or {}, on_exit, on_output, on_err)
end

---@param task_name string | nil
---@param on_exit fun(output) | nil
local launch = function(task_name, on_exit)
	if task_name then
		run(task_name, on_exit)
		return
	end

	local items = core.lua.table.keys(static.tasks)

	if #items == 0 then
		vim.notify("No task registered", vim.log.levels.WARN, {
			title = "Task",
		})
		return
	end

	if #items == 1 then
		run(items[1], on_exit)
		return
	end

	vim.ui.select(items, {
		prompt = "Select task",
	}, function(choice)
		if not choice then
			return
		end
		run(choice, on_exit)
	end)
end

---@param task task.Task
local register = function(task)
	if static.tasks[task.name] then
		vim.notify(string.format("Task %s exists, it's overridden now", task.name), vim.log.levels.WARN, {
			title = "Task",
		})
	end

	static.tasks[task.name] = task.config
end

return {
	register = register,
	launch = launch,
}
