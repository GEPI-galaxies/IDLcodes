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

PRO Prep_images_Galfit, name, INFILE, WHTFILE , ZP , pix_size, OBJFILE, SEGFILE , MASKFILE, OUTFILE, GALFILE, NOISEFILE, PSFFILE, GALOUT, SEX_DETECT_THRESH, SEX_ANALYSIS_THRESH,DEBLEND_MINCONT,DEBLEND_NTHRESH

IF not keyword_set(WHTFILE) THEN WHTFILE='none'
IF not keyword_set(NOISEFILE) THEN NOISEFILE='none'

; Make noise file
;wht=readfits(WHTFILE,header_wht)
;sig = (1./SQRT(wht))
;writefits,NOISEFILE,sig,header_wht

;Sextractor_morpho,INFILE, ZP, OBJFILE, SEGFILE, MASKFILE, OUTFILE ,/RUN_SEX, DETECT_THRESH=SEX_DETECT_THRESH, ANALYSIS_THRESH=SEX_ANALYSIS_THRESH,DEBLEND_MINCONT=DEBLEND_MINCONT,DEBLEND_NTHRESH=DEBLEND_NTHRESH

mask=readfits(MASKFILE, header_mask)
MODFITS, MASKFILE, float(~ mask)

;obj=readfits(OBJFILE, header_obj)
;SXADDPAR,header_obj,'EXPTIME','1'
;MODFITS, OBJFILE, 0, header_obj

im = readfits(OBJFILE,header)
size_im = SIZE(im)
zone = [1, (size(im))[1], 1, (size(im))[2]]  ;;;;; region to fit

init_galfitfile,GALFILE,name,ZP,pix_size,1,OBJFILE,GALOUT,psf_file=PSFFILE,maskfile=MASKFILE,zoneFit=[zone(0),zone(1),zone(2),zone(3)]
; sigma=NOISEFILE

END
