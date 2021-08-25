local function get_inv_totals(shop_inv, refill_inv)
    local inv_totals = {}
	for i = 1, 32 do
		local stack = shop_inv:get_stack("main", i)
		if not stack:is_empty() and stack:is_known() and stack:get_wear() == 0 then
			local name = stack:get_name()
			inv_totals[name] = (inv_totals[name] or 0) + stack:get_count()
		end
	end
    if refill_inv then
        for i = 1, (12*5) do
            local stack = refill_inv:get_stack("main", i)
            if not stack:is_empty() and stack:is_known() and stack:get_wear() == 0 then
                local name = stack:get_name()
                inv_totals[name] = (inv_totals[name] or 0) + stack:get_count()
            end
        end
    end
    return inv_totals
end

local function get_info_lines(owner, shop_inv, inv_totals)
    local lines = {("(AMMshop by %s) Purchases left:"):format(owner)}
    for i = 1, 4, 1 do
		local pay_stack  = shop_inv:get_stack("pay" .. i, 1)
		local give_stack = shop_inv:get_stack("give" .. i, 1)
		if not pay_stack:is_empty() and not give_stack:is_empty() and give_stack:is_known() and give_stack:get_wear() == 0 then
			local name  = give_stack:get_name()
	        local count = give_stack:get_count()
			local stock = inv_totals[name] or 0
			local buy_count = math.floor(stock / count)
			if buy_count ~= 0 then
				local def         = give_stack:get_definition()
				local description = def.short_description or (def.description or ""):match("^[^\n]*")
                if not description or description == "" then
                    description = name
                end
				local message     = ("(%i) %s"):format(buy_count, description)
				table.insert(lines, message)
			end
		end
    end
    return lines
end

function simple_amm.update_shop_info(pos)
    if not simple_amm.is_simple_amm(pos) then return end

    local shop_meta = minetest.get_meta(pos)
    local owner     = simple_amm.get_owner(shop_meta)

	if simple_amm.is_unlimited(shop_meta) then
        simple_amm.set_infotext(shop_meta, "(AMMshop by %s) Stock is unlimited", owner)
        return
    end

    simple_amm.recalc(pos)
    local shop_inv     = simple_amm.get_inventory(shop_meta)
	local refill_spos  = simple_amm.get_refill_spos(shop_meta)
    local refill_pos   = simple_amm.util.string_to_pos(refill_spos)
    local refill_inv
    if refill_pos then
        refill_inv = simple_amm.get_inventory(refill_pos)
    end

	local inv_totals = get_inv_totals(shop_inv, refill_inv)
	local lines = get_info_lines(owner, shop_inv, inv_totals)

    if #lines == 1 then
        simple_amm.set_infotext(shop_meta, "(AMMshop by %s)\nThis shop is empty.", owner)
    else
        local item1 = simple_amm.get_item1(shop_meta)
        local item2 = simple_amm.get_item2(shop_meta)
	if item1 ~= nil and item1 ~= "" and item2 ~= nil and item2 ~= "" then
            local bid = simple_amm.get_bid(shop_meta)
            local ask = simple_amm.get_ask(shop_meta)
            local i1 = item1:gsub(".*:", "")
            local i2 = item2:gsub(".*:", "")
            simple_amm.set_infotext(shop_meta, "(AMMshop by %s)\n%s for %s\nBID: %s ASK: %s", owner, i1, i2, bid, ask)
        else
            simple_amm.set_infotext(shop_meta, table.concat(lines, "\n"):gsub("%%", "%%%%"))
	end
    end
end


minetest.register_lbm({
	name = "simple_amm:load_shop",
	nodenames = {
        "simple_amm:amm",
        "simple_amm:amm_full",
        "simple_amm:amm_empty",
        "simple_amm:amm_used",
        "simple_amm:amm_admin"
    },
    run_at_every_load = true,
	action = function(pos, node)
        simple_amm.clear_shop_entities(pos)
        simple_amm.clear_old_entities(pos)
        simple_amm.update_shop_entities(pos)

        simple_amm.update_shop_info(pos)
        simple_amm.update_shop_color(pos)

        -- convert metadata
        local meta = minetest.get_meta(pos)
        local metatable = meta:to_table() or {}
        if metatable.creative == 1 then
            if metatable.type == 0 then
                metatable.unlimited = 1
                metatable.item_send = nil
                metatable.item_refill = nil
            elseif metatable.type == 1 then
                metatable.unlimited = 0
            end
            if metatable.type then
                metatable.type = nil
            end
        end
        meta:from_table(metatable)
	end,
})
