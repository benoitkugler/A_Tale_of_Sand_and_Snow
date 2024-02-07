from tkinter import ttk
import tkinter as tk
import re 

from base_app import onglet_combat

def afficheCombat():
    for i in panneau.winfo_children():
        i.destroy()
    global champ_combat 
    champ_combat = {}
    
    f = open("lua/implementation/event_combat.lua","r")
    lines = f.readlines()
    f.close()
    nl = 0
    
    regexp1 = re.compile('function\s*apply\.(\w*)')
    regexp2=re.compile('^end')
    regexp3=re.compile('(.*\d+.*)(--.*)$')
    
    name=""
    in_func=False
    for j in lines:
        
        matchname=regexp1.match(j)
    
        if not matchname == None:
            name=matchname.group(1)
            in_func=True
        if not regexp2.match(j) ==  None:
            in_func=False
            
        match = regexp3.search(j) 
        if in_func and not match == None:
            champ_combat[nl]=[0,0]
            champ_combat[nl][0]=tk.StringVar(value=match.group(1))
            box=ttk.Frame(panneau)
            champ_combat[nl][1]=match.group(2)
            ttk.Label(box,width=30,text=name+" : "+match.group(2)).grid()
            ttk.Entry(box,width=120,textvariable=champ_combat[nl][0]).grid(column=1,row=0)
            box.grid()
        nl=nl+1
    
def update_combat():
    fin=open("lua/implementation/event_combat.lua","r")
    lines=fin.readlines()
    fin.close()
    fout=open("lua/implementation/event_combat.lua","w")
    nl=0
    for l in lines:
        if nl in champ_combat:
            fout.write(champ_combat[nl][0].get()+champ_combat[nl][1]+"\n")
        else:
            fout.write(l)
        nl=nl+1
    fout.close()  
    print("Update done.")



panneau = ttk.LabelFrame(onglet_combat,text="Specials & abilities")
panneau.grid()
ttk.Button(onglet_combat,command=update_combat,text="Update").grid()
