; Config_prep_Galfit
PATH_CATALOGUE = '/Users/hypatia/Documents/IMAGES_Kinematics/3D_HST/Catalogue/'
PATH_DATA = '/Users/hypatia/Documents/IMAGES_Kinematics/3D_HST/Imagery/Cutimages_15arcsec/'
CATALOGUE_INPUT = 'Galfit_3DHST_input.cat'


; Prepare input Images
PATH_GALFIT = '/Users/hypatia/Documents/IMAGES_Kinematics/3D_HST/Imagery/Galfit/'
PSF_PATH=''
PSF_FILE = 'FW160_TinyTim_psf.fits'
;PSF_FILE = ''
;PSF_PATH=''
pix_size =0.06
ZP = 25.97
Resolution =0.15

SEX_DETECT_THRESH =2.5
SEX_ANALYSIS_THRESH = 3.

INFILE_SUFFIXE= '_H.fits'
WHTFILE_SUFFIXE= '_H_wht.fits'
MASKFILE_SUFFIXE='_H_msk.fits'
OBJFILE_SUFFIXE='_H_clean.fits'
SEGFILE_SUFFIXE='_H_seg.fits'
OUTFILE_SUFFIXE='_H.ASC'
GALFILE_SUFFIXE='_H.in'
NOISEFILE_SUFFIXE='_H_noise.fits'

; 1D Profile fit
SBProfile_out_SUFFIXE= '_profile.dat'
PRINT_LOG_SUFFIXE= '_H_model.log'
SAVE_PLOT_SUFFIXE= '_H_model.eps'

; GALFIT output
SUBCOMPS_SUFFIXE = '_H_Subcomps.fits'
GALOUT_SUFFIXE = '_H_galout.fits'
GALLOG1_SUFFIXE = '_H_galfit.dat'
GALLOG2_SUFFIXE = '_H_galfit.log'
