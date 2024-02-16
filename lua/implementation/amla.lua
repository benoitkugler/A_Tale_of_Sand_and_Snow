AMLA = {}

---@param t table<string|integer, any>
local function shallow_copy(t)
    local out = {} ---@type table<string|integer, any>
    for i, v in pairs(t) do
        out[i] = v
    end
    return out
end

-- Process an amla tree by computing effect given by a function
---@param amlas_table hero_amla_tree
---@param unit unit
local function _process_amlas(amlas_table, unit)
    local computed_table = {} ---@type WMLTag[]
    for i, amla in ipairs(amlas_table) do
        local computed_amla = shallow_copy(amla) ---@type custom_amla
        for j, effect in ipairs(computed_amla) do
            if type(effect) == "function" then -- executing function with unit as argument
                computed_amla[j] = effect(unit)
            else                               -- just copy
                computed_amla[j] = effect
            end
        end
        computed_table[i] = T.advancement(computed_amla)
    end
    return computed_table
end

-- Add bonus levels based on AMLAs the unit currently has
---@param unit unit
function AMLA.update_lvl(unit)
    local base_lvl = wesnoth.unit_types[unit.type].level
    for amla in wml.child_range(wml.get_child(unit.__cfg, "modifications") or {},
        "advancement") do
        if amla._level_bonus then base_lvl = base_lvl + 1 end
    end
    unit.level = base_lvl
end

function AMLA.adv()
    local u = PrimaryUnit()
    u:remove_modifications({ id = "current_amlas" }, "trait")
    AMLA.update_lvl(u)
end

function AMLA.pre_advance()
    local u = PrimaryUnit()
    local table_amlas = Conf.amlas[ u.id --[[@as Hero]] ] -- loading custom amlas

    if (not table_amlas) or #(u.advances_to) > 0 then return end

    local processed = _process_amlas(table_amlas, u)
    u:add_modification("trait", {
        id = "current_amlas",
        T.effect {
            apply_to = "new_advancement",
            replace = true,
            table.unpack(processed)
        }
    })
end
