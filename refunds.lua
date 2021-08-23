--[[
because this fork turns the "give" and "pay" lines in the shop inventory into
placeholders, and not actual inventory slots, upgrading causes the items
stored in those slots to be lost.

if enabled (by default), this LBM will refund those items, even in the event
that the shop is currently full, by waiting until there's available space.

the items can still be lost, though, if the player empties the shop and then
breaks the node, before the LBM has been run.
--]]


if simple_amm.settings.enable_refund then
    minetest.register_lbm({
        name              = "simple_amm:repay_lost_stuff",
        nodenames         = {
            "simple_amm:amm",
            "simple_amm:amm_empty",
            "simple_amm:amm_full",
            "simple_amm:amm_used",
        },
        run_at_every_load = true,
        action            = function(pos, node)
            -- refund lost inventory items, or store them for later
            local meta = minetest.get_meta(pos)

            -- don't bother refunding admin shops
            if simple_amm.is_admin(meta) then return end

            local owner = simple_amm.get_owner(meta)
            local inv = simple_amm.get_inventory(meta)

            if simple_amm.has_upgraded(meta) then
                local unrefunded = {}
                for _, itemstring in ipairs(simple_amm.get_refund(meta)) do
                    local itemstack = ItemStack(itemstring)
                    if inv:room_for_item("main", itemstack) then
                        simple_amm.log("action", "refunding %s to %s's shop at %s",
                            itemstring, owner, minetest.pos_to_string(pos, 0)
                        )
                        inv:add_item("main", itemstack)
                    else
                        table.insert(unrefunded, itemstack:to_string())
                    end
                end
                if not simple_amm.util.table_is_empty(unrefunded) then
                    simple_amm.set_refund(meta, unrefunded)
                else
                    simple_amm.remove_refund(meta)
                end

            else
                local unrefunded = {}
                for index = 1, 4 do
                    local pay_stack = inv:get_stack("pay" .. index, 1)
                    if not pay_stack:is_empty() then
                        if inv:room_for_item("main", pay_stack) then
                            simple_amm.log("action", "refunding %s to %s's shop at %s",
                                pay_stack:to_string(), owner, minetest.pos_to_string(pos, 0)
                            )
                            inv:add_item("main", pay_stack)
                        else
                            table.insert(unrefunded, pay_stack:to_string())
                        end
                    end
                    local give_stack = inv:get_stack("give" .. index, 1)
                    if not give_stack:is_empty() then
                        if inv:room_for_item("main", give_stack) then
                            simple_amm.log("action", "refunding %s to %s's shop at %s",
                                give_stack:to_string(), owner, minetest.pos_to_string(pos, 0)
                            )
                            inv:add_item("main", give_stack)
                        else
                            table.insert(unrefunded, give_stack:to_string())
                        end
                    end
                end
                if not simple_amm.util.table_is_empty(unrefunded) then
                    simple_amm.set_refund(meta, unrefunded)
                else
                    simple_amm.remove_refund(meta)
                end
                simple_amm.set_upgraded(meta)
            end

        end,
    })
end
