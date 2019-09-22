function smartshop.player_invs(player)
    local player_name     = player:get_player_name()
    local player_inv      = player:get_inventory()
    local player_inv_copy = smartshop.util.clone_tmp_inventory("smartshop_tmp_player_inv", player_inv, "main")
    local player_invs     = {}
    function player_invs.test_take(pay_stack)
        local removed   = player_inv_copy:remove_item("main", pay_stack)
        local remainder_count = pay_stack:get_count() - removed:get_count()
        if remainder_count == 0 then
            return true
        elseif smartshop.currency.is_currency(pay_stack) then
            local remainder = ItemStack(pay_stack:get_name(), remainder_count)
            if smartshop.settings.change_currency then
                local remaining_cents = smartshop.currency.extract_currency(remainder, player_inv_copy)
                if remaining_cents > 0 then
                    return (
                        smartshop.settings.enable_lurkcoin and
                        lurkcoin.bank.getbal(player_name) * 100 >= remaining_cents
                    )
                end
            elseif smartshop.settings.enable_lurkcoin then
                local remaining_cents = smartshop.currency.sum_currency_stack(remainder)
                return lurkcoin.bank.getbal(player_name) * 100 >= remaining_cents
            end
        end
        return false
    end
    function player_invs.take(pay_stack)
        local removed   = player_inv:remove_item("main", pay_stack)
        local remainder_count = pay_stack:get_count() - removed:get_count()
        if remainder_count == 0 then
            return
        elseif smartshop.currency.is_currency(pay_stack) then
            local remainder = ItemStack(pay_stack:get_name(), remainder_count)
            if smartshop.settings.change_currency then
                local remaining_cents = smartshop.currency.extract_currency(remainder, player_inv)
                if remaining_cents == 0 then
                    return
                elseif smartshop.settings.enable_lurkcoin then
                    lurkcoin.bank.subtract(player_name, remaining_cents / 100, "paying shop")
                    return
                end
            elseif smartshop.settings.enable_lurkcoin then
                local remaining_cents = smartshop.currency.sum_currency_stack(remainder)
                lurkcoin.bank.subtract(player_name, remaining_cents / 100, "paying shop")
                return
            end
        end
        smartshop.log("error", "did not extract full payment from player %s", player_name)
    end
    function player_invs.test_accept(give_stack)
        local remainder = player_inv_copy:add_item("main", give_stack)
        return remainder:is_empty()
    end
    function player_invs.accept(give_stack)
        player_inv:add_item("main", give_stack)
    end
    function player_invs.cleanup()
        smartshop.util.delete_tmp_inventory("smartshop_tmp_player_inv")
    end
    return player_invs
end

function smartshop.shop_invs(pos)
    local shop_meta        = minetest.get_meta(pos)
    local is_unlimited     = smartshop.meta.is_unlimited(shop_meta)
    local shop_owner       = smartshop.meta.get_owner(shop_meta)
    local shop_inv         = smartshop.meta.get_inventory(shop_meta)
    local send_to_lurkcoin = smartshop.meta.get_send_to_lurkcoin(shop_meta)
    local send_spos        = smartshop.meta.get_send_spos(shop_meta)
    local send_pos         = smartshop.util.string_to_pos(send_spos)
    local send_inv         = send_pos and minetest.get_meta(send_pos):get_inventory()
    local refill_from_lurkcoin = smartshop.meta.get_refill_from_lurkcoin(shop_meta)
    local refill_spos      = smartshop.meta.get_refill_spos(shop_meta)
    local refill_pos       = smartshop.util.string_to_pos(refill_spos)
    local refill_inv       = refill_pos and minetest.get_meta(refill_pos):get_inventory()

    local shop_inv_copy   = smartshop.util.clone_tmp_inventory("smartshop_tmp_shop_inv", shop_inv, "main")
    local send_inv_copy   = send_inv and smartshop.util.clone_tmp_inventory("smartshop_tmp_send_inv", send_inv, "main")
    local refill_inv_copy = refill_inv and smartshop.util.clone_tmp_inventory("smartshop_tmp_refill_inv", refill_inv, "main")

    local shop_invs = {}
    function shop_invs.test_take(give_stack)
        if is_unlimited then
            -- is stock unlimited?
            return true
        elseif (smartshop.settings.enable_lurkcoin and
                smartshop.currency.is_currency(give_stack) and
                refill_from_lurkcoin) then
            -- can we just take the whole amount from lurkcoin?
            local give_cents = smartshop.currency.sum_currency_stack(give_stack)
            if lurkcoin.bank.getbal(shop_owner) * 100 >= give_cents then
                return true
            end
        end

        if refill_inv_copy then
            -- is there a refill inventory?
            local removed   = refill_inv_copy:remove_item("main", give_stack)
            local remainder_count = give_stack:get_count() - removed:get_count()
            if remainder_count == 0 then
                return true
            else
                -- couldn't take full amount from refill inventory, continue checking
                give_stack = ItemStack(give_stack:get_name(), remainder_count)
            end
        end

        local removed = shop_inv_copy:remove_item("main", give_stack)
        local remainder_count = give_stack:get_count() - removed:get_count()

        if remainder_count == 0 then
            -- success
            return true
        else
            if (smartshop.settings.enable_lurkcoin and
                smartshop.currency.is_currency(give_stack) and
                refill_from_lurkcoin) then
                -- can we take the remainder from lurkcoin?
                local remainder = ItemStack(give_stack:get_name(), remainder_count)
                local remaining_cents = smartshop.currency.sum_currency_stack(remainder)
                return lurkcoin.bank.getbal(shop_owner) * 100 >= remaining_cents
            else
                return false
            end
        end
    end
    function shop_invs.take(give_stack)
        if is_unlimited then
            return
        elseif (smartshop.settings.enable_lurkcoin and
                smartshop.currency.is_currency(give_stack) and
                refill_from_lurkcoin) then
            -- if possible, take the whole amount from lurkcoin
            local give_cents = smartshop.currency.sum_currency_stack(give_stack)
            if lurkcoin.bank.getbal(shop_owner) * 100 >= give_cents then
                lurkcoin.bank.subtract(shop_owner, give_cents / 100, "taking for purchase from shop")
                return
            end
        end

        if refill_inv then
            -- is there a refill inventory? check that first
            local removed         = refill_inv:remove_item("main", give_stack)
            local remainder_count = give_stack:get_count() - removed:get_count()
            if remainder_count == 0 then
                return
            else
                -- not enough in refill inventory
                give_stack = ItemStack(give_stack:get_name(), remainder_count)
            end
        end

        local removed = shop_inv:remove_item("main", give_stack)
        local remainder_count = give_stack:get_count() - removed:get_count()
        if remainder_count == 0 then
            return true
        else
            if (smartshop.settings.enable_lurkcoin and
                smartshop.currency.is_currency(give_stack) and
                refill_from_lurkcoin) then
                local remainder = ItemStack(give_stack:get_name(), remainder_count)
                local remaining_cents = smartshop.currency.sum_currency_stack(remainder)
                return lurkcoin.bank.getbal(shop_owner) * 100 >= remaining_cents
            else
                return false
            end
        end
    end
    function shop_invs.test_accept(pay_stack)
        if is_unlimited then
            return true
        elseif (smartshop.settings.enable_lurkcoin and
                smartshop.currency.is_currency(pay_stack) and
                send_to_lurkcoin) then
            return true
        end

        if send_inv_copy then
            local remainder = send_inv_copy:add_item("main", pay_stack)
            if remainder:is_empty() then
                return true
            else
                pay_stack = remainder
            end
        end

        local remainder = shop_inv_copy:add_item("main", pay_stack)
        return remainder:is_empty()
    end
    function shop_invs.accept(pay_stack)
        if is_unlimited then
            return true
        elseif (smartshop.settings.enable_lurkcoin and
                smartshop.currency.is_currency(pay_stack) and
                send_to_lurkcoin) then
            local cents = smartshop.currency.sum_currency_stack(pay_stack)
            lurkcoin.bank.add(shop_owner, cents / 100, "payment to shop")
            return
        end

        if send_inv then
            local remainder = send_inv:add_item("main", pay_stack)
            if remainder:is_empty() then
                return
            else
                pay_stack = remainder
            end
        end

        shop_inv:add_item("main", pay_stack)
    end
    function shop_invs.cleanup()
        smartshop.util.delete_tmp_inventory("smartshop_tmp_shop_inv")
        smartshop.util.delete_tmp_inventory("smartshop_tmp_send_inv")
        smartshop.util.delete_tmp_inventory("smartshop_tmp_refill_inv")
    end
    return shop_invs
end
