---@class LocalPythonConfig
---@field get_python_path_wrapper fun(workspace: string, debug: boolean): string The functional use of the object to get the python path
---@field find_python_path fun(self: LocalPythonConfig): string The method to find the python path
---@field get_python_path fun(self: LocalPythonConfig): string The method to get the python path
---@field validate_pylsp_in_path fun(self: LocalPythonConfig): boolean The method to validate the python path works with pylsp and mypy
---@field path string The path to the local python executable
---@field path_found boolean The flag to check if the path was found
---@field is_valid boolean The flag to check if the python path is valid
---@field error_message string The error message if the python path is not valid
---@field workspace string The workspace to check for the virtualenv
---@field debug boolean
local M = {}


---@return string python_path
function M:find_python_path ()
	local path = ""

-- Use activated virtualenv
	if vim.env.VIRTUAL_ENV then
		if self.debug then
			vim.notify('Using activated virtualenv: ' .. vim.env.VIRTUAL_ENV, vim.log.levels.INFO)
		end
		path = vim.env.VIRTUAL_ENV .. '/bin/python'
		self.path_found = true
		self.path = path
		return path
	end

	-- Find .venv in workspace
	local match = vim.fn.glob(self.workspace .. '/.venv/bin/python')
	if match ~= '' then
		if self.debug then
			vim.notify('Using virtualenv from workspace: ' .. match, vim.log.levels.INFO)
		end
		self.path_found = true
		path = match
		self.path = path
		return path
	end

	-- Fallback to system Python
	path = vim.fn.exepath('python3') or vim.fn.exepath('python') or 'python'
	if self.debug then
		vim.notify('[find_python_path] No virtualenv found, using system Python', vim.log.levels.INFO)
	end

	self.path = path
	return path
end

--- This is a function that gets the python path,
--- and validates that mypy and pylsp are installed in the virtualenv.
---@return string|nil
function M:get_python_path()
	self:find_python_path()

	if not self.path_found and self.path ~= "" then
		if self.debug then
			vim.notify("[get_python_path] Using system Python", vim.log.levels.INFO)
		end
		return self.path  -- Return system Python without validation
	end

	self:validate_pylsp_in_path()

	if self.is_valid then
		return self.path
	elseif self.error_message ~= nil then
		vim.notify(self.error_message, vim.log.levels.ERROR)
		return nil
	else
		vim.notify("[get_python_path] No virtualenv found", vim.log.levels.ERROR)
		return nil
	end
end

---@param workspace string
---@return LocalPythonConfig
function M.new(workspace)
	local this = setmetatable({}, { __index = M })
	-- Define with custom workspace or cwd
	this.workspace = workspace or vim.fn.getcwd()
	this.is_valid = false
	this.path_found = false
	this.error_message = ""
	this.path = ""
	this.debug = true
	return this
end

function M:validate_pylsp_in_path()

	-- Given a self.path, check if pylsp is in pip list
	-- then check if mypy is installed 

	if not self.path_found then
		if self.debug then
			self.error_message = "[validate_pylsp_in_path] No virtualenv path found"
		end
		return false
	elseif self.debug then
			vim.notify("[validate_pylsp_in_path] path_found: " .. self.path, vim.log.levels.INFO)
	end

	local pip_list = vim.fn.system(self.path .. ' -m pip list')

	if self.debug then
		vim.notify("PIP LIST: " .. pip_list, vim.log.levels.INFO)
	end

	local has_pylsp = string.find(pip_list, "python%-lsp%-server") ~= nil
	local has_mypy = string.find(pip_list, "mypy") ~= nil
	local has_pyslp_mypy = string.find(pip_list, "pylsp%-mypy") ~= nil
	local has_typing = string.find(pip_list, "typing") ~= nil
	local has_rope = string.find(pip_list, "rope") ~= nil
	local has_flake8 = string.find(pip_list, "flake8") ~= nil
	local has_pyls_rope = string.find(pip_list, "pylsp%-rope") ~= nil
	local has_jedi = string.find(pip_list, "jedi") ~= nil

	local has_all = has_pylsp and has_mypy and has_pyslp_mypy and has_typing and has_rope and has_flake8 and has_pyls_rope and has_jedi

	if has_all then
		self.is_valid = true
		return true
	else
		if self.path_found then
			-- Edge ccase that there is a virtualenv, but the python venv is missing modules
			local is_success_repair_install = self:fix_install()
			if is_success_repair_install then
				self.is_valid = true
				return true
			end
		end

		self.is_valid = false
		if not has_pylsp then
			self.error_message = "[validate_pylsp_in_path] pylsp is not installed in the virtualenv"
			vim.notify(self.error_message, vim.log.levels.ERROR)
		end
		if not has_mypy then
			self.error_message = "[validate_pylsp_in_path] mypy is not installed in the virtualenv"
			vim.notify(self.error_message, vim.log.levels.ERROR)
		end
		if not has_pyslp_mypy then
			self.error_message = "[validate_pylsp_in_path] pylsp-mypy is not installed in the virtualenv"
			vim.notify(self.error_message, vim.log.levels.ERROR)
		end
		if not has_typing then
			self.error_message = "[validate_pylsp_in_path] typing is not installed in the virtualenv"
			vim.notify(self.error_message, vim.log.levels.ERROR)
		end
		if not has_rope then
			self.error_message = "[validate_pylsp_in_path] rope is not installed in the virtualenv"
			vim.notify(self.error_message, vim.log.levels.ERROR)
		end
		if not has_flake8 then
			self.error_message = "[validate_pylsp_in_path] flake8 is not installed in the virtualenv"
			vim.notify(self.error_message, vim.log.levels.ERROR)
		end
		if not has_pyls_rope then
			self.error_message = "[validate_pylsp_in_path] pylsp-rope is not installed in the virtualenv"
			vim.notify(self.error_message, vim.log.levels.ERROR)
		end
		if not has_jedi then
			self.error_message = "[validate_pylsp_in_path] jedi is not installed in the virtualenv"
			vim.notify(self.error_message, vim.log.levels.ERROR)
		end
		return false
	end
end


---@return boolean is_success the installation was successful
function M:fix_install()
	if not self.path_found then
		self.error_message = "[install_pylsp] No virtualenv path found"
		return false
	end

	vim.notify("[local_python_config] Attemping to fix install with pip", vim.log.levels.INFO)

	local pip_install = self.path .. ' -m pip install python-lsp-server pylsp-mypy typing rope flake8 pylsp-rope jedi'
	local result = vim.fn.system(pip_install)


	if vim.v.shell_error ~= 0 then
		self.error_message = "[install_pylsp] Error installing pylsp: " .. result
		return false
	end

	vim.notify("[local_python_config] Successfully installed pylsp", vim.log.levels.INFO)

	return true
end

function M:set_debug(debug)
	self.debug = debug
end

---@param workspace string
---@param debug boolean
---@return string
function M.get_python_path_wrapper(workspace, debug)
	local python_config = M.new(workspace)
	python_config:set_debug(debug)
	local path = python_config:get_python_path()
	return path
end

return M
