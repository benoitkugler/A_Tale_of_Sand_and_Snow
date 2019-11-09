-- Misc. helpers

-- Format a translatable string
function Fmt(translatable_str, ...)
    return string.format(tostring(translatable_str), ...)
end

--Return string keys
function table.keys(t)
    local s = {}
    for i, v in pairs(t) do
        if type(i) == "string" then
            s[#s + 1] = i
        end
    end
    return s
end

-- round
function Round(f) return math.floor(0.5 + f) end


--Récupére l'unité primaire ou secondaire d'un event
function PrimaryUnit()
    return wesnoth.get_unit(wesnoth.current.event_context.x1, wesnoth.current.event_context.y1)
end

function SecondaryUnit()
    return wesnoth.get_unit(wesnoth.current.event_context.x2, wesnoth.current.event_context.y2)
end

-- Return the field _level of the abilities with id id_ability
function get_ability(u, id_ability, ability_name)
    ability_name = ability_name or "isHere"
    local list_abilities = H.get_child(u.__cfg, "abilities") or {}
    for ab in H.child_range(list_abilities, ability_name) do
        if ab.id == id_ability then
            return ab._level or 0
        end
    end
end

-- Returns the level of the id_special on the atk.
-- Atk is a unit.attack proxy or a weapon child
function get_special(atk, id_special, special_name)
    special_name = special_name or "isHere"
    if atk == nil then
        return
    end
    local list_specials
    if type(atk) == "userdata" then
        list_specials = atk.specials or {}
    else
        list_specials = H.get_child(atk, "specials")
    end
    for spe in H.child_range(list_specials, special_name) do
        if spe.id == id_special then
            return spe._level
        end
    end
end

-- Return an effect wml table augmenting all defenses by given number (positive is better)
function add_defenses(def)
    return T.effect {
        apply_to = "defense",
        T.defense {
            deep_water = -def,
            shallow_water = -def,
            reef = -def,
            swamp_water = -def,
            flat = -def,
            sand = -def,
            forest = -def,
            hills = -def,
            mountains = -def,
            village = -def,
            castle = -def,
            cave = -def,
            frozen = -def,
            unwalkable = -def,
            fungus = -def,
            impassable = -def
        }
    }
end


function GetLocation()
    return wesnoth.current.event_context.x1, wesnoth.current.event_context.y1
end

-- Returns the table id_skill = lvl
function TableSkills(u)
    local table_amlas = {}
    for __, adv in pairs(u.advancements) do
        table_amlas[adv.id] = (table_amlas[adv.id] or 0) + 1
    end
    table_amlas.amla_dummy = nil
    return table_amlas
end


-- Popup window with translatable string
function Popup(title, message)
    local dialog = {
        T.tooltip {id = "tooltip_large"},
        T.helptip {id = "tooltip_large"},
        T.grid {
            T.row {T.column {T.label {id = "the_title"}}},
            T.row {T.column {T.spacer {id = "space", height = 10}}},
            T.row {T.column {horizontal_alignement = "left", T.label {id = "the_message", characters_per_line = 100}}},
            T.row {T.column {T.spacer {id = "space2", height = 10}}},
            T.row {T.column {T.button {id = "ok", label = _ "OK"}}}
        }
    }

    local function preshow()
        wesnoth.set_dialog_markup(true, "the_title")
        wesnoth.set_dialog_markup(true, "the_message")
        wesnoth.set_dialog_value(
            "<span size='large' color ='#BFA63F' font_weight ='bold'>" .. title .. "</span>",
            "the_title"
        )
        wesnoth.set_dialog_value(message, "the_message")
    end
    wesnoth.show_dialog(dialog, preshow)
end









-- TODO: Cleanup
function table.val_to_str(v)
    if "string" == type(v) then
        v = string.gsub(v, "\n", "\\n")
        if string.match(string.gsub(v, '[^\'"]', ""), '^"+$') then
            return "'" .. v .. "'"
        end
        return '"' .. string.gsub(v, '"', '\\"') .. '"'
    else
        return "table" == type(v) and table.tostring(v) or tostring(v)
    end
end

function table.key_to_str(k)
    if "string" == type(k) and string.match(k, "^[_%a][_%a%d]*$") then
        return k
    else
        return "[" .. table.val_to_str(k) .. "]"
    end
end

function table.tostring(tbl)
    local result, done = {}, {}
    for k, v in ipairs(tbl) do
        table.insert(result, table.val_to_str(v))
        done[k] = true
    end
    for k, v in pairs(tbl) do
        if not done[k] then
            table.insert(result, table.key_to_str(k) .. "=" .. table.val_to_str(v))
        end
    end
    return "{" .. table.concat(result, ",") .. "}"
end

-- Fonctions de conversions

function WmltoLua(myString)
    -- Attention, prend en entrée une chaine sans <> significatif
    local v =
        string.gsub(
        myString,
        "[<>]",
        function(c)
            if c == "<" then
                return "{"
            else
                return "}"
            end
        end
    )
    v = "local r = " .. v .. "return r"
    local c = load(v)()
    return c
end

function LuatoWml(myTable)
    -- Attention, prend en entrée une chaine sans {} significatif
    local v = table.tostring(myTable)
    local c =
        string.gsub(
        v,
        "[{}]",
        function(c)
            if c == "{" then
                return "<"
            else
                return ">"
            end
        end
    )
    return c
end

--implemetation de split
function string:split(sep)
    local sep, fields = sep or ":", {}
    local pattern = string.format("([^%s]+)", sep)
    self:gsub(
        pattern,
        function(c)
            fields[#fields + 1] = c
        end
    )
    return fields[1], fields[2] or ""
end

function string:to_field(sep)
    local sep, fields = sep or ":", {}
    local pattern = string.format("([^%s]+)", sep)
    self:gsub(
        pattern,
        function(c)
            fields[#fields + 1] = c
        end
    )
    return fields
end

function toInt(boole)
    return (boole and 1 or 0)
end



--Renvoie une table sans les blocs du type myType et d'id myId

function supp_id(tab, myType, myId)
    local s = {}
    for i, v in pairs(tab) do
        if type(v) == "table" and #v >= 2 then
            if v[1] == myType and v[2]["id"] == myId then
            else
                table.insert(s, {v[1], supp_id(v[2], myType, myId)})
            end
        else
            s[i] = v
        end
    end
    return s
end

-- idem mais sans condition d'id

function supp(tab, myType)
    local s = {}
    for i, v in pairs(tab) do
        if type(v) == "table" and #v >= 2 then
            if v[1] == myType then
            else
                table.insert(s, {v[1], supp(v[2], myType)})
            end
        else
            s[i] = v
        end
    end
    return s
end

function is_empty(x, y)
    return wesnoth.get_unit(x,y) == nil
end

--Renvoie la location de la case derriere la case 2 (pour la case 1)
function case_derriere(x1, y1, x2, y2)
    return wesnoth.map.rotate_right_around_center({x1, y1}, {x2, y2},3)
end

-- Renvoie la (première) case du tableau ayant comme id myId
function case_array(t, myId)
    for i, v in ipairs(t) do
        if v.id == myId then
            return v, i
        end
    end
end

--Longueur d'un tableau Wml
function wml_len(var)
    return #(H.get_variable_array(var))
end

--Renvoie true si unit possede l'ability isHere/id
function has_ab(unit, id)
    local s = false
    local abb = H.get_child(unit.__cfg, "abilities") or {}
    return (H.get_child(abb, "isHere", id) ~= nil)
end


function sleep(s)
    local ntime = os.clock() + s
    repeat
    until os.clock() > ntime
end




