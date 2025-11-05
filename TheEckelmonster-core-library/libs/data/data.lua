local Log_Stub = require("libs.log.log-stub")
local _Log = Log
if (not script or not _Log or mods) then _Log = Log_Stub end

local data = {}

-- Audit fields
data.valid = false
data.created = nil
data.updated = nil

function data:new(o)
    _Log.debug("data:new")
    _Log.info(o)

    local defaults = {
        valid = self.valid,
        created = game and game.tick or 0,
        updated = game and game.tick or 0,
    }

    local obj = o or defaults

    for k, v in pairs(defaults) do if (obj[k] == nil and type(v) ~= "function") then obj[k] = v end end

    setmetatable(obj, self)
    self.__index = self

    return obj
end

function data:is_valid()
    _Log.debug("data:is_valid")
    return self.created ~= nil and self.created >= 0 and self.updated ~= nil and self.updated >= self.created
end

data.__index = data
return data