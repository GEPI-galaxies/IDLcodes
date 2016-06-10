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
