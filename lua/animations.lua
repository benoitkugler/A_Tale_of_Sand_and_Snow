ANIM = {}

local HOVER_IMAGE = "terrain/hover_hex.png"

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

-- Animate given tiles
function ANIM.hover_tiles(tiles, label)
	for __, v in ipairs(tiles) do
        wesnoth.float_label(v[1], v[2], fmt(_ "<span size='smaller'>%s</span>", label))
    end
    for j = 100, 0, -5 do
        for __, v in ipairs(tiles) do
            wesnoth.add_tile_overlay(v[1], v[2], {image = HOVER_IMAGE .. fmt("~O(%d%%)", j)})
        end
        wesnoth.fire("redraw")
        wesnoth.delay(5)
        for __, v in ipairs(tiles) do
            wesnoth.remove_tile_overlay(v[1], v[2])
        end
	end
end