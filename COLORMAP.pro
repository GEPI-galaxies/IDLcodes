; NAME:
; 		COLORMAP
; PURPOSE:
; 		Compute a colormap with an associated signal-to-noise map from 2 frames and their
; 		associated error frames (wth frame in HST)
;		Follow the methodology described in Zheng et al. 2004 :
; 		http://www.aanda.org/articles/aa/pdf/2005/20/aa1968-04.pdf
;
; CALLING SEQUENCE:
;    rhalf_pixel=COLORMAP, im_blue, im_red, weigth_blue, weigth_red, ZP_1, ZP_2, threshold, colormap, snr 
;
; INPUT:
;   im_blue = Blue frame (2D array), Flux unit
;	im_red  = Red frame (2D array), Flux unit
;	sigma_blue	  = Poisson noise of im_blue
;	sigma_red	  = Poisson noise of im_red
;   ZP_1	  = Zero Point of frame im_blue
;   ZP_2	  = Zero Point of frame im_red
;  threshold  = Signa-to-noise Threshold for the color map. Regions with SNR < threshold are masked
;  
; 
; OUTPUT:
;  colormap  = Color map in magnitudes (2D array)
; 	    snr  = Signal-to-noise map (2D array)
;
;
; PROCEDURES CALLED : NONE
; MODIFICATION HISTORY: 
; 		Created by Myriam R. 29/04/2015 
; 

PRO COLORMAP, im_blue,im_red,sigma_blue,sigma_red,ZP_1,ZP_2,threshold, colormap, snr 
	
  Ratio_image = im_blue/im_red
  colormap = -2.5*ALOG10(Ratio_image)-ZP_2+ZP_1
 
  Colormap_signal = -0.5 *alog(sigma_blue^2/im_blue^2 +1.) + alog(im_blue) + 0.5 * alog(sigma_red^2/im_red^2 +1.) - alog(im_red)
  Colormap_sigma = alog(sigma_blue^2/im_blue^2 +1.) + alog(sigma_red^2/im_red^2 +1.) 
  
; Compute the SNR of the color map 
  snr=Colormap_signal/(Colormap_sigma)
  
  ;mask = WHERE(snr LE threshold,index)
 ; snr[mask] = !Values.F_NAN
  ;colormap[mask] =  !Values.F_NAN

END

