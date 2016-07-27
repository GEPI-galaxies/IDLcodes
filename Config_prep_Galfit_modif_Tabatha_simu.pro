
FILTER = 'R' ; not used yet
CATALOGUE_INPUT = 'CATALOG_INPUT_3_fgas07_10'

;Detection threshold for sextractor
SEX_DETECT_THRESH =1.5
SEX_ANALYSIS_THRESH = 1.5
DEBLEND_MINCONT = 0.001
DEBLEND_NTHRESH=64

; Output Catalogue
CATALOGUE_RHALF ='CATALOG_3_fgas07_10_output.cat'
NOCENTER=1 ; =0 if the object to fit is at the center, else =1




; Config_prep_Galfit
PATH_CATALOGUE = ''
PATH_DATA = ''
PATH_SUM = ''
CATALOGUE_INPUT = 'CATALOG_INPUT_3_fgas07_10'


; Prepare input Images
PATH_GALFIT = ''
PSF_PATH=''
PSF_FILE = ''

Scale_Kpc = 60
pix_size =0.15
ZP = 26.0
Resolution = 1.
exptime=1.

SEX_DETECT_THRESH = 1.5
SEX_ANALYSIS_THRESH = 1.5
DEBLEND_MINCONT = 0.001
DEBLEND_NTHRESH = 64
NOCENTER=1

INFILE_SUFFIXE= '_obj.fits'
WHTFILE_SUFFIXE= '_wht.fits'
MASKFILE_SUFFIXE='_mask.fits'
OBJFILE_SUFFIXE='_clean.fits'
SEGFILE_SUFFIXE='_seg.fits'
OUTFILE_SUFFIXE='.ASC'
GALFILE_SUFFIXE='.in'
NOISEFILE_SUFFIXE='_noise.fits'

; 1D Profile fit
SBProfile_out_SUFFIXE= '_profile.dat'
PRINT_LOG_SUFFIXE= '_model.log'
SAVE_PLOT_SUFFIXE= '_model.eps'

; GALFIT output
SUBCOMPS_SUFFIXE = '_Subcomps.fits'
GALOUT_SUFFIXE = '_galout.fits'
GALLOG1_SUFFIXE = '_galfit.dat'
GALLOG2_SUFFIXE = '_galfit.log'
