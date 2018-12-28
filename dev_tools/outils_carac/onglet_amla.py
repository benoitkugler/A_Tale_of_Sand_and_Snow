from tkinter import ttk
import tkinter as tk
import re
import os 

from base_app import onglet_amla

#Frame avec une bordure
s = ttk.Style()
s.theme_use('alt')
s.configure('Border.TFrame',highlightbackground="red", highlightcolor="red", highlightthickness=1,relief="solid")

def afficheAmlaHero(hero):
    panneau_amla["text"]=hero
    for i in panneau_amla.winfo_children():
        i.destroy()
    
    global champ_amla 
    champ_amla = {"hero":hero}
    
    dic_boxes={}
    f = open("utils/amla/"+hero,"r")
    lines = f.readlines()
    f.close()
    nl = 0
   
    id_adv=""
    in_effect=False
    in_adv=False
    liste_comp=[]
    
    
    regexp1=re.compile('\s*\[effect\]\s*')
    regexp2=re.compile('\s*\[/effect\]\s*')
    regexp3=re.compile('\d+')
    regexp4=re.compile('\s*\[advancement\]\s*')
    regexp5=re.compile('\s*id\s*=\s*(\w*)\s*')
    regexp6=re.compile('\s*\{STANDARD_AMLA_HEAL\s*(\d+)\s*%\s*\}')
    
    nb_col=0
    nb_row=0
    for j in lines:
        matchdigit=regexp3.search(j)
        if in_effect and not matchdigit == None:
            champ_amla[nl] = tk.StringVar(value=j.replace("\n",""))
            ttk.Entry(dic_boxes[id_adv],width=50,textvariable=champ_amla[nl]).grid(column=2+(nb_col%2),row=nb_row)
            if nb_col%2 == 1:
                nb_row=nb_row+1
            nb_col=nb_col+1
            
        matchstandard=regexp6.search(j)
        if not matchstandard == None:
            champ_amla[nl] = tk.StringVar(value=j.replace("\n",""))
            ttk.Entry(dic_boxes[id_adv],width=40,textvariable=champ_amla[nl]).grid(column=1,row=0)
            ttk.Label(dic_boxes[id_adv],width=20,text=id_adv).grid(column=0,row=0)
            
        matcheffect=regexp1.search(j)
        if not matcheffect == None:
            in_effect=True
        
        matchend=regexp2.search(j)
        if not matchend == None:
            in_effect=False
            
        matchadv=regexp4.search(j)
        if not matchadv == None:
            in_adv=True
            nb_col=0
            nb_row=0
        
        
        matchid=regexp5.search(j)
        if in_adv and not matchid == None:
            id_adv = matchid.group(1)
            dic_boxes[id_adv]=ttk.Frame(panneau_amla)
            dic_boxes[id_adv].grid(sticky=tk.W)
            ttk.Separator(panneau_amla).grid(sticky=tk.E+tk.W)
            in_adv=False
            
        nl=nl+1
   
    
def update_amla():
    fichier=champ_amla["hero"]
    fin=open("utils/amla/"+fichier,"r")
    lines=fin.readlines()
    fin.close()
    fout=open("utils/amla/"+fichier,"w")
    nl=0
    for l in lines:
        if nl in champ_amla:
            fout.write(champ_amla[nl].get()+"\n")
        else:
            fout.write(l)
        nl=nl+1
    fout.close() 
    print("Update done.")

def afficheAmla():
    for i in heroes.winfo_children():
        i.destroy()
        
    h = os.listdir("utils/amla")
    col=0
    liste_button =[]
    for i in h:
        ttk.Button(heroes,text=i,command= lambda i=i: afficheAmlaHero(i)).grid(column=col,row=0)
        col=col+1
        
    ttk.Button(boutons,command=update_amla,text="Update").grid(column=1,row=0) 
        


boutons=ttk.Frame(onglet_amla)
boutons.grid()
heroes=ttk.LabelFrame(boutons,text="Heroes")
heroes.grid()
panneau_amla=tk.LabelFrame(onglet_amla)
panneau_amla.grid()
