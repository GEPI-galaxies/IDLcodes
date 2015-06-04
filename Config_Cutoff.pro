; Config_Cutoff
;
; Configuration file for cutting images
; 
PATH_CATALOGUE = '/Users/hypatia/Documents/IMAGES_Kinematics/3D_HST/Catalogue/'
PATH_DATA = '/Users/hypatia/Documents/DATA/IMAGERY/'
PATH_OUT = '/Users/hypatia/Documents/IMAGES_Kinematics/3D_HST/Imagery/Cutimages_15arcsec/'

INPUT_CATALOGUE = 'KMOS3D_Wisnioski2014_z1.cat'

; Sub Folders
Field=['COSMOS','GOODS','UDS']

; Bands to cut
BAND=['V','I','J','H'] ; Name of the band
BAND_HST=['f606w','f814w','f125w','f160w'] 
SIZE_IM=[CEIL(8./0.06),CEIL(8./0.06),CEIL(8./0.06),CEIL(8./0.06)] ; Pixel scale ACS=0.03, WFC3=0.06



