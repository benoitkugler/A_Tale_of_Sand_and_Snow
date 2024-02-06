local unit_id = arg[1]

local AMLAS_PATH = "../../lua/DB/trees/"
local DOT_FILE = "tree.dot"

local DOT_PARAMS = {
    size_x = 15,
    size_y = 10,
    nodesep = 0.2,
    ranksep = 0.2,
    bgcolor = "transparent",
    node_shape = "none",
    cell_border_size = 3,
    number_font_size = 30,
    number_color = "#c0b746",
    desc_font_size = 18,
    basic_border_color = "#000000",
    arrow_color = "#2C2C2C",
    bonus_arrow_color = "#F7E559",
    chiffre_cell_paddind = 5
}

local header_dot = string.format(
    "digraph simple_hierarchy { \n splines=ortho;" ..
    'size="%d,%d";rankdir=LR;nodesep=%f;ranksep=%f;' ..
    "bgcolor=%s;node [shape=%s] \n", DOT_PARAMS.size_x,
    DOT_PARAMS.size_y, DOT_PARAMS.nodesep,
    DOT_PARAMS.ranksep, DOT_PARAMS.bgcolor,
    DOT_PARAMS.node_shape)

local function format_node(id, img, cell_chiffres, cell_desc)
    return string.format(
        [[ %s [ layer=%q , label=<<TABLE COLOR=%q STYLE="ROUNDED" CELLSPACING="0" BORDER=%q>
            <TR><TD BORDER="0"><IMG SRC=%q/></TD>
            %s</TR>
            <TR>%s</TR>
            </TABLE>> ] ]], id, id, BORDER_COLOR, DOT_PARAMS.cell_border_size,
        img, cell_chiffres, cell_desc)
end

-- <TD COLSPAN="2" BORDER="0" COLOR="#000000">
--                 <FONT POINT-SIZE="18" FACE="Monotype Corsiva" >Magic resistances <BR/>  <B> +7 </B> %</FONT>
--             </TD>
-- local template_dot = string.format(
--                          [[ %s [ layer=%s , label=<<TABLE COLOR=%s STYLE="ROUNDED" CELLSPACING="0" BORDER=%q>
--                              '<TR><TD BORDER="0"><IMG SRC=%s/></TD>
--                              <TD CELLPADDING=%q BORDER="0"> %s </TD></TR>
--                              "%s \n </TABLE>> ] ]], "%s", "%q", "%q",
--                          tostring(DOT_PARAMS.cell_border_size), "%s", "%q",
--                          DOT_PARAMS.chiffre_cell_paddind, "%s")

local function format_description(desc)
    return string.format(
        '<FONT POINT-SIZE=%q FACE="Monotype Corsiva">%s</FONT>',
        tostring(DOT_PARAMS.desc_font_size), desc)
end

-- format(id, id, couleur_bordure, img, body)

local function cell_chiffres(with_border, max_level)
    local s = ""
    if with_border then
        s = string.format('BORDER="1" COLOR=%q', DOT_PARAMS.basic_border_color)
    end
    return string.format(
        [[ <TD CELLPADDING=%q BORDER="0"><TABLE CELLSPACING="0" BORDER="0"><TR><TD FIXEDSIZE="true" WIDTH="100" HEIGHT="40" CELLSPACING="0" %s>
                            <FONT COLOR=%q FACE="Monotype Corsiva" POINT-SIZE=%q > <B> 1/%d </B></FONT>
                            </TD></TR></TABLE></TD> ]],
        DOT_PARAMS.chiffre_cell_paddind, s, DOT_PARAMS.number_color,
        DOT_PARAMS.number_font_size, max_level)
end

local function format_text_with_border(desc)
    return string.format([[ <TD BORDER="0" COLSPAN="2" CELLPADDING="3">
                    <TABLE BORDER="0" CELLSPACING="0">
                    <TR><TD  BORDER="1"  COLOR=%q > ]],
            DOT_PARAMS.basic_border_color) ..
        format_description(desc) .. "</TD></TR></TABLE> </TD>"
end

local function block_simple(desc, img, id, max_level)
    local cc = cell_chiffres(false, max_level)
    local cd = '<TD BORDER="0" COLSPAN="2">' .. format_description(desc) ..
        "</TD>"
    return format_node(id, img, cc, cd)
end

local function block_texte(desc, img, id, max_level)
    local cc = cell_chiffres(false, max_level)
    local cd = format_text_with_border(desc)
    return format_node(id, img, cc, cd)
end

local function block_chiffre(desc, img, id, max_level)
    local cc = cell_chiffres(true, max_level)
    local cd = '<TD BORDER="0" COLSPAN="2">' .. format_description(desc) ..
        "</TD>"
    return format_node(id, img, cc, cd)
end

local function block_texte_chiffre(desc, img, id, max_level)
    local cc = cell_chiffres(true, max_level)
    local cd = format_text_with_border(desc)
    return format_node(id, img, cc, cd)
end

---@return string
local function relie(n1, n2, is_bonus)
    local color = is_bonus and DOT_PARAMS.bonus_arrow_color or
        DOT_PARAMS.arrow_color
    return string.format(
        '%s -> %s [layer="layer_fleche",penwidth="7",color=%q, arrowsize="1.5"]; \n',
        n1, n2, color)
end

local function aux(arb)
    local codegraphe = ""
    local edges = {} -- avoid duplicates
    for i, noeud in pairs(arb) do
        table.insert(Layers, noeud.id)
        if noeud["couleur"] ~= nil then
            local r, g, b = noeud.couleur[1], noeud.couleur[2], noeud.couleur[3]
            if noeud.max_level > 1 then
                table.insert(Liste_todo, { noeud.id, r, g, b, 1, noeud.max_level })
                codegraphe = codegraphe ..
                    block_texte_chiffre(noeud.txt, noeud.img,
                        noeud.id, noeud.max_level)
            else
                table.insert(Liste_todo, { noeud.id, r, g, b, 1, 0 })
                codegraphe = codegraphe ..
                    block_texte(noeud.txt, noeud.img, noeud.id,
                        noeud.max_level)
            end
        else
            if noeud.max_level > 1 then
                table.insert(Liste_todo, { noeud.id, 0, 0, 0, 0, noeud.max_level })
                codegraphe = codegraphe ..
                    block_chiffre(noeud.txt, noeud.img, noeud.id,
                        noeud.max_level)
            else
                table.insert(Liste_todo, { noeud.id, 0, 0, 0, 0, 0 })
                codegraphe = codegraphe ..
                    block_simple(noeud.txt, noeud.img, noeud.id,
                        noeud.max_level)
            end
        end

        if noeud.parents ~= nil then -- edges
            for j, k in pairs(noeud.parents) do
                edges[relie(k, noeud.id, noeud.levelbonus)] = true
            end
        end
    end
    for i, _ in pairs(edges) do codegraphe = codegraphe .. i end
    return codegraphe
end

local function prem_l(l, i)
    local code = 'layers="' .. l[i]
    for k, v in pairs(l) do if k ~= i then code = code .. ":" .. v end end

    code = code .. '" \n layerselect="' .. l[i] .. '" \n }'
    return code
end

local function export(layers)
    local nb = 0
    for line in io.lines(DOT_FILE) do nb = nb + 1 end
    local contenu = ""
    local i = 1
    for line in io.lines(DOT_FILE) do
        if i <= (nb - 1) then
            contenu = contenu .. line .. "\n"
            i = i + 1
        end
    end

    for j, k in pairs(layers) do
        local ajout = prem_l(layers, j)
        local file = io.open("layers/" .. k, "w")
        file:write(contenu)
        file:write(ajout)
        file:close()
    end
end

local function write_dot_tree(inArbre)
    Layers = { "layer_fleche" }
    local code = aux(inArbre)
    local code = header_dot .. code .. "}"

    local file = io.open(DOT_FILE, "w")
    file:write(code)
    file:close(file)

    export(Layers)
end

-- Building amla tree from wesnoth lua source
-- setup globals needed by amlas.
_ = function(s) return s end
StandardAmlaHeal = function(s) return {} end
Fmt = function(s) return string.format(s) end
T = {}
DB = { AMLAS = {} }
Round = function(s) return s end
ROMANS = { "I", "II", "III", "IV", "V", "VI" }

setmetatable(T,
    { __index = function(k, t) return function(...) return ... end end })

local function compute_arbre_froms_amla(unit_id)
    local color_border = DB.AMLAS[unit_id]._default_border
    local color_background = DB.AMLAS[unit_id]._default_background
    local tree = {}
    for i, amla in ipairs(DB.AMLAS[unit_id]) do
        if not (amla.id == "default") then
            local tree_node = {
                id = amla.id,
                img = amla.image,
                txt = amla._short_desc,
                max_level = amla.max_times,
                couleur = amla._color,
                levelbonus = amla._level_bonus,
                parents = {}
            }
            local require_amla = amla.require_amla
            if not (require_amla == nil) then
                local crible_parents = {} -- to avoid duplicates
                amla.require_amla:gsub("([^,]+)", function(ra)
                    crible_parents[ra] = true
                end)
                for i, _ in pairs(crible_parents) do
                    table.insert(tree_node.parents, i)
                end
            end
            table.insert(tree, tree_node)
        end
    end
    return tree, color_border, color_background
end

------------------------------------------------------------
-- MAIN
local path = AMLAS_PATH .. unit_id .. ".lua"
dofile(path)

Tree, BORDER_COLOR, Color_background = compute_arbre_froms_amla(unit_id)

Liste_todo = {}
write_dot_tree(Tree)

local sortie = ""
for i, v in pairs(Liste_todo) do
    sortie =
        sortie .. ";" .. v[1] .. ":" .. v[2] .. ":" .. v[3] .. ":" .. v[4] ..
        ":" .. v[5] .. ":" .. v[6]
end
sortie = sortie:sub(2)
sortie = sortie .. " " .. Color_background
print(sortie)
