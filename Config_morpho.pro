PATH_CATALOGUE = ''
PATH_DATA = '../'    
PATH_OUT = ''

; The Input Catalogue must have the following columns 
; Name,Input_file(fits file),redshift,pix_size, ZP
CATALOGUE_INPUT = 'catalogue_morpho.cat'

; Sextractor_files => pas utile ici, il faut copier les fichiers dans
;le repertoire courant
;CONF_FILE='default.sex'
;PARAM_FILE='default.param'
;NNW_FILE='default.nnw'
;CONV_FILE='default.conv'

;Detection threshold for sextractor
DETECT_THRESH=1.0
ANALYSIS_THRESH=1.0
DETECT_MINAREA=10.

;; type of redshift : photo or spectro ?
;REDSHIFT_TYPE='photo'
;REDSHIFT_REF='Dahlen+10'
