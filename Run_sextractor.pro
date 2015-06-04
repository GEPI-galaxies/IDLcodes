; NAME:
; 		RUN_SEXTRACTOR
; PURPOSE :
; 		run sextractor with input parameters 
; INPUT:
; 	INFILE  = fits file to extract
; 	SEGFILE = name of the output fits file from sextractor
; 	OUTFILE = name of the output file from sextractor
; 	DETECT_THRESH = Detection threshold (sigma) for sextractor
; 	ANALYSIS_THRESH = Analysis threshold (sigma) for sextractor
;
; HISTORY : Created by Myriam R. 28/04/2015 
; 

PRO Run_sextractor, INFILE , ZP, SEGFILE, MASKFILE, OUTFILE , DETECT_THRESH=DETECT_THRESH, ANALYSIS_THRESH=ANALYSIS_THRESH

IF ~KEYWORD_SET(DETECT_THRESH) then DETECT_THRESH = 3.5
IF ~KEYWORD_SET(ANALYSIS_THRESH) then ANALYSIS_THRESH = 3.5

SPAWN," sex " + INFILE +" -c default.sex -MAG_ZEROPOINT " + string(ZP) +" -CHECKIMAGE_NAME " + SEGFILE +" -CATALOG_NAME " +OUTFILE + " -DETECT_THRESH " + string(DETECT_THRESH) + " -ANALYSIS_THRESH " + string(ANALYSIS_THRESH)
END
