import re
import json 

MARQUE = "@"
"""Never used on lua code"""

def purge(string):
    """Remove spaces and line breaks 
    outside of " quoted strings"""
    s = ""
    inquote=False
    for i,c in enumerate(string):
        if c =='"':
            if i > 0 and string[i-1] != "\\":
                inquote = not inquote
        if not inquote:
            if not (c == " " or c =="\n"):
                s=s+c
        else:
            s=s+c
    return s


def place_marque(string):
    nb_crochets=0
    inquote=False
    r=""
    for i in string:
        if not inquote:
            if i == '{':
                nb_crochets=nb_crochets+1
                r=r+i
            elif i == '}':
                nb_crochets=nb_crochets-1
                r=r+i
            elif i ==",":
                if nb_crochets == 1:
                    r=r+ MARQUE
                else:
                    r=r+","
            elif i == '"':
                inquote = not inquote
                r=r+i
            else:
                r=r+i
        else:
            if i == '"':
                inquote = not inquote
            r=r+i
    return r


def stringtodic(string):
    dic ={}
    champs_vides=0
    if string[0] == '{':
        s = place_marque(string)
        s = s[1:-1]
        if not s:
            return "", {}
            
        for k in s.split(MARQUE):
            index,value = stringtodic(k)
            if index == "":
                dic[str(champs_vides)] = value
                champs_vides += 1
            else:
                dic[index] =value
        return "",dic
    else:
        a= string.split("=",1)
        return a[0],a[1]
