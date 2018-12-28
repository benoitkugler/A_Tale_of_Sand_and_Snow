import tkinter as tk
from tkinter import ttk
import os
       
root = tk.Tk()
root.title("Caractéristiques des personnages")
root.iconbitmap("@icon-game.xbm")
root.minsize(600,200)

barre_onglets=ttk.Notebook(root)
barre_onglets.grid()

onglet_heroes=ttk.Frame(barre_onglets)
onglet_experience=ttk.Frame(barre_onglets)
onglet_compspe=ttk.Frame(barre_onglets)
onglet_amla=ttk.Frame(barre_onglets)
onglet_combat=ttk.Frame(barre_onglets)

barre_onglets.add(onglet_heroes,text="Caractéristiques des héroes")
barre_onglets.add(onglet_experience,text="Gain d'Expérience spéciale")
barre_onglets.add(onglet_compspe,text="Compétences spéciales")
barre_onglets.add(onglet_amla,text="Avancements")
barre_onglets.add(onglet_combat,text="Event combat")

# onglet_amla.init(barre_onglets)
# onglet_combat.init(barre_onglets)
# onglet_compspe.init(barre_onglets)
# onglet_heros.init(barre_onglets)
# onglet_experience.init(barre_onglets)
