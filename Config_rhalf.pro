; Configuration File for R_halh calculation 
; 
PATH_CATALOGUE = '../'
PATH_DATA = '/Users/hypatia/Documents/IMAGES_Kinematics/3D_HST/Imagery/Cutimages_15arcsec/'
PATH_OUT = '/Users/hypatia/Documents/IMAGES_Kinematics/3D_HST/Rhalf/'

; The Input Catalogue must have the following columns 
; Name,Input_file(fits file),redshift,pix_size, ZP
FILTER = 'J' ; not used yet
CATALOGUE_INPUT = 'Rhalh_3DHST_input.cat'

;Detection threshold for sextractor
SEX_DETECT_THRESH =3.5
SEX_ANALYSIS_THRESH = 3.5

; Output Catalogue
CATALOGUE_RHALF ='Rhalf_3DHST_output.cat'

; HELP 
; Run first Sextractor_morpho_all 
; IDL > Sextractor_morpho_all
; This program creates companion mask, segmentation file from sextractor and 
; images with masked companion from the original input files
;
; Then, run Rhalf_all
; > Rhalf_all,/RUN_SEX
;