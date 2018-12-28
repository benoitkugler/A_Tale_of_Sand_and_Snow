-- Génère un graphe des relations d'une DB


dot = "digraph simple_hierarchy { \n splines=ortho;size=\"15,10\";rankdir=LR;nodesep=0.2;ranksep=0.2;bgcolor=transparent;node [shape=none] \n"


function  block_simple (txt,id)
    return id .. " [  label= " .. txt .. "] \n" 
end


function relie (n1,n2)
    return n1 .. " -> " .. n2 .. "[penwidth=\"7\",color=\"" .. couleur_fleche .. "\",arrowsize=\"1.5\"]; \n"
end


function aux (arb)
    local liens = lienparents(arb)
    local codegraphe = ""
    
    for i,noeud in pairs(arb) do
        codegraphe = codegraphe..block_simple(noeud.txt,noeud.id) 
    
        if noeud.parents ~= nil then
            for j,k in pairs(noeud.parents)  do  
                codegraphe = codegraphe..relie(k,noeud.id)
             end
        end
        
    return codegraphe
end


function main(inArbre)
    local codegrahe = aux(inArbre)
    local code = dot..codegrahe.."}"
    local file = io.open(dir.."/graph/graph.dot","w")
    io.output(file)
    io.write(code)
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
