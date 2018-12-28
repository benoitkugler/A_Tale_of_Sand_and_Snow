(define (script-fu-cree inLayer inLayerF Img)

  
(let*
    (
         (newlayer (car (gimp-layer-copy inLayer 1)))
         (newfond (car (gimp-layer-copy inLayerF 1)))
         (layername (car (gimp-item-get-name inLayer)))
    )
    (gimp-item-set-visible newlayer 1)
    (gimp-image-insert-layer Img newlayer 0 0)
    
    (gimp-image-set-active-layer Img inLayer)
    (gimp-image-insert-layer Img newfond 0 -1)
    (gimp-image-lower-item Img newfond)
    (gimp-item-set-visible newfond 1)
    
    
    (gimp-context-set-sample-transparent 1)
    (gimp-image-select-contiguous-color Img CHANNEL-OP-REPLACE newlayer 10 10)
    (gimp-edit-clear newfond)
    (gimp-item-set-name (car (gimp-image-merge-down Img inLayer CLIP-TO-IMAGE)) layername)
    
    (gimp-selection-invert Img)
    (gimp-context-set-foreground '(117 117 154))
    (gimp-edit-fill newlayer FOREGROUND-FILL)
    (let* 
        (
        (floating-sel (car (gimp-edit-paste newlayer 0))) 
        )
        (gimp-layer-set-opacity floating-sel 70)
        (gimp-floating-sel-anchor floating-sel)
    )
    
    (gimp-layer-set-opacity newlayer 85)

    (gimp-selection-none Img)

    (let*
        (
         (layerfinal (car (gimp-image-get-layer-by-name Img layername)))
        )    
    
    
    (gimp-item-set-visible layerfinal 0)
)
)
)

(define (script-fu-caches inImg inNameLayerFleche inNameLayerFond)

(let* 
    (
         (imagecadenas (car (gimp-file-load RUN-NONINTERACTIVE "/home/benoit/.local/share/wesnoth/1.13/data/add-ons/A_Tale_of_Sand_and_Snow/graph/cadenas.png" "/home/benoit/.local/share/wesnoth/1.13/data/add-ons/A_Tale_of_Sand_and_Snow/graph/cadenas.png")))
        (layercadenas  (car (gimp-image-get-active-layer imagecadenas)))
      )
      (gimp-selection-all imagecadenas)
    (gimp-edit-copy layercadenas)
    (gimp-image-delete imagecadenas)
)
(let* 
    (
        (layerfond (car (gimp-image-get-layer-by-name inImg inNameLayerFond)))
        (layerfleche (car (gimp-image-get-layer-by-name inImg inNameLayerFleche)))
        (nb_layers (car (gimp-image-get-layers inImg)))    
        (alayers (cadr (gimp-image-get-layers inImg)))
        (i 0)
    )
    
    
    (while (< i nb_layers)
        (let* 
                ( 
                (layercurrent (aref alayers i))
                )
        (gimp-selection-none inImg)
            
        (script-fu-add-bevel inImg layercurrent 5 0 0)
        
        (gimp-item-set-visible (aref alayers i) 0)
        (if (not (or (equal? (car (gimp-item-get-name layercurrent)) inNameLayerFleche) (equal? (car (gimp-item-get-name layercurrent)) inNameLayerFond)))
            (script-fu-cree layercurrent layerfond inImg)
        )
        )
        (set! i (+ i 1)) 
        
    )
    (let*
    (
        (cache (car (gimp-image-merge-visible-layers inImg CLIP-TO-IMAGE)))
               
    )
    
    
    (script-fu-add-bevel inImg cache 5 0 0)
    (gimp-item-set-name cache "cache.png")
    
    (gimp-image-lower-item-to-bottom inImg layerfleche)
    (gimp-image-lower-item-to-bottom inImg cache)
    (gimp-image-lower-item-to-bottom inImg layerfond)
    
)
)
)

(script-fu-register
    "script-fu-caches"                        ;func name
    "Caches d'arbre"                                  ;menu label
    "Génère un cache par calque."              ;description
    "Benoit KUGLER"       ;author
    ""
    "2017"                          ;date created
    ""                     ;image type that the script works on
    SF-IMAGE   "Image" 1
    SF-STRING   "Nom du layer de flèches" "layer_fleche.png"
    SF-STRING   "Nom du layer de fond" "layer_fond.png"
  )
(script-fu-menu-register "script-fu-caches" "<Image>/Image")


(define (script-fu-load-caches inDir inNameLayerFleche inColorFondR inColorFondG inColorFondB outDir)
(let*
    (
        (listimg (cadr (file-glob (string-append inDir "/*.png") 1)))
        (nb (car (file-glob (string-append inDir "/*.png") 1)))
        (baseimage (car (gimp-image-new 10 10 RGB)))
        (fondcolor (list inColorFondR inColorFondG inColorFondB))
    )
    
   (while (not (null? listimg))
           (let* 
                (
                    (filename (car listimg))
                    (layer (car (gimp-file-load-layer RUN-NONINTERACTIVE  baseimage filename)))
                )
                (gimp-image-insert-layer baseimage layer 0 0)
           

             (set! listimg (cdr listimg))
             )
    )
    (gimp-image-resize-to-layers baseimage)
    
    (gimp-message "Layers chargés")
    (gimp-selection-all baseimage)
    
    (let* 
        (
           (fond (car (gimp-layer-copy (aref (cadr (gimp-image-get-layers baseimage)) 1) 1)))
           (imgbounds (gimp-selection-bounds baseimage))
           (xmax (cadddr imgbounds))
           (ymax (cadr (cdddr imgbounds)))
        )
        (gimp-item-set-name fond "layer_fond.png")
        (gimp-image-insert-layer baseimage fond 0 0)
        
        (gimp-edit-clear fond)
        (gimp-image-select-round-rectangle baseimage CHANNEL-OP-REPLACE 0 0 xmax ymax 35 35) 
        (gimp-selection-shrink baseimage 3)
        (gimp-selection-feather baseimage 20)
        (gimp-context-set-foreground fondcolor)
        (gimp-edit-fill fond FOREGROUND-FILL)
        (gimp-image-lower-item-to-bottom baseimage fond)
        (plug-in-hsv-noise RUN-NONINTERACTIVE baseimage fond 5 38 63 74)
        (gimp-selection-none baseimage)
         (gimp-message "Fond créé")
        (script-fu-caches baseimage inNameLayerFleche "layer_fond.png")
         (gimp-message "Cache créé")
        (let* (
            (layercache (car (gimp-image-get-layer-by-name baseimage "cache.png")))
            (layerfond (car (gimp-image-get-layer-by-name baseimage "layer_fond.png")))
            (layerfleche (car (gimp-image-get-layer-by-name baseimage inNameLayerFleche)))
        )
        
        (gimp-item-set-visible layerfond 1)
        (gimp-image-merge-down baseimage layercache CLIP-TO-IMAGE)
        (gimp-item-set-visible layerfleche 1)
        (gimp-image-merge-down baseimage layerfleche CLIP-TO-IMAGE)
        
        (gimp-image-scale baseimage 900 550)
        (script-fu-multiple-layer-actions baseimage 1 0 0 '(0 0 0) 4 0 0 0 0 0)
        (gimp-message "Taille de l'image ajustée")

        (script-fu-export-layers baseimage 0  outDir "~l")
        (gimp-message "Layers enregistrés")
        )
    )
    
)
)

(script-fu-register
    "script-fu-load-caches"                        ;func name
    "Caches d'arbre"                                  ;menu label
    "Load et génère un cache par calque."              ;description
    "Benoit KUGLER"       ;author
    ""
    "2017"                          ;date created
    ""                     ;image type that the script works on
    
    SF-DIRNAME  "Dossier contenant les layers" "/home/benoit/.local/share/wesnoth/1.13/data/add-ons/A_Tale_of_Sand_and_Snow/graph/layers"
    SF-STRING   "Nom du layer de flèches" "layer_fleche.png"
    SF-VALUE "Couleur de fond R" "10"
    SF-VALUE "Couleur de fond G" "150"
    SF-VALUE "Couleur de fond B" "40"
    SF-DIRNAME "Dossier d'enregistrement" "/home/benoit/.local/share/wesnoth/1.13/data/add-ons/A_Tale_of_Sand_and_Snow/images/arbres/vranken"
  )


