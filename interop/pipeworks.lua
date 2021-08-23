if not minetest.get_modpath("pipeworks") then
    return
end

local itemstrings = {
    "simple_amm:amm",
    "simple_amm:amm_full",
    "simple_amm:amm_empty",
    "simple_amm:amm_used",
    "simple_amm:amm_admin",
    "simple_amm:wifistorage"
}

for _, itemstring in ipairs(itemstrings) do
    local def = minetest.registered_nodes[itemstring]
    local after_place_node = def.after_place_node
    local after_dig_node = def.after_dig_node
    minetest.override_item(itemstring, {
        after_place_node = function(pos, placer, itemstack)
            if after_place_node then
                after_place_node(pos, placer, itemstack)
            end
            pipeworks.after_place(pos, placer, itemstack)
        end,
        after_dig_node = function(pos, oldnode, oldmetadata, digger)
            if after_dig_node then
                after_dig_node(pos, oldnode, oldmetadata, digger)
            end
            pipeworks.after_dig(pos, oldnode, oldmetadata, digger)
        end,
    })
end
