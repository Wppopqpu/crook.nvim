local M = {}

---@type table<crook.HookGroup>
local group_map = {
	default = 0,
}

local group_count = 0

---@param name string
---@return crook.HookGroup
function  M.get_group(name)
	if nil == group_map[name] then
		group_count = group_count + 1
		group_map[name] = group_count
		return group_count
	end
	local group = group_map[name]
	assert(nil ~= group, "invalid group")
	return group
end

---@type table<boolean>
local group_states = {}

--- to allow or deny the given group
---@param group crook.HookGroup
---@param state boolean
function M.set_group_state(group, state)
	assert("boolean" == type(state))
	if state then
		group_states[group] = nil
		return
	end
	group_states[group] = false
end

--- to get whether a group is enabled
---@param group crook.HookGroup
---@return boolean
function M.get_group_state(group)
	return nil == group_states[group]
end

return M
