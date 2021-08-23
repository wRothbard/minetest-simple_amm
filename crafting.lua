if minetest.get_modpath("smartshop") then
	minetest.register_craft({
		type = "shapeless",
		output = "simple_amm:amm",
		recipe = { "smartshop:shop "}
	})

	minetest.register_craft({
		type = "shapeless",
		output = "simple_amm:wifistorage",
		recipe = { "smartshop:wifistorage "}
	})

	minetest.register_craft({
		type = "shapeless",
		output = "smartshop:shop",
		recipe = { "simple_amm:amm "}
	})

	minetest.register_craft({
		type = "shapeless",
		output = "smartshop:wifistorage",
		recipe = { "simple_amm:wifistorage "}
	})
else
minetest.register_craft({
	output = "simple_amm:amm",
	recipe = {
		{ "default:chest_locked",   "default:chest_locked", "default:chest_locked" },
		{ "default:sign_wall_wood", "default:chest_locked", "default:sign_wall_wood" },
		{ "default:sign_wall_wood", "default:torch",        "default:sign_wall_wood" },
	}
})

minetest.register_craft({
	output = "simple_amm:wifistorage",
	recipe = {
		{ "default:mese_crystal_fragment", "default:chest_locked", "default:mese_crystal_fragment" },
		{ "default:mese_crystal_fragment", "default:chest_locked", "default:mese_crystal_fragment" },
		{ "default:steel_ingot",           "default:copper_ingot", "default:steel_ingot" },
	}
})
end
