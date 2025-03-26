---@class Tab_marks
---@field marks table<Tab_mark> Array of marks
local Tab_marks = {
  marks = {}
}

-- Create a new Tab_marks instance
---@return Tab_marks
function Tab_marks:new()
  local instance = setmetatable({}, { __index = self })
  instance.marks = {}
  return instance
end

-- Add a mark to the collection
---@param mark any The mark data to store
function Tab_marks:add(name, mark)
  self.marks[name] = mark
end

-- Get a mark by name
---@param name string The name/key of the mark
---@return any|nil The mark if found, nil otherwise
function Tab_marks:get(name)
  return self.marks[name]
end

-- Remove a mark by name
---@param name string The name/key of the mark to remove
---@return boolean True if removed, false if not found
function Tab_marks:remove(name)
  if self.marks[name] then
    self.marks[name] = nil
    return true
  end
  return false
end

-- Get all marks
---@return table<string, any> All marks
function Tab_marks:get_all()
  return self.marks
end

return Tab_marks
