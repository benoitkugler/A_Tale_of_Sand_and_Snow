-- Misc. helpers

local _ = wesnoth.textdomain "wesnoth-A_Tale_of_Sand_and_Snow"

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

-- Arrondi
function arrondi(f)
    return math.floor(0.5 + f)
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



--Récupére l'unité primaire ou secondaire d'un event
function get_pri()
    return wesnoth.get_units {x = wesnoth.current.event_context.x1, y = wesnoth.current.event_context.y1}[1]
end

function get_snd()
    return wesnoth.get_units {x = wesnoth.current.event_context.x2, y = wesnoth.current.event_context.y2}[1]
end

function get_loc()
    return wesnoth.current.event_context.x1, wesnoth.current.event_context.y1
end

function is_empty(x, y)
    return wesnoth.get_units {x = x, y = y}[1] == nil
end

--Renvoie la location de la case derriere la case 2 (pour la cas 1)
function case_derriere(x1, y1, x2, y2)
    local dir = wesnoth.map.get_relative_dir({x1, y1}, {x2, y2})
    return wesnoth.map.get_direction(wesnoth.map.get_direction({x1, y1}, dir), dir)
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

-- helper pour récupérer le lvl d'une ability ou d'une special
function get_ability(u, id_ability)
    local list_abilities = H.get_child(u.__cfg, "abilities") or {}
    for ab in H.child_range(list_abilities, "isHere") do
        local name, lvl = ab.id:split("*")
        if name == id_ability then
            if lvl == "" then
                return 1
            else
                return lvl
            end
        end
    end
    return false
end

function get_special(att, id_special)
    local list_specials = H.get_child(att, "specials") or {}
    for spe in H.child_range(list_specials, "isHere") do
        local name, lvl = spe.id:split("*")
        if name == id_special then
            if lvl == "" then
                return 1
            else
                return tonumber(lvl)
            end
        end
    end
    return false
end

function sleep(s)
    local ntime = os.clock() + s
    repeat
    until os.clock() > ntime
end

function table_skills(u)
    local s = {}
    local l = H.get_child(u.__cfg, "modifications") or {}
    for adv in H.child_range(l, "advancement") do
        table.insert(s, adv.id)
    end
    local function structure_skills(liste) -- construit la table de format {skill =lvl ,..} à partir de liste
        local tab_u = {}
        for i, v in pairs(liste) do
            if tab_u[v] ~= nil then
                tab_u[v] = tab_u[v] + 1
            else
                tab_u[v] = 1
            end
        end
        return tab_u
    end
    local table_skill = structure_skills(s)
    return table_skill
end

-- Boite d'information avec chain translatable
function popup(title, message)
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
