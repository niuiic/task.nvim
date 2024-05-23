---@class task.Config
---@field cmd string
---@field args string[]
---@field options {env?: table<string, any>, cwd?: string, uid?: number, gid?: number, verbatim?: boolean, detached?: boolean, hide?: boolean} | nil

---@class task.Task
---@field name string
---@field config fun(): task.Config
---@field on_exit fun(output: string, task_name: string) | fun(output: string, task_name: string)[] | nil

---@type {[string]: task.Task}
local tasks = {}

---@type {[string]: {terminate: fun(), stdin: uv_pipe_t, running: fun():boolean}}
local task_handles = {}

---@type {[string]: string}
local task_output = {}

return {
	tasks = tasks,
	task_handles = task_handles,
	task_output = task_output,
}
