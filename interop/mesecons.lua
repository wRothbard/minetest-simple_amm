if simple_amm.settings.has_mesecon then
    function simple_amm.send_mesecon(pos)
        mesecon.receptor_on(pos)
        minetest.get_node_timer(pos):start(1)
    end

    if mesecon.register_mvps_stopper then
        mesecon.register_mvps_stopper("simple_amm:amm")
        mesecon.register_mvps_stopper("simple_amm:amm_full")
        mesecon.register_mvps_stopper("simple_amm:amm_empty")
        mesecon.register_mvps_stopper("simple_amm:amm_used")
        mesecon.register_mvps_stopper("simple_amm:amm_admin")
        mesecon.register_mvps_stopper("simple_amm:wifistorage")
    end
else
    function simple_amm.send_mesecon() end
end

