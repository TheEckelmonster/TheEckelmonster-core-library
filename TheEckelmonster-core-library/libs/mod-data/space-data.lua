local Constants = require("libs.constants.constants")
local Data_Utils = require("libs.utils.data-utils")
local Startup_Settings_Constants = require("settings.startup.startup-settings-constants")
local String_Utils = require("libs.utils.string-utils")

-- MULTISURFACE_BASE_DISTANCE_MODIFIER
local get_multisurface_base_distance_modifier = function(params)
    local return_val = Data_Utils.get_startup_setting({ setting = Startup_Settings_Constants.settings.MULTISURFACE_BASE_DISTANCE_MODIFIER.name })

    if (params and type(params) ~= "table") then return return_val end

    if (params and type(params.default_value) == "number" and params.default_value > 0) then return_val = params.default_value end

    return return_val
end

local space_data = {}

function space_data.create(params)

    if (not params or type(params) ~= "table") then params = {} end
    if (params and not String_Utils.is_string_valid(params.name)) then params.name = Constants.mod_name_abbreviation .. ".space-data" end
    if (params and String_Utils.is_string_valid(params.data_type)) then params.data_type = nil end
    if (params and type(params.default_distance_modifier) ~= "number") then params.default_distance_modifier = get_multisurface_base_distance_modifier() end
    if (params and type(params.default_distance_modifier) == "number" and params.default_distance_modifier <= 0) then params.default_distance_modifier = get_multisurface_base_distance_modifier() end

    local mod_data = {
        type = "mod-data",
        name = params and params.name,
        data_type = params and params.data_type,
        data = {},
    }

    space_data.create_planet_data({ mod_data = mod_data })
    space_data.create_space_location_data({ mod_data = mod_data })
    space_data.create_connection_data({ mod_data = mod_data, default_distance_modifier = params.default_distance_modifier })

    return mod_data
end

function space_data.create_planet_data(params)

    if (not params or type(params) ~= "table") then return end
    if (not params.mod_data or type(params.mod_data) ~= "table") then return end

    if (data and data.raw and data.raw.planet and type(data.raw.planet) == "table") then
        for _, planet in pairs(data.raw.planet) do
            local planet_data = {
                type = "planet",
                name = nil,
                magnitude = 1,
                gravity_pull = 0,
                orientation = nil,
                star_distance = nil,
                x = 0,
                y = 0,
            }

            if (planet and type(planet) == "table") then
                planet_data.name = planet.name
                planet_data.magnitude = planet.magnitude
                planet_data.gravity_pull = planet.gravity_pull
                planet_data.orientation = planet.orientation
                planet_data.star_distance = planet.distance
                planet_data.x = planet.distance * math.sin((2 * math.pi) * planet.orientation)
                planet_data.y = planet.distance * math.cos((2 * math.pi) * planet.orientation)
            end

            if (planet and type(planet) == "table" and String_Utils.is_string_valid(planet.name)) then
                if (not params.mod_data.data) then params.mod_data.data = {} end
                if (not params.mod_data.data["planet"]) then params.mod_data.data["planet"] = {} end
                params.mod_data.data["planet"][planet.name] = planet_data
            end
        end
    end

    return params.mod_data
end

function space_data.create_space_location_data(params)

    if (not params or type(params) ~= "table") then return end
    if (not params.mod_data or type(params.mod_data) ~= "table") then return end

    if (data and data.raw and data.raw["space-location"] and type(data.raw["space-location"]) == "table") then
        for _, space_location in pairs(data.raw["space-location"]) do
            if (space_location.type == "planet") then goto continue end
            local space_location_data = {
                type = "space-location",
                name = nil,
                magnitude = 1,
                gravity_pull = 0,
                orientation = nil,
                star_distance = nil,
                x = 0,
                y = 0,
            }

            if (space_location and type(space_location) == "table") then
                space_location_data.name = space_location.name
                space_location_data.magnitude = space_location.magnitude
                space_location_data.gravity_pull = space_location.gravity_pull
                space_location_data.orientation = space_location.orientation
                space_location_data.star_distance = space_location.distance
                space_location_data.x = space_location.distance * math.sin((2 * math.pi) * space_location.orientation)
                space_location_data.y = space_location.distance * math.cos((2 * math.pi) * space_location.orientation)
            end

            if (space_location and type(space_location) == "table" and String_Utils.is_string_valid(space_location.name)) then
                if (not params.mod_data.data) then params.mod_data.data = {} end
                if (not params.mod_data.data["space-location"]) then params.mod_data.data["space-location"] = {} end
                params.mod_data.data["space-location"][space_location.name] = space_location_data
            end

            ::continue::
        end
    end

    return params.mod_data
end

function space_data.create_connection_data(params)

    if (not params or type(params) ~= "table") then return end
    if (not params.mod_data or type(params.mod_data) ~= "table") then return end

    if (data and data.raw and data.raw["space-connection"] and type(data.raw["space-connection"]) == "table") then
        for connection_id, space_connection in pairs(data.raw["space-connection"]) do
            local from = params.mod_data.data.planet[space_connection.from] or params.mod_data.data["space-location"][space_connection.from]
            local to = params.mod_data.data.planet[space_connection.to] or params.mod_data.data["space-location"][space_connection.to]

            local distance = ((from.x - to.x) ^ 2 + (from.y - to.y) ^ 2) ^ 0.5

            --[[ planet ]]
            if (params.mod_data.data.planet[space_connection.from]) then
                if (not params.mod_data.data.planet[space_connection.from]["space-connection"]) then params.mod_data.data.planet[space_connection.from]["space-connection"] = {} end
                if (not params.mod_data.data.planet[space_connection.from]["space-connection"][space_connection.to]) then params.mod_data.data.planet[space_connection.from]["space-connection"][space_connection.to] = {} end

                params.mod_data.data.planet[space_connection.from]["space-connection"][space_connection.to].type = "space-connection"
                params.mod_data.data.planet[space_connection.from]["space-connection"][space_connection.to].length = space_connection.length
                params.mod_data.data.planet[space_connection.from]["space-connection"][space_connection.to].forward = space_connection.from .. "-" .. space_connection.to
                params.mod_data.data.planet[space_connection.from]["space-connection"][space_connection.to].reverse = space_connection.to .. "-" .. space_connection.from
                params.mod_data.data.planet[space_connection.from]["space-connection"][space_connection.to].reversed = false
                params.mod_data.data.planet[space_connection.from]["space-connection"][space_connection.to].distance = distance * params.default_distance_modifier
            end

            if (params.mod_data.data.planet[space_connection.to]) then
                if (not params.mod_data.data.planet[space_connection.to]["space-connection"]) then params.mod_data.data.planet[space_connection.to]["space-connection"] = {} end
                if (not params.mod_data.data.planet[space_connection.to]["space-connection"][space_connection.from]) then params.mod_data.data.planet[space_connection.to]["space-connection"][space_connection.from] = {} end

                params.mod_data.data.planet[space_connection.to]["space-connection"][space_connection.from].type = "space-connection"
                params.mod_data.data.planet[space_connection.to]["space-connection"][space_connection.from].length = space_connection.length
                params.mod_data.data.planet[space_connection.to]["space-connection"][space_connection.from].forward = space_connection.to .. "-" .. space_connection.from
                params.mod_data.data.planet[space_connection.to]["space-connection"][space_connection.from].reverse = space_connection.from .. "-" .. space_connection.to
                params.mod_data.data.planet[space_connection.to]["space-connection"][space_connection.from].reversed = true
                params.mod_data.data.planet[space_connection.to]["space-connection"][space_connection.from].distance = distance * params.default_distance_modifier
            end

            --[[ space-location ]]
            if (params.mod_data.data["space-location"][space_connection.from]) then
                if (not params.mod_data.data["space-location"][space_connection.from]["space-connection"]) then params.mod_data.data["space-location"][space_connection.from]["space-connection"] = {} end
                if (not params.mod_data.data["space-location"][space_connection.from]["space-connection"][space_connection.to]) then params.mod_data.data["space-location"][space_connection.from]["space-connection"][space_connection.to] = {} end

                params.mod_data.data["space-location"][space_connection.from]["space-connection"][space_connection.to].type = "space-connection"
                params.mod_data.data["space-location"][space_connection.from]["space-connection"][space_connection.to].length = space_connection.length
                params.mod_data.data["space-location"][space_connection.from]["space-connection"][space_connection.to].forward = space_connection.from .. "-" .. space_connection.to
                params.mod_data.data["space-location"][space_connection.from]["space-connection"][space_connection.to].reverse = space_connection.to .. "-" .. space_connection.from
                params.mod_data.data["space-location"][space_connection.from]["space-connection"][space_connection.to].reversed = false
                params.mod_data.data["space-location"][space_connection.from]["space-connection"][space_connection.to].distance = distance * params.default_distance_modifier
            end

            if (params.mod_data.data["space-location"][space_connection.to]) then
                if (not params.mod_data.data["space-location"][space_connection.to]["space-connection"]) then params.mod_data.data["space-location"][space_connection.to]["space-connection"] = {} end
                if (not params.mod_data.data["space-location"][space_connection.to]["space-connection"][space_connection.from]) then params.mod_data.data["space-location"][space_connection.to]["space-connection"][space_connection.from] = {} end

                params.mod_data.data["space-location"][space_connection.to]["space-connection"][space_connection.from].type = "space-connection"
                params.mod_data.data["space-location"][space_connection.to]["space-connection"][space_connection.from].length = space_connection.length
                params.mod_data.data["space-location"][space_connection.to]["space-connection"][space_connection.from].forward = space_connection.to .. "-" .. space_connection.from
                params.mod_data.data["space-location"][space_connection.to]["space-connection"][space_connection.from].reverse = space_connection.from .. "-" .. space_connection.to
                params.mod_data.data["space-location"][space_connection.to]["space-connection"][space_connection.from].reversed = true
                params.mod_data.data["space-location"][space_connection.to]["space-connection"][space_connection.from].distance = distance * params.default_distance_modifier
            end

            if (not params.mod_data.data) then params.mod_data.data = {} end
            if (not params.mod_data.data["space-connection"]) then params.mod_data.data["space-connection"] = {} end
            if (not params.mod_data.data["space-connection"][connection_id]) then
                params.mod_data.data["space-connection"][connection_id] = {
                    type = "space-connection",
                    from = space_connection.from,
                    to = space_connection.to,
                    reversed = false,
                    length = space_connection.length,
                    distance = space_connection.distance
                }
                params.mod_data.data["space-connection"][space_connection.to .. "-" .. space_connection.from] = {
                    type = "space-connection",
                    from = space_connection.to,
                    to = space_connection.from,
                    reversed = true,
                    length = space_connection.length,
                    distance = space_connection.distance,
                }
            end
        end
    end

    return params.mod_data
end

return space_data