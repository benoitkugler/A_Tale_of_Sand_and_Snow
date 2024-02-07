from tkinter import ttk
import tkinter as tk
import re 

from base_app import onglet_experience


def afficheExp():
    for i in div_panneau_exp.winfo_children():
        i.destroy()
    
    global champ_exp 
    champ_exp = {}
    
    f = open("lua/config/special_exp_gain.lua","r")
    lines = f.readlines()
    f.close()
    nl = 0
    regexp1 = re.compile('function\s*exp_functions\.(\w*)')
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
            champ_exp[nl]=[0,0]
            champ_exp[nl][0]=tk.StringVar(value=match.group(1))
            box=ttk.Frame(div_panneau_exp)
            champ_exp[nl][1]=match.group(2)
            ttk.Label(box,width=30,text=name+" : "+match.group(2)).grid()
            ttk.Entry(box,width=120,textvariable=champ_exp[nl][0]).grid(column=1,row=0)
            box.grid()
        nl=nl+1
        
    
    div_panneau_exp.update_idletasks()
    




def update_xp():
    with open("lua/config/special_exp_gain.lua","r") as fin:
        lines=fin.readlines()
    with open("lua/config/special_exp_gain.lua","w") as fout:
        nl=0
        for l in lines:
            if nl in champ_exp:
                fout.write(champ_exp[nl][0].get()+champ_exp[nl][1]+"\n")
            else:
                fout.write(l)
            nl=nl+1
    print("Update done.")

div_panneau_exp = ttk.LabelFrame(onglet_experience,text="Experience")
div_panneau_exp.grid()
ttk.Button(onglet_experience,command=update_xp,text="Update").grid()
