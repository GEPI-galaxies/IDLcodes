pro makecolormap, im1, im2, zp1, zp2, name_fits=name_fits, scale_eps=scale_eps, snr1=snr1, snr2=snr2, msk=msk, nfilter=nfilter, snr_thresh=snr_thresh,eps_file=eps_file, nofits=nofits, header=header, physcal=physcal,skysub=skysub

;;;;;; HELP ;;;;;;;;;;
;; im1 = blue image
;; im2 = red image
;; WARNING : im1 and im2 MUST habe the same size (pixels)
;; zp1 = zero point of im1
;; zp2 = zero point of im2
;; name_fits : if set, then the fits file of the colormap is created ; notice that whatever the eps_scale, te size of the fits filethe fits file will have the same size of the input images
;; scale_eps : must be set with the keyword eps_file, and it gives the size in pixels of the eps stamps image
;; snr1 and snr2 : if set, then the snr map of the color map is calculated
;; msk : a mask file where the pixels which don't belong to the galaxy habve a zero value
;; nfilter : if set, then a gaussian filter is applied to the colormap, and the fwhm of the gaussian is nfilter
;; snr_thresh : snr threshold for the colormap, if needed
;; eps_file : if set, an eps file of the colormap is created
;; nofits : euh ...apparement ca sert a rien ...
;; header : must be set with the keyword name_fits, it gives the header of the colormap in the fits file (usually, we keep the header of the red image)
;; physcal : conversion of (scale_eps/2) in physical scale, such as kpc, it is a table : [-scale/2.,scale/2.,-scale/2.,scale/2.] where scale=50 kpc for example
;; skysub : if set then the background is calculated and subtracted in im1 and im2



;;; 2*RR is the physical scale (kpc) of the image
;;; nfilter is used for smoothing

IF not KEYWORD_SET(snr_thresh) THEN snr_thresh=0.

;;; image1, image2 and mask must have the same dimensions
;;; 'im1=blue image' and 'im2=red image'
;;; called procedures : img2ps.pro (& img50.pro)

ind = WHERE(msk EQ 0)

new = im1/im2
colormap = msk*0.0
colormap = -2.5*ALOG10(new)-zp2[0]+zp1[0]
;;; because im1 and im2 can be negative in the background regions, new
;;; can be negative and the log function causes arithmetic errors
IF WHERE(FINITE(colormap) EQ 0) NE [-1] THEN colormap[WHERE(FINITE(colormap) EQ 0)]=0.

colormap[ind]=0.

;;; compute the SNR of the color map : need for the snr of im1 and im2
;;; images ; SNR is calculated before subtracting backgrounds to images
IF KEYWORD_SET(snr1) AND KEYWORD_SET(snr2) THEN BEGIN
   col_sig=SQRT(ALOG10(1./snr1^2+1)+ALOG10(1./snr2^2+1))
   col_snr=ABS(colormap)/col_sig
   IF KEYWORD_SET(name_fits) THEN WRITEFITS, name_fits+'_snr.fits', col_snr,header
ENDIF

;;;; subtract background to im1 and im2 and recalculate the color map
IF KEYWORD_SET(skysub) THEN BEGIN
   MMM,im1[WHERE(msk EQ 0)],mb1,sb1
   im1=im1-mb1
   MMM,im2[WHERE(msk EQ 0)],mb2,sb2
   im2=im2-mb2
ENDIF

new = im1/im2
colormap = msk*0.0
colormap = -2.5*ALOG10(new)-zp2[0]+zp1[0]
IF WHERE(FINITE(colormap) EQ 0) NE [-1] THEN colormap[WHERE(FINITE(colormap) EQ 0)]=0.
colormap[ind]=0.

IF KEYWORD_SET(name_fits) THEN WRITEFITS, name_fits+'.fits', colormap,header

IF KEYWORD_SET(eps_file) THEN BEGIN
   xc = (SIZE(colormap))[1]/2.
   yc = (SIZE(colormap))[2]/2.
   
   colormap=colormap[xc-scale_eps/2.:xc+scale_eps/2.,yc-scale_eps/2.:yc+scale_eps/2.]
   msk=msk[xc-scale_eps/2.:xc+scale_eps/2.,yc-scale_eps/2.:yc+scale_eps/2.]
   col_snr=col_snr[xc-scale_eps/2.:xc+scale_eps/2.,yc-scale_eps/2.:yc+scale_eps/2.]

;; estimate color range 
   IF MAX(msk) GE 1 THEN idx=WHERE(colormap NE 0 AND msk NE 1) ELSE idx=WHERE(colormap NE 0)
   eimg=colormap[idx]
   eimg=eimg[WHERE(eimg NE 0 AND FINITE(eimg) EQ 1)]
   MMM,eimg,mm,ss
   eimg=eimg[WHERE(ABS(eimg-mm) LE 4*ss AND FINITE(eimg) EQ 1 )]
   MMM,eimg,mm,ss
   if ss ge 0.8 then ss = 0.8
   mincolor=mm-2*ss
   maxcolor=mm+2*ss
   mincolor=MAX([mincolor,min(eimg)])
   maxcolor=MIN([maxcolor,max(eimg)])
   mincolor=MAX([mincolor,mm-4*ss])
   maxcolor=MIN([maxcolor,mm+4*ss])
   
   x = 90

;;; smoothing if required
   IF KEYWORD_SET(nfilter) THEN colormap=FILTER_IMAGE(colormap,fwhm_gaussian=nfilter)

   mask=colormap*0.0
   mask[WHERE(colormap NE 0)]=1
   mask[WHERE(msk EQ 0)]=0
;stop
;colormap[WHERE(ABS(colormap) LE 1e-5)]=0
;stop

   img2ps,colormap,ct=33,mask=mask,mcolor=[x,x,x],fileps=eps_file+'.eps',plot_title='',myformat='',scalerange=[mincolor,maxcolor],physcal=physcal,xtitl='kpc',ytitle='kpc',xzoom=0.94,YXratio=1.


;;; snr map => writing
   IF KEYWORD_SET(snr1) AND KEYWORD_SET(snr2) THEN BEGIN
      img2ps,col_snr,mcolor=[x,x,x],fileps=eps_file+'_snr.eps',plot_title='',myformat='',scalerange=[min(col_snr[WHERE(colormap NE 0 AND msk NE 1)]),max(col_snr[WHERE(colormap NE 0 AND msk NE 1)])],physcal=physcal,xtitl='kpc',ytitle='kpc',xzoom=0.94,YXratio=1.,/nocolorps,/invert_colorbar
   ENDIF
ENDIF

END


PRO colormap

path='/Users/hypatia/Documents/3D_HST/'
READCOL,path+'/KMOS/KMOS3D_Wisnioski2014_z1.cat',name,dec,ra,z,FORMAT='(a,f,f,f)'

;CANDELS ZP
ZP_I=26.493
ZP_J=26.2303

;;;; ACS zero point : 
;;;;Z0_F435W = 25.673
;;;;Z0_F606W = 26.486
;;;;Z0_F775W = 25.654
;;;;Z0_F850LP = 24.862 

scale=30. ;;; physical scale of 30 kpc
band=['i','J']
pixscale=0.03
zp_blue=25.673
zp_red=24.862 

FOR k=0,N_ELEMENTS(name)-1 DO BEGIN
print, name(k)
;FOR k=0,1 DO BEGIN

	result_blue = FILE_TEST('Cutimages_8arcsec/'+name[k]+'_'+band[0]+'_convol.fits')
	result_red = FILE_TEST('Cutimages_8arcsec/'+name[k]+'_'+band[1]+'.fits')
	
IF result_blue+result_red EQ 2 then begin 
 
   im_blue = READFITS('Cutimages_8arcsec/'+name[k]+'_'+band[0]+'_convol.fits')
   im_red = READFITS('Cutimages_8arcsec/'+name[k]+'_'+band[1]+'.fits')

   wht_blue = READFITS('Cutimages_8arcsec/'+name[k]+'_'+band[0]+'_convol_wht.fits')  ;; for the SNR calculation
   wht_red = READFITS('Cutimages_8arcsec/'+name[k]+'_'+band[1]+'_wht.fits')   ;; for the SNR calculation

   header=HEADFITS('Cutimages_8arcsec/'+name[k]+'_'+band[1]+'.fits',/SILENT) ;;; header kept for the colormap

;; SNR of the red and blue images : 
   sig_b = 0.5625*1./SQRT(wht_blue)
   sig_r = 0.6122*1./SQRT(wht_red)
   snr_blue = ABS(im_blue)/sig_b
   snr_red = ABS(im_red)/sig_r

;; sectracting the sources to build a mask where sky pixels have a
;; value=0
   make_se,im_red,idobj=idobj,detect_thresh=1.5,analysis_thresh=2
   mask=READFITS('seg.fits',/SILENT)
   SPAWN,'rm seg.fits '

   mask[WHERE(mask EQ idobj[0])]=2000
   IF WHERE(mask NE 2000 AND mask NE 0) NE [-1] THEN mask[WHERE(mask NE 2000 AND mask NE 0)]=1
   mask[WHERE(mask EQ 2000)]=2

;;; size of the color image : 
   dd=ZANG(scale,z[k],/SILENT)  ;;;; conversion kpc in arcsec
   ddp=LONG(dd)/pixscale     ;;;; conversion arcsec in pixels
   RR=ROUND(ddp/2.)
   xc = (SIZE(im_red))[1]/2.
   yc = (SIZE(im_red))[2]/2.
   IF RR GE min([(SIZE(im_red))[1],(SIZE(im_red))[2]])/2. THEN BEGIN
      RR = (min([(SIZE(im_red))[1],(SIZE(im_red))[2]])-1)/2.
      scale = pix2kpc(pixscale,z[k],2*RR)
   ENDIF

   name_eps=name[k]+'_i-J'
   name_fits=name[k]+'_i-J'

   makecolormap,im_blue,im_red,zp_blue,zp_red,name_fits=name_fits,scale_eps=2*RR,snr1=snr_blue,snr2=snr_red,nfilter=2,msk=mask,header=header,physcal=[-scale/2.,scale/2.,-scale/2.,scale/2.],eps_file=name_eps
ENDIF
ENDFOR

END
