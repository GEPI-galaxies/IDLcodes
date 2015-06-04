; NAME :
;		pix2kpc
; PURPOSE:
;  Convert pixel value into Kpc 
;  at a given redshift
;  
; INPUT:
;   PIXCALE = (Float) pixel size in arcsec  
;	REDSHIFT = (Float) redshift
;	VALUE	 = Pixel value to be converted (array)
;
; OUTPUT:
;   Result of function = VALUE converted into Kpc
; 
;PROCEDURES CALLED : ZANG (astrolib)
;
; MODIFICATION HISTORY:
;           Created by Karen D.
;			Modified by Myriam R. 28/04/2015

FUNCTION pix2kpc,pixscale,redshift,value

 kpc = FINDGEN(100000)/1000.
 z_kpc = ZANG(kpc,redshift,/SILENT)
 result = INTERPOL(kpc,z_kpc,value*pixscale)

RETURN,result

END
  
