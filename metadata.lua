local function get_meta(pos_or_meta)
    if type(pos_or_meta) == "userdata" then
        return pos_or_meta
    else
        return minetest.get_meta(pos_or_meta)
    end
end

function simple_amm.is_admin(pos_or_meta)
    local meta = get_meta(pos_or_meta)
    return meta:get_int("creative") == 1
end

function simple_amm.set_admin(pos_or_meta, value)
    local meta = get_meta(pos_or_meta)
    meta:set_int("creative", value and 1 or 0)
end

function simple_amm.is_unlimited(pos_or_meta)
    return 0
end

function simple_amm.set_unlimited(pos_or_meta, value)
end

function simple_amm.get_owner(pos_or_meta)
    local meta = get_meta(pos_or_meta)
    return meta:get_string("owner")
end

function simple_amm.set_owner(pos_or_meta, value)
    local meta = get_meta(pos_or_meta)
    meta:set_string("owner", value)
end

function simple_amm.get_infotext(pos_or_meta)
    local meta = get_meta(pos_or_meta)
    return meta:get_string("infotext")
end

function simple_amm.set_infotext(pos_or_meta, value, ...)
    local meta = get_meta(pos_or_meta)
    value = value:format(...)
    return meta:set_string("infotext", value)
end

function simple_amm.get_send_spos(pos_or_meta)
    local meta = get_meta(pos_or_meta)
    return meta:get_string("item_send")
end

function simple_amm.set_send_spos(pos_or_meta, value, ...)
    local meta = get_meta(pos_or_meta)
    value = value:format(...)
    return meta:set_string("item_send", value)
end

function simple_amm.get_refill_spos(pos_or_meta)
    local meta = get_meta(pos_or_meta)
    return meta:get_string("item_refill")
end

function simple_amm.set_refill_spos(pos_or_meta, value, ...)
    local meta = get_meta(pos_or_meta)
    value = value:format(...)
    return meta:set_string("item_refill", value)
end

function simple_amm.get_title(pos_or_meta)
    local meta = get_meta(pos_or_meta)
    return meta:get_string("title")
end

function simple_amm.set_title(pos_or_meta, value, ...)
    local meta = get_meta(pos_or_meta)
    value = value:format(...)
    return meta:set_string("title", value)
end

function simple_amm.get_mesein(pos_or_meta)
    local meta = get_meta(pos_or_meta)
    return meta:get_int("mesein")
end

function simple_amm.set_mesein(pos_or_meta, value)
    local meta = get_meta(pos_or_meta)
    return meta:set_int("mesein", value)
end

function simple_amm.get_inventory(pos_or_meta)
    local meta = get_meta(pos_or_meta)
    return meta:get_inventory()
end

function simple_amm.set_state(pos_or_meta, value)
    local meta = get_meta(pos_or_meta)
    meta:set_int("state", value)
end

function simple_amm.has_upgraded(pos_or_meta)
    local meta = get_meta(pos_or_meta)
    return meta:get("upgraded")
end

function simple_amm.set_upgraded(pos_or_meta)
    local meta = get_meta(pos_or_meta)
    return meta:set_string("upgraded", "true")
end

-- when upgrading, sometimes we can't refund the player if their shop is full
-- so, keep track of it
function simple_amm.set_refund(pos_or_meta, refund)
    local meta = get_meta(pos_or_meta)
    meta:set_string("refund", minetest.write_json(refund))
end

function simple_amm.remove_refund(pos_or_meta)
    local meta = get_meta(pos_or_meta)
    meta:set_string("refund", "")
end

function simple_amm.get_refund(pos_or_meta)
    local meta = get_meta(pos_or_meta)
    local refund = meta:get_string("refund")
    if refund == "" then
        return {}
    else
        return minetest.parse_json(refund)
    end
end
