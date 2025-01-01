local M = {}

M.setup = require("crook.config").setup

local hook = require("crook.hook")
M.prepare_hook = hook.prepare_hook
M.install_hook = hook.install_hook

local control = require("crook.control")
M.get_group = control.get_group
M.set_group_state = control.set_group_state
M.get_group_state = control.get_group_state

return M
