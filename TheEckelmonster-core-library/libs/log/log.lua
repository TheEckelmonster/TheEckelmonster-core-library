local Log_Constants = require("libs.log.log-constants")
local Log_Constants_Functions = require("libs.log.log-constants-functions")

local _Storage_Ref = nil
local _Traceback_Setting_Name = nil
local _Do_Not_Print_Setting_Name = nil

local Log = {}

local locals = {}

function locals.is_string_valid(string_data)
    return string_data and type(string_data) == "string" and string_data:gsub("%s+", "") ~= ""
end

function Log.init(data)
    if (type(data) ~= "table") then return end
    if (type(data.debug_level_name) ~= "string") then return end
    if (type(data.traceback_setting_name) ~= "string") then return end
    if (type(data.do_not_print_setting_name) ~= "string") then return end
    if (type(data.storage_ref) ~= "table") then return end

    _Storage_Ref = data.storage_ref
    _Debug_Level_Name = data.debug_level_name
    _Traceback_Setting_Name = data.traceback_setting_name
    _Do_Not_Print_Setting_Name = data.do_not_print_setting_name

    Log.valid = true
    return 1
end

-- Pretty much purely a convenience method
-- -> Allows printing directly to the game via logging
function Log.none(message, traceback)
    if (not Log.valid or not locals.is_game_loaded()) then return end
    locals.log_message(message, Log_Constants.levels[Log_Constants.NONE.num_val], traceback)
end

function Log.info(message, traceback)
    if (not Log.valid or not locals.is_game_loaded()) then return end
    locals.log_message(message, Log_Constants.levels[Log_Constants.INFO.num_val], traceback)
end

function Log.debug(message, traceback)
    if (not Log.valid or not locals.is_game_loaded()) then return end
    locals.log_message(message, Log_Constants.levels[Log_Constants.DEBUG.num_val], traceback)
end

function Log.warn(message, traceback)
    if (not Log.valid or not locals.is_game_loaded()) then return end
    locals.log_message(message, Log_Constants.levels[Log_Constants.WARN.num_val], traceback)
end

function Log.error(message, traceback)
    if (not Log.valid or not locals.is_game_loaded()) then return end
    locals.log_message(message, Log_Constants.levels[Log_Constants.ERROR.num_val], traceback)
end

function Log.get_log_level()
    if (not Log.valid or not Log._ready) then return end

    local _log_level = Log_Constants.levels[Log_Constants.NONE.num_val]
    local log_level = {
        level = Log_Constants.levels[Log_Constants.NONE.num_val],
        valid = false
    }

    if (not _Storage_Ref) then return log_level end

    _log_level = locals.get_runtime_global_setting({ setting = _Debug_Level_Name })

    if (log_level and _log_level == Log_Constants.NONE.string_val) then
        log_level = Log_Constants.levels[Log_Constants.NONE.num_val]
    elseif (log_level and _log_level == Log_Constants.ERROR.string_val) then
        log_level = Log_Constants.levels[Log_Constants.ERROR.num_val]
    elseif (log_level and _log_level == Log_Constants.WARN.string_val) then
        log_level = Log_Constants.levels[Log_Constants.WARN.num_val]
    elseif (log_level and _log_level == Log_Constants.DEBUG.string_val) then
        log_level = Log_Constants.levels[Log_Constants.DEBUG.num_val]
    elseif (log_level and _log_level == Log_Constants.INFO.string_val) then
        log_level = Log_Constants.levels[Log_Constants.INFO.num_val]
    else
        log_level = Log_Constants.levels[Log_Constants.NONE.num_val]
    end

    if (not _Storage_Ref and log_level) then
        _Storage_Ref.log = {
            level = log_level,
            valid = true
        }
    elseif (_Storage_Ref and log_level) then
        _Storage_Ref.log = {
            level = log_level,
            valid = true
        }
    else
        log("Didn't find log level from settings")
        if (game) then
            game.print("Didn't find log level from settings")
        end
        _Storage_Ref.log = {
            level = Log_Constants.levels[Log_Constants.NONE.num_val],
            valid = false
        }
    end

    return log_level
end

function Log.set_log_level(new_log_obj)
    if (not Log.valid or not Log._ready) then return end

    local function default_return_val()
        -- log("Setting storage.log_level to NONE and invalid")
        if (type(_Storage_Ref) == "table") then
            _Storage_Ref.log = {
                level = Log_Constants.levels[Log_Constants.NONE.num_val],
                valid = false
            }
        end
    end

    if (not new_log_obj or not _Storage_Ref) then return default_return_val() end

    if (    new_log_obj
        and new_log_obj.num_val < 0
    ) then
        return default_return_val()
    end

    if (    new_log_obj
        and new_log_obj.num_val >= 0
    ) then
        _Storage_Ref.log = {
            level = new_log_obj,
            valid = true
        }
        return
    end

    if (not type(new_log_obj) == "number" and not type(new_log_obj) == "string" and not new_log_obj.valid) then
        return default_return_val()
    end

    if (type(new_log_obj) == "number" and new_log_obj >= 0) then
        _Storage_Ref.log = {
            level = Log_Constants_Functions.levels.get_level_by_value({ num_val = new_log_obj }),
            valid = true
        }
        return
    end

    if (type(new_log_obj) == "string") then
        _Storage_Ref.log = {
            level = Log_Constants_Functions.levels.get_level_by_name({ string_val = new_log_obj }),
            valid = true
        }
        return
    end

    local _new_log_level = Log_Constants_Functions.levels.get_level_by_name(new_log_obj)
    if (_Storage_Ref.log) then
        _Storage_Ref.log = {
            level = _new_log_level,
            valid = true
        }
        return
    end

    -- If made it this far, something went wrong
    -- -> return the default value
    log("Returning default log value")
    return default_return_val()
end

function Log.ready()
    Log._ready = true
end

function Log.is_ready()
    return Log._ready
end

function locals.log_message(message, log_level, traceback)
    -- Do nothing if the game is not loaded yet
    if (not locals.is_game_loaded()) then return end

    log_level = log_level or Log_Constants.levels[Log_Constants.NONE.num_val]

    local _log_level = Log.get_log_level()
    if (not _log_level or not _log_level.valid) then
        locals.log_print_message("Log level was invalid", { log_level = Log_Constants.levels[Log_Constants.NONE.num_val], valid = true })
        return
    end

    if (    log_level
        and log_level.valid
        and _log_level
        and _log_level.valid
        and log_level.num_val >= _log_level.num_val
    ) then
        locals.log_print_message(message, log_level, traceback)
    end
end

function locals.log_print_message(message, log_obj, traceback)
    -- Do nothing if the game is not loaded yet
    if (not locals.is_game_loaded()) then return end

    traceback = traceback or false

    -- Validate provided log_obj
    if (not log_obj or not log_obj.valid) then
        -- Something's really wrong if this is happening
        if (game) then
            game.print("log_obj is nil or log_obj is not valid")
        end
        return
    end

    if (not _Storage_Ref or not _Storage_Ref.log) then
        if (game) then
            game.print("log_obj is nil or log_obj is not valid")
        end
        if (_Storage_Ref) then
            log(serpent.block(_Storage_Ref))
            log("log_obj is nil or log_obj is not valid")
            _Storage_Ref.log = Log_Constants.levels[Log_Constants.NONE.num_val]
        end
    end

    if (    log_obj.valid
        and _Storage_Ref
        and _Storage_Ref.log
        and _Storage_Ref.log.level
        and not _Storage_Ref.log.level.valid
    ) then
        if (game) then
            game.print("log_obj ~= storage.log_obj")
        end
        Log.set_log_level(log_obj)
    end

    -- Get the traceback setting
    if (not traceback) then
        traceback = locals.get_runtime_global_setting({ setting = _Traceback_Setting_Name }) or false
    end

    if (traceback) then
        log(debug.traceback())
        message = "(traced) " .. serpent.block(message)
    end

    local do_prefix = log_obj.num_val < Log_Constants.levels[Log_Constants.NONE.num_val].num_val
    log(log_obj.string_val .. ": " .. serpent.block(message))

    local do_not_print = true
    do_not_print = locals.get_runtime_global_setting({ setting = _Do_Not_Print_Setting_Name })
    if (do_not_print == nil) then do_not_print = true end

    if (game and not do_not_print) then
        game.print(
            locals.do_print_prefix(log_obj.string_val, do_prefix)
            .. serpent.block(message))
    end

end

 function locals.get_runtime_global_setting(data)

    if (not data or type(data) ~= "table") then return end
    if (not data.setting or type(data.setting) ~= "string") then return end

    local setting = nil

    if (settings and settings.global and settings.global[data.setting]) then
        setting = settings.global[data.setting].value
    end

    return setting
end

function locals.get_startup_setting(data)

    if (not data or type(data) ~= "table") then return end
    if (not data.setting or type(data.setting) ~= "string") then return end

    local setting = nil

    if (settings and settings.startup and settings.startup[data.setting]) then
        setting = settings.startup[data.setting].value
    end

    return setting
end

function locals.do_print_prefix(prefix, do_prefix)
    if (do_prefix) then return prefix .. ": " else return Log_Constants.constants.EMPTY_STRING end
end

function locals.is_game_loaded() return game and Log._ready end

return Log
