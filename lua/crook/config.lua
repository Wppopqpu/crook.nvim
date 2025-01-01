---@type crook.Opt
local M = {
	hook_method = "replace",
	hook_point_field = "hook_points",
	hooked_wrapper_field = "hooked_wrappers",
}

--- setup config
---@param opt crook.Opt
local function setup(opt)
	if nil ~= opt.hook_method and
		not vim.tbl_contains({ "metatable", "replace" }, opt.hook_method)
		then
		error("invalid hook_method")
	end
	assert(nil == opt.hook_point_field or "string" == type(opt.hook_point_field), "invalid hook_point_field")
	assert(nil == opt.hooked_wrapper_field or "string" == type(opt.hooked_wrapper_field), "invalid hooked_wrapper_field")

	M = vim.tbl_deep_extend("force", opt, M)
end

return setmetatable({}, {
	__index = function (table, key)
		if "setup" == key then
			return setup
		end
		return M[key]
	end
})
