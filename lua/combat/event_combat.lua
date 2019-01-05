-- Implementation of special effect during figth.

 

EC={}

--Fonctions d'applications des effets
local endturn = {}
local apply = {}
local noms = {}
setmetatable(apply,{ __newindex= function (t,k,v)  table.insert(noms,k);rawset(t, k, v)end})
   
local label_pri,label_snd="","" -- Labels personnalisés   
local delay = 0

function EC.combat(dmg_dealt)
    delay = 0
    local type_event =  wesnoth.current.event_context.name
    local u1 , u2  = get_pri() ,get_snd() 
    label_pri,label_snd="","" 
    local x1,y1,x2,y2 = u1 and u1.x, u1 and u1.y,u2 and u2.x,u2 and u2.y
    
    for nb,i in ipairs(noms) do
        if u1 and u1.valid and u2 and u2.valid then
            apply[i](type_event,u1,u2,dmg_dealt)
        end
    end
    
    
    if x1 and y1 then 
        if delay > 0 then wesnoth.delay(delay) end
        wesnoth.float_label(x1,y1,label_pri) 
    end 
    if x2 and y2 then 
        if delay > 0 then wesnoth.delay(delay) end
        wesnoth.float_label(x2,y2,label_snd)  
    end
    if delay > 0 then wesnoth.delay(delay) end
end


function EC.fin_tour ()
    lhero = wesnoth.get_units{ role = "hero"}
    for i,v in pairs(lhero) do
        v.variables.bloodlust = false
    end	
    for i,v in pairs(endturn) do
        v()
    end
end

--helper
function _get_special(att, id_special)
    local list_specials = H.get_child(att, "specials") or {}
    for spe in H.child_range(list_specials, "isHere") do
        local name, lvl = spe.id:split("*")
        if name == id_special then
            if lvl == "" then
                return 1
            else
                return tonumber(lvl)
            end
        end
    end
    return false
end

-- ABILITIES GENERIQUES

-- Shield flat 
function apply.shield_flat (event,pri,snd,dmg)
    local s1 ,s2 = pri.level*2 ,snd.level*2 --shields
    if event == "attack" then
        if get_ability(pri,"shield_flat") then
            pri.hitpoints=pri.hitpoints + s1
        end
        if get_ability(snd,"shield_flat") then
            snd.hitpoints=snd.hitpoints + s2
        end
    elseif event == "attacker_hits" then
        if get_ability(snd,"shield_flat") then
            if dmg < s2 then
                snd.hitpoints = snd.hitpoints + dmg
            elseif snd.hitpoints > 0 then
                snd.hitpoints=snd.hitpoints + s2
            end
            label_snd = label_snd.."<span color='#4A4257'>".._" shield : "..s2.." hitpoints".."</span>\n"
        end
    elseif event == "defender_hits" then
        if get_ability(pri,"shield_flat")  then
            if dmg < s1 then
                pri.hitpoints = pri.hitpoints + dmg
            elseif pri.hitpoints > 0 then
                pri.hitpoints=pri.hitpoints + s1
            end
            label_pri = label_pri.."<span color='#4A4257'>".._" shield : "..s1.." hitpoints".."</span>\n"
        end
    elseif event == "attack_end" then
        if get_ability(pri,"shield_flat") then
            pri.hitpoints=pri.hitpoints - s1
        end
        if get_ability(snd,"shield_flat") then
            snd.hitpoints=snd.hitpoints - s2
        end
    end
end


--  War leeches

function apply.war_leeches (event,pri,snd,dmg)
    if event == "attacker_hits" then
        local lvl = get_ability(snd,"war_leeches")
        if lvl then
            wesnoth.fire ("heal_unit" ,{ T.filter {id = snd.id} , animate =true,amount = 2 * lvl}) --def is hit
        end
    end
end


--ABILITY SPECIAL de BRINX
function apply.bloodlust (event,pri,snd,dmg)
    if event == "die" then
        if get_ability(snd,"bloodlust") then
            if snd.variables and not snd.variables.bloodlust then
                snd.variables.bloodlust = true
                snd.moves= 4 --on kill
                snd.attacks_left = 1
            end
        end
    end
end

function apply.fresh_blood_musp (event,pri,snd,dmg)
    if event == "die" then
        local lvl = get_ability(snd,"fresh_blood_musp")
        if not lvl then
            return 
        end 
        if pri.__cfg.race == "muspell" then
            wesnoth.fire("heal_unit",{animate=(snd.hitpoints ~= snd.max_hitpoints), T.filter{id = snd.id},amount = 2 + 6 * lvl}) --on kill
        end
    end
end


--WEAPON SPECIAL

-- Leeches
function apply.leeches (event,pri,snd,dmg)
    local lvl, u
    if event == "attacker_hits" then
        lvl = _get_special(H.get_child(wesnoth.current.event_context,"weapon"),"leeches")
        u = pri
    elseif event == "defender_hits" then
        lvl = _get_special(H.get_child(wesnoth.current.event_context,"second_weapon"),"leeches")
        u = snd 
    end
    if lvl then
        if u.hitpoints < u.max_hitpoints then
            wesnoth.fire ("heal_unit" ,{ T.filter{id = u.id} , animate =true,amount = arrondi( dmg*(0.05+0.05*lvl))}) --toujours
        end
    end	 
end

-- Pierce
function apply.weapon_pierce (event,pri,snd,dmg)
    if event == "attacker_hits" and _get_special(H.get_child(wesnoth.current.event_context,"weapon"),"weapon_pierce") then
        local loc = case_derriere(pri.x,pri.y,snd.x,snd.y)
        local weapon  =H.get_child(wesnoth.current.event_context,"weapon")
        wesnoth.fire ("harm_unit" ,{ T.filter{x = loc[1], y=loc[2] , {"not" ,{side = pri.side}}} ,  annimate=true,fire_event=true,
        damage_type = weapon.type,amount =  arrondi(dmg*0.5)}) --atker hit
    end
end

-- Mayhem
function apply.mayhem (event,pri,snd,dmg)
    if event == "attacker_hits" and _get_special(H.get_child(wesnoth.current.event_context,"weapon"),"mayhem")  then
        wesnoth.add_modification(snd,"object", { T.effect { apply_to = "attack" , increase_damage = -1 }}    ,false  ) --atker hit
    end
end

-- Cleave
function apply.cleave (event,pri,snd,dmg)
    if event == "attacker_hits" and _get_special(H.get_child(wesnoth.current.event_context,"weapon"),"cleave") then
        local l = wesnoth.get_locations{ T.filter_adjacent_location{ x= pri.x , y = pri.y}, T.filter_adjacent_location{ x =snd.x ,y =snd.y }}
        local att = H.get_child(wesnoth.current.event_context,"weapon")
        for i , v in pairs(l) do
            wesnoth.fire ("harm_unit" ,{ T.filter_second {id=pri.id  },experience=true,T.filter{x =v[1], y=v[2] , {"not" ,{side = pri.side}}} , fire_event=true, annimate=true,
            damage_type = att.type,amount =  arrondi( dmg*0.75)}) --atker hit
        end
    end
end


function apply.res_magic (event,pri,snd,dmg)
    if event == "attacker_hits" then
        local lvl = _get_special(H.get_child(wesnoth.current.event_context,"weapon"),"res_magic") 
        if lvl then
            local value = 3 + 2*lvl --atker hit
            wesnoth.add_modification(snd,"object", {  T.effect{ apply_to = "resistance" ,{"resistance",{fire=value,cold=value,arcane=value} }}    } ,false) 
            label_snd=label_snd.. _"<span color='#B95C43'>-"..value.."% magic resistances</span>\n"
        end
    end
end


function apply.weaker_slow (event,pri,snd,dmg)
    if event == "attacker_hits" then
        local lvl = _get_special(H.get_child(wesnoth.current.event_context,"weapon"),"weaker_slow") 
        if lvl then
            local value = 5 + 5*lvl --atker hit
            wesnoth.add_modification(snd,"object", {duration="turn_end", T.effect{ apply_to = "attack" , increase_damage = "-"..value.."%" }  }  ,true ) 
            label_snd=label_snd.. _"<span color='#919191'>-"..value.."% damage</span>\n"
        end
    end
end


function apply.snare (event,pri,snd,dmg)
    if event == "attacker_hits" and _get_special(H.get_child(wesnoth.current.event_context,"weapon"),"snare") then
        wesnoth.add_modification(snd,"object", {duration="turn_end", T.effect { apply_to = "movement" , set=0 }  }  ,true ) 
        label_snd=label_snd.. _"<span color='#1CDC3F'>Snared</span>\n"
    end
end

function apply.slow_zone (event,pri,snd,dmg)
    if event == "attacker_hits" and _get_special(H.get_child(wesnoth.current.event_context,"weapon"),"slow_zone") then
        local targets = wesnoth.get_units{ T.filter_adjacent{id=snd.id,is_enemy=false }}
        for i,v in pairs(targets) do
            if not v.status.slowed then
                v.status.slowed=true
                wesnoth.float_label(v.x,v.y,_"<span color='#00A8A2'>Slowed !</span>")
            end
        end
        
    end
end

-- Utilise le status chilled
function apply.chilled_dmg (event,pri,snd,dmg)
    if event == "attacker_hits" and snd.status.chilled then
        local lvl = case_array(H.get_variable_array("table_status.chilled"),snd.id).lvl 
        
        local att = H.get_child(wesnoth.current.event_context,"weapon")
        local bonus_dmg = arrondi(dmg*(lvl*0.2+0.5)) --on hit
        if att.type == "cold" then
            if snd.hitpoints-bonus_dmg >0 then
                snd.hitpoints=snd.hitpoints-bonus_dmg
                label_snd=label_snd.. "<span color='#1ED9D0'>"..bonus_dmg.."</span>\n"
            else
                label_snd=label_snd.. "<span color='#1ED9D0'>"..snd.hitpoints.."</span>\n"
                
                if snd.level == 0 then 
                    pri.experience=pri.experience+4
                else
                    pri.experience=pri.experience+8*snd.level
                end
                wesnoth.fire("kill" ,{id=snd.id,  {"second_unit", {id=pri.id }},animate=true,fire_event=true})
            end
        end
    end
end

-- Met le status
function apply.put_status_chilled (event,pri,snd,dmg)
    if event == "attacker_hits" and snd then
        local lvl = _get_special(H.get_child(wesnoth.current.event_context,"weapon"),"status_chilled") 
        if lvl and not snd.status.chilled then
            local s = wesnoth.get_variable("table_status.chilled") or {}
            table.insert(s,{id=snd.id,lvl=lvl,cd=2+toInt(lvl>=4)}) --atker hit
            H.set_variable_array("table_status.chilled",s)
            snd.status.chilled=true
            label_snd=label_snd.. _"<span color='#1ED9D0'>Chilled !</span>\n"
        end
    end
end

-- Mise à jour des status chilled
function endturn.status_chilled()
    local l_status = H.get_variable_proxy_array("table_status.chilled") or {}
    for i,v in pairs(l_status) do
        if v.cd == 1 then
            local u = wesnoth.get_units{id=bloc.id}[1]
            if u then u.status.chilled=nil end
            v = nil
        elseif v.cd then
            v.cd= v.cd -1
        end
    end	
end

function apply.shield (event,pri,snd,dmg)
    if event == "attack" then
        if pri.status.shielded then
            local s = case_array(H.get_variable_array("table_status.shielded"),pri.id).value
            pri.hitpoints = pri.hitpoints + s
            label_pri = label_pri.."<span color='#4A4257'> +"..s.._" shield points</span>\n"
        end
        if snd.status.shielded then
             local s = case_array(H.get_variable_array("table_status.shielded"),snd.id).value
            snd.hitpoints = snd.hitpoints + s
            label_snd = label_snd.."<span color='#4A4257'> +"..s.._" shield points</span>\n"
        end
        delay = 50
    end
    if event == "attacker_hits" and snd.status.shielded then
        local c ,i = case_array(H.get_variable_array("table_status.shielded"),snd.id)
        local sh= c.value
        if dmg >= sh then
            VAR.table_status.shielded[i-1] = nil
            snd.status.shielded = nil
        else
            VAR.table_status.shielded[i-1].value = sh - dmg
        end
    end
    if event == "defender_hits" and pri.status.shielded then
        local c,i = case_array(H.get_variable_array("table_status.shielded"),pri.id)
        local sh= c.value
        if dmg >= sh then
            VAR.table_status.shielded[i-1] = nil
            pri.status.shielded = nil
        else
            VAR.table_status.shielded[i-1].value = sh - dmg
        end
    end
    if event == "attack_end" then
        if pri.status.shielded then
            local s = case_array(H.get_variable_array("table_status.shielded"),pri.id).value
            pri.hitpoints = pri.hitpoints - s
        end
        if snd.status.shielded then
             local s = case_array(H.get_variable_array("table_status.shielded"),snd.id).value
            snd.hitpoints = snd.hitpoints - s
        end
    end
end

function endturn.status_shielded ()
    local l_status = wesnoth.get_units{status="shielded"}
    for i,v in ipairs(l_status) do  
        v.status.shielded =nil
    end
    VAR.table_status.shielded = nil
    VAR.table_status.shielded = {}
end




--Tri pour executer les skills dans l'ordre souhaité
table.sort(noms)
