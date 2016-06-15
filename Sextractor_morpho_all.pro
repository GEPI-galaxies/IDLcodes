; NAME:
;     SEXTRACTOR_MORPHO_ALL
; PURPOSE: 
; Wrapper for Sextractor_morph
; Use input catalogue defined in Config_rhalf configuration file
; The catalogue shoud be in the following format : NAME,FILE,REDSHIFT,PIXEL_SIZE,ZeroPoint
;
; Results store in the PATH_OUT folder defined in Config_rhalf
; 
; PROCEDURES CALLED : Sextractor_morpho 
;
; MODIFICATION HISTORY:
;       Created by Myriam R. 28/04/2015 
;       Modified by Karen D. 15/06/15

PRO Sextractor_morpho_all

@config_morpho

READCOL, PATH_CATALOGUE+CATALOGUE_INPUT, name,file,redshift,pix_size,ZP, FORMAT = '(A,A,F,F,F)'

for i=0, n_elements(name) -1 do begin 
INFILE = PATH_DATA + file(i)

MASKFILE=PATH_OUT+name(i)+'_mask.fits'
OBJFILE=PATH_OUT+name(i)+'_obj.fits'
SEGFILE=PATH_OUT+name(i)+'_seg.fits'
SEXCAT=PATH_OUT+name(i)+'.ASC'

Run_sextractor, INFILE, ZP(i), SEGFILE, SEXCAT, DETECT_THRESH=DETECT_THRESH, ANALYSIS_THRESH=ANALYSIS_THRESH, DETECT_MINAREA=DETECT_MINAREA

Sextractor_morpho,INFILE, ZP(i), OBJFILE, SEGFILE, MASKFILE, SEXCAT

PRINT,'---------------'+name(i)+'--------------------'
SPAWN,'ds9 '+INFILE+' '+SEGFILE+' '+MASKFILE+' '+OBJFILE


endfor
	
END
