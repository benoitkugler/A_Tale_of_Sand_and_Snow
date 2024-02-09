ANIM = {}

local HOVER_IMAGE = "terrain/hover_hex.png"

-- Highlight zaap/arch position
---@param x integer
---@param y integer
---@param direc 'd' | 'r'
function ANIM.anim_zaap(x, y, direc)
    wesnoth.interface.scroll_to_hex(x, y)
    if direc == "d" then
        for i = 5, 18 do
            wesnoth.interface.delay(70)
            wesnoth.interface.remove_item(x, y)
            wesnoth.interface.add_item_halo(x, y,
                "terrain/animation/zaap-red-droite/bg-" .. i .. ".png~CROP(0,38,181,213)")
        end
    end
    wesnoth.interface.remove_item(x, y)
    --items.place_halo(20,17, "terrain/animation/zaap-red-droite/disable.png~CROP(0,38,181,213)")
end

function ANIM.clear_overlays()
    for x, y in wesnoth.current.map:iter() do
        wesnoth.interface.remove_hex_overlay(x, y)
    end
    wml.fire("redraw")
end

-- Animate given tiles
---@param tiles location[]
---@param label string
---@param tiles2 location[]?
---@param label2 string?
---@param color2 string?
function ANIM.hover_tiles(tiles, label, tiles2, label2, color2)
    tiles2 = tiles2 or {}
    label2 = label2 or ""
    color2 = color2 or ""
    for __, v in ipairs(tiles) do
        wesnoth.interface.float_label(v[1], v[2], Fmt(_ "<span size='smaller'>%s</span>", label))
    end
    for __, v in ipairs(tiles2) do
        wesnoth.interface.float_label(v[1], v[2], Fmt(_ "<span size='smaller' color='%s'>%s</span>", color2, label2))
    end

    for __, v in ipairs(tiles) do
        wesnoth.interface.add_hex_overlay(v[1], v[2], { image = HOVER_IMAGE .. Fmt("~O(%d%%)", 40) })
    end
    for __, v in ipairs(tiles2) do
        wesnoth.interface.add_hex_overlay(v[1], v[2],
            { image = HOVER_IMAGE .. Fmt("~O(%d%%)~BLEND(%d,0,0,1)", 40, 50) })
    end
    wml.fire("redraw")
end

-- Thunder effect (from macro in interface-utils.cfg)
function ANIM.thunder()
    local function color_adjust(r, g, b)
        wml.fire("color_adjust", { red = r, green = g, blue = b })
    end
    color_adjust(67, 67, 67)
    color_adjust(100, 100, 100)
    color_adjust(33, 33, 33)
    color_adjust(0, 0, 0)
end

-- Quake effect (from macro in interface-utils.cfg)
function ANIM.quake()
    local function scroll(x, y) wml.fire("scroll", { x = x, y = y }) end
    scroll(5, 0)
    scroll(-10, 0)
    scroll(5, 5)
    scroll(0, -10)
    scroll(0, 5)
end

-- Transposition
---@param id_source string
---@param id_target string
---@param is_first_pass boolean
function ANIM.transposition(id_source, id_target, is_first_pass)
    local flag = is_first_pass and "transposition_in" or "transposition_out"
    wml.fire(
        "animate_unit",
        {
            flag = flag,
            T.filter { id = id_source },
            T.animate { flag = flag, T.filter { id = id_target } }
        }
    )
end
