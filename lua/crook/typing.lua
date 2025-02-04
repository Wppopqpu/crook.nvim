---@alias crook.ArgList any[]

---@class crook.HookContext
---@field public args crook.ArgList @args to be used
---@field public res any | nil @result of the hooked function
---@field public shared table @enable communication between hooks

---@alias crook.Hook fun(context: crook.HookContext)

---@alias crook.HookGroup integer

---@class crook.HookInstance
---@field public proc crook.Hook
---@field public proc_post crook.Hook
---@field public group crook.HookGroup | nil
---@field public prefer "first" | "last" | nil @controls exec order
---@field public before crook.HookGroup[] | nil @to run before
---@field public after crook.HookGroup[] | nil @to run after


---@class crook.HookPoint
---@field public fallback function @original function
---@field public hooks crook.HookInstance[] @hooks to be called

---@class crook.Opt
---@field public hook_method "replace" | nil @specifies how to hook
---@field public hook_point_field string | nil @field used to store hook_points in metatable
---@field public hooked_wrapper_field string | nil @field used to store hooked wrappers in metatable
