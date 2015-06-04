; Config_Ellipse
;
PATH_CATALOGUE = '/Users/hypatia/Documents/IMAGES_Kinematics/3D_HST/Catalogue/'
PATH_DATA = '/Users/hypatia/Documents/IMAGES_Kinematics/3D_HST/Imagery/Cutimages_15arcsec/'
CATALOGUE_INPUT = 'Galfit_3DHST_input.cat'

; Create Sum bands
;BANDS=['I','J','H']
BANDS=['H']
SUFIXE_sum='_sum.fits'
PATH_SUM = '/Users/hypatia/Documents/IMAGES_Kinematics/3D_HST/Imagery/Sum/'
SEX_DETECT_THRESH =2.5
SEX_ANALYSIS_THRESH = 3.

; Create ellipse 
Path_ELLIPSE1_IN='/Users/hypatia/Documents/IMAGES_Kinematics/3D_HST/Imagery/Galfit/'
Path_GUESS_OUT='/Users/hypatia/Documents/IMAGES_Kinematics/3D_HST/Imagery/Galfit/'
