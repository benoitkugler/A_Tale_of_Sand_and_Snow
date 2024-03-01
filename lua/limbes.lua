---Implements the special dimension called Limbes and the related Otchigin sorcerers
Limbes = {}

local LIMBE_FLOOR = "Yli"
local LIMBE_WALL = "Wli"
local LIMBE_WIDTH = 10
local LIMBE_HEIGHT = 10

---@class terrain_save : location
---@field terrain string

---@return integer, integer, integer, integer, integer, integer, integer
local function limbes_geoms()
    local m = wesnoth.current.map
    local width, height, border = m.playable_width, m.playable_height, m.border_size
    local xstart = (width - LIMBE_WIDTH) // 2
    if xstart % 2 == 0 then xstart = xstart + 1 end -- wall better looking
    local xstop = (width + LIMBE_WIDTH) // 2
    local ystart = (height - LIMBE_HEIGHT) // 2
    local ystop = (height + LIMBE_HEIGHT) // 2
    return width, height, border, xstart, ystart, xstop, ystop
end

---@param u unit
local function is_limbe_actor(u)
    return u.id == "morgane" or u.id == "drumar" or u.id == "bunshop" or u.role == "otchigin"
end

---remove melee attacks
---@param unit unit
local function enter_update_unit(unit)
    unit.status._limbe = true
    unit.canrecruit = true

    unit:add_modification('trait', {
        id = "_limbe_weakness",
        name = _ "Limbe weakness",
        description = _ "Walking the limbes affects everyone: melee and physical attacks are disabled; \z
        fire and cold spells are less efficient.",
        T.effect {
            apply_to = "remove_attacks",
            range = "melee",
            { "or", { type = 'blade,pierce,impact' } }
        },
        T.effect {
            apply_to = "attack",
            type = 'fire,cold',
            increase_damage = "-50%",
        }
    })

    if unit.role == "otchigin" then
        unit.alignment = "neutral"
    end
end

---@param unit unit
local function close_update_unit(unit)
    unit.status._limbe = nil
    unit.canrecruit = false
    unit:remove_modifications({ id = "_limbe_weakness" }, 'trait')
    if unit.role == "otchigin" then
        unit.alignment = "chaotic"
    end
end

-- Put all units in their recall lists, except the limbe actors
-- Apply a custom '_limbe_recall' status to be able to recall them afterwards
-- Store the location, which will be erased on save/load otherwise.
local function enter_limbe_units()
    local _, _, _, xstart, ystart, xstop, ystop = limbes_geoms()
    xstart = xstart + 2
    ystart = ystart + 2
    xstop = xstop - 2
    ystop = ystop - 2
    for __, u in pairs(wesnoth.units.find_on_map({})) do
        u:custom_variables().x = u.x
        u:custom_variables().y = u.y
        if is_limbe_actor(u) then
            enter_update_unit(u)

            if wesnoth.sides.is_enemy(u.side, 1) then
                u.x, u.y = wesnoth.paths.find_vacant_hex(xstart, ystart, u)
            else
                u.x, u.y = wesnoth.paths.find_vacant_hex(xstop, ystop, u)
            end
        else
            u.status._limbe_recall = true
            u:to_recall()
        end
    end
end

local function close_limbe_units()
    for __, u in pairs(wesnoth.units.find_on_map({})) do
        -- restore original positions
        u.x = u:custom_variables().x
        u.y = u:custom_variables().y

        close_update_unit(u)
    end
    for __, u in pairs(wesnoth.units.find_on_recall { status = "_limbe_recall" }) do
        local x, y = u:custom_variables().x, u:custom_variables().y
        u:to_map(x, y)
    end
end

---@alias compressed_terrains string


---shift x, y by one to handle 0 coordinates
---@param terrains terrain_save[]
---@return compressed_terrains
local function compress_terrain(terrains)
    ---@type string[][]
    local matrix = {}
    for __, hex in ipairs(terrains) do
        local l = matrix[hex.x + 1] or {}
        l[hex.y + 1] = hex.terrain
        matrix[hex.x + 1] = l
    end
    local rows = {}
    for __, row in ipairs(matrix) do
        table.insert(rows, stringx.join(row, ","))
    end
    return stringx.join(rows, ";")
end

---@param terrains compressed_terrains
local function decompress_terrain(terrains)
    local out = {} ---@type terrain_save[]
    for x, row in ipairs(terrains:split(";")) do
        for y, terrain in ipairs(row:split(",")) do
            table.insert(out, { x = x - 1, y = y - 1, terrain = terrain })
        end
    end
    return out
end


-- Saves the current terrain information in variable array LIMBE_TERRAIN_VARIABLE
-- and apply limbe terrain
local function enter_limbe_terrain()
    local map = wesnoth.current.map;
    local width, height, border, xstart, ystart, xstop, ystop = limbes_geoms()

    ---@type terrain_save[]
    local current_terrains = {}

    for x = 0, width + border do
        for y = 0, height + border do
            ---@type string
            local new_terrain
            if (y == ystart and (x == xstart or x == xstop)) then
                new_terrain = LIMBE_FLOOR
            elseif ((x == xstart or x == xstop) and (ystart <= y and y <= ystop)) or
                ((y == ystart or y == ystop) and (xstart <= x and x <= xstop)) then
                new_terrain = LIMBE_WALL
            else
                new_terrain = LIMBE_FLOOR
            end
            local terrain = map[{ x, y }]
            table.insert(current_terrains, { x = x, y = y, terrain = terrain })
            map[{ x, y }] = new_terrain
        end
    end

    CustomVariables().limbe_terrain = compress_terrain(current_terrains)
end

local function close_limbe_terrain()
    local map = wesnoth.current.map;
    local old_terrain = decompress_terrain(CustomVariables().limbe_terrain)
    for __, v in ipairs(old_terrain) do
        map[{ v.x, v.y }] = v.terrain
    end
    -- cleanup unused variable
    CustomVariables().limbe_terrain = ""
end

local function has_limbe_ennemies()
    for __, u in pairs(wesnoth.units.find_on_map({})) do
        if wesnoth.sides.is_enemy(1, u.side) and is_limbe_actor(u) then return true end
    end
    return false
end


function Limbes.enter()
    if not has_limbe_ennemies() then
        Popup("No ennemies",
            _ "You can't fight in the Limbes since <b>no ennemy</b> is able to follow you...")
        return false
    end
    enter_limbe_terrain()
    enter_limbe_units()
    return true
end

function Limbes.close()
    close_limbe_units()
    close_limbe_terrain()
end

---Create a private unit with type otchigin{rank},
---for the given 'side'
---@param rank 1|2|3
---@param side integer
function Limbes.create_otchigin(rank, side)
    local regen_value = 40 + rank --[[@as integer]] * 20
    local unit = wesnoth.units.create {
        side = side,
        type = "otchigin" .. tostring(rank),
        role = "otchigin",
        --- add the special abilities
        T.abilities {
            T.resistance {
                id = "tengi_res",
                name = _ "Force field",
                description = _ "The power of the Tengi makes Muspell sorcerers very resilient.",
                description_inactive = _ "In the Limbes, everything is different...",
                value = 70 + rank * 6,
                affect_self = true,
                T.filter { { "not", { status = "_limbe" } } },
            },
            T.regenerate {
                id = "tengi_regen",
                name = "Tengi's strengh",
                description = Fmt(_ "The power of the Tengi grants Muspell sorcerers %d regeneration.", regen_value),
                description_inactive = _ "In the Limbes, everything is different...",
                value = regen_value,
                poison = "cured",
                affect_self = true,
                T.filter { { "not", { status = "_limbe" } } },
            },
        },
    }
    return unit
end

---Grants allies the bonus, for each Otchigin not defeated
function Limbes.refresh_otchigin_buff()
    wesnoth.units.remove_trait("_otchigin_buff")

    -- select all otchigins and compute the total bonus
    -- we assume otchigins will always be allied
    local l_otchigins = wesnoth.units.find_on_map { role = "otchigin" }
    local o_count, total_level = 0, 0
    for __, otchigin in ipairs(l_otchigins) do
        -- dying units are still returned by find_on_map
        local valid = otchigin.hitpoints > 0 and not (otchigin.status["_limbe"])
        if valid then
            o_count = o_count + 1
            total_level = total_level + otchigin.level
        end
    end
    if total_level == 0 then return end

    -- With 3 elder othigins, total_level = 18
    local bonus_res = total_level * 3

    local desc = (o_count == 1 and
        Fmt(_ "The power of one Otchingin (level %d) enhances Muspell fighters.", total_level) or
        Fmt(_ "The combined powers of %d Otchingins (total level %d) enhance Muspell fighters.", o_count, total_level))
    desc = desc .. Fmt(_ "\n<span color='light green'>+%d%%</span> defense and resistance", bonus_res)

    local side = l_otchigins[1].side
    -- apply the trait
    local trait = {
        id = "_otchigin_buff",
        name = _ "Tengi's blessing",
        description = desc,
        AddDefenses(bonus_res),
        AddResistances(bonus_res),
        T.effect {
            apply_to = "attack",
            increase_damage = Round(total_level * 0.75),
            increase_attacks = o_count,
        }
    }
    for __, unit in ipairs(wesnoth.units.find_on_map {
        T.filter_side { T.allied_with { side = side } },
        { "not", { role = "otchigin" } },
    }) do
        unit:add_modification('trait', trait)
    end
end
