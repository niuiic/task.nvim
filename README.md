# task.nvim

Task manager for neovim.

[More neovim plugins](https://github.com/niuiic/awesome-neovim-plugins)

## Dependencies

- [niuiic/core.nvim](https://github.com/niuiic/core.nvim)

## Usage

<img src="https://github.com/niuiic/assets/blob/main/task.nvim/usage.gif" />

1. Register tasks

```lua
local split_win = require("task.output").use_split_win()

---@class task.Config
---@field cmd string
---@field args string[]
---@field options {env?: table<string, any>, cwd?: string, uid?: number, gid?: number, verbatim?: boolean, detached?: boolean, hide?: boolean} | nil

---@class task.Task
---@field name string
---@field config fun(): task.Config
---@field on_exit fun(output: string, task_name: string) | fun(output: string, task_name: string)[] | nil

---@param task task.Task
require("task").register({
	name = "dart",
	config = function()
		return {
			cmd = "dart",
			args = { "run", vim.api.nvim_buf_get_name(0) },
		}
	end,
	on_exit = {
		require("task.output").notify_done,
		split_win,
	},
})
```

2. Launch task

```lua
---@param task_name string | nil
require("task").launch()
```

3. Preview output

```lua
---@param task_name string | nil
---@param output_method fun(output: string, task_name: string) | nil
require("task").preview()
```

For builtin output methods, check `lua/task/output.lua`.
