#!/bin/bash
echo "Welcome in the ALMA tree image builder !"
 
ADDON_DATA_PATH=$HOME/.var/app/org.wesnoth.Wesnoth/data/wesnoth/1.17/data/add-ons/A_Tale_of_Sand_and_Snow/
WESNOTH_PATH=/var/lib/flatpak/app/org.wesnoth.Wesnoth/current/active/files/share/wesnoth/
GIMP_CMD="flatpak run org.gimp.GIMP"
set -e;

keep="1"
full_process="0"
while [ $keep = "1" ]
do  
    echo "Character ID ? :";
    read commande;
    if [ "$commande" = "" ]; then
        echo "Missing parameters !"
    else
        tabl_par=(${commande// / })
        id=${tabl_par[0]}
        arg1=${tabl_par[1]}
        if [ "$arg1" == "-f" ]; then
            full_process="1"
        fi;
        keep="0"
    fi;
done  


if [ $full_process = "0" ]; then
echo "Lancer la création du code du graphe et des ALMA ? (Poursuivre : Entree)"
read 
fi;

rm -r ${ADDON_DATA_PATH}dev_tools/graph/layers;
mkdir ${ADDON_DATA_PATH}dev_tools/graph/layers;
lua_out=$(lua ${ADDON_DATA_PATH}dev_tools/graph/build_graph.lua $id); 
lua_out=($lua_out)

liste_layers=${lua_out[0]}
couleurfond=${lua_out[1]}" "${lua_out[2]}" "${lua_out[3]}
echo "Codes générés !";

if [ $full_process = "0" ]; then
echo "Lancer la création du graphe et des layers ? (Poursuivre : Entree)"
read
fi;

dot -q -Tpng ${ADDON_DATA_PATH}dev_tools/graph/tree.dot -o ${ADDON_DATA_PATH}dev_tools/graph/images/tree.png -Gimagepath=${ADDON_DATA_PATH}images:${WESNOTH_PATH}/data/core/images;
cd ${ADDON_DATA_PATH}dev_tools/graph/layers;

for i in *
do
    dot -q -Tpng $i -o $i"-1.png" -Gimagepath=${ADDON_DATA_PATH}images:${WESNOTH_PATH}/data/core/images;
    rm $i
done &&
echo "Création des layers réussie !";

if [ $full_process = "0" ]; then
echo "Voir le graphe ? (Poursuivre : o, sauter: Entree)"
read view;
    if [ "$view" = "o" ]; then
        display ${ADDON_DATA_PATH}dev_tools/graph/images/tree.png
    fi;
fi;

if [ $full_process = "0" ]; then
echo "Lancer la mise à jour des layers ? (Poursuivre : o, sauter : Entree)"
read update_layers
    if [ "$update_layers" = "o" ]; then
        cmd="${GIMP_CMD} -i -d -b '(python-fu-build-wesnoth-text-effect RUN-NONINTERACTIVE \""$liste_layers"\")' -b '(gimp-quit 1)'"
        eval $cmd &&
        echo "Mise à jour des layers (couleur, nombre) réussie";
    fi;
fi;


if [ $full_process = "0" ]; then   
echo "Lancer la création de la couche cachante ? (Poursuivre : Entree)"
read 
fi;

# cd ${ADDON_DATA_PATH}dev_tools/graph
rm -r -f ${ADDON_DATA_PATH}images/arbres/$id;
mkdir -p ${ADDON_DATA_PATH}images/arbres/$id;
args=$couleurfond" "$ADDON_DATA_PATH"images/arbres/"$id
com="${GIMP_CMD} -i -d -b '(python-fu-build-wesnoth-caches RUN-NONINTERACTIVE \""$args"\")' -b '(gimp-quit 1)'"
eval $com

if [ $full_process = "0" ]; then
echo "Ouvrir le dossier ? (Poursuivre : o, sauter: Entree)"
read view;
    if [ "$view" = "o" ]; then  
        nautilus ${ADDON_DATA_PATH}images/arbres/$id
    fi;
fi;

echo "Building process achieved with succes."
exit 0
