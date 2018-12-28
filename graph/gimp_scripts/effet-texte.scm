(define (is-transparent inImg inLayer inX inY)
    (gimp-image-select-item inImg CHANNEL-OP-REPLACE inLayer)
    (gimp-image-select-rectangle inImg CHANNEL-OP-INTERSECT inX inY 1 1)
    (car (gimp-selection-is-empty inImg))
)


(define (is-black inImg inLayer inX inY)
(if  (equal? (car (gimp-image-pick-color inImg inLayer inX inY 0 0 0)) '(0 0 0)) (- 1 0) (- 1 1))
)



(define (script-fu-effet-texte inColor inImg)

(let* 
    (
        (layer (car (gimp-image-get-active-layer inImg)))
        (keep 1)
    )
    (gimp-context-set-sample-transparent 1)
    (gimp-image-select-contiguous-color inImg CHANNEL-OP-REPLACE layer 1 1)
    (gimp-selection-invert inImg)
    (let*
        (
            (bounds (gimp-selection-bounds inImg))
            (xmiddle (+ (cadr bounds) (quotient (- (cadddr bounds) (cadr bounds)) 2)))
            (y (- (cadr (cdddr bounds)) 1))
        )
        
        (while (= keep 1) 
            (if (and (= 0 (is-transparent inImg layer xmiddle y)) (= 1 (is-black inImg layer xmiddle y)))
                (begin
                    (set! keep 0)
                    (gimp-context-set-sample-transparent 0)
                    (gimp-image-select-contiguous-color inImg CHANNEL-OP-REPLACE layer xmiddle y)
                    (gimp-edit-clear layer)
                   
                )
             )
             (set! y (- y 1))
        )
        (let*
            (
                (cadretext  (gimp-selection-bounds inImg))
                (x1 (cadr cadretext))
                (y1 (caddr cadretext))
                (x2 (cadddr cadretext))
                (y2 (cadr (cdddr cadretext)))
                (newlayer (car (gimp-layer-copy layer 1)))
            )
            (gimp-image-select-rectangle inImg CHANNEL-OP-REPLACE x1 y1 (- x2 x1) (- y2 y1))
            (gimp-context-set-sample-transparent 1)
            (gimp-image-select-contiguous-color inImg CHANNEL-OP-SUBTRACT layer x1 y1)
            (gimp-edit-clear layer)
            
            (gimp-selection-invert inImg)
            (gimp-image-insert-layer inImg newlayer 0 0)
            (gimp-edit-clear newlayer)
           
            (script-fu-layerfx-outer-glow inImg newlayer inColor 75 0 0 0 0 5 0 1)
            (gimp-image-merge-visible-layers inImg CLIP-TO-IMAGE)
           
            (gimp-selection-none inImg)
;;             (gimp-displays-flush)
        )
        
    )
    )
   
)

(script-fu-register
    "script-fu-effet-texte"                        ;func name
    "Effet sur le texte"                                  ;menu label
    "Entoure le texte d'un effet coloré."              ;description
    "Benoit KUGLER"       ;author
    ""
    "2017"                          ;date created
    ""                     ;image type that the script works on
    SF-COLOR "Couleur" '(255 127 0)
    SF-IMAGE  "Image" 1
  )
(script-fu-menu-register "script-fu-effet-texte" "<Image>/Image")



(define (script-fu-changenum image inNumero)
(let* 
    (
        (layer (car (gimp-image-get-active-layer image)))
        (keep 1)
    )
    (gimp-context-set-sample-transparent 1)
    (gimp-image-select-contiguous-color image CHANNEL-OP-REPLACE layer 1 1)
    (gimp-selection-invert image)
    (let*
        (
            (bounds (gimp-selection-bounds image))
            (xthird (+ (cadr bounds) (* (quotient (- (cadddr bounds) (cadr bounds)) 4) 3)))
            (y  (caddr bounds))
        )
        
        (while (= keep 1) 
            (if (and (= 0 (is-transparent image layer xthird y)) (= 1 (is-black image layer xthird y)))
                (begin
                    
                    (set! keep 0)
                    (gimp-context-set-sample-transparent 0)
                    (gimp-image-select-contiguous-color image CHANNEL-OP-REPLACE layer xthird y)
                    (gimp-edit-clear layer)
                      
                  
                )
             )
             (set! y (+ y 1))
        )
    )
    (if (> inNumero 1) 
    (begin
    (let*
        (
            (bounds (gimp-selection-bounds image))
            (x (cadr bounds))
            (ymiddle   (+ (caddr bounds) (quotient (- (cadr (cdddr bounds)) (caddr bounds)) 2)))
        )
        (set! keep 1)
        
    
        (while (= keep 1)
            (if (= 0 (is-transparent image layer x ymiddle))
            (begin
                (set! keep 0)
                (gimp-context-set-sample-transparent 0)
                (gimp-context-set-sample-threshold 1)
                (gimp-image-select-contiguous-color image CHANNEL-OP-REPLACE layer (+ x 1) ymiddle)
                (gimp-context-set-sample-threshold 0.1)
            )
            )
            (set! x (+ x 1))
        )
        (gimp-edit-clear layer)
    )
    (let*
        (
            (cadrechiffre  (gimp-selection-bounds image))
            (x1 (cadr cadrechiffre))
            (y1 (caddr cadrechiffre))
            (x2 (cadddr cadrechiffre))
            (y2 (cadr (cdddr cadrechiffre)))
        )
        (gimp-image-select-rectangle image CHANNEL-OP-REPLACE x1 y1 (- x2 x1) (- y2 y1))
        (let* 
            (
            (imagechiffre (car (gimp-file-load RUN-NONINTERACTIVE (string-append (string-append "/home/benoit/.local/share/wesnoth/1.13/data/add-ons/A_Tale_of_Sand_and_Snow/graph/" (number->string inNumero)) ".png") (string-append (string-append "/home/benoit/.local/share/wesnoth/1.13/data/add-ons/A_Tale_of_Sand_and_Snow/graph/" (number->string inNumero)) ".png"))))
            (layerchiffre  (car (gimp-image-get-active-layer imagechiffre)))
            )
            (gimp-selection-all imagechiffre)
            (gimp-edit-copy layerchiffre)
            (gimp-image-delete imagechiffre)
        )
        (let* 
            (
            (floating-sel (car (gimp-edit-paste layer 0))) 
            )
            (gimp-floating-sel-anchor floating-sel)
        )
    )
    )
    )
)
)



(define (script-fu-texte inR inG inB inFichier inBool inNumero)
    (let*
        (
            (image (car (gimp-file-load RUN-NONINTERACTIVE inFichier inFichier)))
            (color (list inR inG inB))
            
        )
;;         (gimp-display-new image)
       (if (= inBool 1) 
        (script-fu-effet-texte color image)
        )
        (if (> inNumero 0) 
        (script-fu-changenum image inNumero)
        )
        (gimp-selection-none image)
        (script-fu-add-bevel image (aref (cadr (gimp-image-get-layers image)) 0) 5 0 0)
        (let* 
        ( 
        (drawable (car (gimp-image-get-active-drawable image)))
        ) 
        (file-png-save RUN-NONINTERACTIVE image drawable inFichier inFichier 0 5 0 0 0 0 0) 
        )
	(gimp-image-delete image)
)
)

(script-fu-register
    "script-fu-texte"                        ;func name
    "Effet sur le texte"                                  ;menu label
    "Charge un fichier puis entoure le texte d'un effet coloré."              ;description
    "Benoit KUGLER"       ;author
    ""
    "2017"                          ;date created
    ""                     ;image type that the script works on
    SF-VALUE "Couleur R" "255"
    SF-VALUE "Couleur G" "125"
    SF-VALUE "Couleur B" "0"
    SF-FILENAME "Image" "/home/benoit/.local/share/wesnoth/1.13/data/add-ons/A_Tale_of_Sand_and_Snow/graph/layers/pm.png"
    SF-TOGGLE "Highlight texte" 0
    SF-VALUE "Change numero" "2"
)
