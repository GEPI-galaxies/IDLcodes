; NAME:
; 		Colormap_all
;
; PURPOSE:
; Wrapper for COLORMAP
; Use input catalogue defined in Config_imagery_plot configuration file
; The catalogue shoud be in the following format : NAME,FILE,REDSHIFT,PIXEL_SIZE,ZeroPoint
; 
; OPTIONAL INPUT KEYWORDS:
; 		/MASK = Companion can be masked using the mask generate by SEXTRACTOR_MORPHO
;				Config_imagery_plot
; 		/SMOOTH = Smooth the colormap and snr map with a gaussian filter 
; 				  FWHM of the gaussian is defined in SMOOTH_G @Config_imagery_plot
;
; PROCEDURES CALLED : COLORMAP,GAUSS_SMOOTH, img2ps
;					  READFITS, WRITEFITS, ZANG (astrolib)
; MODIFICATION HISTORY:
;                    Created by Myriam R. 28/04/2015
;


PRO colormap_all, MASK=MASK, SMOOTH=SMOOTH

@Config_imagery_plot

READCOL, PATH_CATALOGUE+CATALOGUE_INPUT, name,file,redshift,pix_size,ZP, FORMAT = '(A,A,F,F,F)'

for i=0,0 do begin 
print, name(i)
image_blue = readfits(PATH_DATA+name(i)+'_'+band_map[0]+'.fits', header_b,/SILENT)
image_red  =  readfits(PATH_DATA+name(i)+'_'+band_map[1]+'.fits', header_r,/SILENT)

exptime_blue = SXPAR( header_b, 'EXPTIME')
exptime_red = SXPAR( header_r, 'EXPTIME')

scale=[exptime_blue,exptime_red]/min([exptime_blue,exptime_red])

;image_blue=(image_blue + 544./exptime_blue) 
;image_red= (image_red + 544./(exptime_red / 1.50988))  
writefits,PATH_MAPS_OUT+name(i)+'_J_counts.fits',(image_blue),header_b
writefits,PATH_MAPS_OUT+name(i)+'_H_counts.fits',(image_red),header_r

weigth_blue =  readfits(PATH_DATA+name(i)+'_'+band_map[0]+'_wht.fits',header,/SILENT)
weigth_red  = readfits( PATH_DATA+name(i)+'_'+band_map[1]+'_wht.fits', header,/SILENT)

weigth_blue=weigth_blue / (exptime_blue)^2
weigth_red=weigth_red / (exptime_red/ 1.50988)^2

ZP_1 = ZP_band[0]
ZP_2 = ZP_band[1]

IF KEYWORD_SET(mask) then begin
	mask = readfits(PATH_MASK+name(i)+'_mask.fits', hader_mask,/SILENT)
	zero_mask=WHERE(Mask EQ 0)
	image_blue[zero_mask]  = !Values.F_NAN
	image_red[zero_mask]   = !Values.F_NAN
	weigth_blue[zero_mask] = !Values.F_NAN
	weigth_red[zero_mask]  = !Values.F_NAN
ENDIF

colormap, image_blue,image_red,1/sqrt(weigth_blue),1/sqrt(image_red), ZP_1, ZP_2,SN_threshold, colormap, snr

writefits,PATH_MAPS_OUT+name(i)+'_JH.fits',colormap,header_r
writefits,PATH_MAPS_OUT+name(i)+'_JH_snr.fits',snr,header_r

; Cut Region with size MAP_SCALE aroung the center
dd=ZANG(MAP_SCALE,redshift[i],/SILENT)  ; conversion kpc in arcsec
scale_EPS=LONG(dd)/PIXELSCALE     	    ; conversion arcsec in pixels
xc = (SIZE(colormap))[1]/2.				; Image center
yc = (SIZE(colormap))[2]/2.
color_stamp=colormap[xc-scale_EPS:xc+scale_EPS,yc-scale_EPS:yc+scale_EPS]
snr_stamp=snr[xc-scale_EPS:xc+scale_EPS,yc-scale_EPS:yc+scale_EPS]


IF KEYWORD_SET(SMOOTH) then begin 
	color_stamp=GAUSS_SMOOTH(color_stamp,SMOOTH_G,/NAN,/EDGE_WRAP)
	snr_stamp=GAUSS_SMOOTH(snr_stamp,SMOOTH_G,/NAN,/EDGE_WRAP)	
ENDIF

Color_maps_min=min(color_stamp,/NAN)
SNR_min=min(snr_stamp,/NAN)
Color_maps_max=max(color_stamp,/NAN)
SNR_max=max(snr_stamp,/NAN)



; Save colormap and sn map in EPS
IMG2PS ,color_stamp, [MAP_SCALE,MAP_SCALE],[Color_maps_min,Color_maps_max], 'I - J',['Kpc','Kpc'], SAVE_EPS=PATH_MAPS_OUT+name(i)+'_JH.eps'
IMG2PS ,snr_stamp, [MAP_SCALE,MAP_SCALE],[Color_maps_min,Color_maps_max], 'SNR',['Kpc','Kpc'],/GREY , /INVERSE , SAVE_EPS=PATH_MAPS_OUT+name(i)+'_JH_SNR.eps'
         
endfor

END