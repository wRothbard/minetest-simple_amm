local on_timer
if simple_amm.settings.has_mesecon then
    function on_timer(pos, elapsed)
        mesecon.receptor_off(pos)
        return false
    end
else
    function on_timer() return false end
end

local function tube_can_insert(pos, node, stack, direction)
    local meta = minetest.get_meta(pos)
    local inv  = simple_amm.get_inventory(meta)
    return inv:room_for_item("main", stack)
end

local function tube_insert(pos, node, stack, direction)
    local meta  = minetest.get_meta(pos)
    local inv   = simple_amm.get_inventory(meta)
    local added = inv:add_item("main", stack)
    simple_amm.update_shop_color(pos)
    return added
end

local function after_place_node(pos, placer)
    local shop_meta   = minetest.get_meta(pos)
    local player_name = placer:get_player_name()
    local is_admin = simple_amm.util.player_is_admin(player_name) and 1 or 0
    simple_amm.set_owner(shop_meta, player_name)
    simple_amm.set_infotext(shop_meta, ("Shop by: %s"):format(player_name))
    simple_amm.set_admin(shop_meta, is_admin)
    simple_amm.set_unlimited(shop_meta, is_admin)
    simple_amm.set_upgraded(shop_meta)
    simple_amm.update_shop_color(pos)
end

local function on_construct(pos)
    local meta = minetest.get_meta(pos)
    simple_amm.set_state(meta, 0) -- mesecons?
    local inv = simple_amm.get_inventory(meta)
    inv:set_size("main", 32)
    inv:set_size("give1", 1)
    inv:set_size("pay1", 1)
    inv:set_size("give2", 1)
    inv:set_size("pay2", 1)
    inv:set_size("give3", 1)
    inv:set_size("pay3", 1)
    inv:set_size("give4", 1)
    inv:set_size("pay4", 1)
end

local function on_rightclick(pos, node, player, itemstack, pointed_thing)
    simple_amm.shop_showform(pos, player)
end

local function allow_metadata_inventory_put(pos, listname, index, stack, player)
    if not simple_amm.util.can_access(player, pos) then
        return 0
    elseif stack:get_wear() ~= 0 then
        return 0
    elseif listname == "main" then
        return stack:get_count()
    else
        local inv = simple_amm.get_inventory(pos)
        local old_stack = inv:get_stack(listname, index)
        if old_stack:get_name() == stack:get_name() then
            local old_count = old_stack:get_count()
            local add_count = stack:get_count()
            local max_count = old_stack:get_stack_max()
            local new_count = math.min(old_count + add_count, max_count)
            old_stack:set_count(new_count)
            inv:set_stack(listname, index, old_stack)

        else
            inv:set_stack(listname, index, stack)
        end

        -- so we don't remove anything from the player's own stuff
        return 0
    end
end

local function allow_metadata_inventory_take(pos, listname, index, stack, player)
    if not simple_amm.util.can_access(player, pos) then
        return 0
    elseif listname == "main" then
        return stack:get_count()
    else
        local inv = simple_amm.get_inventory(pos)
        inv:set_stack(listname, index, ItemStack(""))
        return 0
    end
end

local function allow_metadata_inventory_move(pos, from_list, from_index, to_list, to_index, count, player)
    if not simple_amm.util.can_access(player, pos) then
        return 0
    elseif from_list == "main" and to_list == "main" then
        return count
    elseif from_list == "main" then
        local inv   = simple_amm.get_inventory(pos)
        local stack = inv:get_stack(from_list, from_index)
        if allow_metadata_inventory_put(pos, to_list, to_index, stack, player) ~= 0 then
            return count
        else
            return 0
        end
    elseif to_list == "main" then
        local inv   = simple_amm.get_inventory(pos)
        local stack = inv:get_stack(to_list, to_index)
        if allow_metadata_inventory_take(pos, from_list, from_index, stack, player) ~= 0 then
            return count
        else
            return 0
        end
    else
        return count
    end
end

local function on_metadata_inventory_put(pos, listname, index, stack, player)
    if listname == "main" then
        simple_amm.log("action", "%s put %q in %s @ %s",
                      player:get_player_name(),
                      stack:to_string(),
                      minetest.get_node(pos).name,
                      minetest.pos_to_string(pos)
        )
    end
end

local function on_metadata_inventory_take(pos, listname, index, stack, player)
    if listname == "main" then
        simple_amm.log("action", "%s took %q from %s @ %s",
                      player:get_player_name(),
                      stack:to_string(),
                      minetest.get_node(pos).name,
                      minetest.pos_to_string(pos)
        )
    end
end

local function can_dig(pos, player)
    local meta  = minetest.get_meta(pos)
    local inv   = simple_amm.get_inventory(meta)
    local owner = simple_amm.get_owner(meta)
    if (owner == "" or simple_amm.util.can_access(player, pos)) and inv:is_empty("main") then
        simple_amm.clear_shop_entities(pos)
        return true
    end
end

local simple_amm_def                                 = {
    description                   = "Smartshop",
    tiles                         = { "(default_chest_top.png^[colorize:#FFFFFF77)^default_obsidian_glass.png" },
    groups                        = { choppy                  = 2,
                                      oddly_breakable_by_hand = 1,
                                      tubedevice              = 1,
                                      tubedevice_receiver     = 1,
                                      mesecon                 = 2 },
    drawtype                      = "nodebox",
    node_box                      = { type  = "fixed",
                                      fixed = { -0.5, -0.5, -0.0, 0.5, 0.5, 0.5 } },
    paramtype2                    = "facedir",
    paramtype                     = "light",
    sunlight_propagates           = true,
    light_source                  = 10,
    on_timer                      = on_timer,
    tube                          = { insert_object   = tube_insert,
                                      can_insert      = tube_can_insert,
                                      input_inventory = "main",
                                      connect_sides   = { left   = 1,
                                                          right  = 1,
                                                          front  = 1,
                                                          back   = 1,
                                                          top    = 1,
                                                          bottom = 1 } },
    after_place_node              = after_place_node,
    on_construct                  = on_construct,
    on_rightclick                 = on_rightclick,
    allow_metadata_inventory_put  = allow_metadata_inventory_put,
    allow_metadata_inventory_take = allow_metadata_inventory_take,
    allow_metadata_inventory_move = allow_metadata_inventory_move,
    on_metadata_inventory_put     = on_metadata_inventory_put,
    on_metadata_inventory_take    = on_metadata_inventory_take,
    can_dig                       = can_dig,
    on_blast                      = function() end,
}

local simple_amm_full_def                            = simple_amm.util.deepcopy(simple_amm_def)
simple_amm_full_def.drop                             = "simple_amm:amm"
simple_amm_full_def.tiles                            = { "(default_chest_top.png^[colorize:#FFFFFF77)^(default_obsidian_glass.png^[colorize:#0000FF77)" }
simple_amm_full_def.groups.not_in_creative_inventory = 1

local simple_amm_empty_def                           = simple_amm.util.deepcopy(simple_amm_full_def)
simple_amm_empty_def.tiles                           = { "(default_chest_top.png^[colorize:#FFFFFF77)^(default_obsidian_glass.png^[colorize:#FF000077)" }

local simple_amm_used_def                            = simple_amm.util.deepcopy(simple_amm_full_def)
simple_amm_used_def.tiles                            = { "(default_chest_top.png^[colorize:#FFFFFF77)^(default_obsidian_glass.png^[colorize:#00FF0077)" }

local simple_amm_admin_def                           = simple_amm.util.deepcopy(simple_amm_full_def)
simple_amm_admin_def.tiles                           = { "(default_chest_top.png^[colorize:#FFFFFF77)^(default_obsidian_glass.png^[colorize:#00FFFF77)" }

minetest.register_node("simple_amm:amm", simple_amm_def)
minetest.register_node("simple_amm:amm_full", simple_amm_full_def)
minetest.register_node("simple_amm:amm_empty", simple_amm_empty_def)
minetest.register_node("simple_amm:amm_used", simple_amm_used_def)
minetest.register_node("simple_amm:amm_admin", simple_amm_admin_def)

simple_amm.shop_node_names = {
    "simple_amm:amm",
    "simple_amm:amm_full",
    "simple_amm:amm_empty",
    "simple_amm:amm_used",
    "simple_amm:amm_admin"
}

function simple_amm.is_simple_amm(pos)
    local node = minetest.get_node(pos)
    local node_name = node.name
    for _, name in ipairs(simple_amm.shop_node_names) do
        if name == node_name then return true end
    end
    return false
end
