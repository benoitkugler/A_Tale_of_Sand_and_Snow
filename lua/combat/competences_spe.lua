local _ = wesnoth.textdomain "wesnoth-A_Tale_of_Sand_and_Snow"



CS = {}

local l ={ vranken = "transposition"}


local fonc ={}
function CS.comp_spe ()
    local u = get_pri()
    fonc[l[u.id]]()
end


local function new_des (tab,des,ab_id)
	local s={}
	for i,v in pairs(tab) do
		if type(v) == "table" and #v >= 2 then
			if v[1]  == "isHere" and v[2].id==ab_id then
				local new = v[2]
				new["description"] = des
				table.insert(s,{v[1],new })
			else
				table.insert(s,{v[1],new_des(v[2],des,ab_id)})
			end
		else
			s[i] = v
		end
	end
	return s
end

local function update_ab(ab_id,unit)
	local des=""
	for i in H.child_range(H.get_child(unit.__cfg,"abilities"),"isHere") do
		if i.id == ab_id then
			local fin = string.find(tostring(i.description),"\n")
			des = _""..string.sub(tostring(i.description),1,fin-1)
		end
	end
	if unit.variables.comp_spe_cd > 1 then
		des =des.."\n".."<span color='orange'>Available in "..unit.variables.comp_spe_cd.. " turns </span>"
	elseif unit.variables.comp_spe_cd == 1 then
		des = des.."\n".."<span color='orange'>Available in "..unit.variables.comp_spe_cd.. " turn</span>"
	elseif unit.variables.comp_spe_cd == 0 then
		des = des.."\n".."<span color='green'>Available now</span>"
	end
	
	local newu = new_des(unit.__cfg,des,ab_id)
	
	wesnoth.extract_unit(unit)
	wesnoth.put_unit(newu)
end

function fonc.transposition () 
	local vr = wesnoth.get_units{ id = "vranken"}[1]
	
	if vr.variables.comp_spe_cd == 0 then
		local sword_spirit = wesnoth.get_units{ id = "sword_spirit"}[1]
		wesnoth.fire("animate_unit",{flag="transposition_in" ,{"filter", { id="vranken"}} , {"animate" ,{flag="transposition_in" ,{"filter", { id="sword_spirit"}}}}})
		vr.variables.comp_spe_cd = 3 -  vr.variables.comp_spe_lvl
		wesnoth.extract_unit(vr)
		wesnoth.extract_unit(sword_spirit)
		local x ,y = vr.x ,vr.y
		local x2,y2 = sword_spirit.x,sword_spirit.y
	
		vr:to_map(sword_spirit.x,sword_spirit.y)
		sword_spirit:to_map(x,y)
		wesnoth.fire("animate_unit",{flag="transposition_out" ,{"filter", { id="vranken"}},{"animate" ,{flag="transposition_out" ,{"filter", { id="sword_spirit"}}}}})
		update_ab("transposition"..tostring(vr.variables.comp_spe_lvl),vr)
	else
		wesnoth.fire("print",{text=_"This ability isn't ready yet ! ("..vr.variables.comp_spe_cd.." turn(s) left)" , size = 40, red= 150,green=20,blue=150,duration = 100} )
	end
end

function CS.debut_tour ()
	local lhero = wesnoth.get_units{role="hero"}
	for i,v in pairs(lhero) do
		if v.variables.comp_spe then
                    local comp_id = l[v.id]..tostring(v.variables.comp_spe_lvl)
                    if v.variables.comp_spe_cd > 2 then
                            v.variables.comp_spe_cd = v.variables.comp_spe_cd  -1
                    elseif 	v.variables.comp_spe_cd == 2 then
                            v.variables.comp_spe_cd = 1
                    elseif v.variables.comp_spe_cd == 1 then
                            v.variables.comp_spe_cd = 0
                    end
            
                    update_ab(comp_id,v)
		end
	end
end



