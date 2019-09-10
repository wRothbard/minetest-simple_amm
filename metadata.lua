smartshop.meta = {}

local function get_meta(pos_or_meta)
    if type(pos_or_meta) == "userdata" then
        return pos_or_meta
    elseif type(pos_or_meta) == "table" and pos_or_meta.x and pos_or_meta.y and pos_or_meta.z then
        return minetest.get_meta(pos_or_meta)
    end
end

function smartshop.meta.is_creative(pos_or_meta)
    local meta = get_meta(pos_or_meta)
    return meta:get_int("creative") == 1
end

function smartshop.meta.set_creative(pos_or_meta, value)
    local meta = get_meta(pos_or_meta)
    meta:set_int("creative", value and 1 or 0)
end

function smartshop.meta.is_unlimited(pos_or_meta)
    local meta = get_meta(pos_or_meta)
    return meta:get_int("unlimited") == 1
end

function smartshop.meta.set_unlimited(pos_or_meta, value)
    local meta = get_meta(pos_or_meta)
    meta:set_int("unlimited", value and 1 or 0)
end

function smartshop.meta.get_owner(pos_or_meta)
    local meta = get_meta(pos_or_meta)
    return meta:get_string("owner")
end

function smartshop.meta.set_owner(pos_or_meta, value)
    local meta = get_meta(pos_or_meta)
    meta:set_string("owner", value)
end

function smartshop.meta.get_infotext(pos_or_meta)
    local meta = get_meta(pos_or_meta)
    return meta:get_string("infotext")
end

function smartshop.meta.set_infotext(pos_or_meta, value, ...)
    local meta = get_meta(pos_or_meta)
    value = value:format(...)
    return meta:set_string("infotext", value)
end

function smartshop.meta.get_send_spos(pos_or_meta)
    local meta = get_meta(pos_or_meta)
    return meta:get_string("item_send")
end

function smartshop.meta.set_send_spos(pos_or_meta, value, ...)
    local meta = get_meta(pos_or_meta)
    value = value:format(...)
    return meta:set_string("item_send", value)
end

function smartshop.meta.get_refill_spos(pos_or_meta)
    local meta = get_meta(pos_or_meta)
    return meta:get_string("item_refill")
end

function smartshop.meta.set_refill_spos(pos_or_meta, value, ...)
    local meta = get_meta(pos_or_meta)
    value = value:format(...)
    return meta:set_string("item_refill", value)
end

function smartshop.meta.get_title(pos_or_meta)
    local meta = get_meta(pos_or_meta)
    return meta:get_string("title")
end

function smartshop.meta.set_title(pos_or_meta, value, ...)
    local meta = get_meta(pos_or_meta)
    value = value:format(...)
    return meta:set_string("title", value)
end

function smartshop.meta.get_mesein(pos_or_meta)
    local meta = get_meta(pos_or_meta)
    return meta:get_int("mesein")
end

function smartshop.meta.set_mesein(pos_or_meta, value)
    local meta = get_meta(pos_or_meta)
    return meta:set_int("mesein", value)
end

function smartshop.meta.get_inventory(pos_or_meta)
    local meta = get_meta(pos_or_meta)
    return meta:get_inventory()
end

function smartshop.meta.set_state(pos_or_meta, value)
    local meta = get_meta(pos_or_meta)
    meta:set_int("state", value)
end

function smartshop.meta.get_send_to_lurkcoin(pos_or_meta)
    local meta = get_meta(pos_or_meta)
    return meta:get_int("send_to_lurkcoin") == 1
end

function smartshop.meta.set_send_to_lurkcoin(pos_or_meta, value)
    local meta = get_meta(pos_or_meta)
    meta:set_int("send_to_lurkcoin", value and 1 or 0)
end

function smartshop.meta.get_refill_from_lurkcoin(pos_or_meta)
    local meta = get_meta(pos_or_meta)
    return meta:get_int("refill_from_lurkcoin") == 1
end

function smartshop.meta.set_refill_from_lurkcoin(pos_or_meta, value)
    local meta = get_meta(pos_or_meta)
    meta:set_int("refill_from_lurkcoin", value and 1 or 0)
end
