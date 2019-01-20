ES={}


VAR.objets_joueur={ceinture_geant="brinx",bottes_celerite=0,ring_haste="vranken",shield_myrom="drumar"}
wesnoth.set_variable("heros_joueur","brinx,vranken,drumar")

-- local br = wesnoth.get_unit("brinx")
-- br.variables.status_shielded_hp = 15
-- br.status.shielded = true

function ES.kill()
end
function ES.atk()
   
end

-- Put all units in their recall lists, except Morgane, and the Otchigins
-- Apply a custom l_imbe_recall status to be able to recall them afterwards
function _units_to_recall()
    for u in wesnoth.get_units() do
        if not (u.id == "morgane" or u.type == "otchigin1"
                or u.type == "otchigin2" or u.type == "otchigin3") then
            u.status._limbe_recall = true
            u:to_recall()
        end
    end
end


function test()
    -- ES.dump_amla()

end

local function _table_to_string(tab) 
    local s,v_s = "", ""
    for i,v in pairs(tab) do
        if not (type(i) == "number") then        
            if type(v) == "number" or type(v) == "boolean" then
                v_s = tostring(v)
            else
                v_s = '"' .. v .. '"'
            end
            if i == "description" then
                v_s = "_ " .. v_s
            end
            s = s .. i .. " = " .. v_s .. ",\n"
        end
    end
    for i,v in ipairs(tab) do
        tag = v[1]
        s= s .. "T." .. tag .. " { \n"
        s = s .. _table_to_string(v[2])
        s = s .. "}, \n"
    end
    return s
end

function ES.dump_amla()
    local types = {"amla_vranken", "amla_brinx", "amla_drumar", "amla_xavier"}  
    local s = ""
    for i,t in pairs(types) do
        local u = wesnoth.create_unit {type = t}
        s = s .. "\n \n" .. t .. " = { \n"
        for adv in H.child_range(u.__cfg, "advancement") do
            s = s .. "\n { \n " .. _table_to_string(adv) .. "\n },"
        end
        s = s .. "\n } \n"
    end 
    wesnoth.message(s)
end


local s = wesnoth.theme_items.edit_left_button_function
function wesnoth.theme_items.edit_left_button_function()
    local r = s()
    wesnoth.message(wesnoth.debug(r))
    return r
end
--     wesnoth.add_modification(u,"object",{{"effect",{apply_to="attack",{"set_specials", { {"isHere",{id="slow_zone",name="test"} }  }}  }}},false)
