local M = {}

M.setup = require("crook.config").setup

local hook = require("crook.hook")
M.install_hook = hook.install_hook

local control = require("crook.control")
M.get_group = control.get_group

return M
