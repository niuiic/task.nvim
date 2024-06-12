local static = require("task.static")
local core = require("core")

---@param task_name string
local run = function(task_name)
	if not static.tasks[task_name] then
		vim.notify(string.format("Task %s not found", vim.log.levels.ERROR, {
			title = "Task",
		}))
		return
	end

	local config = static.tasks[task_name].config()
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
		local on_job_exit = static.tasks[task_name].on_exit

		if not on_job_exit then
			on_job_exit = { require("task.output").notify }
		end
		---@diagnostic disable-next-line: param-type-mismatch
		if not vim.islist(on_job_exit) then
			on_job_exit = { on_job_exit }
		end
		---@diagnostic disable-next-line: param-type-mismatch
		core.lua.list.each(on_job_exit, function(fn)
			fn(static.task_output[task_name], task_name)
		end)
		static.task_handles[task_name] = nil
	end
	local on_output = function(_, data)
		static.task_output[task_name] = static.task_output[task_name] .. data
		local task_handle = static.task_handles[task_name]
		if not task_handle then
			return
		end
		local on_job_output = static.tasks[task_name].on_output
		if not on_job_output then
			return
		end
		---@diagnostic disable-next-line: param-type-mismatch
		if not vim.islist(on_job_output) then
			---@diagnostic disable-next-line: assign-type-mismatch
			on_job_output = { on_job_output }
		end
		local write = function(str)
			vim.uv.write(task_handle.stdin, str)
			static.task_output[task_name] = static.task_output[task_name] .. str
		end
		---@diagnostic disable-next-line: param-type-mismatch
		core.lua.list.each(on_job_output, function(fn)
			fn(data, write, task_name)
		end)
	end
	local on_err = function(_, data)
		static.task_output[task_name] = static.task_output[task_name] .. data
		local task_handle = static.task_handles[task_name]
		if not task_handle then
			return
		end
		local on_job_err = static.tasks[task_name].on_err
		if not on_job_err then
			return
		end
		---@diagnostic disable-next-line: param-type-mismatch
		if not vim.islist(on_job_err) then
			---@diagnostic disable-next-line: assign-type-mismatch
			on_job_err = { on_job_err }
		end
		local write = function(str)
			vim.uv.write(task_handle.stdin, str)
			static.task_output[task_name] = static.task_output[task_name] .. str
		end
		---@diagnostic disable-next-line: param-type-mismatch
		core.lua.list.each(on_job_err, function(fn)
			fn(data, write, task_name)
		end)
	end

	static.task_output[task_name] = ""
	static.task_handles[task_name] =
		core.job.spawn(config.cmd, config.args, config.options or {}, on_exit, on_err, on_output)
end

---@param task_name string | nil
local launch = function(task_name)
	if task_name then
		run(task_name)
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
		run(items[1])
		return
	end

	vim.ui.select(items, {
		prompt = "Select task",
	}, function(choice)
		if not choice then
			return
		end
		run(choice)
	end)
end

---@param task_name string | nil
---@param output_method fun(output: string, task_name: string) | nil
local preview = function(task_name, output_method)
	local render = function(name)
		output_method = output_method or require("task.output").use_float_win()

		if not static.task_output[name] then
			vim.notify(string.format("No output for task %s", name), vim.log.levels.WARN, {
				title = "Task",
			})
			return
		end

		output_method(static.task_output[name], name)
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

	static.tasks[task.name] = task
end

return {
	register = register,
	launch = launch,
	preview = preview,
}
