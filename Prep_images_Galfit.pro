; NAME:
; 		 Prep_images_Galfit
; PURPOSE: 
; 		Prepare Galfit input images 
;
; CALLING SEQUENCE:
;   Prep_images_Galfit, name , INFILE, WHTFILE , ZP , pix_size, OBJFILE, SEGFILE , $
;						MASKFILE, OUTFILE, GALFILE, NOISEFILE, PSFFILE, SEX_DETECT_THRESH, SEX_ANALYSIS_THRESH
;
; INPUT:
;   name = name of the object   
;   INFILE = Science input file    
;   WHTFILE = Weigth file for INFILE   
;   ZP = Zero-point 
;   pix_size = pixel scale in arcsec / pixel
;   SEX_DETECT_THRESH = Detection threshold for Sextractor
;   SEX_ANALYSIS_THRESH = Analysis threshold for Sextractor
;   PSFFILE = Name of the input PSF file 
;
;   Name of the file to be created by the routine : 
;   OBJFILE = science file with companion masked
;   SEGFILE = Segmentation file from Galfit
;   MASKFILE = Mask file for galfit; Mask = 1.
;   OUTFILE = Ascii output file from sextractor
;   GALFILE = Input for galfit
;   NOISEFILE = name of the noise file 
;
; PROCEDURES CALLED : Sextractor_morpho, READFITS, SXADDPAR, MODFITS, init_galfitfile
; MODIFICATION HISTORY: 
; 		Created by Myriam R. 06/05/2015 
; 

PRO Prep_images_Galfit, name, INFILE, WHTFILE , ZP , pix_size, OBJFILE, SEGFILE , MASKFILE, OUTFILE, GALFILE, NOISEFILE, PSFFILE, GALOUT, SEX_DETECT_THRESH, SEX_ANALYSIS_THRESH

; Make noise file
wht=readfits(WHTFILE,header_wht)
sig = (1./SQRT(wht))
writefits,NOISEFILE,sig,header_wht

Sextractor_morpho,INFILE, ZP, OBJFILE, SEGFILE, MASKFILE, OUTFILE ,/RUN_SEX, DETECT_THRESH=SEX_DETECT_THRESH, ANALYSIS_THRESH=SEX_ANALYSIS_THRESH

mask=readfits(MASKFILE, header_mask)
MODFITS, MASKFILE, float(~ mask)

obj=readfits(OBJFILE, header_obj)
SXADDPAR,header_obj,'EXPTIME','1'
MODFITS, OBJFILE, 0, header_obj

im = readfits(OBJFILE,header)
size_im = SIZE(im)
zone = [1, (size(im))[1], 1, (size(im))[2]]  ;;;;; region to fit

init_galfitfile,GALFILE,name,ZP,pix_size,1,OBJFILE,GALOUT, sigma=NOISEFILE,psf_file=PSFFILE,maskfile=MASKFILE,zoneFit=[zone(0),zone(1),zone(2),zone(3)]


END


PRO Prep_Galfit_all

@Config_prep_Galfit

READCOL, PATH_CATALOGUE+CATALOGUE_INPUT, name,file,redshift,pix_size,ZP, FORMAT = '(A,A,F,F,F)'


for i=0, n_elements(name) -1 do begin 


INFILE= PATH_SUM+name(i)+INFILE_SUFFIXE
WHTFILE= PATH_SUM+name(i)+WHTFILE_SUFFIXE

MASKFILE=PATH_SUM+name(i)+MASKFILE_SUFFIXE
OBJFILE=PATH_SUM+name(i)+OBJFILE_SUFFIXE
SEGFILE=PATH_SUM+name(i)+SEGFILE_SUFFIXE
OUTFILE=PATH_SUM+name(i)+OUTFILE_SUFFIXE
GALFILE=PATH_SUM+name(i)+GALFILE_SUFFIXE
NOISEFILE=PATH_SUM+name(i)+NOISEFILE_SUFFIXE

PSFFILE = PSF_PATH+PSF_FILE
IF STRMATCH(name(i),'*COS3*') then PSFFILE=PSF_PATH+'COSMOS/cosmos_3dhst.v4.0.F160W_psf.fits'
IF STRMATCH(name(i),'*GS3*') then PSFFILE=PSF_PATH+'GOODS/goodss_3dhst.v4.0.F160W_psf.fits'
IF STRMATCH(name(i),'*U3*') then PSFFILE=PSF_PATH+'UDS/uds_3dhst.v4.0.F160W_psf.fits'

Prep_images_Galfit, name(i)+'_'+BANDS[0], INFILE, WHTFILE , ZP  , pix_size, OBJFILE, SEGFILE , MASKFILE, OUTFILE, GALFILE, NOISEFILE, PSFFILE , SEX_DETECT_THRESH, SEX_ANALYSIS_THRESH


endfor

END