local Constants = require("libs.constants.constants")
local String_Utils = require("libs.utils.string-utils")

local settings_utils = {}

--[[ Sets order of the provided settings to match the order they appear in the provided array
    -> returns a table containing the ordered array, and a dictionary by name of the provided settings
]]
function settings_utils.order_settings(data)

    if (type(data) ~= "table") then return end
    if (type(data.settings) ~= "table") then return end

    local settings_array = {}
    local settings_dictionary  = {}

    local i = 1
    for k, v in pairs(data.settings) do
        if (type(v) == "table") then
            if (String_Utils.is_string_valid(k) and String_Utils.is_string_valid(v.name)) then
                settings_array[i] = v
                i = i + 1
            end
        end
    end

    for k, v in pairs(settings_array) do
        local order_1 = ((k - 1) % 26)
        local order_2 = math.floor((k - 1) / 26) % 26
        local order_3 = math.floor((k - 1) / 676) % 26

        local order = Constants.order_struct.order_array[order_3] .. Constants.order_struct.order_array[order_2] .. Constants.order_struct.order_array[order_1]
        v.order = order
        v.order_num = k

        settings_dictionary[v.name] = v
    end

    return
    {
        array = settings_array,
        dictionary = settings_dictionary
    }
end

return settings_utils