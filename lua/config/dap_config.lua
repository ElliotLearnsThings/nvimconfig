-- DAP CONFIG
local dap = require('dap')
local dapui = require("dapui")
require("lazydev").setup({
  library = { "nvim-dap-ui" },
})

dap.set_log_level('TRACE')


local function debug_log(msg)
  vim.notify("DAP DEBUG: " .. msg, vim.log.levels.INFO)
end

local function open_dapui()
	-- Add a small delay to ensure DAP is fully initialized
	vim.defer_fn(function()
		dapui.open()
		-- Print a debug message
		-- vim.notify("DAP UI opened", vim.log.levels.INFO)
	end, 100)
end


local function close_dapui()
	dapui.close()
	vim.notify("DAP UI closed", vim.log.levels.INFO)
end


-- conf py
dap.configurations.python = {
	{
		type = 'python',
		console = "integratedTerminal",
		request = 'launch',
		name = 'Launch file',
		program = "${file}",
		pythonPath = function()
			return vim.fn.exepath('python3') or vim.fn.exepath('python') or 'python'
		end,
		-- Add the frozen modules flag
		args = {"-Xfrozen_modules=off"},
	},
	{
		type = 'python',
		console = "integratedTerminal",
		request = 'attach',
		name = 'Attach remote',
		connect = {
			port = 5678,
			host = '127.0.0.1',
		},
		-- Add the frozen modules flag for attach mode too
		args = {"-Xfrozen_modules=off"},
	},
}


-- Adapters py
dap.adapters.python = function(cb, config)
	if config.request == 'attach' then
		-- Attach configuration remains the same
		---@diagnostic disable-next-line: undefined-field
		local port = (config.connect or config).port
		---@diagnostic disable-next-line: undefined-field
		local host = (config.connect or config).host or '127.0.0.1'
		cb({
			type = 'server',
			port = assert(port, '`connect.port` is required for a python `attach` configuration'),
			host = host,
			options = {
				source_filetype = 'python',
			},
		})
	else
		-- For launch configurations, add the flag to debugpy
		local python_path = vim.fn.exepath('python3') or vim.fn.exepath('python') or 'python'

		cb({
			type = 'executable',
			command = python_path,
			-- Add the flag here
			args = { '-Xfrozen_modules=off', '-m', 'debugpy.adapter' },
			options = {
				source_filetype = 'python',
			},
		})
	end
end

-- Improved TypeScript/JavaScript debug configuration
--


-- Configuration for attaching to Node.js
-- Configuration focused on direct process attachment

-- Create TypeScript/JavaScript configurations

dap.adapters.node = {
  type = 'server',
  host = 'localhost',
  port = 8123,
  executable = {
    command = 'node',
    args = {
      vim.fn.stdpath('data') .. '/mason/packages/js-debug-adapter/js-debug/src/dapDebugServer.js',
      '8123'
    },
  }
}

-- Create an integrated terminal launch configuration
dap.configurations.typescript = {
  {
    name = 'Launch in Terminal',
    type = 'node',
    request = 'launch',  -- LAUNCH instead of ATTACH
    program = '${file}',
    cwd = '${workspaceFolder}',
    runtimeExecutable = 'npx',
    runtimeArgs = { 'tsx' },
    sourceMaps = true,
    outFiles = { '${workspaceFolder}/dist/**/*.js' },
    -- Use integrated terminal instead of debug console
    console = 'integratedTerminal',
    internalConsoleOptions = 'neverOpen',
    -- More reliable source mapping
    resolveSourceMapLocations = {
      '${workspaceFolder}/**',
      '!**/node_modules/**',
    },
    -- Skip irrelevant files
    skipFiles = {
      '<node_internals>/**',
      '${workspaceFolder}/node_modules/**/*.js',
    },
    -- More reliable execution
    protocol = 'inspector',
    -- Keep running on disconnect
    killBehavior = 'none',
    -- Debug settings
    trace = true,
  },
  
  -- Configuration to run a specific main file
  {
    name = 'Launch main.ts',
    type = 'node',
    request = 'launch',
    program = '${workspaceFolder}/main.ts',
    cwd = '${workspaceFolder}',
    runtimeExecutable = 'npx',
    runtimeArgs = { 'tsx' },
    sourceMaps = true,
    outFiles = { '${workspaceFolder}/dist/**/*.js' },
    console = 'integratedTerminal',
    internalConsoleOptions = 'neverOpen',
    resolveSourceMapLocations = {
      '${workspaceFolder}/**',
      '!**/node_modules/**',
    },
    skipFiles = {
      '<node_internals>/**',
      '${workspaceFolder}/node_modules/**/*.js',
    },
    protocol = 'inspector',
    killBehavior = 'none',
    trace = true,
  }
}


-- Match JavaScript configuration
dap.configurations.javascript = dap.configurations.typescript

-- Update Go configuration to use the found dlv path
dap.configurations.go = {
	{
		type = 'go',
		console = "integratedTerminal",
		request = 'launch',
		name = 'Launch file',
		program = "${file}",
	},
	{
		type = 'go',
		console = "integratedTerminal",
		request = 'attach',
		name = 'Attach to process',
		processId = require('dap.utils').pick_process,
	},
}

-- Adapters Go

dap.adapters.go = function(callback, config)
	-- Try to find dlv
	local dlv_path = vim.fn.exepath('dlv')

	-- If not found in PATH, try common locations
	if dlv_path == '' then
		-- Try Go bin directory
		local home = os.getenv('HOME')
		local possible_paths = {
			home .. '/go/bin/dlv',
			home .. '/.go/bin/dlv',
			home .. '/gopath/bin/dlv',
			home .. '/.gopath/bin/dlv',
		}

		for _, path in ipairs(possible_paths) do
			if vim.fn.executable(path) == 1 then
				dlv_path = path
				break
			end
		end

		-- If still not found, show error
		if dlv_path == '' then
			vim.notify("Delve debugger (dlv) not found. Install with: go install github.com/go-delve/delve/cmd/dlv@latest", vim.log.levels.ERROR)
			return
		end
	end

	-- Configure the adapter
	callback({
		type = 'server',
		port = '${port}',
		executable = {
			command = dlv_path,
			args = { 'dap', '-l', '127.0.0.1:${port}' },
		}
	})
end


-- Rust configurations
dap.configurations.rust = {
	{
		type = 'rust',
		request = 'launch',
		name = 'Debug executable',
		program = function()
			debug_log("Finding Rust executable")
			-- Try a simpler approach first
			local cwd = vim.fn.getcwd()
			local target_name = vim.fn.fnamemodify(cwd, ":t")
			local executable = cwd .. "/target/debug/" .. target_name

			debug_log("Using executable: " .. executable)
			return executable
		end,
		cwd = "${workspaceFolder}",
		console = "integratedTerminal",
		prelaunch = function()
			debug_log("Running cargo build")
			local result = vim.fn.system("cargo build")
			debug_log("Build result: " .. result)
			return true
		end,
		args = {},
		-- Add this to see if it helps with UI stability
		runInTerminal = false,
	},
	{
		type = 'rust',
		request = 'launch',
		name = 'Debug current file (cargo run)',
		program = function()
			return vim.fn.getcwd() .. "/target/debug/" .. vim.fn.fnamemodify(vim.fn.getcwd(), ":t")
		end,
		cwd = "${workspaceFolder}",
		console = "integratedTerminal",
		prelaunch = function()
			vim.fn.system("cargo build")
			return true
		end,
	},
	{
		type = 'rust',  -- This needs to match your adapter name
		request = 'launch',
		name = 'Debug Rust Tests',
		program = function()
			-- First compile the tests without running them


			local function parse_output()
				local output = vim.fn.system("cargo test --no-run")
				local msg = ""
				local is_error = false

				if vim.v.shell_error ~= 0 then
					is_error = true
					msg = "Error in cargo"
					return {output, is_error, msg}
				end

				local index = string.find(output, "Executable")

				if index == nil then
					is_error = true
					msg = "Could not parse output"
					return {output, is_error, msg}
				end

				local parsed = string.sub(output, index)
				index = string.find(parsed, "deps/")

				if index == nil then
					is_error = true
					msg = "Could not parse output"
					return {output, is_error, msg}
				end

				parsed = string.sub(parsed, index+5, string.len(parsed)-2)
				return {output, is_error, parsed}
			end


			local parse_output_table = parse_output()
			local output = parse_output_table[1]
			local is_error = parse_output_table[2]
			local msg = parse_output_table[3]


			if is_error then
				vim.notify("Failed to run cargo test: " .. output .. "\nParse Error: " .. msg, vim.log.levels.ERROR)
				return
			else
				vim.notify("Successfully compiled tests: " .. output .. "\nFile: " .. msg, vim.log.levels.INFO)
			end

			local binary_path = vim.fn.getcwd() .. "/target/debug/deps/" .. msg

			vim.notify(binary_path, vim.log.levels.INFO)

			return binary_path
		end,
		args = function()
			local test_name = vim.fn.expand('<cword>')

			-- If we're in a test file and have a word under cursor, use it as the test name
			if test_name ~= "" and (vim.fn.expand('%'):match("_test%.rs$") or vim.fn.expand('%'):match("test_.*%.rs$")) then
				return {"--exact", test_name}
			else
				-- Otherwise, optionally prompt for a test name
				test_name = vim.fn.input("Test name (leave empty to run all tests): ")
				if test_name ~= "" then
					return {"--exact", test_name}
				end
			end

			return {}
		end,
		cwd = "${workspaceFolder}",
		console = "integratedTerminal",
		stopOnEntry = false,
	},
	{
		type = 'rust',
		request = 'attach',
		name = 'Attach to process',
		processId = require('dap.utils').pick_process,
		cwd = "${workspaceFolder}",
		console = "integratedTerminal",
	},
}

-- Rust adapter (using CodeLLDB)
dap.adapters.rust = {
  type = 'server',
  port = '${port}',
  executable = {
    command = vim.fn.stdpath('data') .. '/mason/packages/codelldb/extension/adapter/codelldb',
    args = { '--port', '${port}' },
  },
  name = "lldb",
}



-- DAP keybindings with <leader>d prefix
local keymap = vim.keymap.set
local opts = { noremap = true, silent = true }

-- Start/continue debugging session
keymap('n', '<C-i>', dap.continue, opts)
-- Step over
keymap('n', '<leader>dn', dap.step_over, opts)
-- Step into
keymap('n', '<C-p>', dap.step_into, opts)
-- Step out
keymap('n', '<leader>do', dap.step_out, opts)
-- Toggle breakpoint
keymap('n', '<leader>db', dap.toggle_breakpoint, opts)
-- Set conditional breakpoint
keymap('n', '<leader>dB', function()
  dap.set_breakpoint(vim.fn.input('Breakpoint condition: '))
end, opts)
-- Open REPL
keymap('n', '<leader>dr', dap.repl.open, opts)
-- Run last
keymap('n', '<leader>dl', dap.run_last, opts)
-- Terminate session
keymap('n', '<leader>dx', dap.terminate, opts)
-- kill port
keymap('n', '<leader>dk', ':KillPort<Space>')


vim.api.nvim_create_user_command('KillPort', function(opts)
    local port = opts.args
    if port and port ~= "" then
        vim.fn.system('lsof -ti :' .. port .. ' | xargs kill')
        vim.notify('Killed processes on port ' .. port, vim.log.levels.INFO)
    else
        vim.notify('No port specified', vim.log.levels.ERROR)
    end
end, {
    nargs = '?',
    desc = 'Kill processes running on specified port'
})

function kp(port)
    if port and port ~= "" then
        vim.fn.system('lsof -ti :' .. port .. ' | xargs kill')
        vim.notify('Killed processes on port ' .. port, vim.log.levels.INFO)
    else
        vim.notify('No port specified', vim.log.levels.ERROR)
    end
end



-- Dap ui

dapui.setup({
  -- Keep your existing configuration, but add these options:
  auto_open = false,  -- Don't auto-open on session start
  auto_close = false, -- Don't auto-close on session end


	icons = { expanded = "▾", collapsed = "▸", current_frame = "▸" },
	mappings = {
		open = "o",
		edit = "e",
		expand = { "<CR>", "<2-LeftMouse>" },
		remove = "d",
	},
	element_mappings = {},
	expand_lines = true,
	force_buffers = true,
	floating = {
		max_height = nil,
		max_width = nil,
		border = "single",
		mappings = {
			close = { "q", "<Esc>" },
		},
	},
	controls = {
		enabled = true,
		element = "repl",
		icons = {
			pause = "",
			play = "",
			step_into = "",
			step_over = "",
			step_out = "",
			run_last = "",
			terminate = "",
		},
	},
	render = {
		max_type_length = nil,
		max_value_lines = 100,
	},
	layouts = {
		{
			elements = {
				{ id = "scopes", size = 0.7 },
				{ id = "breakpoints", size = 0.3 },
			},
			size = 30,
			position = "top",
		},
		{
			elements = {
				{ id = "repl", size = 0.3 },
				{ id = "stacks", size = 0.7 },
			},
			size = 30,
			position = "bottom",
		},
	},
})

keymap('n', '<leader>du', "<CMD>:Debug<CR>", opts)
keymap('n', '<leader>dU', function() dapui.close() end, opts)

-- UI control commands
vim.api.nvim_create_user_command('DapUIOpen', function() open_dapui() end, {})
vim.api.nvim_create_user_command('DapUIClose', function() close_dapui() end, {})

-- Smart debug command that adapts to the current filetype
vim.api.nvim_create_user_command('Debug', function()
	local filetype = vim.bo.filetype

	-- Pre-debug actions based on filetype
	if filetype == "rust" then
		vim.notify("Building Rust project...", vim.log.levels.INFO)
		local result = vim.fn.system("cargo build")
		if vim.v.shell_error ~= 0 then
			vim.notify("Cargo build failed: " .. result, vim.log.levels.ERROR)
			return
		end
		vim.notify("Rust build complete", vim.log.levels.INFO)
	elseif filetype == "go" then
		vim.notify("Building Go project...", vim.log.levels.INFO)
		local result = vim.fn.system("go build .")
		if vim.v.shell_error ~= 0 then
			vim.notify("Go build failed: " .. result, vim.log.levels.ERROR)
			return
		end
		vim.notify("Go build complete", vim.log.levels.INFO)
	elseif filetype == "python" then
		-- Python doesn't need pre-compilation
		vim.notify("Starting Python debugger...", vim.log.levels.INFO)
	end

	-- Then open the UI manually
	open_dapui()

	-- Wait a bit before starting the debugger
	vim.defer_fn(function()
		dap.continue()
	end, 200)
end, {})


-- Kill process
keymap('n', '<leader>dd', "<CMD>:Debug<CR>", opts)

-- Keep the specific Rust debug command for backward compatibility
vim.api.nvim_create_user_command('DebugRust', function()
	vim.cmd("Debug")
end, {})

-- Set up new listeners
dap.listeners.after.event_initialized["dapui_config"] = open_dapui
dap.listeners.after.event_terminated["dapui_config"] = close_dapui
dap.listeners.after.event_exited["dapui_config"] = close_dapui




local function with_ui(callback)
  pcall(function() require('dapui').close() end)
  vim.defer_fn(function()
    require('dapui').open()
    vim.defer_fn(callback, 100)
  end, 100)
end

-- Commands
vim.api.nvim_create_user_command('LaunchTS', function()
  with_ui(function()
    dap.run(dap.configurations.typescript[1])
  end)
end, {})

vim.api.nvim_create_user_command('LaunchMain', function()
  with_ui(function()
    dap.run(dap.configurations.typescript[2])
  end)
end, {})

-- Keymaps
vim.keymap.set('n', '<leader>dl', '<CMD>LaunchTS<CR>', { noremap = true, silent = true })
vim.keymap.set('n', '<leader>dm', '<CMD>LaunchMain<CR>', { noremap = true, silent = true })

-- Create .nvim.lua file in project root
vim.api.nvim_create_user_command('CreateDebugConfig', function()
  local config_content = [[
-- Project-specific debug configuration
if vim.fn.filereadable(vim.fn.getcwd() .. '/package.json') == 1 then
  local dap = require('dap')
  
  -- Setup debug keymaps
  vim.keymap.set('n', '<leader>dl', '<CMD>LaunchTS<CR>', { noremap = true, silent = true })
  vim.keymap.set('n', '<leader>dm', '<CMD>LaunchMain<CR>', { noremap = true, silent = true })
  
  -- Auto-open UI on debug events
  dap.listeners.after.event_initialized["dapui_config"] = function()
    require('dapui').open()
  end
  
  -- Print welcome message
  print("TypeScript debugging enabled for this project")
end
]]
  
  local file = io.open(vim.fn.getcwd() .. '/.nvim.lua', 'w')
  if file then
    file:write(config_content)
    file:close()
    print("Debug configuration saved to .nvim.lua")
  else
    print("Failed to create .nvim.lua file")
  end
end, {})


