; NAME:
; 		 RHALF
; PURPOSE: 
; 		Compute Rhalf from an image file
;
; CALLING SEQUENCE:
;    rhalf_pixel=Rhalf( image, Xc, Yc, E, PA, Major_axis=Major_axis, /PLOT, FLUXTOT=FLUXTOT)
;
; INPUT:
;   INFILE= name of the fits file  
;	Xc	  = Center of the object ( pixel)
;	Yc	  = Center of the object in pixel
;	PA 	  = Position angle
;   E	  = B/A ratio
;
; OPTIONAL INPUT KEYWORDS:
;		/PLOT = IF SET plot curve of growth
;		Major_axis = Input approximate length of the major axis (in pixel) (Float)
;       FLUXTOT = input total flux from other code, e.g sextractor. 
; 				the R_half is computed at FLUXTOT/2
; 
; OUTPUT:
;  Rhalf  = R_half in pixel
; 		    Compute from the derivate
; 		    IF FLUXTOT set then return an array with two elements : rhalf from derivate and from the total
;
;
; PROCEDURES CALLED : SKY(astrolib), DIST_ELLIPSE,INTERPOL,DERIV, COYOTE
; MODIFICATION HISTORY: 
; 		Created by Myriam R. 28/04/2015 
; 


FUNCTION Rhalf, image, Xc, Yc, E, PA, Major_axis=Major_axis, PLOT=PLOT, FLUXTOT=FLUXTOT
	
	sizex=(SIZE(image))[1]
	sizey=(SIZE(image))[2]
	
	;Subtract sky level
	sky,image,skymode,/SILENT
	obj_im= image-replicate(skymode,size(image,/DIMENSIONS))
	sky,image,skymode,/SILENT
	
	;Calculating flux and mag inside ellipses around the target
	DIST_ELLIPSE, ell, [sizex,sizey], Xc, Yc, E, PA, /DOUBLE 
	
	flux_ram = fltarr(sizex/2)
	flux_ram(*)=!Values.F_NAN
	mag_ram = fltarr(sizex/2)
	mag_ram(*)=!Values.F_NAN
	rr = (findgen(sizex/2)+1)
	
	lim = floor(sizex/2.)
	if KEYWORD_SET(Major_axis) then lim = 8*Major_axis

	FOR k = 0, lim -1 DO BEGIN
		indy = where(ell LE rr(k),counts_ell)
		flux_ram(k) = total(image(indy))
		mag_ram(k) = total(image(indy))/counts_ell
	ENDFOR
	
	;Calculate the Flux total from the magnitude derivate (radius when the derivate tends to zero)
	deriv_mag=DERIV(rr,mag_ram)
	seuil=0.1*(max(mag_ram)-min(mag_ram))/100.
	noise=median(mag_ram(WHERE(deriv_mag LT seuil)))
	total_rr=INTERPOL(rr,mag_ram,noise)
	f_tot=INTERPOL(flux_ram,rr,total_rr)
	Half_radius1=INTERPOL(rr,flux_ram,f_tot/2.)
	print,'Half light radius [pixel] from ellipse method',Half_radius1
	
	if KEYWORD_SET(PLOT) then begin
	;Plot light growth curves
	cgplot,rr, flux_ram,xtitle='Radius of ellipse',ytitle='flux',xrange=[0,150],thick=2
	cgoplot,[0,sizex],[f_tot,f_tot],linestyle=3,color='coral'
	cgoplot,[0,sizex],[f_tot/2,f_tot/2],linestyle=2,color='coral'
	cgoplot,[Half_radius1,Half_radius1],[0,max(flux_ram)],linestyle=2,color='coral'
	ENDIF
	
	if KEYWORD_SET(FLUXTOT) then begin
	;Calculate the Flux total from the iso flux estimated by sextractor
	Half_radius2=INTERPOL(rr,flux_ram,FLUXTOT/2.)
	print,'half radius [pixel] from sextractor',Half_radius2
		if KEYWORD_SET(PLOT) then begin
		cgoplot,[0,sizex],[FLUXTOT,FLUXTOT],linestyle=2,color='blue'
		cgoplot,[Half_radius2,Half_radius2],[0,max(flux_ram)],linestyle=2,color='blue'
		endif
	return,[Half_radius1,Half_radius2]
	endif
	

	return,[Half_radius1]
		
END

