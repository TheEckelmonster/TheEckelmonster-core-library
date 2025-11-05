local Log_Stub = require("libs.log.log-stub")
local _Log = Log
if (not script or not _Log or mods) then _Log = Log_Stub end

local settings_service = {}

local _Storage_Ref = {}

local locals = {}

function settings_service.init(data)
    if (type(data) ~= "table") then return end
    if (type(data.storage_ref) ~= "table") then return end

    _Storage_Ref = data.storage_ref

    settings_service.valid = true

    return 1
end

function settings_service.get_runtime_global_setting(data)
    if (not settings_service.valid) then return end
    _Log.debug("settings_service.get_runtime_global_setting")
    _Log.info(data)

    if (not data or type(data) ~= "table") then return end
    if (not data.setting or type(data.setting) ~= "string") then return end

    if (not _Storage_Ref.settings or type(_Storage_Ref.settings) ~= "table") then _Storage_Ref.settings = {} end
    if (not _Storage_Ref.settings["runtime-global"] or type(_Storage_Ref.settings["runtime-global"]) ~= "table") then _Storage_Ref.settings["runtime-global"] = {} end

    local setting = _Storage_Ref.settings["runtime-global"][data.setting]

    if (setting == nil or data.reindex) then
        setting = locals.get_runtime_global_setting(data)
    end

    _Storage_Ref.settings["runtime-global"][data.setting] = setting

    return setting
end

function settings_service.get_startup_setting(data)
    if (not settings_service.valid) then return end
    _Log.debug("settings_service.get_startup_setting")
    _Log.info(data)

    if (not data or type(data) ~= "table") then return end
    if (not data.setting or type(data.setting) ~= "string") then return end

    if (not _Storage_Ref.settings or type(_Storage_Ref.settings) ~= "table") then _Storage_Ref.settings = {} end
    if (not _Storage_Ref.settings["startup"] or type(_Storage_Ref.settings["startup"]) ~= "table") then _Storage_Ref.settings["startup"] = {} end

    local setting = _Storage_Ref.settings["startup"][data.setting]

    if (setting == nil or data.reindex) then
        setting = locals.get_startup_setting(data)
    end

    _Storage_Ref.settings["startup"][data.setting] = setting

    return setting
end

 function locals.get_runtime_global_setting(data)
    _Log.debug("locals.get_runtime_global_setting")
    _Log.info(data)

    if (not data or type(data) ~= "table") then return end
    if (not data.setting or type(data.setting) ~= "string") then return end

    local setting = nil

    if (settings and settings.global and settings.global[data.setting]) then
        setting = settings.global[data.setting].value
    end

    return setting
end

-- function locals.get_runtime_user_setting(data)
--     _Log.debug("get_runtime_user_setting")
--     _Log.info(data)

--     if (not data or type(data) ~= "table") then return end
--     if (not data.setting or type(data.setting) ~= "string") then return end
--     if (data.player_id ~= nil) then return end

--     local setting = Runtime_User_Settings_Constants.settings_dictionary[data.setting] and Runtime_User_Settings_Constants.settings_dictionary[data.setting].default_value

--     -- if (settings and settings.global and settings.global[data.setting]) then
--     if (settings.get_player_settings(data.player_id)[data.setting]) then
--         setting = settings.global[data.setting].value
--     end

--     return setting
-- end

function locals.get_startup_setting(data)
    _Log.debug("locals.get_startup_setting")
    _Log.info(data)

    if (not data or type(data) ~= "table") then return end
    if (not data.setting or type(data.setting) ~= "string") then return end

    local setting = nil

    if (settings and settings.startup and settings.startup[data.setting]) then
        setting = settings.startup[data.setting].value
    end

    return setting
end

return settings_service