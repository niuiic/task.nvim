local static = require("task.static")
local core = require("core")

---@param task_name string
---@param on_job_exit fun(output) | nil
local run = function(task_name, on_job_exit)
	local get_config = static.tasks[task_name]
	if not get_config then
		vim.notify(string.format("Task %s not found", vim.log.levels.ERROR, {
			title = "Task",
		}))
		return
	end
	local config = get_config()
	if not config then
		vim.notify("No config provided, task exits", vim.log.levels.WARN, {
			title = "Task",
		})
		return
	end

	local handle = static.task_handles[task_name]
	if handle then
		local choice = vim.fn.confirm(string.format("Task %s is running, relaunch it?", task_name), "&Yes\n&No", 2)
		if choice == 1 then
			handle.terminate()
		else
			return
		end
	end

	local on_exit = function()
		if not on_job_exit then
			vim.notify(static.task_output[task_name], vim.log.levels.INFO, {
				title = string.format("Task %s", task_name),
			})
		else
			on_job_exit(static.task_output[task_name])
		end
		static.task_handles[task_name] = nil
	end
	local on_output = function(_, data)
		static.task_output[task_name] = static.task_output[task_name] .. data
	end
	local on_err = function(_, data)
		static.task_output[task_name] = static.task_output[task_name] .. data
	end

	static.task_output[task_name] = ""
	static.task_handles[task_name] =
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

---@param task_name string | nil
---@param output_method fun(output) | nil
local preview = function(task_name, output_method)
	local render = function(name)
		output_method = output_method or require("task.output").use_float_win()

		if not static.task_output[name] then
			vim.notify(string.format("No output for task %s", name), vim.log.levels.WARN, {
				title = "Task",
			})
			return
		end

		output_method(static.task_output[name])
	end

	if task_name then
		render(task_name)
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
		render(items[1])
		return
	end

	vim.ui.select(items, {
		prompt = "Select task",
	}, function(choice)
		if not choice then
			return
		end
		render(choice)
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
	preview = preview,
}
