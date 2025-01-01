-- FIXME:delete "metatable" hook method because it is wrong and ridiculus

local M = {}
---@type crook.Opt
local config = require("crook.config")
local utils = require("crook.utils")


--- execute hook_point
---@param hook_point crook.HookPoint
---@param args crook.ArgList
local function exec_hooked_point(hook_point, args)
	for _, hook in ipairs(hook_point.hooks) do
		hook.proc({ args = args })
	end
	return hook_point.fallback(unpack(args))
end

--- get wrapper to replace the function to be hooked
---@param hook_point crook.HookPoint
---@return function
local function get_hooked_wrapper(hook_point)
	return function (...)
		return exec_hooked_point(hook_point, utils.pack(...))
	end
end


--- returns hook points of a given table
--- assumes metatable exists
---@param root table
---@return table<crook.HookPoint> | nil @hook points
local function get_hook_points(root)
	return getmetatable(root)[config.hook_point_field]
end

--- returns hook point of a specific field
--- assumes metatable exists
---@param root table
---@param field string
---@return crook.HookPoint | nil
local function get_hook_point(root, field)
	local hook_points = get_hook_points(root)
	if nil ~= hook_points then
		return hook_points[field]
	end
	return nil
end

--- returns hooked wrappers of a given table
--- assumes metatable exists
---@param root table
---@return table<function> | nil
local function get_hooked_wrappers(root)
	return getmetatable(root)[config.hooked_wrapper_field]
end

--- install hook point for a specific field
--- assumes metatable exists
---@param root table @table that contains the field
---@param field string @field name
local function install_hook_point(root, field)
	---@type metatable
	local metatable = getmetatable(root)
	---@type string
	local hook_point_field = config.hook_point_field
	metatable[hook_point_field] = metatable[hook_point_field] or {}
	metatable[hook_point_field][field] = {
		fallback = root[field],
		hooks = {},
	}
end

--- installs hooked wrapper to a specific field
--- assumes metatable exists
--- If no hook_point is given,
--- it will get the hook_point from metatable.
--- So you may want to call it after install_hook_point.
---@param root table @table that contains the field
---@param field string @field name
---@param hook_point? crook.HookPoint @hook point to use
local function install_hooked_wrapper(root, field, hook_point)
	hook_point = hook_point or get_hook_point(root, field)

	---@diagnostic disable-next-line: param-type-mismatch
	local wrapper = get_hooked_wrapper(hook_point)
	if "replace" == config.hook_method then
		rawset(root, field, wrapper)
		return
	end
	if "metatable" == config.hook_method then
		---@type metatable
		local metatable = getmetatable(root)
		---@type string
		local wrapper_field = config.hook_point_field
		metatable[wrapper_field] = metatable[wrapper_field] or {}

		metatable[wrapper_field][field] = wrapper
		return
	end
end

--- installs new __index into metatable to make hook works
--- used when config.hook_method == "metatable"
--- assumes metatable exists
---@param root table
local function install_hook_router(root)
	---@type metatable
	local metatable = getmetatable(root)
	local old_index_func = metatable.__index or function (t, k)
		return t[k]
	end

	metatable.__index = function(t, k)
		---@type metatable
		if nil == get_hook_point(t, k) then
			return old_index_func(t, k)
		end
		return get_hooked_wrappers(t)[k]
	end
end

--- prepares hook infrastructure for a specific field
---@param root table @table that contains the field
---@param field string
local function prepare_hook_infrastructure(root, field)
	-- set the metatable if it doesn't exist
	utils.prepare_metatable(root)

	-- We have done this before.
	if nil ~= get_hook_point(root, field) then
		return
	end

	-- if there are no hook points,
	-- then __index has not been changed yet
	if "metatable" == config.hook_method
		and nil == get_hook_points(root)
		then
		install_hook_router(root)
		-- utils.log_inspected(getmetatable(root))
	end
	install_hook_point(root, field)
	install_hooked_wrapper(root, field)
	-- utils.log_inspected(getmetatable(root))
end

--- solves run order for two hook
---@param hook1 crook.HookInstance
---@param hook2 crook.HookInstance
---@return "before" | "after" | "relaxed"
local function get_run_order(hook1, hook2)
	local before = vim.tbl_contains(hook1.before, hook2.group)
		or vim.tbl_contains(hook2.after, hook1.group)
	local after = vim.tbl_contains(hook1.after, hook2.group)
		or vim.tbl_contains(hook2.before, hook1.group)

	if before then
		if after then
			error("failed to solve hook run order")
		end
		return "before"
	end

	if after then
		return "after"
	end
	return "relaxed"
end

---@param root table
---@param field string
---@param hook crook.HookInstance
local function __install_hook(root, field, hook)
	hook.group = hook.group or 0
	hook.after = hook.after or {}
	hook.before = hook.before or {}

	---@type crook.HookInstance[]
	-- utils.log_inspected(get_hook_point(root, field))
	local hook_list = get_hook_point(root, field).hooks
	---@type "find" | "check"
	local current_state = "find"
	local loc = 1
	for i, h in ipairs(hook_list) do
		if #hook_list == i and "find" == current_state then
			loc =  #hook_list + 1
			break
		end
		local order = get_run_order(hook, h)
		if "after" == order then
			if "check" == current_state then
				error("failed to solve hook run order")
			end
			goto continue
		end
		if "relaxed" == order then
			if "last" ~= hook.prefer and "find" == current_state then
				loc = i
				current_state = "check"
			end
			goto continue
		end
		if "before" == order then
			if "find" == current_state then
				loc = i
				current_state = "check"
			end
			goto continue
		end
	    ::continue::
	end

	table.insert(hook_list, loc, hook)
end

--- installs hook into given field of given table
---@param root table @table that contains the field
---@param field string field name
---@param hook crook.HookInstance hook instance
function M.install_hook(root, field, hook)
	assert("table" == type(root))
	assert("string" == type(field))
	assert("function" == type(hook.proc))
	assert("function" == type(root[field]))

	prepare_hook_infrastructure(root, field)
	__install_hook(root, field, hook)
end

return M
