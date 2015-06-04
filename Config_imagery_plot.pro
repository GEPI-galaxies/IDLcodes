; Config_imagery_plot
;
PATH_CATALOGUE = '/Users/hypatia/Documents/IMAGES_Kinematics/3D_HST/Catalogue/'
PATH_DATA = '/Users/hypatia/Documents/IMAGES_Kinematics/3D_HST/Imagery/Cutimages_8arcsec/'
CATALOGUE_INPUT = 'Rhalh_3DHST_input.cat'

; Create color images
PATH_COLOR_OUT = '/Users/hypatia/Documents/IMAGES_Kinematics/3D_HST/Imagery/Color_Image/'
BANDS=['I','J','H']
ZOOM_SCALE_color_images = 1.
scale_min = 9.
scale_max = 12.
SUFIXE_color='_VJH_color.png'

; Create color ds9 script
PATH_ds9_OUT = '/Users/hypatia/Documents/IMAGES_Kinematics/3D_HST/Imagery/Color_Maps/'


; Create color maps
PATH_MAPS_OUT = '/Users/hypatia/Documents/IMAGES_Kinematics/3D_HST/Imagery/Color_Maps/'
PATH_MASK = '/Users/hypatia/Documents/IMAGES_Kinematics/3D_HST/Rhalf/'
MAP_SCALE=25. ;   physical scale of the map in Kpc
band_map=['J','H']
ZP_band=[26.23,25.956]
;ZP_band=[25.944,26.23]
PIXELSCALE = 0.06 ; in arcsec
SN_threshold = 1.
SMOOTH_G = 0.4

; Create color mosaic
PATH_MOSAIC_OUT = '/Users/hypatia/Documents/IMAGES_Kinematics/3D_HST/Imagery/Color_Mosaic/'
