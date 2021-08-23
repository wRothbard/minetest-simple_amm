simple_amm.settings = {}

simple_amm.settings.has_mesecon = minetest.global_exists("mesecon")
simple_amm.settings.has_currency = minetest.get_modpath("currency")

local settings = minetest.settings

simple_amm.settings.max_wifi_distance = tonumber(settings:get("simple_amm.max_wifi_distance")) or 30
simple_amm.settings.wifi_link_time = tonumber(settings:get("simple_amm.wifi_link_time")) or 30
simple_amm.settings.change_currency = settings:get_bool("simple_amm.change_currency", true)
simple_amm.settings.enable_refund = settings:get_bool("simple_amm.enable_refund", false)

simple_amm.settings.admin_shop_priv = settings:get("simple_amm.admin_shop_priv") or "simple_amm_admin"


minetest.register_privilege(simple_amm.settings.admin_shop_priv, {
    description = "A privilege used to make simple_amms unlimited"
})
