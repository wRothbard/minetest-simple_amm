smartshop.log("action", "currency exchange enabled")
smartshop.currency = {}

local known_currency = {
    ["currency:minegeld_cent_5"]=5,
    ["currency:minegeld_cent_10"]=10,
    ["currency:minegeld_cent_25"]=25,
    ["currency:minegeld"]=100,
    ["currency:minegeld_5"]=500,
    ["currency:minegeld_10"]=1000,
    ["currency:minegeld_50"]=5000,
    ["currency:minegeld_100"]=10000,

    -- custom currency on Tunneler's Abyss
    ["currency:cent_1"]=1,
    ["currency:cent_2"]=2,
    ["currency:cent_5"]=5,
    ["currency:cent_10"]=10,
    ["currency:cent_20"]=20,
    ["currency:cent_50"]=50,
    ["currency:buck_1"]=100,
    ["currency:buck_2"]=200,
    ["currency:buck_5"]=500,
    ["currency:buck_10"]=1000,
    ["currency:buck_20"]=2000,
    ["currency:buck_50"]=5000,
    ["currency:buck_100"]=10000,
    ["currency:buck_200"]=20000,
    ["currency:buck_500"]=50000,
    ["currency:buck_1000"]=100000,
}

function smartshop.currency.cents_to_string(cents)
    return ("%s.%02i"):format(math.floor(cents / 100), cents % 100)
end

local available_currency = {}
for name, cents in pairs(known_currency) do
    if minetest.registered_items[name] then
        available_currency[name] = cents
        smartshop.log("action", "available currency: %s=%q", name, smartshop.currency.cents_to_string(cents))
    end
end

function smartshop.currency.is_currency(stack)
    return available_currency[stack:get_name()]
end

function smartshop.currency.sum_currency_stack(stack)
    return (available_currency[stack:get_name()] or 0) * stack:get_count()
end

function smartshop.currency.sum_inv(inv, list_name)
    local size = inv:get_size(list_name)
    local total = 0
    for index = 1, size do
        local stack = inv:get_stack(list_name, index)
        total = total + smartshop.sum_currency_stack(stack)
    end
    return total
end

function smartshop.currency.extract_currency(stack, inv)
    error("NOT IMPLEMENTED")
end
