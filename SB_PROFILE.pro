; NAME:
;     SB_PROFILE
;
; PURPOSE: 
; 		Extract surface brithgness profile and PA and E profiles  
; 		from iraf ellipse output 
;
; CALLING SEQUENCE: 
; SB_PROFILE, file_ellipse, file_fits, ZP , Pixel_scale, redshift, file_out, PLOT=PLOT, SAVE_PLOT=save_file, /COSMO_DIMMING
;
; INPUT: 
;		file_ellipse = Name of the ASCII output file from Ellipse (iraf)
;		file_fits    = Name of the fits file from which ellipse was computed 
;		ZP  		 = Zero Point of the input image
;		Pixel_scale  = Pixel scale of the image (arcsec per pixel)
;
; OUTPUT:
;    	file_out = Name of the ASCII output file
; 	  
; OPTIONAL INPUT KEYWORDS:
;		/PLOT = PLOT profiles
;		SAVE_PLOT = If SET save the plot in the SAVE_PLOT file
;		/COSMO_DIMMING = Correct for the cosmological dimming
;
; PROCEDURES CALLED : NONE
; MODIFICATION HISTORY: 
; 		Created by Myriam R. 29/04/2015 
; 


PRO SB_PROFILE,ellipse_out,image_file, ZP , Pixel_scale, redshift, file_out, PLOT=PLOT, SAVE_PLOT=SAVE_PLOT, COSMO_DIMMING=COSMO_DIMMING

image = readfits(image_file,header)

; Replace all indev value 'INDEF' in ellipse file by -999 before reading file
INDEF_VALUE ='-999'
Comd_FileIN="'s%INDEF%"+INDEF_VALUE+"%g' "
Comd_config="sed -e "+Comd_FileIN +"< "+ellipse_out+" > "+'tmp_file.dat'
spawn,Comd_config
spawn, 'cp tmp_file.dat '+ellipse_out
readcol,ellipse_out,format='(i,f,f,f,f,f,f,f,f,f,f,f,f)', row,sma,Int,I_err,E,E_err,PA,PA_err,xc,yc, TFLUX_C,TMAG_E,NPIX_E,/silent

x_kpc = pix2kpc(Pixel_scale,redshift,sma)

; Convert into surface brigtness profiles
SB = -2.5*alog10(Int)+ZP + 2.5*alog10(Pixel_scale^2)
SB_low = -2.5*alog10(Int - I_err)+ZP + 2.5*alog10(Pixel_scale^2)
SB_high = -2.5*alog10(Int + I_err)+ZP + 2.5*alog10(Pixel_scale^2)

IF KEYWORD_SET(COSMO_DIMMING) then begin
SB= SB - 10*alog10(1+redshift)
SB_low =SB_low - 10*alog10(1+redshift)
SB_high= SB_high - 10*alog10(1+redshift)
ENDIF

without_err =WHERE(PA_err LE -999 OR E_err LE -999, N_no_err, COMPLEMENT=with_err)
 IF N_no_err GE 1 then begin
 	PA_err(without_err)=0	
	E_err(without_err)=0
 ENDIF

; Integrate mag
 
; Write output file
openw, lun, file_out, /get_lu
printf, lun, format='(a)','SB_PROFILE output file for '+image_file+' '+ellipse_out
IF KEYWORD_SET(COSMO_DIMMING) then printf,lun, format='(a)',' Corrected from cosmological dimming'
printf, lun, format='(a)',' SMA_P   SMA_K   Intens Intens_err  SB   SB_ERR_L SB_ERR_H  PA  PA_ERR  Ellip ELlip_err X0  Y0 TMAG_E'
printf, lun, format='(a)',' (Pixel)   (Kpc)   (Flux)   (Flux)   (mag/arcsex^2) (mag/arcsex^2) (deg) (deg)  ()() (pixel) (pixel) (mag)'
for i=0, n_elements(sma) -1 do begin
printf,lun,format='(i,2x,6(f8.4,2x),2(f7.3,2x),2(f8.3,2x),2(f8.4,2x),f8.3)',$
		sma(i),x_kpc(i),Int(i), I_err(i), SB(i), SB_low(i), SB_high(i), PA(i), PA_err(i), E(i),E_err(i), xc(i),yc(i),TMAG_E(i)
endfor
free_lun, lun
 
IF KEYWORD_SET(PLOT) then begin
	print,SAVE_PLOT
	IF KEYWORD_SET(SAVE_PLOT) then cgPS_Open, Filename=SAVE_PLOT
	IF ~KEYWORD_SET(SAVE_PLOT) then window,1,xsize=700,ysize=600, TITLE=ellipse_out

	cgplot, x_kpc,SB,XTITLE='Radius [Kpc]',YTITLE='Surface magnitude [mag/arcsec^2]',$
		   col='red', Position=[0.05, 0.10, 0.40, 0.90],xthic=2,ythic=2, charsize=1.5,CHARTHICK=2 ,yrange=[max(SB)+0.5,min(SB)-0.5]
	loadct,0
	oploterror, x_kpc, SB, SB - SB_low, psym=3,/HIBAR,ERRCOLOR=150
	oploterror, x_kpc, SB, SB_high - SB, psym=3,/LOBAR,ERRCOLOR=150

	cgplot,x_kpc,PA,YTITLE='PA [deg]',xrange=rangeX,col='red',thic=2, $
		   Position=[0.55, 0.55, 0.95, 0.90],xthic=2,ythic=2, charsize=1.5,CHARTHICK=1.2, /NoErase,XS=1
	oploterror,x_kpc,PA,PA_err, psym=3,ERRCOLOR=50

	cgplot,x_kpc,E,thic=2,XTITLE='Radius [Kpc]',YTITLE='E',xrange=rangeX, $
		   Position=[0.55, 0.10, 0.95, 0.45],xthic=2,ythic=2, charsize=1.5,col='red', CHARTHICK=1.2,/NoErase,XS=1
	oploterror,x_kpc,E,E_err, psym=3,ERRCOLOR=50

	IF KEYWORD_SET(SAVE_PLOT) then cgPS_Close

	size_data = 200
	scale_zoom=2

	Window, 2,xsize=size_data * scale_zoom,ysize=size_data * scale_zoom
	image_CROP =   CONGRID( image(150:350, 150:350),size_data * scale_zoom, size_data * scale_zoom)
	image_scl=alogscale(255-image_CROP,/auto)

	loadct,0
	TVSCL, image_scl
	X_center=xc -150
	Y_center=yc -150
	loadct,12
	for i=0, n_elements(sma)-1 do begin
		IF ((i MOD 2) EQ 0) then TVELLIPSE, sma[i]*scale_zoom, $
			scale_zoom*(1 -E[i]) * sma[i],scale_zoom* X_center[i], scale_zoom* Y_center[i],  PA[i] - 90 ,color=200
	endfor
	

ENDIF

END


