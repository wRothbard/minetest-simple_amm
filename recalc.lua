local fee_decimal = simple_amm.settings.fee_percent / 100

simple_amm.ensure_size6 = function(pos, inv)
	local size6 = inv:get_size("give6")
	if not size6 or size6 < 1 then
		inv:set_size("give5", 1)
		inv:set_size("pay5", 1)
		inv:set_size("give6", 1)
		inv:set_size("pay6", 1)
		simple_amm.recalc(pos)
	end
end

-- calculate the cost to buy n item1, in item2
local function calc_cost_to_buy(count1, count2, n)
	local liquidity = count1 * count2
	if count1 - n > 0 then
		return math.ceil(((liquidity / (count1 - n)) - count2) * (1 + fee_decimal))
	end
	return 0
end

-- calculate how many item2 you get if you spend n item1
local function calc_quant_for_spend(count1, count2, n)
	local liquidity = count1 * count2
	return math.floor(count2 - (liquidity / (count1 + n * (1 - fee_decimal))))
end

simple_amm.recalc = function(pos)
	local meta = minetest.get_meta(pos)
	local spos = minetest.pos_to_string(pos)
	simple_amm.set_item1(meta, "")
	simple_amm.set_item2(meta, "")
	simple_amm.set_bid(meta, 0)
	simple_amm.set_ask(meta, "")
	local inv = meta:get_inventory()
	inv:set_stack("pay1", 1, ItemStack(""))
	inv:set_stack("give1", 1, ItemStack(""))
	inv:set_stack("pay2", 1, ItemStack(""))
	inv:set_stack("give2", 1, ItemStack(""))
	inv:set_stack("pay3", 1, ItemStack(""))
	inv:set_stack("give3", 1, ItemStack(""))
	inv:set_stack("pay4", 1, ItemStack(""))
	inv:set_stack("give4", 1, ItemStack(""))
	inv:set_stack("pay5", 1, ItemStack(""))
	inv:set_stack("give5", 1, ItemStack(""))
	inv:set_stack("pay6", 1, ItemStack(""))
	inv:set_stack("give6", 1, ItemStack(""))
	local item1
	local item2
	local count1 = 0
	local count2 = 0
	for i = 1, 32, 1 do
		local stack = inv:get_stack("main", i)
		local name = stack:get_name()
		-- minetest.log("action", "slot " .. i .. " " .. name)
		if name ~= nil and name ~= "" then
			local count = stack:get_count()
			if item1 == nil then
				item1 = name
			elseif name ~= item1 and item2 == nil then
				item2 = name
			end
			if item1 == name then
				count1 = count1 + count
			elseif item2 == name then
				count2 = count2 + count
			else
				return
			end
		end
	end
	if count1 ~= 0 and count2 ~= 0 then
		if count1 > count2 then  -- swap so the 2nd item is always the greater quantity
			local tmpCount = count2
			count2 = count1
			count1 = tmpCount
			local tmpItem = item2
			item2 = item1
			item1 = tmpItem
		end
		simple_amm.set_item1(meta, item1)
		simple_amm.set_item2(meta, item2)
		-- minetest.log("action", "item1 " .. item1 .. " " .. count1)
		-- minetest.log("action", "item2 " .. item2 .. " " .. count2)

		if count1 == count2 then
			minetest.log("action", spos .. ": equal quantities of " .. item1 .. "/" .. item2)
			simple_amm.set_ask(meta, 2)
			simple_amm.set_bid(meta, 0.5)
			inv:set_stack("pay3", 1, ItemStack({name = item2, count = 2}))
			inv:set_stack("give3", 1, ItemStack(item1))
			inv:set_stack("pay4", 1, ItemStack({name = item1, count = 2}))
			inv:set_stack("give4", 1, ItemStack(item2))
			local price2 = calc_cost_to_buy(count1, count2, 2)
			if price2 > 0 then
				inv:set_stack("pay2", 1, ItemStack({name = item2, count = price2}))
				inv:set_stack("give2", 1, ItemStack({name = item1, count = 2}))
				inv:set_stack("pay5", 1, ItemStack({name = item1, count = price2}))
				inv:set_stack("give5", 1, ItemStack({name = item2, count = 2}))
			end
			local price3 = calc_cost_to_buy(count1, count2, 3)
			if price3 > 0 then
				inv:set_stack("pay1", 1, ItemStack({name = item2, count = price3}))
				inv:set_stack("give1", 1, ItemStack({name = item1, count = 3}))
				inv:set_stack("pay6", 1, ItemStack({name = item1, count = price3}))
				inv:set_stack("give6", 1, ItemStack({name = item2, count = 3}))
			end
			return
		end

		-- how much does it cost to buy one item1?
		local ask = calc_cost_to_buy(count1, count2, 1)
		if ask > 0 then
			simple_amm.set_ask(meta, ask)
			inv:set_stack("pay3", 1, ItemStack({name = item2, count = ask}))
			inv:set_stack("give3", 1, ItemStack(item1))
			minetest.log("action", spos .. ": cost_of_one_item1_in_item2 (ask): " .. ask .. " " .. item2 .. " for one " .. item1)
		end

		-- how much can you get for spending one item1?
		local bid = calc_quant_for_spend(count1, count2, 1)
		if bid > 0 then
			simple_amm.set_bid(meta, bid)
			inv:set_stack("pay4", 1, ItemStack(item1))
			inv:set_stack("give4", 1, ItemStack({name = item2, count = bid}))
			minetest.log("action", spos .. ": quant_of_item2_for_one_item1 (bid): " .. bid .. " " .. item2 .. " for one " .. item1)
		end

		-- now what about a x2 "bulk buy"?
		local ask2 = calc_cost_to_buy(count1, count2, 2)
		if ask2 > 0 then
			inv:set_stack("pay2", 1, ItemStack({name = item2, count = ask2}))
			inv:set_stack("give2", 1, ItemStack({name = item1, count = 2}))
			-- minetest.log("action", "cost of two item1 in item2: " .. ask2)
		end
		local bid2 = calc_quant_for_spend(count1, count2, 2)
		if bid2 > 0 then
			inv:set_stack("pay5", 1, ItemStack({name = item1, count = 2}))
			inv:set_stack("give5", 1, ItemStack({name = item2, count = bid2}))
			-- minetest.log("action", "quant of item2 for two item1: " .. bid2)
		end

		-- what about x3 ?
		local ask3 = calc_cost_to_buy(count1, count2, 3)
		if ask3 > 0 then
			inv:set_stack("pay1", 1, ItemStack({name = item2, count = ask3}))
			inv:set_stack("give1", 1, ItemStack({name = item1, count = 3}))
			-- minetest.log("action", "cost of three item1 in item2: " .. ask3)
		end
		local bid3 = calc_quant_for_spend(count1, count2, 3)
		if bid3 > 0 then
			inv:set_stack("pay6", 1, ItemStack({name = item1, count = 3}))
			inv:set_stack("give6", 1, ItemStack({name = item2, count = bid3}))
			-- minetest.log("action", "quant of item2 for three item1: " .. bid3)
		end
	end
end
