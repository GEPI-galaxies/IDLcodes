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
; 

PRO Sextractor_morpho_all

@Config_rhalf

READCOL, PATH_CATALOGUE+CATALOGUE_INPUT, name,file,redshift,pix_size,ZP, FORMAT = '(A,A,F,F,F)'

for i=0, n_elements(name) -1 do begin 
INFILE = PATH_DATA + file(i)
spawn,"cp "+ INFILE +" "+PATH_OUT + file(i)

MASKFILE=PATH_OUT+name(i)+'_mask.fits'
OBJFILE=PATH_OUT+name(i)+'_obj.fits'
SEGFILE=PATH_OUT+name(i)+'_seg.fits'
OUTFILE=PATH_OUT+name(i)+'.ASC'
Sextractor_morpho,INFILE, ZP(i), OBJFILE, SEGFILE, MASKFILE, OUTFILE ,/RUN_SEX, DETECT_THRESH=SEX_DETECT_THRESH, ANALYSIS_THRESH=SEX_ANALYSIS_THRESH

endfor
	
END