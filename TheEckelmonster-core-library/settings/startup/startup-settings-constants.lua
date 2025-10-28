local Constants = require("libs.constants.constants")

local k2so_active = mods and mods["Krastorio2-spaced-out"] and true or scripts and scripts.active_mods and scripts.active_mods["Krastorio2-spaced-out"]
local saa_s_active = mods and mods["SimpleAtomicArtillery-S"] and true or scripts and scripts.active_mods and scripts.active_mods["SimpleAtomicArtillery-S"]
local sa_active = mods and mods["space-age"] and true or scripts and scripts.active_mods and scripts.active_mods["space-age"]
local se_active = mods and mods["space-exploration"] and true or scripts and scripts.active_mods and scripts.active_mods["space-exploration"]

local startup_settings_constants = {}

local prefix = Constants.mod_name_abbreviation

startup_settings_constants.settings = {
    MULTISURFACE_BASE_DISTANCE_MODIFIER = {
        type = "int-setting",
        name = prefix .. "multisurface-base-distance-modifier",
        setting_type = "startup",
        order = "",
        default_value = 3000,
        maximum_value = 2 ^ 32,
        minimum_value = 1,
    },
}

local settings_array = {}
local i = 1
for k, v in pairs(startup_settings_constants.settings) do
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

if (sa_active) then
    local sa_crafting_categories =
    {
        "captive-spawner-process",
        "chemistry-or-cryogenics",
        "cryogenics",
        "cryogenics-or-assembling",
        "crafting-with-fluid-or-metallurgy",
        "crushing",
        "electronics-or-assembling",
        "electromagnetics",
        "electronics",
        "electronics-with-fluid",
        "metallurgy",
        "metallurgy-or-assembling",
        "organic",
        "organic-or-assembling",
        "organic-or-chemistry",
        "organic-or-hand-crafting",
        "pressing",
    }

    for k, v in pairs(sa_crafting_categories) do
        -- table.insert(startup_settings_constants.settings.ATOMIC_BOMB_CRAFTING_MACHINE.allowed_values, v)
    end
end

if (se_active) then
    local se_crafting_categories =
    {
        "arcosphere",
        -- "condenser-turbine",
        -- "big-turbine",
        "casting",
        "kiln",
        -- "delivery-cannon",
        -- "delivery-cannon-weapon",
        -- "fixed-recipe", -- generic group for anything with a fixed recipe, not chosen by player
        "fuel-refining",
        "core-fragment-processing",
        "lifesupport", -- same as "space-lifesupport" but can be on land
        "melting",
        "nexus",
        "pulverising",
        "crafting-or-electromagnetics",
        -- "hard-recycling", -- no conflict with "recycling"
        -- "hand-hard-recycling", -- no conflict with "recycling"
        "se-electric-boiling", -- needs to be SE specific otherwise energy values will be off
        "space-accelerator",
        "space-astrometrics",
        "space-biochemical",
        "space-collider",
        "space-crafting", -- same as basic assembling but only in space
        "space-decontamination",
        "space-electromagnetics",
        "space-elevator",
        "space-materialisation",
        "space-genetics",
        "space-gravimetrics",
        "space-growth",
        "space-hypercooling",
        "space-laser",
        "space-lifesupport", -- same as "lifesupport" but can only be in space
        "space-manufacturing",
        "space-mechanical",
        "space-observation-gammaray",
        "space-observation-xray",
        "space-observation-uv",
        "space-observation-visible",
        "space-observation-infrared",
        "space-observation-microwave",
        "space-observation-radio",
        "space-plasma",
        "space-radiation",
        "space-radiator",
        -- "space-hard-recycling", -- no conflict with "recycling"
        "space-research",
        "space-spectrometry",
        "space-supercomputing-1",
        "space-supercomputing-2",
        "space-supercomputing-3",
        "space-supercomputing-4",
        "space-thermodynamics",
        -- "spaceship-console",
        -- "spaceship-antimatter-engine",
        -- "spaceship-ion-engine",
        -- "spaceship-rocket-engine",
        -- "pressure-washing",
        -- "dummy",
        -- "no-category"
    }

    for k, v in pairs(se_crafting_categories) do
        -- table.insert(startup_settings_constants.settings.ATOMIC_BOMB_CRAFTING_MACHINE.allowed_values, v)
    end
end

startup_settings_constants.settings_dictionary  = {}

for k, v in pairs(startup_settings_constants.settings) do
    startup_settings_constants.settings_dictionary[v.name] = v
end

return startup_settings_constants