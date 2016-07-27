; NAME:
; 		GALOUT_IMAGES
; PURPOSE:
; 		Read the output cube image from GALFIT
; 		(image/model/res) and create EPS images of the image,
; 		model and residues
; 		
; CALLING SEQUENCE:
;    GALOUT_IMAGES,GALOUT_FILE, OUTEPS1, OUTEPS2, OUTEPS3, REDSHIFT=redshift,KPC_SCALE=kpc_scale,THRESH=threh,MSKFILE=mskfile,PIXSCALE=pixscale,Z_label=Z_label
;
; INPUT:
;   GALOUT_FILE = datacube with image/model/residu (GALFIT output)
;   OUTEPS1 = file name for the eps image of the galaxy
;   OUTEPS2 = file name for the eps image of the model
;   OUTEPS3 = file name for the eps image of the residual map
;  
;  OPTIONAL INPUT KEYWORDS:
; 	REDSHIFT = redshift of the galaxy (must be provided if keyword kpc_scale
;       to calculated the corresponding size in pixels)
;       PIXSCALE = pixel size (must be provided if keyword kpc_scale
;       to calculated the corresponding size in pixels)
;       KPC_SCALE = size of the output images in kpc
; 	MSKFILE = mask file where pixels with a value=0 are not taking
; 	into account when calculating the image scale (min-max) 
; 	THRESH = vector giving
; 	[min_im,max_im,min_mod,max_mod,min_res,max_res] of the three
; 	images (galaxy/model/residual map)
; 	Z_label = labels for intensity axis. If set, then an intensity
; 	scale is added in the output images   
; 	      
;
; PROCEDURES CALLED : pix2kpc, img2ps
; MODIFICATION HISTORY: 
;               Created by Karen D. 06/05/2015

FUNCTION TRIM_IM, im, xc,yc,x_size,y_size
img_trim=im[xc-x_size: xc+x_size,yc-y_size: yc+y_size ]
return, img_trim
END

PRO GALOUT_IMAGES,GALOUT_FILE, OUTEPS1, OUTEPS2, OUTEPS3, REDSHIFT=redshift,KPC_SCALE=kpc_scale,THRESH=thresh,MSKFILE=mskfile,PIXSCALE=pixscale,Z_label=Z_label
 
fimg=GALOUT_FILE

feps=OUTEPS1
feps2=OUTEPS2
feps3=OUTEPS3
print,fimg
img=READFITS(fimg,EXTEN_NO=1,/SILENT)  ;; reading the original image
model=READFITS(fimg,EXTEN_NO=2,/SILENT) ;; reading the model image
res=READFITS(fimg,EXTEN_NO=3,/SILENT) ;; reading the residual image

IF KEYWORD_SET(mskfile) THEN BEGIN
   mask=READFITS(MSKFILE,/SILENT) ;; mask file which masks the other objects or too bright region to optimize the dynamic of the output image
     z_range=[MIN(img[WHERE(mask NE 1)]),MAX(img[WHERE(mask NE 1)])]
ENDIF ELSE BEGIN
   z_range=[MIN(img),MAX(img)]
ENDELSE

xc = (SIZE(img))[1]/2.
yc = (SIZE(img))[2]/2.

IF KEYWORD_SET(kpc_scale) THEN BEGIN
;;;; determine the size of output images in pixels (square stamps)
   spatial_label=['kpc','kpc']
   dd=ZANG(kpc_scale,redshift,/SILENT)
   ddp=long(dd/pixscale)
   xymax = ROUND(ddp/2.)
;stop
  ; img=TRIM_IM(img, xc,yc,xymax,xymax)
  ; model=TRIM_IM(model, xc,yc,xymax,xymax)
  ; res=TRIM_IM(res, xc,yc,xymax,xymax) 
   print, xymax
   IF xymax GE MIN([(SIZE(img))[1],(SIZE(img))[2]])/2. THEN BEGIN
      xymax = (MIN([(SIZE(img))[1],(SIZE(img))[2]])-1)/2.
      kpc_scale = pix2kpc(pixscale,redshift,2*xymax)          
   ENDIF
   scale=[kpc_scale/2.,kpc_scale/2.]
ENDIF ELSE BEGIN         ;;;; pixel units, input image size
   xymax=(MIN([(SIZE(img))[1],(SIZE(img))[2]])-1)/2.
   scale=[xymax,xymax]
   spatial_label=['pix','pix']
ENDELSE

img2ps,img,scale,z_range,spatial_label,save_eps=outeps1,/grey,/inverse,/log,z_label=z_label
img2ps,model,scale,z_range,spatial_label,save_eps=outeps2,/grey,/inverse,/log,z_label=z_label
img2ps,res,scale,z_range,spatial_label,save_eps=outeps3,/grey,/log,z_label=z_label

END
