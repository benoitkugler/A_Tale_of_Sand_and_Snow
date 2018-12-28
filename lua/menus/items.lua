local _ = wesnoth.textdomain "wesnoth-A_Tale_of_Sand_and_Snow"

wesnoth.dofile("~add-ons/A_Tale_of_Sand_and_Snow/lua/menus/comp_spe.lua")
wesnoth.dofile("~add-ons/A_Tale_of_Sand_and_Snow/lua/menus/arbre.lua")

MI ={}

--MENU MOUVEMENT INVOQUÉ PAR LES ABILITIES ELUSIVE ET WAR JUMP
local function isIn(l,x,y)
    local bo = false
    local mv = 0
    for i,v in pairs(l) do
        if (v[1] == x and v[2] ==y) then
            bo = true
            mv = v[3]
        end
    end
    return bo,mv
end

function MI.war_jump(id,x,y)
    local u = wesnoth.get_units{id = id}[1]
    local tox,toy = get_loc()
    if u == nil then 
        popup(_"Error",_"This unit can't <span color='red'>War Jump </span> now. Please <span weight='bold'>select</span> it again.")
    else
        local loc = wesnoth.find_reach(u,{ignore_units=true})
        local b,moves_left = isIn(loc,tox,toy)
        if  u.x ~= x or u.y ~= y or not has_ab(u,"war_jump") or not b or not is_empty(tox,toy) then
            popup(_"Error",_""..tostring(u.name).." can't <span color='red'>War Jump </span> right now. Please <span weight='bold'>select</span> it again.")
        else
           
    wesnoth.fire("teleport",{{"filter",{id=id}},x=tox,y=toy,animate=true})
             u.moves=0
        end
    end
    wesnoth.fire("clear_menu_item",{id="movement"})
end

function MI.elusive(id,x,y)
    local u = wesnoth.get_units{id = id}[1]
    local tox,toy = get_loc()
   
    if u == nil then 
            popup(_"Error",_"This unit can't be <span color='green'>Elusive</span> right now. Please <span weight='bold'>select</span> it again.")
    else
        local loc = wesnoth.find_reach(u,{ignore_units=true})
        local b,moves_left = isIn(loc,tox,toy)
        
        if  u.x ~= x or u.y ~= y or not has_ab(u,"elusive") or not b or not is_empty(tox,toy) then
             popup(_"Error",_""..tostring(u.name).."  can't be <span color='green'>Elusive</span> right now. Please <span weight='bold'>select</span> it again.")
        else
             wesnoth.fire("move_unit",{id=id,to_x=tox,to_y=toy,fire_event=true})
             u.moves=moves_left
        end
    end
    wesnoth.fire("clear_menu_item",{id="movement"})
end


--MENU SKILLS (CONTENANT AMLA et COMP SPE)
local dialog = {T.tooltip { id = "tooltip_large" },T.helptip { id = "tooltip_large" },T.grid {
    T.row {  T.column{T.label {id = "titre"} }} ,
    T.row{T.column{T.spacer{height=10}}},
    T.row {  T.column{
        T.horizontal_listbox{id="tabs",
        T.list_definition{
            T.row {T.column { 
                horizontal_grow = true, 
                T.toggle_panel { T.grid{T.row{T.column{
                    border= 'all',
                    border_size=15,
                    T.label{id="onglet"}
                }
            }}
        }}}}}}},
    T.row{T.column{T.spacer{height=10}}},
    T.row {  T.column{
        T.stacked_widget{
            id="pages",
            {"layer", A.dialog},
            {"layer", MCS.dialog},
            T.layer{ T.row{T.column{
                T.label{id="cache"}}}
            },
        }}} ,
    T.row{ T.column{ T.button { id = "ok", label = _"Return" }}}
 }}
 

 
local function preshow(unit)
    MI.skills_help = true
    wesnoth.set_dialog_markup(true,"titre")
 	wesnoth.set_dialog_value(_"<span font_size = 'large' font_weight ='bold' ><span  color ='#BFA63F' >Skills of your unit </span>"..unit.name.."</span>","titre")
    
    wesnoth.set_dialog_value(_"Advancements","tabs",1,"onglet")
    wesnoth.set_dialog_value(_"Special skills","tabs",2,"onglet")
    
    wesnoth.set_dialog_value(2,"pages")
    MCS.preshow(unit)
    
   
    local function onTab()
        local i = wesnoth.get_dialog_value("tabs")
        wesnoth.set_dialog_value(i,"pages")
        if i == 1 then
            MCS.postshow()
            if unit.__cfg.advances_to == "" then
                A.preshow(unit)
            else
                wesnoth.set_dialog_value(3,"pages")
                wesnoth.set_dialog_value(unit.name.._" has yet to reach its maximum level...","cache")
                wesnoth.set_dialog_visible(false,"cache")
                wesnoth.set_dialog_visible(true,"cache")
            end 
        else
            if next(unit.variables["table_comp_spe"]) then
                if  unit.__cfg.advances_to == "" then
                    MCS.init()
                else
                    wesnoth.set_dialog_value(3,"pages")
                    wesnoth.set_dialog_value(_"It's a bit early to show you the amazing skills "..unit.name.." will get...","cache")
                    wesnoth.set_dialog_visible(false,"cache")
                    wesnoth.set_dialog_visible(true,"cache")
                end
            else
                wesnoth.set_dialog_value(3,"pages")
                wesnoth.set_dialog_value(_"Sadly, "..unit.name.." won't get specials skills in this campaign...","cache")
                wesnoth.set_dialog_visible(false,"cache")
                wesnoth.set_dialog_visible(true,"cache")
            end
        end     
    end
    wesnoth.set_dialog_callback(onTab,"tabs")
    
    onTab()
    
end

function MI.skills_advances()
    local u = get_pri()
    wesnoth.show_dialog(dialog,function () preshow(u) end)
end
