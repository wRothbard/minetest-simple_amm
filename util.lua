simple_amm.util = {}

function simple_amm.util.string_to_pos(spos)
    -- can't just use minetest.string_to_pos, for sake of backward compatibility
    if not spos or type(spos) ~= "string" then
        return nil
    end
    local x, y, z = spos:match("^%s*%(?%s*(%-?%d+)[%s,]+(%-?%d+)[%s,]+(%-?%d+)%s*%)?%s*$")
    if x and y and z then
        return vector.new(tonumber(x), tonumber(y), tonumber(z))
    end
end

simple_amm.util.pos_to_string = minetest.pos_to_string

function simple_amm.util.player_is_admin(player_name)
    return minetest.check_player_privs(player_name, {[simple_amm.settings.admin_shop_priv] = true})
end

function simple_amm.util.can_access(player, pos)
    local player_name = player:get_player_name()

    return (
        simple_amm.get_owner(pos) == player_name or
        minetest.check_player_privs(player_name, { protection_bypass = true })
    )
end

function simple_amm.util.deepcopy(orig, copies)
    -- taken from lua documentation
    copies = copies or {}
    local orig_type = type(orig)
    local copy
    if orig_type == "table" then
        if copies[orig] then
            copy = copies[orig]
        else
            copy = {}
            for orig_key, orig_value in next, orig, nil do
                copy[simple_amm.util.deepcopy(orig_key, copies)] = simple_amm.util.deepcopy(orig_value, copies)
            end
            copies[orig] = copy
            setmetatable(copy, simple_amm.util.deepcopy(getmetatable(orig), copies))
        end
    else -- number, string, boolean, etc
        copy = orig
    end
    return copy
end

function simple_amm.util.table_invert(t)
    local inverted = {}
    for k,v in pairs(t) do inverted[v] = k end
    return inverted
end

function simple_amm.util.table_reversed(t)
    local len = #t
    local reversed = {}
    for i = len,1,-1 do
        reversed[len - i + 1] = t[i]
    end
    return reversed
end

function simple_amm.util.table_contains(t, value)
    for _, v in ipairs(t) do
        if v == value then return true end
    end
    return false
end

function simple_amm.util.table_is_empty(t)
    for _ in pairs(t) do return false end
    return true
end

function simple_amm.util.pairs_by_keys(t, f)
    local a = {}
    for n in pairs(t) do
        table.insert(a, n)
    end
    table.sort(a, f)
    local i = 0
    return function()
        i = i + 1
        if a[i] == nil then
            return nil
        else
            return a[i], t[a[i]]
        end
    end
end

function simple_amm.util.pairs_by_values(t, f)
    if not f then
        f = function(a, b) return a < b end
    end
    local s = {}
    for k, v in pairs(t) do
        table.insert(s, {k, v})
    end
    table.sort(s, function(a, b)
        return f(a[2], b[2])
    end)
    local i = 0
    return function()
        i = i + 1
        local v = s[i]
        if v then
            return unpack(v)
        else
            return nil
        end
    end
end

function simple_amm.util.round(x)
    -- approved by kahan
    if x % 2 ~= 0.5 then
        return math.floor(x+0.5)
    else
        return x - 0.5
    end
end

function simple_amm.util.clone_tmp_inventory(inv_name, src_inv, src_list_name)
    local tmp_inv = minetest.create_detached_inventory(inv_name, {
        allow_move = function(inv, from_list, from_index, to_list, to_index, count, player) return count end,
        allow_put = function(inv, listname, index, stack, player) return stack:get_size() end,
        allow_take = function(inv, listname, index, stack, player) return stack:get_size() end,
    })

    for name, _ in pairs(src_inv:get_lists()) do
        if not tmp_inv:is_empty(name) or tmp_inv:get_size(name) ~= 0 then
            simple_amm.log("error", "attempt to re-use existing temporary inventory %s", inv_name)
            return
        end
    end

    if src_list_name then
        tmp_inv:set_size(src_list_name, src_inv:get_size(src_list_name))
        tmp_inv:set_list(src_list_name, src_inv:get_list(src_list_name))
    else
        for name, list in pairs(src_inv:get_lists()) do
            tmp_inv:set_size(name, src_inv:get_size(name))
            tmp_inv:set_list(name, list)
        end
    end

    return tmp_inv
end

function simple_amm.util.delete_tmp_inventory(inv_name)
    minetest.remove_detached_inventory(inv_name)
end
