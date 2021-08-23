simple_amm = {}
simple_amm.redo = true
simple_amm.version = "20210220.0"

local modname = minetest.get_current_modname()
simple_amm.modname = modname
simple_amm.modpath = minetest.get_modpath(modname)

function simple_amm.log(level, message, ...)
    message = message:format(...)
    minetest.log(level, ("[%s] %s"):format(modname, message))
end

simple_amm.player_pos = {}
simple_amm.add_storage = {}  -- used for linking shops to external storage

dofile(simple_amm.modpath .. "/settings.lua")
dofile(simple_amm.modpath .. "/util.lua")

dofile(simple_amm.modpath .. "/metadata.lua")

-- interop that affects the API
dofile(simple_amm.modpath .. "/interop/currency.lua")
dofile(simple_amm.modpath .. "/interop/mesecons.lua")

dofile(simple_amm.modpath .. "/entities.lua")

dofile(simple_amm.modpath .. "/shop_node.lua")
dofile(simple_amm.modpath .. "/shop_display.lua")
dofile(simple_amm.modpath .. "/shop_formspec.lua")
dofile(simple_amm.modpath .. "/shop_color.lua")

dofile(simple_amm.modpath .. "/storage_node.lua")
dofile(simple_amm.modpath .. "/storage_formspec.lua")

dofile(simple_amm.modpath .. "/crafting.lua")

-- interop that doesn't affect the API
dofile(simple_amm.modpath .. "/interop/pipeworks.lua")
dofile(simple_amm.modpath .. "/interop/tubelib.lua")

dofile(simple_amm.modpath .. "/refunds.lua")


minetest.register_on_player_receive_fields(function(player, form, pressed)
    if form == "simple_amm.shop_showform" then
        simple_amm.shop_receive_fields(player, pressed)
    elseif form == "simple_amm.wifi_showform" then
        simple_amm.wifi_receive_fields(player, pressed)
    end
end)
