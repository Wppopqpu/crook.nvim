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

return M
