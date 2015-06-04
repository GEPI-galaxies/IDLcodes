; NAME:
; 		Rhalf_all_ALL
;
; PURPOSE:
; Wrapper for Rhalf
; Use input catalogue defined in Config_rhalf configuration file
; The catalogue shoud be in the following format : NAME,FILE,REDSHIFT,PIXEL_SIZE,ZeroPoint
;
; This code use the results from sextractor from Sextractor_morpho.pro store in the header
; 	      TBD : load the results form ellipse iraf
;
; Results written in the CATALOGUE_Rhalf in the PATH_CATALOGUE folder defined in Config_rhalf
; 
; PROCEDURES CALLED : Rhalf
; MODIFICATION HISTORY:
;                    Created by Myriam R. 28/04/2015
; 

PRO Rhalf_all, RUN_SEX=RUN_SEX

@Config_rhalf

READCOL, PATH_CATALOGUE+CATALOGUE_INPUT, name,file,redshift,pix_size,ZP, FORMAT = '(A,A,F,F,F)'
openw, lun, PATH_CATALOGUE+CATALOGUE_Rhalf, /get_lu
printf, lun, format='(a)','Name Rhalf_CG Rhalf_CG Rhalf_SEX Rhalf_SEX'
printf, lun, format='(a)','       (Kpc)   (pixel)   (Kpc)   (pixel)'

for i=0, n_elements(name) -1 do begin 
	print,'Object:' + name(i)
	OBJ_FILE = PATH_OUT + name(i) +"_obj.fits"
	im = readfits(OBJ_FILE,/SILENT,header) 

	if KEYWORD_SET(RUN_SEX) then begin
	PA =  SXPAR( header, 'PA')
	Xc =  SXPAR( header, 'XCENTER')
	Yc =  SXPAR( header, 'YCENTER')
	 E =  SXPAR( header, 'ELLIP')		
	RADIUS =SXPAR( header, 'RADIUS')
	FLUXTOT =  SXPAR( header, 'FLUXTOT')
	endif

	rhalf=Rhalf(im, Xc, Yc, E, PA, Major_axis=RADIUS, PLOT=PLOT, FLUXTOT=FLUXTOT)
	rhalf_Kpc=pix2kpc(pix_size[i],redshift[i],rhalf)

    print,'Half light radius [kpc] (ellipse): ',rhalf_Kpc[0]
	print,'Half light radius [kpc] (sextractor): ',rhalf_Kpc[1]
	err_radiusKpc=abs(rhalf_Kpc[0]-rhalf_Kpc[1])/2.
	print,'Error : +/-',err_radiusKpc
	
	printf, lun, name(i), rhalf_Kpc[0], rhalf[0], rhalf_Kpc[1],rhalf[0], format='(a,4(f6.2,x))'
	
endfor

 free_lun, lun
END
