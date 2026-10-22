--- Resolves the Python interpreter a project actually uses, for LSP settings.
---
--- Written for uv, which breaks the naive ".venv next to the file I'm editing"
--- assumption in two ways:
---   * in a uv workspace, the single `.venv` lives at the *workspace* root, which
---     can be several directories above the member package being edited,
---   * the environment can be moved somewhere else entirely with
---     $UV_PROJECT_ENVIRONMENT.
---
--- It matters because basedpyright only reads `python.pythonPath` and
--- `python.venvPath` out of the LSP settings it is sent -- `python.venv`, which
--- is what pyrightconfig.json/pyproject.toml use, is ignored over the wire. So
--- the interpreter has to be resolved here and handed over as `pythonPath`.
local M = {}

local is_win = vim.fn.has('win32') == 1

--- vim.fs.normalize() gives forward slashes on every platform, so Windows
--- absolute paths arrive as "C:/...".
--- @param path string
--- @return boolean
local function is_absolute(path)
	return vim.startswith(path, '/') or path:match('^%a:/') ~= nil
end

--- @param venv string Absolute path to a virtualenv directory
--- @return string|nil python Path to its interpreter, if it has one
local function interpreter(venv)
	local path = is_win and (venv .. '/Scripts/python.exe') or (venv .. '/bin/python')
	return vim.fn.executable(path) == 1 and path or nil
end

--- Virtualenv directory names to look for, most specific first.
--- $UV_PROJECT_ENVIRONMENT may be absolute, in which case it is not a name at
--- all; `find_venv_upward` takes it as the answer instead of joining it.
--- @return string[]
local function venv_names()
	local names = {}
	if vim.env.UV_PROJECT_ENVIRONMENT and vim.env.UV_PROJECT_ENVIRONMENT ~= '' then
		table.insert(names, vim.env.UV_PROJECT_ENVIRONMENT)
	end
	vim.list_extend(names, { '.venv', 'venv' })
	return names
end

--- Walks up from `dir` looking for a virtualenv, so that a file inside a uv
--- workspace member finds the environment at the workspace root. Stops at $HOME
--- so that a stray ~/.venv doesn't get attached to every project.
--- @param dir string
--- @return string|nil
local function find_venv_upward(dir)
	local home = vim.fs.normalize(vim.env.HOME or '~')
	local names = venv_names()

	local search = { dir }
	for parent in vim.fs.parents(dir) do
		table.insert(search, parent)
	end

	for _, candidate in ipairs(search) do
		if candidate == home then
			break
		end
		for _, name in ipairs(names) do
			local venv = vim.fs.normalize(name)
			if not is_absolute(venv) then
				venv = candidate .. '/' .. name
			end
			local python = interpreter(venv)
			if python then
				return python
			end
		end
	end
end

--- @param dir string
--- @return boolean
local function is_uv_project(dir)
	if vim.fn.filereadable(dir .. '/uv.lock') == 1 or vim.fn.filereadable(dir .. '/uv.toml') == 1 then
		return true
	end
	local pyproject = dir .. '/pyproject.toml'
	if vim.fn.filereadable(pyproject) ~= 1 then
		return false
	end
	for _, line in ipairs(vim.fn.readfile(pyproject)) do
		if line:match('^%s*%[tool%.uv') then
			return true
		end
	end
	return false
end

--- Last resort for uv projects whose environment the directory walk missed:
--- `uv python find` resolves the project (and workspace) environment itself.
--- @param dir string
--- @return string|nil
local function uv_python_find(dir)
	if vim.fn.executable('uv') ~= 1 or not is_uv_project(dir) then
		return nil
	end

	local ok, result = pcall(function()
		return vim.system({ 'uv', 'python', 'find' }, { cwd = dir, text = true }):wait(2000)
	end)
	if not ok or result.code ~= 0 then
		return nil
	end

	local path = vim.trim(result.stdout or '')
	return vim.fn.executable(path) == 1 and path or nil
end

--- @type table<string, string>
local cache = {}

--- Resolves the interpreter for a project root, in order of how specific the
--- evidence is: an in-tree virtualenv, then an activated one, then whatever uv
--- says, then system Python.
--- @param root_dir string|nil Defaults to the current working directory
--- @return string python
function M.resolve(root_dir)
	local dir = vim.fs.normalize(root_dir or vim.fn.getcwd())

	if cache[dir] then
		return cache[dir]
	end

	local python = find_venv_upward(dir)

	if not python and vim.env.VIRTUAL_ENV and vim.env.VIRTUAL_ENV ~= '' then
		python = interpreter(vim.fs.normalize(vim.env.VIRTUAL_ENV))
	end

	if not python then
		python = uv_python_find(dir)
	end

	if not python then
		local system = vim.fn.exepath('python3')
		python = system ~= '' and system or 'python3'
	end

	cache[dir] = python
	return python
end

--- Drops the memoised interpreters.
function M.clear()
	cache = {}
end

--- Re-resolves the interpreter and pushes it to the running servers, so that a
--- `uv sync` that has just created .venv is picked up without restarting Nvim.
vim.api.nvim_create_user_command('PythonEnv', function()
	M.clear()

	local clients = vim.lsp.get_clients({ bufnr = 0, name = 'basedpyright' })
	if vim.tbl_isempty(clients) then
		vim.notify('No basedpyright attached; would use ' .. M.resolve(), vim.log.levels.WARN)
		return
	end

	for _, client in ipairs(clients) do
		local python = M.resolve(client.root_dir)
		client.settings.python = client.settings.python or {}
		client.settings.python.pythonPath = python
		client:notify('workspace/didChangeConfiguration', { settings = client.settings })
		vim.notify(('basedpyright [%s]: %s'):format(client.root_dir or '?', python), vim.log.levels.INFO)
	end
end, { desc = 'Re-resolve the Python interpreter and send it to the running LSP' })

return M
