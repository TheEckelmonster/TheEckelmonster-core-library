local Constants = require("libs.constants.constants")
local String_Utils = require("libs.utils.string-utils")

local mod_data = {}

function mod_data.create(params)
    if (not params or type(params) ~= "table") then params = {} end
    if (params and not String_Utils.is_string_valid(params.name)) then params.name = Constants.mod_name_abbreviation .. ".mod-data" end
    if (params and String_Utils.is_string_valid(params.data_type)) then params.data_type = nil end

    local mod_data = {
        type = "mod-data",
        name = params and params.name,
        data_type = params and params.data_type,
        data = {},
    }

    return mod_data
end

return mod_data