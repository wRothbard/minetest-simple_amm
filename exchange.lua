function smartshop.player_invs(player)
	local player_name     = player:get_player_name()
	local player_inv      = player:get_inventory()
	local player_inv_copy = smartshop.util.clone_tmp_inventory("smartshop_tmp_player_inv", player_inv, "main")
	local player_invs     = {}
	function player_invs.test_take(payment_stack)
		local payment         = player_inv_copy:remove_item("main", payment_stack)
		local remaining_count = payment_stack:get_count() - payment:get_count()
		if remaining_count == 0 then
			return true
		elseif smartshop.currency.is_currency(payment) then
			local remaining_to_pay = ItemStack(payment_stack:get_name(), remaining_count)
			if smartshop.settings.change_currency then
				local remaining_amount = smartshop.currency.extract_currency(remaining_to_pay, player_inv_copy)
				local remaining_cents  = remaining_amount:to_cents()
				if remaining_cents > 0 then
					return (
						smartshop.settings.enable_lurkcoin and
						lurkcoin.bank.getbal(player_name) * 100 >= remaining_cents
					)
				end
			elseif smartshop.settings.enable_lurkcoin then
				local remaining_amount = smartshop.currency.sum_currency_stack(remaining_to_pay)
				local remaining_cents  = remaining_amount:to_cents()
				return lurkcoin.bank.getbal(player_name) * 100 >= remaining_cents
			end
		end
		return false
	end
	function player_invs.take(payment_stack)
		local payment         = player_inv:remove_item("main", payment_stack)
		local remaining_count = payment_stack:get_count() - payment:get_count()
		if remaining_count == 0 then
			return
		elseif smartshop.currency.is_currency(payment) then
			local remaining_to_pay = ItemStack(payment_stack:get_name(), remaining_count)
			if smartshop.settings.change_currency then
				local remaining_amount = smartshop.currency.extract_currency(remaining_to_pay, player_inv)
				local remaining_cents  = remaining_amount:to_cents()
				if remaining_cents == 0 then
					return
				elseif smartshop.settings.enable_lurkcoin then
					lurkcoin.bank.subtract(player_name, remaining_cents / 100, "paying shop")
					return
				end
			elseif smartshop.settings.enable_lurkcoin then
				local remaining_amount = smartshop.currency.sum_currency_stack(remaining_to_pay)
				local remaining_cents  = remaining_amount:to_cents()
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
	local spos             = minetest.pos_to_string(pos)
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
			return true
		elseif (smartshop.settings.enable_lurkcoin and
				smartshop.currency.is_currency(give_stack) and
				refill_from_lurkcoin) then
			local give_amount = smartshop.currency.sum_currency_stack(give_stack)
			local give_cents  = give_amount:to_cents()
			return lurkcoin.bank.getbal(shop_owner) * 100 >= give_cents
		elseif refill_inv_copy then
			local remainder = refill_inv_copy:remove_item(give_stack)
			if remainder:is_empty() then
				return true
			else
				give_stack = remainder
			end
		end

		local remainder = shop_inv_copy:remove_item(give_stack)
		if remainder:get_count() > 0 then
			if (smartshop.settings.enable_lurkcoin and
				smartshop.currency.is_currency(remainder) and
				refill_from_lurkcoin) then
				local remaining_amount = smartshop.currency.sum_currency_stack(remainder)
				local remaining_cents  = remaining_amount:to_cents()
				return lurkcoin.bank.getbal(shop_owner) * 100 >= remaining_cents
			else
				return false
			end
		else
			return true
		end
	end
	function shop_invs.take(give_stack)
		if is_unlimited then
			return
		elseif (smartshop.settings.enable_lurkcoin and
				smartshop.currency.is_currency(give_stack) and
				refill_from_lurkcoin) then
			local give_amount = smartshop.currency.sum_currency_stack(give_stack)
			local give_cents  = give_amount:to_cents()
			if lurkcoin.bank.getbal(shop_owner) * 100 >= give_cents then
				lurkcoin.bank.subtract(player_name, give_cents / 100, "taking for purchase from shop")
				return
			end
		end

		if refill_inv then
			local remainder = refill_inv:remove_item(give_stack)
			if remainder:is_empty() then
				return
			else
				give_stack = remainder
			end
		end

		local remainder = shop_inv_copy:remove_item(give_stack)
		if remainder:get_count() > 0 then
			if (smartshop.settings.enable_lurkcoin and
				smartshop.currency.is_currency(remainder) and
				refill_from_lurkcoin) then
				local remaining_amount = smartshop.currency.sum_currency_stack(remainder)
				local remaining_cents  = remaining_amount:to_cents()
				return lurkcoin.bank.getbal(shop_owner) * 100 >= remaining_cents
			else
				return false
			end
		else
			return true
		end
	end
	function shop_invs.test_accept(payment_stack) end
	function shop_invs.take(accept) end
	function shop_invs.cleanup()
		smartshop.util.delete_tmp_inventory("smartshop_tmp_shop_inv")
		smartshop.util.delete_tmp_inventory("smartshop_tmp_send_inv")
		smartshop.util.delete_tmp_inventory("smartshop_tmp_refill_inv")
	end
	return shop_invs
end
