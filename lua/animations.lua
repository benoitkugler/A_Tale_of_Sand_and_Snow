ANIM = {}

-- Highlight zaap/arch position
function ANIM.anim_zaap(x,y,direc)
	local items=wesnoth.require "lua/wml/items.lua"
	wesnoth.scroll_to_tile(x,y)
	if direc == "d" then
		for i =5,19 do 
		wesnoth.delay(70)
			items.remove(x,y)
			items.place_halo(x,y, "terrain/animation/zaap-red-droite/bg-"..i..".png~CROP(0,38,181,213)")
		end	
	end
		items.remove(x,y)
	--items.place_halo(20,17, "terrain/animation/zaap-red-droite/disable.png~CROP(0,38,181,213)")
end