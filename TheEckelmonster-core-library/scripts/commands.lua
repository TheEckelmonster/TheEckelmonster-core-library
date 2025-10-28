local Core_Utils = require("libs.utils.core-utils")

local locals = {}

local _commands = {}


function _commands.print_storage(event)
    locals.validate_command(event, function(player)

        local file_name = "storage_" .. game.tick
        local exported_file_name = Core_Utils.table.traversal.traverse_print(storage, file_name, _, { full = true  })
        player.print("Exported table to: ../Factorio/script-output/" .. tostring(exported_file_name))
    end)
end

function _commands.print_table(event)
    locals.validate_command(event, function (player)

        Core_Utils.commands.print_table({ player = player, event = event })
    end)
end

function locals.validate_command(event, fun)
    if (event) then

        local player = nil
        if (game and event.player_index > 0 and game.players) then player = game.get_player(event.player_index) end

        if (player) then fun(player) end
    end
end

-- commands.add_command("tecl.print_table", "", _commands.print_table)
-- commands.add_command("tecl.print_storage", "Exports to a .json file the underlying storage data.", _commands.print_storage)

return _commands