local function can_receive_payments(pay_stack, give_stack, shop_inv, send_inv)
    local answer = shop_inv:room_for_item("main", pay_stack)

    if (not answer) and shop_inv:contains_item("main", give_stack) then
        local tmp_inv = simple_amm.util.clone_tmp_inventory("tmp_can_exchange", shop_inv, "main")
        tmp_inv:remove_item("main", give_stack)
        answer = tmp_inv:room_for_item("main", pay_stack)
        simple_amm.util.delete_tmp_inventory("tmp_can_exchange")

    elseif send_inv and send_inv:room_for_item("main", pay_stack) then
        answer = true
    end

    return answer
end

local function get_exchange_status(shop_inv, slot, send_inv, refill_inv)
    local pay_key = "pay"..slot
    local pay_stack = shop_inv:get_stack(pay_key, 1)
    local give_key = "give"..slot
    local give_stack = shop_inv:get_stack(give_key, 1)

    -- TODO: this isn't quite correct, as it doesn't allow for stacks split between the shop and storage
    if give_stack:is_empty() or pay_stack:is_empty() then
        return "skip"
    elseif not can_receive_payments(pay_stack, give_stack, shop_inv, send_inv) then
        return "full"
    elseif shop_inv:contains_item("main", pay_stack) or (send_inv and send_inv:contains_item("main", pay_stack)) then
        return "used"
    elseif not (shop_inv:contains_item("main", give_stack) or (refill_inv and refill_inv:contains_item("main", give_stack))) then
        return "empty"
    else
        return "ignore"
    end
end

function simple_amm.update_shop_color(pos)
    --[[
    normal: nothing in the give slots
    full  : no exchanges possible because no room for pay items
    empty : no exchanges possible because no more give items
    used  : pay items in main
    ]]--
    if not simple_amm.is_simple_amm(pos) then
        return
    end
    local shop_meta    = minetest.get_meta(pos)
    local shop_inv     = simple_amm.get_inventory(shop_meta)
    local is_unlimited = simple_amm.is_unlimited(shop_meta)
	local send_spos    = simple_amm.get_send_spos(shop_meta)
    local send_pos     = simple_amm.util.string_to_pos(send_spos)
	local send_inv     = send_pos and minetest.get_meta(send_pos):get_inventory()
	local refill_spos  = simple_amm.get_refill_spos(shop_meta)
    local refill_pos   = simple_amm.util.string_to_pos(refill_spos)
	local refill_inv   = refill_pos and minetest.get_meta(refill_pos):get_inventory()

    local total        = 4
    local full_count   = 0
    local empty_count  = 0
    local used         = false

    for slot = 1,4 do
        local status = get_exchange_status(shop_inv, slot, send_inv, refill_inv)
        if status == "full" then
            full_count = full_count + 1
        elseif status == "empty" then
            empty_count = empty_count + 1
        elseif status == "used" then
            used = true
        elseif status == "skip" then
            total = total - 1
        end
    end

    local to_swap
    if total == 0 then
        to_swap = "simple_amm:amm_empty"
    elseif is_unlimited then
        to_swap = "simple_amm:amm_admin"
    elseif full_count == total then
        to_swap = "simple_amm:amm_full"
    elseif empty_count == total then
        to_swap = "simple_amm:amm_empty"
    elseif used then
        to_swap = "simple_amm:amm_used"
    else
        to_swap = "simple_amm:amm"
    end

    local node = minetest.get_node(pos)
    local node_name = node.name
    if node_name ~= to_swap then
        minetest.swap_node(pos, {
            name = to_swap,
            param2 = node.param2
        })
    end
end
