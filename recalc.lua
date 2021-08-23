local fee_decimal = simple_amm.settings.fee_percent / 100

simple_amm.recalc = function(pos)
	local meta = minetest.get_meta(pos)
	simple_amm.set_item1(meta, "")
	simple_amm.set_item2(meta, "")
	local inv = meta:get_inventory()
	inv:set_stack("pay1", 1, ItemStack(""))
	inv:set_stack("give1", 1, ItemStack(""))
	inv:set_stack("pay2", 1, ItemStack(""))
	inv:set_stack("give2", 1, ItemStack(""))
	inv:set_stack("pay3", 1, ItemStack(""))
	inv:set_stack("give3", 1, ItemStack(""))
	inv:set_stack("pay4", 1, ItemStack(""))
	inv:set_stack("give4", 1, ItemStack(""))
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
		simple_amm.set_item1(meta, item1)
		simple_amm.set_item2(meta, item2)
		-- minetest.log("action", "item1 " .. item1 .. " " .. count1)
		-- minetest.log("action", "item2 " .. item2 .. " " .. count2)
		local liquidity = count1 * count2

		local allow_buy_one_item1 = true
		local allow_buy_one_item2 = true

		-- if there's much more of one item than another, then the buy one item looks crazy compared
		-- to the other prices, so don't compute or display it
		if count1 > 1.5 * count2 then
			allow_buy_one_item1 = false
		end
		if count2 > 1.5 * count1 then
			allow_buy_one_item2 = false
		end

		-- how much does it cost to buy one of each item?
		if count1 - 1 > 0 and allow_buy_one_item1 then
			local cost_of_one_item1_in_item2 = math.ceil(((liquidity / (count1 - 1)) - count2) * (1 + fee_decimal))
			inv:set_stack("pay1", 1, ItemStack({name = item2, count = cost_of_one_item1_in_item2}))
			inv:set_stack("give1", 1, ItemStack(item1))
			-- minetest.log("action", "cost_of_one_item1_in_item2: " .. cost_of_one_item1_in_item2)
		end
		if count2 - 1 > 0 and allow_buy_one_item2 then
			local cost_of_one_item2_in_item1 = math.ceil(((liquidity / (count2 - 1)) - count1) * (1 + fee_decimal))
			inv:set_stack("pay2", 1, ItemStack({name = item1, count = cost_of_one_item2_in_item1}))
			inv:set_stack("give2", 1, ItemStack(item2))
			-- minetest.log("action", "cost_of_one_item2_in_item1: " .. cost_of_one_item2_in_item1)
		end

		-- how much can you get for spending one of each item?
		local quant_of_item1_for_one_item2 = math.floor(count1 - (liquidity / (count2 + (1 - fee_decimal))))
		if quant_of_item1_for_one_item2 > 0 then
			inv:set_stack("pay3", 1, ItemStack(item2))
			inv:set_stack("give3", 1, ItemStack({name = item1, count = quant_of_item1_for_one_item2}))
			-- minetest.log("action", "quant_of_item1_for_one_item2: " .. quant_of_item1_for_one_item2)
		end
		local quant_of_item2_for_one_item1 = math.floor(count2 - (liquidity / (count1 + (1 - fee_decimal))))
		if quant_of_item2_for_one_item1 > 0 then
			inv:set_stack("pay4", 1, ItemStack(item1))
			inv:set_stack("give4", 1, ItemStack({name = item2, count = quant_of_item2_for_one_item1}))
			-- minetest.log("action", "quant_of_item2_for_one_item1: " .. quant_of_item2_for_one_item1)
		end
	end
end
