local _ = wesnoth.textdomain "wesnoth-A_Tale_of_Sand_and_Snow"

DB = wesnoth.require("~add-ons/A_Tale_of_Sand_and_Snow/lua/DB/competences_spe.lua")

MCS ={}


--Helper de mise en couleur
local function in_color(str_translatable,str_color)
    local str = tostring(str_translatable)
    local function replace (s)
        local s2 = s:gsub("|","")
        return "<span color='"..str_color.."'>"..s2.."</span>"         
    end
    local sr,u = str:gsub("(|[%s%w:%-%%]*|)",replace)
    return sr
end

-- Gestion du menu

function MCS.postshow()
    MCS.table = nil
    MCS.u_lvl = nil
    MCS.t = nil
    MCS.xp_total = nil
    MCS.xp_dispo = nil 
    MCS.select_functions =nil
    MCS.to_valid = nil
end


MCS.dialog = { T.row{T.column{T.panel{definition="story_viewer_panel",T.grid{
    T.row{T.column{T.spacer{height=10}}},
  	T.row { T.column{border="left,right",border_size=20, T.grid{ 
        T.row{  T.column{T.label {id = "text_xp_dispo",label="test7789"}},
                T.column{T.spacer{width = 15}},
                T.column{T.label {id = "text_xp_total"}},
                T.column{T.spacer{width = 15}},
                T.column{T.button {id = "help_button",label=_"Show info"}}}
        }}},
    T.row{T.column{T.spacer{height=7}}},
  	T.row{T.column{border="left,right",border_size=10,T.label{id="help",characters_per_line = 80}}},
  	T.row{T.column{T.spacer{height=7}}}
    }}}},
    T.row {  T.column{ border = "all", border_size = 10, T.grid{ 
        T.row { T.column {T.panel{definition="box_display",id="cadre_next", T.grid{
            T.row{T.column{ T.label{id ="titre_pres" }}},
            T.row{T.column{T.spacer{height=7}}},
            T.row{T.column{T.label{id="text_pres_suiv",characters_per_line = 35}}},
            T.row{T.column{T.spacer{height=7}}},
            T.row{T.column{T.button{id="lvl_up",label=_"Level up skill"}}}}}},
                T.column{T.spacer{width=7}},
                T.column{ T.listbox { id = "lcomp",T.list_definition{ T.row {T.column { horizontal_grow = true   ,border= 'all',border_size=5, T.toggle_panel { T.grid{ 
                    T.row{  T.column{ border= 'all',border_size=5, T.image{   id ="img_comp"}},
                            T.column{border= 'right',border_size=5,T.image{id= "img_lvl"} },
                            T.column{   grow_factor = 1 ,  horizontal_grow = true , T.label{ id= "text_comp",  characters_per_line=50}}	
                }}}}}}}}
        }}}}
    
  }
  
  
function MCS.preshow(unit)
    local function affiche_pres(bool)
        wesnoth.set_dialog_visible(bool,"cadre_next")
         wesnoth.set_dialog_visible(bool,"titre_pres")
        wesnoth.set_dialog_visible(bool,"text_pres_suiv")
        wesnoth.set_dialog_visible(bool,"lvl_up")
    end
    
    local function active_selectl(i)
        affiche_pres(false)
        
        local comp = MCS.t[i]
        local lvl = tonumber(MCS.table[comp["name"]])
        if lvl  == comp.max_lvl then
            wesnoth.set_dialog_value(_"<span style='italic'>Max level reached </span>","text_pres_suiv")	
            wesnoth.set_dialog_value("","titre_pres")	
            wesnoth.set_dialog_value(_" ","lvl_up")
            affiche_pres(true)
            wesnoth.set_dialog_visible(false,"lvl_up")
            wesnoth.set_dialog_active(false,"lvl_up")
        elseif MCS.u_lvl < comp.require_lvl then
            wesnoth.set_dialog_active(false,"lvl_up")
        else
            wesnoth.set_dialog_active(true,"lvl_up")
            wesnoth.set_dialog_value(_"<span style='italic' color ='#BFA63F'>Next level : </span>","titre_pres")
            wesnoth.set_dialog_value(in_color(comp[lvl+2].des,comp.color),"text_pres_suiv")
            if  MCS.xp_dispo >= comp[lvl+1].cout_suivant then
                wesnoth.set_dialog_value(_"Level up : "..comp[lvl+1].cout_suivant.." points","lvl_up")
            else
                wesnoth.set_dialog_value(_"Points needed : "..comp[lvl+1].cout_suivant,"lvl_up")
                wesnoth.set_dialog_active(false,"lvl_up")
            end
            affiche_pres(true)
        end
    end
    
    local function non_active_selectl(i)
        affiche_pres("hidden")
    end
    
    function MCS.init ()
        
        wesnoth.set_dialog_markup(true,"text_xp_dispo")
        wesnoth.set_dialog_markup(true,"text_xp_total")
        wesnoth.set_dialog_markup(true,"titre_pres")
        wesnoth.set_dialog_markup(true,"text_pres_suiv")
        wesnoth.set_dialog_markup(true,"help")
    
    
        affiche_pres("hidden")
        wesnoth.set_dialog_active(false,"lvl_up")
        
        
        MCS.table = unit.variables["table_comp_spe"]
        MCS.u_lvl = tonumber( unit.__cfg.level)
        MCS.t = DB.info[unit.id]
        MCS.xp_total = unit.variables.xp
        MCS.xp_dispo = unit.variables.xp 
        
        MCS.select_functions ={}
        
        MCS.to_valid = false
   
--         suppression des items de la liste des competences
        wesnoth.remove_dialog_item(1,#(MCS.t),"lcomp")
        
--         ecriture de la liste des competences et mise à jour de l'xp
        for i,v in ipairs(MCS.t) do
            local max_lvl = v["max_lvl"]
            local lvl = tonumber(MCS.table[v["name"]])
            for j = 1,lvl,1 do
                MCS.xp_dispo = MCS.xp_dispo - v[j].cout_suivant		
            end
            if MCS.u_lvl >= v.require_lvl then
                if not v.require_avancement or (table_skills(unit)[v.require_avancement.id] ~= nil) then
                    wesnoth.set_dialog_value(in_color(v.name_aff,v.color).."\n"..in_color(v[lvl+1].des,v.color),"lcomp",i,"text_comp")
                    wesnoth.set_dialog_value(v.img,"lcomp",i,"img_comp")
                    wesnoth.set_dialog_value("comp_spe/"..max_lvl.."-"..lvl..".png","lcomp",i,"img_lvl")
                    MCS.select_functions[i] = active_selectl
                else
                    wesnoth.set_dialog_value("<span style='italic'>"..v.require_avancement.des.."</span>","lcomp",i,"text_comp")
                    wesnoth.set_dialog_value(v.img,"lcomp",i,"img_comp")
                    MCS.select_functions[i]=non_active_selectl                  
                end
            else
                wesnoth.set_dialog_value(_"<span style='italic'>Require level "..v.require_lvl.."</span>","lcomp",i,"text_comp")
                wesnoth.set_dialog_value(v.img,"lcomp",i,"img_comp")
                MCS.select_functions[i] = non_active_selectl   
            end
            wesnoth.set_dialog_markup(true,"lcomp",i,"text_comp")
        end
        
--        affichage de l'xp
        wesnoth.set_dialog_value(_" <span font_style='italic' ><span color ='#BFA63F'  >Points available :  </span><span font_weight ='bold' >"..MCS.xp_dispo.."</span></span>","text_xp_dispo")
        wesnoth.set_dialog_value(_" <span font_style='italic'  color ='#BFA63F'  >Total points:  "..MCS.xp_total.."</span>","text_xp_total")
    end
    
  
    
	local function selectl()
        MCS.to_valid=false
        local i = wesnoth.get_dialog_value("lcomp")
        MCS.select_functions[i](i)
    end
	
	

	
	
 


    local function show_help()
        if MI.skills_help  then
            wesnoth.set_dialog_visible(false,"help")
            wesnoth.set_dialog_visible(true,"help")          
            
            wesnoth.set_dialog_value(MCS.t.help_des.."\n<span style='italic'>"..MCS.t.help_ratios.."</span>","help")
            wesnoth.set_dialog_value(_"Hide info","help_button")
            MI.skills_help =false
        else
            wesnoth.set_dialog_visible(false,"help")            
            wesnoth.set_dialog_value("","help")
            MI.skills_help = true
            wesnoth.set_dialog_value(_"Show info","help_button")
        end
    end
   
 	
    
 	local function select_lvlup()
        if MCS.to_valid then
            local i = wesnoth.get_dialog_value("lcomp")
            local comp = MCS.t[i]
            local newlvl = unit.variables["table_comp_spe."..comp.name] + 1
            unit.variables["table_comp_spe."..comp.name] = newlvl 
            DB.apply[comp.name](newlvl,unit)
            MCS.init()
        else
            wesnoth.set_dialog_value(_"Confirm ?","lvl_up")
            MCS.to_valid=true
        end
    end
    
   wesnoth.set_dialog_callback(show_help,"help_button")
 	wesnoth.set_dialog_callback(selectl,"lcomp")
 	wesnoth.set_dialog_callback(select_lvlup,"lvl_up")
 end 
  
