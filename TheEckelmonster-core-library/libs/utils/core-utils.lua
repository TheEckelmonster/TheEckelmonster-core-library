local Log_Stub = require("libs.log.log-stub")
local _Log = Log
if (not script or not _Log or mods) then _Log = Log_Stub end

local depth = function ()
    local self = { depth = 0 }
    local get = function () return self.depth end
    local increment = function () self.depth = self.depth + 1 end
    local decrement = function () self.depth = self.depth - 1 end
    local reset = function () self.depth = 0 end

    return {
        get = get,
        increment = increment,
        decrement = decrement,
        reset = reset,
    }
end

local traversal = {
    calls = 0,
    file = {
        default_prefix = "TheEckelmonster-core-library",
        postfix = ".json",
    },
    depth = depth(),
    SPACING = "    ",
}

function traversal.set_prefix(data)
    _Log.debug("traversal.set_prefix")
    _Log.info(data)

    if (not data or type(data) ~= "table") then return end
    if (not data.prefix or type(data.prefix) ~= "string") then return end

    traversal.file.prefix = data.prefix
end

function traversal.traverse_find(t_name, data, found_data, path, optionals)
    _Log.debug("traversal.traverse_find")
    _Log.info(t_name)
    _Log.info(data)
    _Log.info(found_data)
    _Log.info(path)
    _Log.info(optionals)

    if (t_name == nil or type(t_name) ~= "string" or #(string.gsub(t_name, " ", "")) <= 0) then return end
    if (data == nil or type(data) ~= "table") then data = storage end
    if (found_data == nil or type(found_data) ~= "table") then found_data = {} end
    if (path == nil or type(path) ~= "string") then path = "storage" end

    traversal.calls = 0
    local depth = depth()

    local function do_traverse(t_name, data, found_data, path, optionals)
        if (traversal.calls > 2 ^ 16) then return end

        traversal.calls = traversal.calls + 1
        depth.increment()

        local t_return = { data = nil, name = path, return_val = 0, depth = 2 ^ 8 - 1 }

        local function should_return(_t_return, optionals)

            if (type(_t_return) == "table") then
                if (_t_return.do_return) then
                    depth.reset()
                    return _t_return
                elseif (_t_return.return_val and t_return.return_val and _t_return.return_val > t_return.return_val) then
                    t_return = _t_return
                    return false
                elseif (not t_return.return_val) then
                    t_return = _t_return
                    return false
                end
            end
            return false
        end

        if (not found_data[data] or found_data[data] and found_data[data].depth > depth.get()) then
            if (not found_data[data]) then found_data[data] = {} end
            found_data[data].depth = depth.get()

            for k, v in pairs(data) do
                if (type(v) == "table") then
                    if (optionals.parsed_name) then
                        if (path .. "." .. tostring(k)):find(t_name, 1, true) then
                            depth.reset()
                            return { data = v, name = path .. "." .. tostring(k), do_return = true }
                        end
                        if (  (optionals.parsed_name.step.t[tostring(k)] and depth.get() == optionals.parsed_name.step.a[optionals.parsed_name.step.t[tostring(k)]])
                            or optionals.parsed_name.t[path .. "." .. tostring(k)]
                            or optionals.parsed_name.reversed.t[path .. "." .. tostring(k)]) then

                            local _t_return = do_traverse(t_name, v, found_data, path .. "." .. tostring(k), optionals)
                            if (should_return(_t_return, optionals)) then return should_return(_t_return, optionals) end

                            return { data = v, name = path .. "." .. tostring(k), return_val = optionals.parsed_name.reversed.t[k], depth = depth.get() }
                        end
                    end
                    if (tostring(k) == t_name or path .. "." .. tostring(k) == t_name) then depth.reset(); return { data = v, name = path .. "." .. tostring(k) , do_return = true, depth = depth.get() } end
                    local _t_return = do_traverse(t_name, v, found_data, path .. "." .. tostring(k), optionals)
                    if (should_return(_t_return, optionals)) then return should_return(_t_return, optionals) end
                end
            end
        end

        depth.decrement()
        return t_return
    end
    return do_traverse(t_name, data, found_data, path, optionals)
end

function traversal.traverse_print(data, file_name, found_data, optionals)
    _Log.debug("traversal.traverse_print")
    _Log.info(data)
    _Log.info(file_name)
    _Log.info(found_data)
    _Log.info(optionals)

    if (data == nil or type(data) ~= "table") then return -1 end
    if (file_name == nil or type(file_name) ~= "string") then return -1 end
    if (found_data == nil or type(found_data) ~= "table") then found_data = {} end

    optionals = type(optionals) == "table" and optionals or { max_depth = 4 }

    traversal.calls = 0
    local depth = depth()
    if (traversal.file.prefix) then
        if (type(traversal.file.prefix) ~= "string") then
            file_name = traversal.file.default_prefix .. "/" .. file_name
            traversal.file.prefix = traversal.file.default_prefix
        else
            local prefix = traversal.file.prefix
            if (not prefix:find("/", -1) and not prefix:find("\\", -1)) then
                prefix = prefix .. "/"
            end
            file_name = prefix .. file_name
        end
    end
    if (not file_name:find(traversal.file.postfix, -5)) then file_name = file_name .. traversal.file.postfix end

    local function do_traverse(data, file_name, found_data, optionals)

        if (not optionals.full and type(optionals.max_depth) == "number" and depth.get() > optionals.max_depth) then return --[[else log("depth = " .. depth.get())]] end

        if (depth.get() == 0) then
            helpers.write_file(file_name, "{")
        end
        if (traversal.calls > 2 ^ 16) then return end
        traversal.calls = traversal.calls + 1

        depth.increment()
        if (data == nil or type(data) ~= "table") then return nil end
        if (found_data == nil or type(found_data) ~= "table") then found_data = {} end

        local t = nil

        if (not found_data[data] or found_data[data] and found_data[data].depth > depth.get()) then
            if (not found_data[data]) then found_data[data] = {} end
            found_data[data].depth = depth.get()
            t = {}

            for k, v in pairs(data) do
                local formatted_index = "\"" .. tostring(k) .. "\""
                if (type(tonumber(k)) == "number") then formatted_index = tonumber(k) end

                if (type(v) ~= "table") then
                    if (next(data, k)) then
                        helpers.write_file(file_name, "\n" .. string.rep(traversal.SPACING, depth.get()) .. formatted_index .. ": " .. serpent.block(v) .. ",", true)
                    else
                        helpers.write_file(file_name, "\n" .. string.rep(traversal.SPACING, depth.get()) .. formatted_index .. ": " .. serpent.block(v), true)
                    end
                else
                    local function func(data, file_name, found_data, optionals)
                        if (not optionals.full and type(optionals.max_depth) == "number" and depth.get() > optionals.max_depth) then return --[[else log("depth = " .. depth.get())]] end

                        if (traversal.calls > 2 ^ 16) then return end
                        traversal.calls = traversal.calls + 1

                        local traversed_t = do_traverse(data, file_name, found_data, optionals)

                        if (traversed_t) then
                            for i, j in pairs(traversed_t) do
                                local _formatted_index = "\"" .. tostring(i) .. "\""
                                if (type(tonumber(i)) == "number") then _formatted_index = tonumber(i) end
                                if (type(j) ~= "table") then
                                    if (next(traversed_t, i)) then
                                        helpers.write_file(file_name, "\n" .. string.rep(traversal.SPACING, depth.get() - 1) .. _formatted_index .. ": " .. serpent.block(j) .. ",", true)
                                    else
                                        helpers.write_file(file_name, "\n" .. string.rep(traversal.SPACING, depth.get() - 1) .. _formatted_index .. ": " .. serpent.block(j), true)
                                    end
                                else
                                    helpers.write_file(file_name, "\n" .. string.rep(traversal.SPACING, depth.get()) .. _formatted_index .. ": {", true)
                                    depth.increment()
                                    func(j, file_name, found_data, optionals)
                                    depth.decrement()
                                    if (next(traversed_t, i)) then
                                        helpers.write_file(file_name, "\n" .. string.rep(traversal.SPACING, depth.get()) .. "},", true)
                                    else
                                        helpers.write_file(file_name, "\n" .. string.rep(traversal.SPACING, depth.get()) .. "}", true)
                                    end
                                end
                            end
                        end
                    end

                    helpers.write_file(file_name, "\n" .. string.rep(traversal.SPACING, depth.get()) .. formatted_index .. ": {", true)

                    func(v, file_name, found_data, optionals)

                    if (next(data, k)) then
                        helpers.write_file(file_name, "\n" .. string.rep(traversal.SPACING, depth.get()) .. "},", true)
                    else
                        helpers.write_file(file_name, "\n" .. string.rep(traversal.SPACING, depth.get()) .. "}", true)
                    end
                end
            end
        else
            t = {}

            depth.increment()
            for k, v in pairs(data) do
                local formatted_index = "\"" .. tostring(k) .. "\""
                if (type(tonumber(k)) == "number") then formatted_index = tonumber(k) end

                if (type(v) ~= "table") then
                    if (next(data, k)) then
                        helpers.write_file(file_name, "\n" .. string.rep(traversal.SPACING, depth.get() - 1) .. formatted_index .. ": " .. serpent.block(v) .. ",", true)
                    else
                        helpers.write_file(file_name, "\n" .. string.rep(traversal.SPACING, depth.get() - 1) .. formatted_index .. ": " .. serpent.block(v), true)
                    end
                else
                    if (next(data, k)) then
                        helpers.write_file(file_name, "\n" .. string.rep(traversal.SPACING, depth.get() - 1) .. formatted_index .. ": \"".. traversal.file.prefix .. "-placeholder\",", true)
                    else
                        helpers.write_file(file_name, "\n" .. string.rep(traversal.SPACING, depth.get() - 1) .. formatted_index .. ": \"".. traversal.file.prefix .."-placeholder\"", true)
                    end
                end
            end
            depth.decrement()
        end

        depth.decrement()
        if (depth.get() == 0) then helpers.write_file(file_name, "\n" .. string.rep(traversal.SPACING, depth.get()) .. "}", true) end

        return t
    end
    do_traverse(data, file_name, found_data, optionals)
    return file_name
end

local _commands = {}

function _commands.parse_parameters(data)
    _Log.error("_commands.parse_parameters")
    _Log.warn(data)

    local return_data = {}

    if (not data or type(data) ~= "table") then return return_data end
    if (not data.event or type(data.event) ~= "table") then return return_data end

    local parameter_string = data.event.parameter
    return_data.max_depth = 1
    return_data.everything = false

    local pattern = "%-%-(%a+)(=*)(%d*)%s*"
    local _, j, param, equal, param_val = parameter_string:find(pattern, 1)

    if (equal and equal ~= "" and equal ~= "=") then return end

    while param ~= nil do

        if (param_val) then
            if (param:lower() == "depth" or param:lower() == "d") then return_data.max_depth = type(tonumber(param_val)) == "number" and tonumber(param_val) or 1 end
        end
        if (param:lower() == "everything" or param:lower() == "all") then return_data.everything = param_val ~= nil or false end
        if (param == "E" or param == "A") then return_data.everything = param_val ~= nil or false end

        parameter_string = parameter_string:sub(j + 1, #parameter_string)

        _, j, param, equal, param_val = parameter_string:find(pattern, 1)
        if (equal and equal ~= "" and equal ~= "=") then return end
    end

    return_data.t_name = parameter_string
    return_data.t_parsed_name = { t = {}, a = {}, step = { t = {}, a = {}, }, reversed = { t = {}, a = {}, } }
    return_data.i = 1
    return_data.index = 0
    return_data.r_index = 0
    return_data.name = return_data.t_name
    return_data.remainder = return_data.t_name
    return_data.storage_prefix = false

    if (return_data.everything) then
        return_data.valid = true

        return return_data
    end

    repeat
        local _i = return_data.t_name:find("%.", (return_data.index > 0 and return_data.index + 1 or 1)) or 0
        local r_i = return_data.t_name:reverse():find("%.", (return_data.r_index > 0 and return_data.r_index + 1 or 1)) or 0
        return_data.index = return_data.index + _i
        return_data.r_index = return_data.r_index + r_i

        return_data.name = return_data.remainder:sub(1, return_data.remainder:find("%.") and return_data.remainder:find("%.") - 1 or #return_data.remainder)
        return_data.remainder = return_data.remainder:sub(return_data.remainder:find("%.") and return_data.remainder:find("%.") + 1 or 1, #return_data.remainder)

        local current_name = return_data.t_name:sub(1, (_i - 1))
        local step_name = return_data.name
        local reversed_name = return_data.t_name:reverse():sub(1, (r_i - 1)):reverse()

        if (return_data.i == 1 and step_name == "storage") then return_data.storage_prefix = true end
        if (return_data.t_parsed_name.t[current_name] or return_data.t_parsed_name.reversed.t[reversed_name]) then break end
        return_data.t_parsed_name.t[current_name] = return_data.i
        return_data.t_parsed_name.a[return_data.i] = current_name
        if (return_data.storage_prefix) then
           return_data.t_parsed_name.step.t[step_name] = return_data.i - 1
            return_data.t_parsed_name.step.a[return_data.i - 1] = step_name
        else
            return_data.t_parsed_name.step.t[step_name] = return_data.i
            return_data.t_parsed_name.step.a[return_data.i] = step_name
        end
        return_data.t_parsed_name.reversed.t[reversed_name] = return_data.i
        return_data.t_parsed_name.reversed.a[return_data.i] = reversed_name

        return_data.i = return_data.i + 1
    until return_data.i > 2 ^ 6

    return_data.valid = true

    return return_data
end

function _commands.print_table(data)
    _Log.error("_commands.print_table")
    _Log.warn(data)

    if (not data or type(data) ~= "table") then return end
    local player = data.player
    if (not player or not player.valid) then return end

    local parsed_parameters = _commands.parse_parameters({ event = data.event })
    if (not parsed_parameters or not parsed_parameters.valid) then return end

    local t_name = "storage"
    local t = nil

    if (not parsed_parameters.everything) then
        local t_parsed_name = parsed_parameters.t_parsed_name
        t_name = parsed_parameters.t_name
        t = { data = nil, name = t_name }

        local function func(data)
            if (t_parsed_name.step.a[data.i] and t_parsed_name.step.t[t_parsed_name.step.a[data.i]]) then
                local name = data.t.a[data.i]
                if (data.table[name]) then
                    t.data = data.table[name]
                    t.name = data.name .. "." .. name
                    if (next(data.t.a, data.i)) then
                        func({ t = data.t, i = next(data.t.a, data.i), name = t.name, table = data.table[name] })
                    end
                end
            end
        end

        local depth = 1

        if (t_parsed_name.step.a[depth] and t_parsed_name.step.t[t_parsed_name.step.a[depth]]) then
            local name = t_parsed_name.step.a[depth]
            if (storage[name]) then
                t.data = storage[name]
                t.name = "storage." .. name
                if (next(t_parsed_name.step.a, depth)) then
                    func({ t = t_parsed_name.step, i = next(t_parsed_name.step.a, depth), name = name, table = storage[name] })
                end
            end
        end

        if (t.data == nil) then
            if (storage[t_name]) then
                if (type(storage[t_name]) == "table") then
                    t.data = { storage[t_name] }
                else
                    t.data = storage[t_name]
                end
                t.name = "storage." .. t_name
            else
                t = traversal.traverse_find(t_name, _, _, path --[[Think this can be used for an arbitrary table; defaults to "storage" if not provided]], { parsed_name = t_parsed_name, max_depth = max_depth })
            end
        end
    else
        t = { data = storage, name = t_name }
    end

    if (t ~= nil and type(t) == "table") then
        if (t.data and type(t.data) == "table") then
            local file_name = t.name .. "_" .. game.tick
            local exported_file_name = traversal.traverse_print(t.data, file_name, _, { max_depth = parsed_parameters.max_depth })
            player.print("Exported table to : ../Factorio/script-output/" .. tostring(exported_file_name))
        else
            player.print("Could not find table: " .. t.name)
        end
    else
        if (t) then
            player.print("Could not find table: " .. t.name)
        else
            player.print("Could not find table")
        end
    end
end

local core_utils = {
    commands = _commands,
    counter = { new = function () return depth() end },
    table = {
        traversal = traversal,
        reassign = function (table_old, table_new, data)
            if (type(table_old) == "table" and table_old[data.field] and type(table_new) == "table") then
                table_new[data.field] = table_old[data.field]
                table_old[data.field] = nil
            end
        end,
    },
}

function core_utils.init(data)
    if (not data or type(data) ~= "table") then return end
    if (not data.log or type(data.log) ~= "table") then return end
end

return core_utils