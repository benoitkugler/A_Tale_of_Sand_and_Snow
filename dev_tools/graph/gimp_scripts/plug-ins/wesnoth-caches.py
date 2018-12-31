#!/usr/bin/env python
# coding=utf-8

from gimpfu import pdb, main, PF_STRING, PF_VALUE, register, gimp
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
FILL_FOREGROUND = 0
RGB = 0

def _is_transparent(inImg, inLayer, inX, inY):
    _, pixel = pdb.gimp_drawable_get_pixel(inLayer, inX, inY)
    return pixel[3] == 0


def _is_black(inImg,inLayer,inX,inY):
    _, pixel = pdb.gimp_drawable_get_pixel(inLayer, inX, inY)
    return pixel[0] == 0 and pixel[1] == 0 and pixel[2] == 0


def cree_background(inLayer,inLayerF,Img):
	"""Add background to inLayer"""
	newlayer = pdb.gimp_layer_copy(inLayer, True)
	newfond = pdb.gimp_layer_copy(inLayerF, True)
	layername = pdb.gimp_item_get_name(inLayer)
		
	pdb.gimp_item_set_visible(newlayer, True)
	pdb.gimp_image_insert_layer(Img,newlayer, None, 0)
	
	pdb.gimp_image_set_active_layer(Img,inLayer)
	pdb.gimp_image_insert_layer(Img, newfond, None, -1)
	pdb.gimp_image_lower_item(Img, newfond)
	pdb.gimp_item_set_visible(newfond, 1)
	
	pdb.gimp_context_set_sample_transparent(True)
	pdb.gimp_image_select_contiguous_color(Img, CHANNEL_OP_REPLACE, newlayer, 10, 10)
	pdb.gimp_edit_clear(newfond)
	pdb.gimp_item_set_visible(inLayer, True)
	clipped_layer = pdb.gimp_image_merge_down(Img, inLayer, CLIP_TO_IMAGE)
	pdb.gimp_item_set_name(clipped_layer, layername)
	
	pdb.gimp_selection_invert(Img)
	pdb.gimp_context_set_foreground((117, 117, 154))
	pdb.gimp_edit_fill(newlayer, FILL_FOREGROUND)

	floating_sel = pdb.gimp_edit_paste(newlayer,0) 
	pdb.gimp_layer_set_opacity(floating_sel, 70)
	pdb.gimp_floating_sel_anchor(floating_sel)
		
	pdb.gimp_layer_set_opacity(newlayer, 85)
	pdb.gimp_selection_none(Img)

	layerfinal = pdb.gimp_image_get_layer_by_name(Img, layername)
	pdb.gimp_item_set_visible(layerfinal , False)


def caches(inImg, inNameLayerFleche, inNameLayerFond):
	path_cadenas = GRAPH_PATH + "cadenas.png"
	imagecadenas = pdb.gimp_file_load(path_cadenas, path_cadenas)
	layercadenas  = pdb.gimp_image_get_active_layer(imagecadenas)
      
	pdb.gimp_selection_all(imagecadenas)
	pdb.gimp_edit_copy(layercadenas)
	pdb.gimp_image_delete(imagecadenas)

	layerfond = pdb.gimp_image_get_layer_by_name(inImg, inNameLayerFond)
	layerfleche = pdb.gimp_image_get_layer_by_name(inImg, inNameLayerFleche)
	_, alayers = pdb.gimp_image_get_layers(inImg)  
	
	for layercurrent in alayers: 
		pdb.gimp_selection_none(inImg)    
		layercurrent = gimp.Item.from_id(layercurrent)
		pdb.script_fu_add_bevel(inImg, layercurrent, 5, 0, 0)

		pdb.gimp_item_set_visible(layercurrent, False)
		layername = pdb.gimp_item_get_name(layercurrent)
		if not ( layername == inNameLayerFleche or layername == inNameLayerFond):
			cree_background(layercurrent, layerfond, inImg)

	cache = pdb.gimp_image_merge_visible_layers(inImg, CLIP_TO_IMAGE)
	pdb.script_fu_add_bevel(inImg, cache, 5, 0, 0)
	pdb.gimp_item_set_name(cache, "cache.png")

	pdb.gimp_image_lower_item_to_bottom(inImg, layerfleche)
	pdb.gimp_image_lower_item_to_bottom(inImg, cache)
	pdb.gimp_image_lower_item_to_bottom(inImg, layerfond)


def load_caches(args):
	inColorFondR, inColorFondG, inColorFondB, outDir = args.split(" ")
	inDir, inNameLayerFleche = "layers", "layer_fleche-1.png"
	inColorFondR, inColorFondG, inColorFondB = int(inColorFondR), int(inColorFondG), int(inColorFondB)
	
	nb, listimg = pdb.file_glob(inDir + "/*.png", 1)
	baseimage = pdb.gimp_image_new(10, 10, RGB)
	fondcolor =(inColorFondR,inColorFondG,inColorFondB)

	for filename in listimg:
		layer = pdb.gimp_file_load_layer(baseimage, filename)
		pdb.gimp_image_insert_layer(baseimage, layer, None, 0)

	pdb.gimp_image_resize_to_layers(baseimage)
	pdb.gimp_message("Layers chargés")
	pdb.gimp_selection_all(baseimage)

	layerfond = pdb.gimp_image_get_layers(baseimage)[1][1]
	layerfond = gimp.Item.from_id(layerfond)
	fond = pdb.gimp_layer_copy(layerfond, 1)
	_,_,_, xmax, ymax = pdb.gimp_selection_bounds(baseimage)

	pdb.gimp_item_set_name(fond, "layer_fond.png")
	pdb.gimp_image_insert_layer(baseimage, fond, None, 0)

	pdb.gimp_edit_clear(fond)
	pdb.gimp_image_select_round_rectangle(baseimage, CHANNEL_OP_REPLACE, 0, 0, xmax, ymax, 35, 35) 
	pdb.gimp_selection_shrink(baseimage, 3)
	pdb.gimp_selection_feather(baseimage,20)
	pdb.gimp_context_set_foreground(fondcolor)
	pdb.gimp_edit_fill(fond, FILL_FOREGROUND)
	pdb.gimp_image_lower_item_to_bottom(baseimage, fond)
	pdb.plug_in_hsv_noise(baseimage, fond, 5, 38, 63, 74)
	pdb.gimp_selection_none(baseimage)
	pdb.gimp_message("Fond créé")
	caches(baseimage, inNameLayerFleche, "layer_fond.png")
	pdb.gimp_message("Cache créé")

	layercache = pdb.gimp_image_get_layer_by_name(baseimage, "cache.png")
	layerfond = pdb.gimp_image_get_layer_by_name(baseimage, "layer_fond.png")
	layerfleche  =pdb.gimp_image_get_layer_by_name(baseimage, inNameLayerFleche)

	pdb.gimp_item_set_visible(layerfond, True)
	pdb.gimp_image_merge_down(baseimage, layercache, CLIP_TO_IMAGE)
	pdb.gimp_item_set_visible(layerfleche, True)
	pdb.gimp_image_merge_down(baseimage, layerfleche, CLIP_TO_IMAGE)

	pdb.gimp_image_scale(baseimage, 900, 550)
	# drawable = pdb.gimp_image_get_active_drawable(baseimage)
	pdb.script_fu_multiple_layer_actions(baseimage, None, 
											0, 0, (0, 0, 0), 4, 0, 0, 0, 0, 0)
	pdb.gimp_message("Taille de l'image ajustée")

	pdb.script_fu_export_layers(baseimage, None, outDir, "~l")
	pdb.gimp_message("Layers enregistrés")

register(
    "build_wesnoth_caches",
    "Wesnoth AMLA tree caches",
    "Build caches for given amla tree",
    "Benoit KUGLER", "", "2017",
    "Wesnoth ATE",
    "",
	[
		(PF_STRING, "string", "args", None)
	],
    [],
    load_caches,
    menu="<Image>/Filters"
)
# a invoquer from console line with python-fu-build-wesnoth-text-effect RUN-NONINTERACTIVE liste
main()