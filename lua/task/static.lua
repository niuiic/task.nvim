---@class task.Config
---@field cmd string
---@field args string[]
---@field options {env: table<string, any>, cwd: string, uid: number, gid: number, verbatim: boolean, detached: boolean, hide: boolean} | nil

---@class task.Task
---@field name string
---@field config fun(): task.Config

---@type {[string]: fun(): task.Config}
local tasks = {}

return {
	tasks = tasks,
}
