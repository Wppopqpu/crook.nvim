local M = {}

--- sets metatable to {} when it doesn't exists
---@param t table
function M.prepare_metatable(t)
	if nil == getmetatable(t) then
		setmetatable(t, {})
	end
end

---@param msg string
function M.log(msg)
	vim.api.nvim_echo({{"[crook]"..msg, "ErrorMsg"}}, true, {})
end

---@param obj any
function M.log_inspected(obj)
	M.log("[inspect]"..vim.inspect(obj))
end

--- custom table.pack
---@vararg any
function M.pack(...)
	local t = {}
	t.n = select("#", ...)
	for i = 1, t.n do
		t[i] = select(i, ...)
	end
	return t
end

return M
