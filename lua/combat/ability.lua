local _ = wesnoth.textdomain "wesnoth-A_Tale_of_Sand_and_Snow"


AB = {}

-- Renvoie true si la case x,y est à coté d'un ennemi de unit
local function next_to(unit,x,y) 
	local s = false
	for a,b in H.adjacent_tiles(x,y) do
		if not is_empty(a,b) then
		 	s =  s or wesnoth.is_enemy(wesnoth.get_units{x=a,y=b}[1].side,unit.side)
		end
	end
	return s
end

local location_set = wesnoth.require "lua/location_set.lua"

local function tiles_bloque(unit)
	local pourrait = location_set.of_pairs(wesnoth.find_reach(unit,{ignore_units=true}))
        local peut = location_set.of_pairs(wesnoth.find_reach(unit))
	local bloque = pourrait:filter(function(x,y,v) return (is_empty(x,y) and next_to(unit,x,y) and (peut:get(x,y) == nil)) end)
        return bloque:to_pairs() 
end

local function pourrait(unit)
       local pourrait = location_set.of_pairs(wesnoth.find_reach(unit,{ignore_units=true}))
	local peut = location_set.of_pairs(wesnoth.find_reach(unit))
	pourrait = pourrait:filter(function(x,y,v) return (is_empty(x,y) and (peut:get(x,y) == nil))  end)
	return pourrait:to_pairs()
end


--Appelée sur sélection d'une unité
function AB.select() 
    wesnoth.fire("set_menu_item",{id="movement",T.show_if{{"false",{}}}})
    local u = get_pri()
    if has_ab(u,"war_jump") and u.moves > 0 then
        AB.war_jump(u)
    end
    
    if has_ab(u,"elusive") and u.moves > 0 then
        AB.elusive(u)
   end   
end
    
function AB.war_jump(unit)
    
    local bloque = tiles_bloque(unit)
    
    local listx,listy= "", ""
    for i,v in pairs(bloque) do
        listx= listx..","..v[1]
        listy= listy..","..v[2]
    end
    listx=string.sub(listx,2)
    listy=string.sub(listy,2)
     wesnoth.fire("set_menu_item",{id="movement",description=_"War jump here with "..unit.name.." !",image="menu/war_jump.png",{"show_if",{{"have_location",{x="$x1",y="$y1",{"and",{x=listx,y=listy}} } }}} ,  {"command",{ {"lua",{ code="MI.war_jump(\""..unit.id.."\","..unit.x..","..unit.y..")"}}}}  })
    
    for i,v in pairs(bloque) do
           wesnoth.float_label(v[1],v[2], _"<span size='smaller'>Right-click here</span>")
    end
    for j = 100,0,-5 do
        for i,v in pairs(bloque) do
            wesnoth.add_tile_overlay(v[1],v[2], { image = "terrain/hover_hex.png~O("..j.."%)" })
        end
        wesnoth.fire("redraw")
        wesnoth.delay(5)
        for i,v in pairs(bloque) do
           wesnoth.remove_tile_overlay(v[1],v[2])
        end
    end  
    
end


function AB.elusive(unit)
   
    local  pou = pourrait(unit)
    local listx,listy= "", ""
    for i,v in pairs(pou) do
        listx= listx..","..v[1]
        listy= listy..","..v[2]
    end
    listx=string.sub(listx,2)
      wesnoth.fire("set_menu_item",{id="movement",description=_"Sneak here with "..unit.name.." !",image="menu/elusive.png",{"show_if",{{"have_location",{x="$x1",y="$y1",{"and",{x=listx,y=listy}} } }}} ,  {"command",{ {"lua",{ code="MI.elusive(\""..unit.id.."\","..unit.x..","..unit.y..")"}}}}  })
      
    for i,v in pairs(pou) do
           wesnoth.float_label(v[1],v[2], _"<span size='smaller'>Right-click here</span>")
    end
    for j = 100,0,-5 do
        for i,v in pairs(pou) do
            wesnoth.add_tile_overlay(v[1],v[2], { image = "terrain/hover_hex.png~O("..j.."%)" })
        end
        wesnoth.fire("redraw")
        wesnoth.delay(5)
        for i,v in pairs(pou) do
           wesnoth.remove_tile_overlay(v[1],v[2])
        end
     end
    
end

