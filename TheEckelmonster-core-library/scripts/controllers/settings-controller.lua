local Log_Stub = require("libs.log.log-stub")
local _Log = Log
if (not _Log) then _Log = Log_Stub end

local _Settings_Service = nil

local settings_controller = {}
settings_controller.name = "settings_controller"

function settings_controller.init(data)
    if (type(data) ~= "table") then return end
    if (type(data.settings_service) ~= "table" or not data.settings_service.valid) then return end

    _Settings_Service = data.settings_service

    settings_controller.register_on_runtime_mod_setting_changed()

    settings_controller.valid = true
    return 1
end

function settings_controller.on_runtime_mod_setting_changed(event)
    if (not settings_controller.valid) then return end
    _Log.debug("settings_controller.on_runtime_mod_setting_changed")
    _Log.info(event)

    if (not settings_controller.valid) then return end
    if (type(_Settings_Service) ~= "table") then return end

    if (not event.setting or type(event.setting) ~= "string") then return end
    if (not event.setting_type or type(event.setting_type) ~= "string") then return end

    if (not (event.setting:find(Constants.mod_name, 1, true) == 1)) then return end

    if (event.setting_type == "runtime-global") then
        _Settings_Service.get_runtime_global_setting({  reindex = true, setting = event.setting })
    elseif (event.setting_type == "runtime-user") then
    elseif (event.setting_type == "startup") then
        _Settings_Service.get_startup_setting({  reindex = true, setting = event.setting })
    end
end

function settings_controller.register_on_runtime_mod_setting_changed(data)
    Event_Handler:register_event({
        event_name = "on_runtime_mod_setting_changed",
        source_name = "settings_controller.on_runtime_mod_setting_changed",
        func_name = "settings_controller.on_runtime_mod_setting_changed",
        func = settings_controller.on_runtime_mod_setting_changed,
    })
end

function settings_controller.unregister_on_runtime_mod_setting_changed(data)
    Event_Handler:register_event({
        event_name = "on_runtime_mod_setting_changed",
        source_name = "settings_controller.on_runtime_mod_setting_changed",
    })
end

return settings_controller