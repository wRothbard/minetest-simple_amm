local function toggle_mesein(meta)
    local mesein = simple_amm.get_mesein(meta)
    if mesein <= 2 then
        mesein = mesein + 1
    else
        mesein = 0
    end
    simple_amm.set_mesein(meta, mesein)
end


function simple_amm.wifi_receive_fields(player, pressed)
    local player_name = player:get_player_name()
    local pos         = simple_amm.player_pos[player_name]
    if not pos then return end
    local meta = minetest.get_meta(pos)

    if pressed.mesesin then
        toggle_mesein(meta)
        simple_amm.wifi_showform(pos, player)
    elseif pressed.save then
        local title = pressed.title
        if not title or title == "" then
            title = "wifi " .. minetest.pos_to_string(pos)
        end
        simple_amm.set_title(meta, title)
        local spos = minetest.pos_to_string(pos)
        simple_amm.log("action", "%s set title of wifi storage at %s to %s", player_name, spos, title)
        simple_amm.player_pos[player_name] = nil
    elseif pressed.quit then
        simple_amm.player_pos[player_name] = nil
    end
end

function simple_amm.wifi_showform(pos, player)
    if not simple_amm.util.can_access(player, pos) then return end
    local meta        = minetest.get_meta(pos)
    local player_name = player:get_player_name()
    local spos        = minetest.pos_to_string(pos)
    local fpos        = pos.x .. "," .. pos.y .. "," .. pos.z
    local title       = simple_amm.get_title(meta)
    if not title or title == "" then
        title = "wifi " .. spos
    end
    title = minetest.formspec_escape(title)

    local gui = "size[12,9]"

    if simple_amm.settings.has_mesecon then
        local mesein = simple_amm.get_mesein(meta)
        if mesein == 0 then
            gui = gui .. "button[0,7;2,1;mesesin;Don't send]"
        elseif mesein == 1 then
            gui = gui .. "button[0,7;2,1;mesesin;Incoming]"
        elseif mesein == 2 then
            gui = gui .. "button[0,7;2,1;mesesin;Outcoming]"
        elseif mesein == 3 then
            gui = gui .. "button[0,7;2,1;mesesin;Both]"
        end
        gui = gui .. "tooltip[mesesin;Send mesecon signal when items from shops does:]"
    end

    gui = gui
       .. "field[0.3,5.3;2,1;title;;" .. title .. "]"
       .. "tooltip[title;Used with connected simple_amms]"
       .. "button_exit[0,6;2,1;save;Save]"
       .. "list[nodemeta:" .. fpos .. ";main;0,0;12,5;]"
       .. "list[current_player;main;2,5;8,4;]"
       .. "listring[nodemeta:" .. fpos .. ";main]"
       .. "listring[current_player;main]"

    local shop_info = simple_amm.add_storage[player_name]
    if shop_info and shop_info.pos then
        local distance = vector.distance(shop_info.pos, pos)
        if distance > simple_amm.settings.max_wifi_distance then
            minetest.chat_send_player(player_name, "Too far, max distance " .. simple_amm.settings.max_wifi_distance)
        end
        local shop_meta = minetest.get_meta(shop_info.pos)
        if shop_info.send then
            simple_amm.set_send_spos(shop_meta, spos)
            minetest.chat_send_player(player_name, "send storage connected")
        elseif shop_info.refill then
            simple_amm.set_refill_spos(shop_meta, spos)
            minetest.chat_send_player(player_name, "refill storage connected")
        else
            simple_amm.log("warning", "weird data received when linking storage: %s", minetest.serialize(shop_info))
        end
        simple_amm.add_storage[player_name] = nil
    end

    simple_amm.player_pos[player_name] = pos
    minetest.after(0, minetest.show_formspec, player_name, "simple_amm.wifi_showform", gui)
end



