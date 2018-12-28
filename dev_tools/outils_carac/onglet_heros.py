from tkinter import ttk
import tkinter as tk
import re 
import os 

from base_app import onglet_heroes

def doublons_cfg(l):
    s = []
    r= []
    for j in l:
        s.append(j[0:-5])
        
    for j in s:
        if not(j in r):
            r.append(j)
    return sorted(r)

# heroes
def afficheData(hero,heroes):
    
    for i in div_panneau.winfo_children():
        i.destroy()
    panneau=ttk.Frame(div_panneau)
    panneau.grid()
    
    
    heroes.sort()
    global champ 
    champ = {}
    
    column=0
    for i in heroes:
        if hero in i:
            champ[i]={}
            champ[i]["var"]= {}
            f = open("units/heroes/"+i,"r")
            champ[i]["widget"]=ttk.LabelFrame(panneau,text=i)
            lines = f.readlines()
            nl = 0
            current_atk=False
            name=""
            regexp1=re.compile('\s*name\s*=\s*(\w*)' )
            regexp2 =re.compile('\s*(damage|number|experience|hitpoints|movement)\s*=\s*([0-9]*)' )
            for j in lines:
                if "[attack]" in j:
                    current_atk=True
                if "[/attack]" in j:
                    current_atk=False
                    name=""
                    
                matchname=regexp1.match(j)
                if not matchname == None:
                    if current_atk:
                        name=matchname.group(1)
                        
                    
                
                match = regexp2.match(j)
                if not match == None:
                    champ[i]["var"][nl]=tk.StringVar(value=match.group(1)+"="+match.group(2))
                    box = ttk.Frame(champ[i]["widget"])
                    ttk.Label(box,width=12,text=name+" :").grid()
                    ttk.Entry(box,width=20,textvariable=champ[i]["var"][nl]).grid(column=1,row=0)
                    box.grid()
                    
                nl=nl+1
                
            
            champ[i]["widget"].grid(column=column,row=0)
            f.close()
            column = column +1
    
    div_panneau.update_idletasks()
    ttk.Button(div_panneau,command=update_heroes,text="Update").grid()
    
def update_heroes():
    for fichier in champ:
        fin=open("units/heroes/"+fichier,"r")
        lines=fin.readlines()
        fin.close()
        fout=open("units/heroes/"+fichier,"w")
        nl=0
        for l in lines:
            if nl in champ[fichier]["var"]:
                fout.write(champ[fichier]["var"][nl].get()+"\n")
            else:
                fout.write(l)
            nl=nl+1
        fout.close()    
    print("Update done.")

def afficheHeroes():
    global panel_heroes
    for i in panel_heroes.winfo_children():
        i.destroy()
    h = os.listdir("units/heroes")
    h_simple = doublons_cfg(h)
    liste_button =[]
    for i in h_simple:
        ttk.Button(panel_heroes,text=i,command= lambda i=i: afficheData(i,h)).grid()


# Onglet heros
panel_heroes=ttk.LabelFrame(onglet_heroes,text="Héros présents")
div_panneau = ttk.LabelFrame(onglet_heroes,height=400,width=800,text="Caractéristiques")

panel_heroes.grid()
div_panneau.grid(column=1,row=0)
