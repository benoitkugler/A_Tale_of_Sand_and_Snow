local unit = arg[1]
local dir = arg[2]

dot = "digraph simple_hierarchy { \n splines=ortho;size=\"15,10\";rankdir=LR;nodesep=0.2;ranksep=0.2;bgcolor=transparent;node [shape=none] \n"
    
function  block_simple (txt,img,id,max_level)
    return id.." [ layer=\""..id.."\" , label=<  <TABLE COLOR=\""..couleur_bordure.."\" STYLE=\"ROUNDED\" CELLSPACING=\"0\"  BORDER=\"6\"> \n <TR><TD ROWSPAN=\"3\" BORDER=\"0\" ><IMG SRC=\""..img.."\"/></TD><TD BORDER=\"0\"></TD></TR> \n <TR><TD BORDER=\"0\" ><FONT COLOR=\""..couleur_chiffres.."\" FACE=\"Monotype Corsiva\" POINT-SIZE=\"30\"><B> 1/"..tostring(max_level).." </B></FONT></TD></TR> \n  <TR><TD BORDER=\"0\"></TD></TR> \n <TR><TD COLSPAN=\"2\" BORDER=\"0\" COLOR=\"#000000\" ><FONT POINT-SIZE=\"18\" FACE=\"Monotype Corsiva\" >"..txt.."</FONT></TD></TR> \n  </TABLE>>] \n" 
end


function  block_texte(txt,img,id,max_level)
    return id.." [ layer=\""..id.."\" , label=<  <TABLE COLOR=\""..couleur_bordure.."\" STYLE=\"ROUNDED\" CELLSPACING=\"0\"  BORDER=\"6\"> \n <TR><TD ROWSPAN=\"3\" BORDER=\"0\" ><IMG SRC=\""..img.."\"/></TD><TD BORDER=\"0\"></TD></TR> \n <TR><TD BORDER=\"0\"><FONT COLOR=\""..couleur_chiffres.."\" FACE=\"Monotype Corsiva\" POINT-SIZE=\"30\"><B> 1/"..tostring(max_level).." </B></FONT></TD></TR> \n  <TR><TD BORDER=\"0\"></TD></TR> \n <TR><TD BORDER=\"0\" COLSPAN=\"2\"><TABLE BORDER=\"0\" CELLSPACING=\"3\"><TR><TD  BORDER=\"1\"  COLOR=\"#000000\" ><FONT POINT-SIZE=\"18\" FACE=\"Monotype Corsiva\" >"..txt.."</FONT></TD></TR></TABLE></TD></TR> \n  </TABLE>>] \n" 
end
function  block_chiffre(txt,img,id,max_level)
    return id.." [ layer=\""..id.."\" , label=<  <TABLE COLOR=\""..couleur_bordure.."\" STYLE=\"ROUNDED\" CELLSPACING=\"0\"  BORDER=\"6\"> \n <TR><TD ROWSPAN=\"3\" BORDER=\"0\" ><IMG SRC=\""..img.."\"/></TD><TD BORDER=\"0\"></TD></TR> \n <TR><TD BORDER=\"1\" COLOR=\"#000000\" ><FONT COLOR=\""..couleur_chiffres.."\" FACE=\"Monotype Corsiva\" POINT-SIZE=\"30\"><B> 1/"..tostring(max_level).." </B></FONT></TD></TR> \n  <TR><TD BORDER=\"0\"></TD></TR> \n <TR><TD COLSPAN=\"2\" BORDER=\"0\" COLOR=\"#000000\" ><FONT POINT-SIZE=\"18\" FACE=\"Monotype Corsiva\" >"..txt.."</FONT></TD></TR> \n  </TABLE>>] \n" 
end

function  block_texte_chiffre (txt,img,id,max_level)
    return id.." [ layer=\""..id.."\" , label=<  <TABLE COLOR=\""..couleur_bordure.."\" STYLE=\"ROUNDED\" CELLSPACING=\"0\"  BORDER=\"6\"> \n <TR><TD ROWSPAN=\"3\" BORDER=\"0\" ><IMG SRC=\""..img.."\"/></TD><TD BORDER=\"0\"></TD></TR> \n <TR><TD BORDER=\"1\" COLOR=\"#000000\" ><FONT COLOR=\""..couleur_chiffres.."\" FACE=\"Monotype Corsiva\" POINT-SIZE=\"30\"><B> 1/"..tostring(max_level).." </B></FONT></TD></TR> \n  <TR><TD BORDER=\"0\"></TD></TR> \n <TR><TD BORDER=\"0\" COLSPAN=\"2\"><TABLE BORDER=\"0\" CELLSPACING=\"3\"><TR><TD  BORDER=\"1\"  COLOR=\"#000000\" ><FONT POINT-SIZE=\"18\" FACE=\"Monotype Corsiva\" >"..txt.."</FONT></TD></TR></TABLE></TD></TR> \n  </TABLE>>] \n" 
end

function relie (n1,n2,is_bonus)
    if is_bonus then
        return n1.." -> "..n2.."[layer=\"layer_fleche\",penwidth=\"7\",color=\""..couleur_fleche_bonus.."\",arrowsize=\"1.5\"]; \n"
    else
        return n1.." -> "..n2.."[layer=\"layer_fleche\",penwidth=\"7\",color=\""..couleur_fleche.."\",arrowsize=\"1.5\"]; \n"
   end
end

local function lienparents (arb)
    t={}
    for i,v in pairs(arb) do
       t[v.id] = v.max_level
    end
    return t
end

function aux (arb)
    local liens= lienparents(arb)
    local codegraphe = ""
    local codewml ="#Macro a inclure dans le fichier amla_dummies dans le bloc unit type de l'unité :\n"
    for i,v in pairs(liens) do
        codewml =codewml.."{AMLA_"..unit.."_"..i.."}\n"
    end
    codewml=codewml.."\n{AMLA_"..unit.."_default} \n \n"
    for i,noeud in pairs(arb) do
        -- PARTIE GRAPHE
        table.insert(l_layers,noeud.id)
        if noeud["couleur"] ~= nil then
            local r,g,b = noeud.couleur[1],noeud.couleur[2],noeud.couleur[3]
            if noeud.max_level > 1 then
                table.insert(liste_afaire,{noeud.id,r,g,b,1,noeud.max_level})
                codegraphe = codegraphe..block_texte_chiffre(noeud.txt,noeud.img,noeud.id,noeud.max_level)
            else
                table.insert(liste_afaire,{noeud.id,r,g,b,1,0})
                codegraphe = codegraphe..block_texte(noeud.txt,noeud.img,noeud.id,noeud.max_level)
            end
        else
            if noeud.max_level > 1 then
                table.insert(liste_afaire,{noeud.id,0,0,0,0,noeud.max_level})
                codegraphe = codegraphe..block_chiffre(noeud.txt,noeud.img,noeud.id,noeud.max_level)
            else
                table.insert(liste_afaire,{noeud.id,0,0,0,0,0})
                codegraphe = codegraphe..block_simple(noeud.txt,noeud.img,noeud.id,noeud.max_level) 
            end
        end
        coderequire=""
        if noeud.parents ~= nil then
            coderequire="\trequire_amla= "
            for j,k in pairs(noeud.parents)  do  
                    codegraphe = codegraphe..relie(k,noeud.id,noeud.levelbonus)
                    coderequire=coderequire..string.rep(k..",",liens[k])
             end
            coderequire=string.sub(coderequire,1,string.len(coderequire)-1).."\n"
        end
        
        --PARTIE AMLA
        codewml = codewml.."#define AMLA_"..unit.."_"..noeud.id.."\n[advancement]\n \tid="..noeud.id.." \n"..coderequire.."\tmax_times="..tostring(noeud.max_level).." \n\tdescription=\n\timage=\""..noeud.img.."\"\n\talways_display=1\n\t[effect]\n\t\tapply_to=\n\t\tname=\n\t[/effect]\n\t{STANDARD_AMLA_HEAL 10%}\n[/advancement]\n#enddef \n \n"
    end
    codewml=codewml.."#define AMLA_"..unit.."_default\n[advancement]\n \tid=default\n \trequire_amla= \n \tmax_times=-1 \n\t[effect]\n\t\tapply_to=hitpoints\n\t\tincrease_total=3\n \t[/effect]\n\t{STANDARD_AMLA_HEAL 5%}\n[/advancement]\n#enddef \n \n"
    
    return {codegraphe,codewml}
end


function prem_l (l,i)
    local code = "layers=\""..l[i]
    for k,v in pairs(l) do
        if k ~= i then
            code=code..":"..v
        end
    end
    
    code=code.."\" \n layerselect=\""..l[i].."\" \n }"
    return code
end

function export(layers)
    local nb = 0
    for line in io.lines(dir.."/graph/tree.dot") do
        nb = nb +1
    end
    local contenu = ""
    local i = 1
    for line in io.lines(dir.."/graph/tree.dot") do
        if i <= (nb-1) then
                contenu = contenu..line.."\n"
                i = i+1
        end
    end
        
    for j,k in pairs(layers) do
        local ajout= prem_l(layers,j)
        local file = io.open(dir.."/graph/layers/"..k,"w")
        io.output(file)
        io.write(contenu)
        io.write(ajout)
        io.close(file)
        
    end
    
end

function main(inArbre)
    l_layers={"layer_fleche"}
    local codes = aux(inArbre)
    local code = dot..codes[1].."}"
   local file = io.open(dir.."/graph/tree.dot","w")
    io.output(file)
    io.write(code)
    io.close(file)
    export(l_layers)
    
    local file = io.open(dir.."/graph/tmp.cfg","w")
    
    io.output(file)
    io.write(codes[2])
    io.close(file)
    
end


dofile(dir.."/graph/arbres_lua/"..unit..".lua")
couleur_bordure = defaultbordure

couleur_fleche="#2C2C2C"
couleur_fleche_bonus="#F7E559"
couleur_chiffres="#c0b746"
liste_afaire={}
main(arbre)
local sortie = ""
for i,v in pairs(liste_afaire) do
    sortie=sortie..";"..v[1]..":"..v[2]..":"..v[3]..":"..v[4]..":"..v[5]..":"..v[6]
end
sortie=sortie:sub(2)
print(sortie)
local file = io.open(dir.."/graph/lastcmd","w")
io.output(file)
io.write(sortie)
io.close(file)
