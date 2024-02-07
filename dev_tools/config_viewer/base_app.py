import tkinter as tk
from tkinter import ttk
import os
       
root = tk.Tk()
root.title("Configuration editor")
root.minsize(600,200)

barre_onglets=ttk.Notebook(root)
barre_onglets.grid()

onglet_heroes=ttk.Frame(barre_onglets)
onglet_experience=ttk.Frame(barre_onglets)
onglet_compspe=ttk.Frame(barre_onglets)
onglet_amla=ttk.Frame(barre_onglets)
onglet_combat=ttk.Frame(barre_onglets)

barre_onglets.add(onglet_heroes,text="Heroes units")
barre_onglets.add(onglet_experience,text="Special XP gain")
barre_onglets.add(onglet_compspe,text="Special skills")
barre_onglets.add(onglet_amla,text="AMLA")
barre_onglets.add(onglet_combat,text="Combat events")

 