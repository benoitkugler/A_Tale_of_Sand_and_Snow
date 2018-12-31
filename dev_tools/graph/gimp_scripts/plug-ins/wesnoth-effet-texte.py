#!/usr/bin/env python


from gimpfu import pdb, main, PF_STRING, register, gimp
import json
import shutil
import time

GRAPH_PATH = "/home/benoit/.config/wesnoth-1.14/data/add-ons/A_Tale_of_Sand_and_Snow/dev_tools/graph/images/"

# gimp constants
RUN_NONINTERACTIVE = 1
CHANNEL_OP_SUBTRACT = 1
CHANNEL_OP_REPLACE = 2
CHANNEL_OP_INTERSECT = 3
CLIP_TO_IMAGE = 1

def _is_transparent(inImg, inLayer, inX, inY):
    _, pixel = pdb.gimp_drawable_get_pixel(inLayer, inX, inY)
    return pixel[3] == 0


def _is_black(inImg,inLayer,inX,inY):
    _, pixel = pdb.gimp_drawable_get_pixel(inLayer, inX, inY)
    return pixel[0] == 0 and pixel[1] == 0 and pixel[2] == 0


def effet_texte(inColor, inImg):
    layer = pdb.gimp_image_get_active_layer(inImg)
    
    pdb.gimp_context_set_sample_transparent(True)
    pdb.gimp_image_select_contiguous_color(inImg, CHANNEL_OP_REPLACE, layer, 1, 1)
    pdb.gimp_selection_invert(inImg)

    _, x, _, x2, y2  = pdb.gimp_selection_bounds(inImg)
    xmiddle = x + (x2 - x) // 2
    y = y2 - 1
        
    keep = True
    while keep:
        if y < 0:
            print("Error in effet_texte for img {} : y < 0 !".format(inImg))
            return
        if (not _is_transparent(inImg, layer, xmiddle, y)) and  _is_black(inImg, layer, xmiddle, y):
            keep = False
            pdb.gimp_context_set_sample_transparent(False)
            pdb.gimp_image_select_contiguous_color(inImg, CHANNEL_OP_REPLACE, layer, xmiddle, y)
            pdb.gimp_edit_clear(layer)
                
        y -= 1

    _, x1, y1, x2, y2  = pdb.gimp_selection_bounds(inImg)
    newlayer = pdb.gimp_layer_copy(layer, True)

    pdb.gimp_image_select_rectangle(inImg, CHANNEL_OP_REPLACE, x1, y1, x2-x1, y2-y1)
    pdb.gimp_context_set_sample_transparent(True)
    pdb.gimp_image_select_contiguous_color(inImg, CHANNEL_OP_SUBTRACT, layer, x1, y1)
    pdb.gimp_edit_clear(layer)
    
    pdb.gimp_selection_invert(inImg)
    pdb.gimp_image_insert_layer(inImg, newlayer, None, 0)
    pdb.gimp_edit_clear(newlayer)
    
    pdb.script_fu_layerfx_outer_glow(inImg, newlayer, inColor, 75, 0, 0, 0, 0, 5, 0, 1)
    pdb.gimp_image_merge_visible_layers(inImg, CLIP_TO_IMAGE)
    
    pdb.gimp_selection_none(inImg)
    pdb.gimp_displays_flush()


def _find_black_not_transparent(image, layer, x, y_init):
    """Search along y for the first black not transparent pixel"""
    layer.get_pixel_rgn(x,y_init,1,layer.height)

    y = y_init
    while _is_transparent(image, layer, x, y) or not _is_black(image,layer,x,y):
        y += 1
    return y


def change_num(image, inNumero):
    layer = pdb.gimp_image_get_active_layer(image)

    pdb.gimp_context_set_sample_transparent(True)
    pdb.gimp_image_select_contiguous_color(image, CHANNEL_OP_REPLACE,layer, 1, 1)
    pdb.gimp_selection_invert(image)
    _, x, y, x2, y2  = pdb.gimp_selection_bounds(image)
    xthird=x  + ((x2 - x) // 4  * 3)

    y = _find_black_not_transparent(image, layer, xthird, y)

    pdb.gimp_context_set_sample_transparent(False)
    pdb.gimp_image_select_contiguous_color(image, CHANNEL_OP_REPLACE, layer, xthird, y)
    pdb.gimp_edit_clear(layer)
                    
    if inNumero > 1:        
        _, x, y, x2, y2  = pdb.gimp_selection_bounds(image)
        ymiddle = y + ( (y2 - y) // 2)

        keep = True
        while keep:
            if not _is_transparent(image, layer, x, ymiddle):
                keep = False
                pdb.gimp_context_set_sample_transparent(False)
                pdb.gimp_context_set_sample_threshold(1)
                pdb.gimp_image_select_contiguous_color(image, CHANNEL_OP_REPLACE, layer, x+1, ymiddle)
                pdb.gimp_context_set_sample_threshold(0.1)
 
            x += 1
        pdb.gimp_edit_clear(layer)

        _, x1, y1, x2, y2  = pdb.gimp_selection_bounds(image)
        
        pdb.gimp_image_select_rectangle(image, CHANNEL_OP_REPLACE, x1, y1, x2-x1, y2-y1)
        
        filename = GRAPH_PATH + str(inNumero) + ".png"

        imagechiffre = pdb.gimp_file_load(filename, filename)
        layerchiffre = pdb.gimp_image_get_active_layer(imagechiffre)
        
        pdb.gimp_selection_all(imagechiffre)
        pdb.gimp_edit_copy(layerchiffre)
        pdb.gimp_image_delete(imagechiffre)
        
        floating_sel = pdb.gimp_edit_paste(layer,False)
        pdb.gimp_floating_sel_anchor(floating_sel)


def texte(inR,inG,inB,inFichier,highlight_text,change_numero):
    print("\tLoading image {}".format(inFichier))
    image = pdb.gimp_file_load(inFichier,inFichier)
    color = (inR,inG,inB)

    # pdb.gimp_display_new(image)
    if highlight_text:
        print("\t\tHighlighting text...")
        effet_texte(color, image)
    
    if change_numero > 0:
        print("\t\tChanging number...")
        change_num(image, change_numero)
    
    pdb.gimp_selection_none(image)
    layer_id = pdb.gimp_image_get_layers(image)[1][0]
    layer = gimp.Item.from_id(layer_id)
    pdb.script_fu_add_bevel(image, layer, 5, False, False)
    drawable = pdb.gimp_image_get_active_drawable(image)

    pdb.file_png_save(image, drawable, inFichier, inFichier,
                        0,5,0,0,0,0,0) 
    pdb.gimp_image_delete(image)


def launch(arg_string):
    """json formatted string containing a list of texte arguments"""
    l = arg_string.split(";")
    nb = len(l)
    print("Launching gimp text effects ({} to go)...".format(nb))
    ti = time.time()
    for i,text in enumerate(l):
        print("\tItem {} / {} ...".format(i+1, nb))
        id_noeud, r, g, b, highlight_text, max_numero = text.split(":")
        r, g, b, highlight_text, max_numero = int(r), int(g), int(b), int(highlight_text), int(max_numero)
        inFichier = id_noeud + "-1.png"
        if max_numero == 0:
            texte(r, g, b, inFichier, highlight_text, 0)
        else:
            for j in range(2, max_numero +1): # copy before updating
                name = id_noeud + "-" + str(j) + ".png"
                shutil.copy(inFichier, name)
            texte(r, g, b, inFichier, highlight_text, 1) # first udptate
            for j in range(2, max_numero +1):
                name = id_noeud + "-" + str(j) + ".png"
                texte(r, g, b, name, highlight_text, j)
    print("Gimp task done in {:.2f} sec.".format(time.time() - ti))

    # l = json.loads(arg_string)
    # print(l)


register(
    "build_wesnoth_text_effect",
    "Wesnoth AMLA tree effect",
    "Add colored glow to texts in given list of files",
    "Benoit KUGLER", "", "2017",
    "Wesnoth ATE",
    "",
	[(PF_STRING, "string", "Json args", None)],
    [],
    launch,
    menu="<Image>/Filters"
)
# a invoquer from console line with python-fu-build-wesnoth-text-effect RUN-NONINTERACTIVE liste

main()