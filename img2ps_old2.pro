; NAME:
; 		IMG2PS
; PURPOSE:
; 		Plot image frame and save into a EPS file 
; 		
; CALLING SEQUENCE:
;    IMG2PS, image, XY_max_scale, Z_range ,Z_label,XY_label, SAVE_EPS=SAVE_EPS, SAVE_PNG=SAVE_PNG, GREY=GREY, INVERSE=INVERSE, LOG=LOG
;
; INPUT:
;   image = 2D frame to save
;	XY_max_scale  = Max value for spatial axis (assume that the scale is linear and symetric)
;   Z_range       = Min Max intensity 
;	Z_label	      = Labels for intensity axis
;   XY_label	  = Labels for spatial axis ['Label X','Label Y']
;  
;  OPTIONAL INPUT KEYWORDS:
; 	SAVE_EPS = Name of the EPS output file  
; 	SAVE_PNG = Name of the PNG output file 
; 	/GREY	 = Grey scale instead of color
; 	/INVERSE  = Invert colors 
; 	/LOG      = Plot the log of the image value
;
; PROCEDURES CALLED : cgColorbar, cgLoadCT, cgImage, cgPS_Close, cgPS_Open, cgDisplay (Coyote package)
; MODIFICATION HISTORY: 
; 		Created by Myriam R. 29/04/2015 
;               Modified by Karen D. 06/05/2015

PRO img2ps ,img, XY_max_scale, Z_range ,XY_label, SAVE_EPS=SAVE_EPS, SAVE_PNG=SAVE_PNG, GREY=GREY, INVERSE=INVERSE, LOG=LOG, Z_label=Z_label

   IF KEYWORD_SET(LOG) then begin
      img=alog10(img) 
      Value_range=alog10(Z_range)
      IF FINITE(Value_range[0]) EQ 0 THEN Value_range[0]=MIN(img[WHERE(FINITE(img) EQ 1)])
      IF FINITE(Value_range[1]) EQ 0 THEN Value_range[1]=MAX(img[WHERE(FINITE(img) EQ 1)])
   ENDIF ELSE value_range=z_range

   img_scale = BytScl(img, Min=value_range[0], Max=value_range[1], /NAN)

   IF KEYWORD_SET(INVERSE) then begin 
      img_scale=255-img_scale
      Value_range=REVERSE(Z_range)
   ENDIF
  
   IF KEYWORD_SET(Z_label) THEN begin
      position=[0.125, 0.125, 0.8, 0.95] 
      size_display=[400,300]
   ENDIF ELSE BEGIN
      position=[0.17, 0.17, 0.95, 0.95]
      size_display=[400,400]
   ENDELSE

   IF KEYWORD_SET(SAVE_EPS) then cgPS_Open, SAVE_EPS
   
   cgDisplay, size_display[0], size_display[0]
   axis_format = {XTicks:4, XTickname:[STRTRIM(round(-XY_max_scale[0]),1), STRTRIM(round(XY_max_scale[0]/2.),1), $
                 STRTRIM(0,1), STRTRIM(round(XY_max_scale[0]/2.),1), STRTRIM(round(XY_max_scale[0]),1)],$
                 YTicks:4, YTickname:[STRTRIM(round(-XY_max_scale[1]),1), STRTRIM(round(XY_max_scale[1]/2.),1),$
                 STRTRIM(0,1), STRTRIM(round(XY_max_scale[1]/2.),1), STRTRIM(round(XY_max_scale[1]),1)]}
     
   IF KEYWORD_SET(GREY) then begin
   cgLoadCT, 0
   cgImage, img_scale, XRange=xrange, YRange=yrange, /AXES ,/KEEP_ASPECT_RATIO, Palette=palette, $
      XTitle=XY_label[0], YTitle=XY_label[1],  Position=position, AXKEYWORDS=axis_format
   IF KEYWORD_SET(Z_label) THEN cgColorbar, Position=[0.875, 0.120, 0.92, 0.95], Title=Z_label,/Reverse, $
        NColors=254, Bottom=1,Ticklen=-0.25, /Top, /VERTICAL,  Range=[Z_range[0], Z_range[1]],$
       TLocation='RIGHT'       
   ENDIF
	
   
   IF ~KEYWORD_SET(GREY) then begin
   cgLoadCT, 33
   TVLCT, cgColor('gray', /Triple), -10
   TVLCT, r, g, b, /Get
   palette = [ [r], [g], [b] ]
   cgImage, img_scale, XRange=xrange, YRange=yrange, /AXES ,/KEEP_ASPECT_RATIO, Palette=palette, $
      XTitle=XY_label[0], YTitle=XY_label[1],  Position=[0.125, 0.125, 0.8, 0.95], AXKEYWORDS=axis_format       
   IF KEYWORD_SET(Z_label) THEN cgColorbar, Position=[0.875, 0.120, 0.92, 0.95], Title=Z_label, $
        NColors=254, Bottom=1,Ticklen=-0.25, /Top, /VERTICAL,  Range=[Z_range[0], Z_range[1]],$
       TLocation='RIGHT'
   ENDIF
  
  IF KEYWORD_SET(SAVE_EPS) then  cgPS_Close
  IF KEYWORD_SET(SAVE_PNG) then  cgPS2Raster, SAVE_EPS, /PNG, Width=400
   
END
   

             
