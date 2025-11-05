local Constants = require("libs.constants.constants")
local Log_Constants = require("libs.log.log-constants")
local Log_Constants_Functions = require("libs.log.log-constants-functions")

local is_string_valid = function (string_data)
    return string_data and type(string_data) == "string" and string_data:gsub("%s+", "") ~= ""
end

local log_settings = {}

function log_settings.create(params)
    if (type(params) ~= "table") then params = {} end
    if (not is_string_valid(params.prefix)) then params.prefix = Constants.mod_name_abbreviation end
    if (type(params.settings_array) ~= "table") then params.settings_array = {} end

    local settings =
    {
        {
            type = "string-setting",
            name = params.prefix .. "-" .. Log_Constants.settings.DEBUG_LEVEL.name,
            setting_type = "runtime-global",
            default_value = Log_Constants.settings.DEBUG_LEVEL.value,
            allowed_values = Log_Constants_Functions.levels.get_names()
        },
        {
            type = "bool-setting",
            name = params.prefix .. "-" .. Log_Constants.settings.DO_TRACEBACK.name,
            setting_type = "runtime-global",
            default_value = Log_Constants.settings.DO_TRACEBACK.default_value,
        },
        {
            type = "bool-setting",
            name = params.prefix .. "-" .. Log_Constants.settings.DO_NOT_PRINT.name,
            setting_type = "runtime-global",
            default_value = Log_Constants.settings.DO_NOT_PRINT.default_value,
        },
    }

    local settings_array_ordered = {}

    for k, v in pairs(settings) do table.insert(settings_array_ordered, v) end
    for k, v in pairs(params.settings_array) do table.insert(settings_array_ordered, v) end

    for k, v in ipairs(settings_array_ordered) do
        local order_1 = ((k - 1) % 26)
        local order_2 = math.floor((k - 1) / 26) % 26
        local order_3 = math.floor((k - 1) / 676) % 26

        local order =   Constants.order_struct.order_array[order_3]
                     .. Constants.order_struct.order_array[order_2]
                     .. Constants.order_struct.order_array[order_1]

        v.order = order
    end

    return settings
end

return log_settings
