# Crook.nvim (***WIP***)

## INTRO

`crook.nvim` is a simple plugin that provides a unified way (use `rawset`)
to hook (mock) nvim's lua api.

## INSTALLATION

lazy.nvim:

```lua
{
    "wppopqpu/crook.nvim",
    -- OPTIONAL: load before other plugins to make sure apis are mocked
    priority = 9999,
    config = function ()
        local crook = require("crook")
        crook.setup{}

        -- OPTIONAL: mock them before other plugins use it
        crook.prepare_hook(vim.api, "nvim_open_win")
    end,
},
```

## USAGE (EXAMPLE)

```lua
local crook = require("crook")
local utils = require("crook.utils")

-- OPTIONAL
crook.prepare_hook(vim.api, "nvim_open_win")

local group = crook.get_group("my_group")

crook.install_hook(vim.api, "nvim_open_win", {
    -- to be run before fallback
    proc = function(ctx)
        utils.log("Hello") -- do something you want

        utils.log_inspected(ctx.args) -- read the arguments
        ctx.args[1] = 0 -- modify the arguments
    end,
    -- to be run after fallback
    proc_post = function(ctx)
        utils.log_inspected(ctx.shared) -- read the shared table
        utils.log_inspected(ctx.res)
        ctx.res = 42 -- modify the result
    end,
    -- OPTIONAL
    -- default group is "none" (0)
    group = group,
    -- OPTIONAL
    -- to run before those groups
    before = { 0, 2, 3, 4 },
    -- OPTIONAL
    -- to run after those groups
    after = { 42, 37 },
    -- OPTIONAL
    -- to run as early as possible
    prefer = "first", -- or "last" to run as late as possible
})


-- disable group
crook.set_group_state(crook.get_group("none"), false) -- or true to enable

-- get group state
assert(not crook.get_group_state(0))
```

## WARNING

This *experimental* plugin is developed by a middle school student,
use it ***at your own risk***.

## MOTIVATION

Several plugins I want to develop need to mock nvim's lua api.
But it is bad for them to mock on their own,
which causes deeper stack (?).
So I try to solve this problem.
