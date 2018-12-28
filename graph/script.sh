#!/bin/bash
echo "Bienvenue dans l'outil de création d'arbre de compétences !"
 
ADDON_DATA_PATH=$HOME/.config/wesnoth-1.14/data/add-ons/A_Tale_of_Sand_and_Snow/
WESNOTH_PATH=/usr/share/games/wesnoth/1.14

keep="1"
full_process="0"
while [ $keep = "1" ]
do  
    echo "Choisir l'ID du personnage (fichier lua à charger et dossier d'écriture) :";
    read commande;
    if [ "$commande" = "" ]; then
        echo "Parametres manquants !"
    else
        tabl_par=(${commande// / })
        arg1=${tabl_par[0]}
        if [ "$arg1" == "-f" ]; then
            full_process="1"
            id=${tabl_par[1]}
        else
            id=$arg1
        fi;
        keep="0"
    fi;
done  


couleurfond=$(lua -e "dofile(\"${ADDON_DATA_PATH}graph/arbres_lua/"$id".lua\"); print(defaultfond)")


if [ $full_process = "0" ]; then
echo "Lancer la création du code du graphe et des ALMA ? (Poursuivre : Entree)"
read 
fi;

rm -r ${ADDON_DATA_PATH}graph/layers;
mkdir ${ADDON_DATA_PATH}graph/layers;
> ${ADDON_DATA_PATH}graph/tmp.cfg;
myvar=$(lua ${ADDON_DATA_PATH}graph/gener.lua $id ${ADDON_DATA_PATH}); 
echo "Codes générés !";

if [ $full_process = "0" ]; then
echo "Lancer la création du graphe et des layers ? (Poursuivre : Entree)"
read
fi;

dot -Tpng ${ADDON_DATA_PATH}graph/tree.dot -o ${ADDON_DATA_PATH}graph/images/tree.png -Gimagepath=${ADDON_DATA_PATH}images:${WESNOTH_PATH}/data/core/images;
cd ${ADDON_DATA_PATH}graph/layers;

for i in *
do
    dot -Tpng $i -o $i"-1.png" -Gimagepath=${ADDON_DATA_PATH}images:${WESNOTH_PATH}/data/core/images;
    rm $i
done &&
echo "Création des layers réussie !";

if [ $full_process = "0" ]; then
echo "Voir le graphe ? (Poursuivre : o, sauter: Entree)"
read view;
    if [ "$view" = "o" ]; then
        display ${ADDON_DATA_PATH}graph/images/tree.png
    fi;
fi;

if [ $full_process = "0" ]; then
echo "Lancer la mise à jour des layers ? (Poursuivre : Entree)"
read 
fi;

commandebash="gimp-console -d"

for i in $(echo $myvar| tr ";" "\n")
do
param=(${i//:/ })

    if [ ${param[5]} = 0 ]; then
        if [ ${param[4]} = 1 ]; then
            commandebash=$commandebash" -b '(script-fu-texte "${param[1]}" "${param[2]}" "${param[3]}" \""${param[0]}"-1.png\" 1 0)'"
        else
            commandebash=$commandebash" -b '(script-fu-texte 0 0 0 \""${param[0]}"-1.png\" 0 0)'"
        fi
    else
        commandebash=$commandebash" -b '(script-fu-texte "${param[1]}" "${param[2]}" "${param[3]}" \""${param[0]}"-"1".png\" "${param[4]}" 1)'"
        for ((j=2;j<=${param[5]};j++))
        do
            cp ${param[0]}"-1.png" ${param[0]}"-"$j".png" 
            commandebash=$commandebash" -b '(script-fu-texte "${param[1]}" "${param[2]}" "${param[3]}" \""${param[0]}"-"$j".png\" "${param[4]}" "$j")'"
        done
    fi
done &&
commandebash=$commandebash" -b '(gimp-quit 1)'"
eval $commandebash &&
echo "Mise à jour des layers (couleur, nombre) réussie";


if [ $full_process = "0" ]; then   
echo "Lancer la création de la couche cachante ? (Poursuivre : Entree)"
read 
fi;

cd ${ADDON_DATA_PATH}graph
rm -r ${ADDON_DATA_PATH}images/arbres/$id;
mkdir ${ADDON_DATA_PATH}images/arbres/$id;
com="gimp-console -c -d -b '(script-fu-load-caches \"layers\" \"layer_fleche-1.png\" "$couleurfond" \"${ADDON_DATA_PATH}images/arbres/"$id"\")' -b '(gimp-quit 1)'"
eval $com

if [ $full_process = "0" ]; then
echo "Ouvrir le dossier ?"
read
fi;

nautilus ${ADDON_DATA_PATH}images/arbres/$id
exit 0
