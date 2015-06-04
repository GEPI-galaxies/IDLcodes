; NAME:
; 	   CUT_STAMPS
;
; PURPOSE:
; 			Return a subregion of a image around pixel (x,y) 
; 			of size t[0] X t[1] 
; 
; CALLING SEQUENCE:
; 
; INPUTS: 
;  		IM = image to cut
;   	 x = x position of the center
;   	 y = y position of the center
;  		 t = size of the new image (2 elements array) [nx,ny]
;
; OPTIONAL INPUT KEYWORDS:
;   	/SQUARE : square image. use nx for ny
;    	/COORD : only return coordinates 
;  		HEADER : Input header of the image IM and return updated header
;
; OUTPUTS: 
;         Result of function = sub region of the input image (2D array)
; EXAMPLE: 
; 	     Cut a sub region of size [20,40] from image (a 2D array) around pixel [50,80]
; 		 IDL> image=readfits('image.fits', header) 
; 		 IDL> cubimage=cut_stamps(image,50,80,[20,40])
;
;        Update header with new subregion
; 		 IDL> cubimage=cut_stamps(image,50,80,[20,40], header=header)
;
; PROCEDURES CALLED : HEXTRACT (astrolib)
;
; MODIFICATION HISTORY:
;  		        Created by Karen D. 
; 				Modified by Myriam R. 28/05/2015

FUNCTION cut_stamps,im,x,y,t,SQUARE=SQUARE,coord=coord,header=header

;; t can be a 2-dim array (dimx,dimy)

size_im = size(im)

IF N_ELEMENTS(t) EQ 1 THEN t=REPLICATE(t,2)

xmin = FLOOR(x-t[0]/2.)
xmax = FLOOR(x+t[0]/2.)-1
ymin = FLOOR(y-t[1]/2.)
ymax = FLOOR(y+t[1]/2.)-1

IF KEYWORD_SET(SQUARE) THEN BEGIN
   IF xmin LT 0 THEN BEGIN
      xmin = 0
      xmax = FLOOR(2*x)-1
      ymin = FLOOR(y-(xmax-xmin)/2.)
      ymax = FLOOR(y+(xmax-xmin)/2.)-1
   ENDIF
   IF xmax GE size_im[1] THEN BEGIN
      xmin = FLOOR(2*x-(size_im(1))+1)
      xmax = FLOOR(size_im[1]-1)
      ymin = FLOOR(y-(xmax-xmin)/2.)
      ymax = FLOOR(y+(xmax-xmin)/2.)-1
   ENDIF
   IF ymin LT 0 THEN BEGIN
      ymin = 0
      ymax = FLOOR(2*y)-1
      xmin = FLOOR(x-(ymax-ymin)/2.)
      xmax = FLOOR(x+(ymax-ymin)/2.)-1
   ENDIF 
   IF ymax GE size_im[2] THEN BEGIN
      ymin = FLOOR(2*y-(size_im[2])+1)
      ymax = FLOOR(size_im[2]-1)
      xmin = FLOOR(x-(ymax-ymin)/2.)
      xmax = FLOOR(x+(ymax-ymin)/2.)-1
   ENDIF
ENDIF ELSE BEGIN
   IF xmin LT 0 THEN xmin=0
   IF xmax GE size_im[1] THEN BEGIN
      xmax=size_im[1]-1
   ENDIF 
   IF ymin LT 0 THEN ymin=0
   IF ymax GE size_im[2] THEN BEGIN
      ymax=size_im[2]-1
   ENDIF
ENDELSE

IF keyword_set(coord) THEN BEGIN
   RETURN,[xmin,xmax,ymin,ymax]
ENDIF ELSE BEGIN
   IF keyword_set(header) THEN BEGIN
      HEXTRACT,im,header,newim,newhdr,xmin,xmax,ymin,ymax,/SILENT
      header = newhdr
      RETURN,newim
   ENDIF ELSE BEGIN
      res=im[xmin:xmax,ymin:ymax]
      RETURN,res
   ENDELSE 
ENDELSE


END
