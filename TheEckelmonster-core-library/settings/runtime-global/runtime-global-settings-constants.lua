local Constants = require("libs.constants.constants")

local k2so_active = mods and mods["Krastorio2-spaced-out"] and true or scripts and scripts.active_mods and scripts.active_mods["Krastorio2-spaced-out"]
local saa_s_active = mods and mods["SimpleAtomicArtillery-S"] and true or scripts and scripts.active_mods and scripts.active_mods["SimpleAtomicArtillery-S"]
local sa_active = mods and mods["space-age"] and true or scripts and scripts.active_mods and scripts.active_mods["space-age"]
local se_active = mods and mods["space-exploration"] and true or scripts and scripts.active_mods and scripts.active_mods["space-exploration"]

local runtime_global_settings_constants = {}

local prefix = Constants.mod_name_abbreviation

runtime_global_settings_constants.settings = {
    -- MULTISURFACE_BASE_DISTANCE_MODIFIER = {
    --     type = "int-setting",
    --     name = prefix .. "multisurface-base-distance-modifier",
    --     setting_type = "runtime_global",
    --     order = "",
    --     default_value = 3000,
    --     maximum_value = 2 ^ 32,
    --     minimum_value = 1,
    -- },
}

local settings_array = {}
local i = 1
for k, v in pairs(runtime_global_settings_constants.settings) do
    settings_array[i] = v
    i = i + 1
end

for k, v in pairs(settings_array) do
    local order_1 = ((k - 1) % 26)
    local order_2 = math.floor((k - 1) / 26) % 26
    local order_3 = math.floor((k - 1) / 676) % 26

    local order = Constants.order_struct.order_array[order_3] .. Constants.order_struct.order_array[order_2] .. Constants.order_struct.order_array[order_1]
    v.order = order
    v.order_num = k
end

runtime_global_settings_constants.settings_dictionary  = {}
runtime_global_settings_constants.settings_array = {}

local i = 1
for k, v in pairs(runtime_global_settings_constants.settings) do
    table.insert(runtime_global_settings_constants.settings_array, v)
    runtime_global_settings_constants.settings_dictionary[v.name] = v
    v.order_num = i
    i = i + 1
end

return runtime_global_settings_constants