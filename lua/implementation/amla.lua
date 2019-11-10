AMLA = {}

-- Process an amla tree by computing effect given by a function
local function _process_amlas(amlas_table, unit)
    local computed_table = {}
    for i, amla in ipairs(amlas_table) do
        local computed_amla = {}
        for j, value in pairs(amla) do
            if type(value) == "function" then -- executing function with unit as argument
                computed_amla[j] = value(unit)
            else -- just copy
                computed_amla[j] = value
            end
        end
        computed_table[i] = T.advancement(computed_amla)
    end
    return computed_table
end

-- Add bonus levels based on AMLAs the unit currently has
function AMLA.update_lvl(unit)
    local base_lvl = wesnoth.unit_types[unit.type].level
    for amla in H.child_range(H.get_child(unit.__cfg, "modifications") or {},
                              "advancement") do
        if amla._level_bonus then base_lvl = base_lvl + 1 end
    end
    unit.level = base_lvl
end

function AMLA.adv()
    local u = PrimaryUnit()
    u:remove_modifications({id = "current_amlas"}, "trait")
    AMLA.update_lvl(u)
end

function AMLA.pre_advance()
    local u = PrimaryUnit()
    local table_amlas = DB.AMLAS[u.id] -- loading custom amlas

    if (table_amlas == nil) or #(u.advances_to) > 0 then return end

    table_amlas = _process_amlas(table_amlas, u)
    u:add_modification("trait", {
        id = "current_amlas",
        T.effect{
            apply_to = "new_advancement",
            replace = true,
            table.unpack(table_amlas)
        }
    })
end
