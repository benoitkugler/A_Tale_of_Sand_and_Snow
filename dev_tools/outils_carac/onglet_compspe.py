from tkinter import ttk
import tkinter as tk
import re 

from convertion import *
from base_app import onglet_compspe

DB_FILE = "lua/DB/competences_spe.lua"

def afficheCompspe():
    
    f = open(DB_FILE,"r")
    lines = f.readlines()
    f.close()
    for i in heroes.winfo_children():
        i.destroy()
        
    col=0
    for j in lines:
        matchname=re.compile('\s*info\["(\w*)"\]\s*=\s*(.*)').search(j)
        if not matchname == None:
            unit_id = matchname.group(1)
            ttk.Button(heroes,text=unit_id,command=lambda h=unit_id:compspe(h)).grid(column=col,row=0)
            col=col+1
    
    ttk.Button(boutons,command=update_compspe,text="Update").grid(column=1,row=0) 
    
           
         
def compspe(hero):    
    global panneau_comp
    panneau_comp["text"]=hero
    for i in panneau_comp.winfo_children():
        i.destroy()
    
    global champ_compspe 
    champ_compspe = [{},{}]
    
    with open(DB_FILE,"r") as f:
        lines = f.readlines()
   
    name=""
    in_func=False
    liste_comp=[]
    
    regexp1=re.compile('\s*info\["'+hero+'"\]\s*=\s*(.*)')
    regexp2=re.compile('\s*function\s*apply\.(\w*)')
    regexp3=re.compile('^end')
    regexp4=re.compile('(.*\d+.*)(--.*)$')
    
    nb_box=0
    partie1 = ttk.Frame(panneau_comp)
    partie1.grid()
    for nl, j in enumerate(lines):
        matchname=regexp1.search(j)
       
        if not matchname == None:
            print("match", matchname.group(1), j)
            print(nl)
            a,dic = stringtodic(purge(matchname.group(1)))
            
            champ_compspe[0][nl]=dic
            champ_compspe[0]["unit"]=hero
            for k in sorted(dic):
                if k == "help_des":
                    champ_compspe[0][nl]["help_des"]=tk.StringVar(value=dic["help_des"])
                elif k == "help_ratios":
                    champ_compspe[0][nl]["help_ratios"]=tk.StringVar(value=dic["help_ratios"])
                    ttk.Entry(panneau_comp,width=150,textvariable=champ_compspe[0][nl]["help_ratios"]).grid()
                else:
                    box = ttk.LabelFrame(partie1,text=dic[k]["name"])
                    liste_comp.append(dic[k]["name"])
                    for r in sorted(dic[k]):
                        box2=ttk.Frame(box)
                        if r.isdigit():
                            champ_compspe[0][nl][k][r]["cout_suivant"]=tk.StringVar(value=dic[k][r]["cout_suivant"])
                            champ_compspe[0][nl][k][r]["des"]=tk.StringVar(value=dic[k][r]["des"])
                            ttk.Label(box2,text="Cout lvl suivant").grid()
                            ttk.Entry(box2,width=5,textvariable=champ_compspe[0][nl][k][r]["cout_suivant"]).grid(column=1,row=0)
                            ttk.Label(box2,text="Description").grid(column=2,row=0)
                            ttk.Entry(box2,width=55,textvariable=champ_compspe[0][nl][k][r]["des"]).grid(column=3,row=0)
                        else:
                            champ_compspe[0][nl][k][r]=tk.StringVar(value=dic[k][r])
                        box2.grid()
                    box.grid(row=int(nb_box/2),column=nb_box%2)
                    nb_box=nb_box+1
                
                    
            
            
        
            
        matchapply=regexp2.search(j)
        if not matchapply == None:
            name='"'+matchapply.group(1)+'"'
            in_func=True
          
        matchend=regexp3.search(j)
        if not matchend == None:
            in_func=False
          
       
        if in_func :
            match = regexp4.search(j) 
            if not match == None and name in liste_comp:
                champ_compspe[1][nl]=[tk.StringVar(value=match.group(1)),match.group(2)]
                box = ttk.LabelFrame(panneau_comp,text=name)
                ttk.Label(box,text=match.group(2)).grid()
                ttk.Entry(box,width=150,textvariable=champ_compspe[1][nl][0]).grid(column=1,row=0)
                box.grid()
         


#le dictinnaire contient ds StringVar 
def dictostring(dic):
    s ="{"
    if type(dic)==type(tk.StringVar()):
        return dic.get()
    else:
        for i in sorted(dic,key=lambda s: "zzzzzzz"+s if s.isdigit() else s):
            if i.isdigit():
                s=s+dictostring(dic[i])+","
            else:
                s=s+i+"="+dictostring(dic[i])+","
        s =s[0:-1]
        s=s+"}"
        return s
    
def update_compspe():
    for i in champ_compspe[0]:
        if type(i)==type(1):
            newline = dictostring(champ_compspe[0][i])
            fin=open(DB_FILE,"r")
            lines=fin.readlines()
            fin.close()
            fout=open(DB_FILE,"w")
            nl=0
            for l in lines:
                if nl == int(i):
                    fout.write('info["'+champ_compspe[0]["unit"]+'"]='+newline+"\n")
                else:
                    fout.write(l)
                nl=nl+1
            fout.close()
            
    fin=open(DB_FILE,"r")
    lines=fin.readlines()
    fin.close()
    fout=open(DB_FILE,"w")
    nl=0
    for l in lines:
        if nl in champ_compspe[1]:
            fout.write(champ_compspe[1][nl][0].get()+champ_compspe[1][nl][1]+"\n")
        else:
            fout.write(l)
        nl=nl+1
    fout.close() 
    print("Update done.")



boutons=ttk.Frame(onglet_compspe)
boutons.grid()
heroes=ttk.LabelFrame(boutons,text="Heroes")
heroes.grid()
panneau_comp=tk.LabelFrame(onglet_compspe)
panneau_comp.grid()
