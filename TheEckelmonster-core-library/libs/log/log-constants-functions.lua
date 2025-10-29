local Log_Constants = require("libs.log.log-constants")

local log_constants_functions = {}

log_constants_functions.levels = {}

log_constants_functions.levels.get_names = function(reindex)
    reindex = reindex or false

    if (    not reindex
        and log_constants_functions
        and log_constants_functions.levels
        and log_constants_functions.levels.list
    ) then
        return log_constants_functions.levels.list
    end

    local list = {}

    local levels = Log_Constants.levels

    for i, log_level in pairs(levels) do
        list[1 + #levels - log_level.num_val] = log_level.string_val
    end

    log_constants_functions.levels.list = list

    return list
end

log_constants_functions.levels.to_value = function(level)
    if (not level) then return Log_Constants.levels[Log_Constants.NONE.num_val].string_val end

    if (level.string_val == Log_Constants.levels[Log_Constants.INFO.num_val].string_val) then
        return Log_Constants.levels[Log_Constants.INFO.num_val].value
    end
    if (level.string_val == Log_Constants.levels[Log_Constants.DEBUG.num_val].string_val) then
        return Log_Constants.levels[Log_Constants.DEBUG.num_val].value
    end
    if (level.string_val == Log_Constants.levels[Log_Constants.WARN.num_val].string_val) then
        return Log_Constants.levels[Log_Constants.WARN.num_val].value
    end
    if (level.string_val == Log_Constants.levels[Log_Constants.ERROR.num_val].string_val) then
        return Log_Constants.levels[Log_Constants.ERROR.num_val].value
    end
    if (level.string_val == Log_Constants.levels[Log_Constants.NONE.num_val].string_val) then
        return Log_Constants.levels[Log_Constants.NONE.num_val].value
    end

    return Log_Constants.levels[Log_Constants.NONE.num_val].string_val
end

log_constants_functions.levels.to_name = function(level)
    if (not level) then return Log_Constants.levels[Log_Constants.NONE.num_val].string_val end

    if (level.num_val == Log_Constants.levels[Log_Constants.INFO.num_val].num_val) then
        return Log_Constants.levels[Log_Constants.INFO.num_val].string_val
    end
    if (level.num_val == Log_Constants.levels[Log_Constants.DEBUG.num_val].num_val) then
        return Log_Constants.levels[Log_Constants.DEBUG.num_val].string_val
    end
    if (level.num_val == Log_Constants.levels[Log_Constants.WARN.num_val].num_val) then
        return Log_Constants.levels[Log_Constants.WARN.num_val].string_val
    end
    if (level.num_val == Log_Constants.levels[Log_Constants.ERROR.num_val].num_val) then
        return Log_Constants.levels[Log_Constants.ERROR.num_val].string_val
    end
    -- Return an empty string for NONE, because... well... its name is "none"
    -- ->  Really a convenience for printing directly at the game level via logging
    if (level.num_val == Log_Constants.levels[Log_Constants.NONE.num_val].num_val) then
        return Log_Constants.constants.EMPTY_STRING
    end

    return Log_Constants.levels[Log_Constants.NONE.num_val].string_val
end

log_constants_functions.levels.get_level_by_value = function(level)
    if (not level) then return Log_Constants.levels[Log_Constants.NONE.num_val] end

    if (level.num_val == Log_Constants.levels[Log_Constants.INFO.num_val].num_val) then
        return Log_Constants.levels[Log_Constants.INFO.num_val]
    end
    if (level.num_val == Log_Constants.levels[Log_Constants.DEBUG.num_val].num_val) then
        return Log_Constants.levels[Log_Constants.DEBUG.num_val]
    end
    if (level.num_val == Log_Constants.levels[Log_Constants.WARN.num_val].num_val) then
        return Log_Constants.levels[Log_Constants.WARN.num_val]
    end
    if (level.num_val == Log_Constants.levels[Log_Constants.ERROR.num_val].num_val) then
        return Log_Constants.levels[Log_Constants.ERROR.num_val]
    end
    if (level.num_val == Log_Constants.levels[Log_Constants.NONE.num_val].num_val) then
        return Log_Constants.levels[Log_Constants.NONE.num_val]
    end

    return Log_Constants.levels[Log_Constants.NONE.num_val]
end

log_constants_functions.levels.get_level_by_name = function(level)
    if (not level) then return Log_Constants.levels[Log_Constants.NONE.num_val] end

    if (level.string_val == Log_Constants.levels[Log_Constants.INFO.num_val].string_val) then
        return Log_Constants.levels[Log_Constants.INFO.num_val]
    end
    if (level.string_val == Log_Constants.levels[Log_Constants.DEBUG.num_val].string_val) then
        return Log_Constants.levels[Log_Constants.DEBUG.num_val]
    end
    if (level.string_val == Log_Constants.levels[Log_Constants.WARN.num_val].string_val) then
        return Log_Constants.levels[Log_Constants.WARN.num_val]
    end
    if (level.string_val == Log_Constants.levels[Log_Constants.ERROR.num_val].string_val) then
        return Log_Constants.levels[Log_Constants.ERROR.num_val]
    end
    if (level.string_val == Log_Constants.levels[Log_Constants.NONE.num_val].string_val) then
        return Log_Constants.levels[Log_Constants.NONE.num_val]
    end

    return Log_Constants.levels[Log_Constants.NONE.num_val]
end

return log_constants_functions