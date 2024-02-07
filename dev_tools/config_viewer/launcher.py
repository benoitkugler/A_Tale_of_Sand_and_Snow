# coding: utf-8
import os
from tkinter import ttk

from base_app import barre_onglets, root
from onglet_heros import afficheHeroes
from onglet_experience import afficheExp
from onglet_compspe import afficheCompspe
from onglet_amla import afficheAmla
from onglet_combat import afficheCombat

os.chdir("../..")
print(os.getcwd())

def Tab(event):
    tab = barre_onglets.index("current")
    if tab == 0:
        afficheHeroes()
    elif tab == 1:
        afficheExp()
    elif tab == 2:
        afficheCompspe()
    elif tab == 3:
        afficheAmla()
    elif tab == 4:
        afficheCombat()


barre_onglets.bind("<<NotebookTabChanged>>",Tab)

s = ttk.Style()
s.theme_use('alt')

root.mainloop()


