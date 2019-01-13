ANIM = {}

local HOVER_IMAGE = "terrain/hover_hex.png"

-- Highlight zaap/arch position
function ANIM.anim_zaap(x, y, direc)
	local items = wesnoth.require "lua/wml/items.lua"
	wesnoth.scroll_to_tile(x, y)
	if direc == "d" then
		for i = 5, 19 do
			wesnoth.delay(70)
			items.remove(x, y)
			items.place_halo(x, y, "terrain/animation/zaap-red-droite/bg-" .. i .. ".png~CROP(0,38,181,213)")
		end
	end
	items.remove(x, y)
	--items.place_halo(20,17, "terrain/animation/zaap-red-droite/disable.png~CROP(0,38,181,213)")
end

-- Animate given tiles
function ANIM.hover_tiles(tiles, label, step, tiles2, label2, red_shift2)
	step = step or 5
	tiles2 = tiles2 or {}
	label2 = label2 or ""
	red_shift2 = red_shift2 or 0
	for __, v in ipairs(tiles) do
		wesnoth.float_label(v[1], v[2], fmt(_ "<span size='smaller'>%s</span>", label))
	end
	for __, v in ipairs(tiles2) do
		wesnoth.float_label(v[1], v[2], fmt(_ "<span size='smaller'>%s</span>", label2))
	end

	for j = 100, 0, -step do
		for __, v in ipairs(tiles) do
			wesnoth.add_tile_overlay(v[1], v[2], {image = HOVER_IMAGE .. fmt("~O(%d%%)", j)})
		end
		for __, v in ipairs(tiles2) do
			wesnoth.add_tile_overlay(v[1], v[2], {image = HOVER_IMAGE .. fmt("~O(%d%%)~BLEND(%d,0,0,1)", j, red_shift2)})
		end
		wesnoth.fire("redraw")
		wesnoth.delay(5)
		for __, v in ipairs(tiles) do
			wesnoth.remove_tile_overlay(v[1], v[2])
		end
		for __, v in ipairs(tiles2) do
			wesnoth.remove_tile_overlay(v[1], v[2])
		end
	end
end


-- Thunder effect (from macro in interface-utils.cfg)
function ANIM.thunder()
	local function color_adjust(r, g, b)
		wesnoth.fire("color_adjust", {red = r, green = g, blue = b})
	end
	color_adjust(67, 67, 67)
	color_adjust(100, 100, 100)
	color_adjust(33, 33, 33)
	color_adjust(0, 0, 0)
end

-- Quake effect (from macro in interface-utils.cfg)
function ANIM.quake()
	local function scroll(x,y) wesnoth.fire("scroll", {x = x, y = y}) end
	scroll(5,0)
	scroll(-10,0)
	scroll(5,5)
	scroll(0,-10)
	scroll(0,5)
end