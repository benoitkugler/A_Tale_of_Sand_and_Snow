-- Track special experience gains
-- Actual modiciation should be oneliner, annotated with a -- comment


 


EXP = {}


local exp_functions = {
    sword_spirit={},
    brinx={},
    drumar={},
    rymor={},
    bunshop={},
    global={}
}
  
function exp_functions.global.combat(atk,def)
    local rymor = wesnoth.get_unit("rymor")
    local is_next = false
    for x,y in H.adjacent_tiles(def.x,def.y) do  
        local u  = wesnoth.get_unit(x,y) -- neighbour of defender
        is_next = is_next or (u and u.id == "rymor") -- is rymor next to the defender ?
    end
    if is_next and not wesnoth.is_enemy(def.side,rymor.side) then  -- defender is ally and next to rymor
        rymor.variables.xp = rymor.variables.xp + (atk.__cfg.level + 2) -- def next to rymor
    end
end
    
function exp_functions.bunshop.combat(atk,def)
    if atk.id == "bunshop"  then
--       Used by event kill : is oneshot ?
        bunshop_atk_unit_full = (def.hitpoints == def.max_hitpoints)

        local c=case_derriere(atk.x,atk.y,def.x,def.y)
        if wesnoth.eval_conditional {{ "have_unit", { x=c[1],y=c[2] ,{ "fiter_side", { {"allied_with",{side=atk.side}} }}}}} then
            atk.variables.xp = atk.variables.xp +(def.__cfg.level + 1)*2 --backstab attack
        end
    end
end

function exp_functions.bunshop.kill(kil,dyi)
    if kil.id == "bunshop"  then
        if bunshop_atk_unit_full then
            kil.variables.xp = kil.variables.xp + 3*(dyi.__cfg.level+2) --one shot 
        end
    end
end

function exp_functions.rymor.combat(atk,def)
    if def.id == "rymor"  then
        def.variables.xp = def.variables.xp +(atk.__cfg.level + 1)*2 --defense
    end
end

function exp_functions.sword_spirit.adv(dummy)
    local u = wesnoth.get_units{ id = "vranken"}[1]
    u.variables.xp = u.variables.xp + 60 --sword_spirit lvl up
end
    
function exp_functions.sword_spirit.combat(atk,def)
    if atk.id == "sword_spirit"  then
        local u = wesnoth.get_units{ id = "vranken"}[1]
        u.variables.xp = u.variables.xp + 1 +2*def.__cfg.level  --attaque
    elseif def.id == "sword_spirit"  then
        local u = wesnoth.get_units{ id = "vranken"}[1]
        u.variables.xp = u.variables.xp +atk.__cfg.level + 1 --defense
    end
end

function exp_functions.sword_spirit.kill(kil,dyi)
    if kil.id == "sword_spirit"  then
		local u = wesnoth.get_units{ id = "vranken"}[1]
		u.variables.xp = u.variables.xp + 1+ 3*dyi.__cfg.level--sword_spirit kills
    end
end


function exp_functions.brinx.combat(atk,def)
    if atk.race == "muspell" and def.id == "brinx" then
        def.variables.xp = def.variables.xp + atk.__cfg.level + 1 --defense contre muspell
    elseif def.race == "muspell" and atk.id == "brinx" then
        atk.variables.xp = atk.variables.xp + def.__cfg.level*3 --attaque contre muspell
    end
end

function exp_functions.brinx.kill(kil,dyi)
    if kil.id == "brinx" and dyi.race == "muspell" then
        kil.variables.xp = kil.variables.xp + 1+ dyi.__cfg.level*5 --brinx kills muspell
	end
end

function exp_functions.drumar.combat(atk,def)
    if def.id == "drumar" then
        local weapon = H.get_child(wesnoth.current.event_context,"second_weapon")
        if weapon.type == "cold" then
            def.variables.xp = def.variables.xp + atk.__cfg.level + 1 --defense cold
        end
        if H.get_child(weapon,"specials") ~= nil and H.get_child(H.get_child(weapon,"specials"),"slow") ~= nil then
            def.variables.xp = def.variables.xp + arrondi((atk.__cfg.level+ 1)*1.45) --defense slow
        end
    elseif atk.id == "drumar" then
        local weapon = H.get_child(wesnoth.current.event_context,"weapon")
        if weapon.type == "cold" then
            atk.variables.xp = atk.variables.xp +( def.__cfg.level + 2)*1--attaque cold
        end
        if H.get_child(weapon,"specials") ~= nil and H.get_child(H.get_child(weapon,"specials"),"slow") ~= nil then
            atk.variables.xp = atk.variables.xp + arrondi((def.__cfg.level + 1)*1.5)  --attaque slow
        end
        if H.get_child(weapon,"specials") ~= nil and H.get_child(H.get_child(weapon,"specials"),"isHere","snare") ~= nil then
            atk.variables.xp = atk.variables.xp + arrondi((def.__cfg.level + 1)*2) --attaque snare
        end
        if weapon.name=="chilling touch" then
            atk.variables.xp = atk.variables.xp + arrondi((def.__cfg.level+ 1)*2.4) --attaque chilling touch
        end
    end
end




-- Default values for combat, kill , advance events
-- for caracters not here
setmetatable(exp_functions,{
    __index= function (t,k) 
            return {
                combat=function(a,b) end,
                kill=function(a) end,
                adv=function(a,b) end
            } 
        end}
    )

-- Default values of function for incomplete characters
function dummy(...)
end

for carc,rep_func in pairs(exp_functions) do
    setmetatable(rep_func,{
        __index= function(t,k)
            return dummy
        end})
end

-- Top level

function EXP.adv()
    local unit = get_pri()
    exp_functions[unit.id].adv(unit)
end

function EXP.atk()
    local atker = get_pri()
	local defer = get_snd()
	exp_functions[atker.id].combat(atker,defer)
	exp_functions[defer.id].combat(atker,defer)
    exp_functions.global.combat(atker,defer)
end

function EXP.kill()
	local dying = get_pri()
	local killer = get_snd()
	exp_functions[dying.id].kill(killer,dying)
	exp_functions[killer.id].kill(killer,dying)
end
