; NAME:
; 		PLOTPROFILE
; PURPOSE:
; 		Plot the galaxy and model profile (in image flux and
; 		in surface brightness) along the major and minor axis
; 		of the larger fitted component and save into a EPS file 
; 		
; CALLING SEQUENCE:
;    PLOTPROFILE,zp,pixscale,Z_label,LOG_FILE, GALOUT_FILE, SUBCOMP_FILE, OUTEPS, exptime=exptime, redshift=redshift,xaxis_unit=xaxis_unit, scale=scale
;
; INPUT:
;   zp = zero point used to convert flux in mag
;   pixcale  = pixel size in arcsec/pix to convert mag in surface brightness
;   Z_label  = (char) unit of intensity axis
;   LOG_FILE = name of the *.log file (GALFIT output)
;   SUBCOMP_FILE = name of the datacube with model subcomponent (GALFIT output)
;   OUTEPS = file name for the output eps image
; 
;  OPTIONAL INPUT KEYWORDS:
;   exptime = exposure time used to convert flux in surface
;   brightness. Default value is 1.  
;   redshift = redshift of the galaxy, must be provided if
;   xaxis_unit='kpc', used to convert pixels into kpc
;   xaxis_unit = axis unit (pix,arcsec or kpc)	
;   scale = size of the x axis window for the plot. Default is the
;   image size.
; 	
; PROCEDURES CALLED : cgPS_Close, cgPS_Open, cgDisplay (Coyote
; package), readlog, pix2kpc
; MODIFICATION HISTORY:  
;               Created by Karen D. 07/05/2015


FUNCTION flux2mag,imgin,zp,pixscale,exptime,width=width

    img=imgin
    IF TOTAL(img) EQ 0 THEN RETURN,img
    IF KEYWORD_SET(width) THEN aw=width*2+1 ELSE aw=1
    img=img/(aw*pixscale*pixscale)
    IF KEYWORD_SET(exptime) THEN img=img/exptime
    img[where(img GT 0)] = -2.5*ALOG10(img[WHERE(img GT 0)])+zp
    ind = WHERE(img LE 0,ndx)
    IF ndx NE 0 THEN img[ind] = 99.
  RETURN,img
END



PRO plotprofile,zp,pixscale,Z_label,LOG_FILE, SUBCOMP_FILE, OUTEPS, exptime=exptime, redshift=redshift,xaxis_unit=xaxis_unit, scale=scale

;; default values
IF not KEYWORD_SET(exptime) THEN exptime=1.
IF not KEYWORD_SET(redshift) THEN zz=0. ELSE zz=redshift
IF not KEYWORD_SET(xaxis_unit) THEN xaxis_unit='pix'
IF xaxis_unit EQ 'kpc' AND not KEYWORD_SET(redshift) THEN BEGIN
   PRINT,'ERROR : kpc axis scale requires a redshift value !'
   goto,end_error
ENDIF

readlog, LOG_FILE, Components, chi2=chi2
Ncomp=N_ELEMENTS(Components.type)
ind_expdisk = WHERE(STRMATCH(Components[*].type,'expdisk') EQ 1, Nexpdisk)
ind_sersic = WHERE(STRMATCH(Components[*].type,'sersic') EQ 1, Nsersic)
ind_psf = WHERE(STRMATCH(Components[*].type,'psf') EQ 1, Npsf)
ind_sky = WHERE(STRMATCH(Components[*].type,'sky') EQ 1, Nsky)

; Sky_value
sky = Components[ind_sky].sky

;; profile plotted along the semi-major and semi-minor axis of the
;; largest (external) component
tmp=MAX(Components[*].Re,ind_maxR)
PA = Components[ind_maxR].PA
cx = Components[ind_maxR].x0
cy = Components[ind_maxR].y0
width=5 ;;; number of pixels over which the flux is summed

; Image profile
img=READFITS(SUBCOMP_FILE, EXTEN_NO=0,/SILENT)
img=img-sky
hsize = (SIZE(img))[1]
vsize = (SIZE(img))[2]
angle_major=PA-90.
angle_minor=PA

img_profile_major = img2profile(img,angle_major,[cx,cy],width) 
img_profile_minor = img2profile(img,angle_minor,[cx,cy],width) 

; model profile
model_img = FLTARR((SIZE(img))[1],(SIZE(img))[2],Ncomp)
model_profile_major = FLTARR(hsize,Ncomp)
model_profile_minor = FLTARR(hsize,Ncomp)

FOR k=0,Ncomp-1 DO BEGIN
   model_img[*,*,k] = READFITS(SUBCOMP_FILE, EXTEN_NO=k+1,/SILENT)
   model_profile_major[*,k] = img2profile(model_img[*,*,k],angle_major,[cx,cy],width)  
   model_profile_minor[*,k] = img2profile(model_img[*,*,k],angle_minor,[cx,cy],width)
ENDFOR
tot_profile_major = TOTAL(model_profile_major,2)  
tot_profile_minor = TOTAL(model_profile_minor,2)

;;; surface brightness conversion

mag_img_profile_major=flux2mag(img_profile_major,zp,pixscale,exptime)
mag_img_profile_minor=flux2mag(img_profile_minor,zp,pixscale,exptime)

mag_model_profile_major=model_profile_major
mag_model_profile_minor=model_profile_minor

FOR k=0,Ncomp-1 DO BEGIN
   mag_model_profile_major[*,k]=flux2mag(model_profile_major[*,k],zp,pixscale,exptime)
   mag_model_profile_minor[*,k]=flux2mag(model_profile_minor[*,k],zp,pixscale,exptime)
ENDFOR
mag_tot_profile_major = flux2mag(tot_profile_major,zp,pixscale,exptime)
mag_tot_profile_minor = flux2mag(tot_profile_minor,zp,pixscale,exptime)



;;; x axis scale
psize=MIN([hsize,vsize])
paxis=FINDGEN(psize)- psize/2.  ; pixels

IF xaxis_unit EQ 'pix' THEN xaxis=paxis ELSE IF xaxis_unit EQ 'arcsec' THEN xaxis=paxis*pixscale ELSE IF xaxis_unit EQ 'kpc' THEN xaxis=pix2kpc(pixscale,redshift,paxis)
IF KEYWORD_SET(scale) THEN xlimits=[-scale/2.,scale/2] ELSE xlimits=[MIN(xaxis),MAX(xaxis)]

;;; y axis flux scale
np=N_ELEMENTS(model_profile_major[*,0])
pmax=MAX([MAX(model_profile_major[np/2.-10:np/2+10,*]),img_profile_major[np/2.-10:np/2+10],tot_profile_major[np/2.-10:np/2+10]])
ylimits_flux=[-0.05*pmax,pmax*1.05]

;;; y axis mag scale
mag_min=MIN([MIN(mag_model_profile_major[np/2.-10:np/2+10,*]),mag_img_profile_major[np/2.-10:np/2+10],mag_tot_profile_major[np/2.-10:np/2+10]])
mag_max=MAX([MAX(mag_model_profile_major[np/2.-10:np/2+10,*]),mag_img_profile_major[np/2.-10:np/2+10],mag_tot_profile_major[np/2.-10:np/2+10]])
ylimits_mag=[mag_max+2,mag_min-1]

cgPS_Open, OUTEPS, /inches, portrait=1,  xsize=6, ysize=3.75,$ 
        xoffset=1.25, yoffset=3.62, /nomatch ,encapsulated=1.

cgDisplay,600,600
pos = cgLayout([2,2], OXMargin=[6,1], OYMargin=[5,1], XGap=6, YGap=5)
;!P.MULTI=[0,2,2]
;!x.thick = 2
; !y.thick = 2
; !x.margin=3.2
; !y.margin=2.    
cgPLOT,xaxis,img_profile_major,xtit='Major axis (kpc)',ytit=textoidl('Flux ('+Z_label+')'),thick=3,xs=1,xr=xlimits,yr=ylimits_flux,ys=1,xthick=2,ythick=2,charsize=1,color='black',charthick=2,aspect=1.,Position=pos[*,0]
FOR k=0,Ncomp-1 DO BEGIN
   cgPLOT,xaxis,model_profile_major[*,k],COLOR=Components[k].Color,THICK=2,LINE=2,/OVERPLOT
ENDFOR
IF ncomp GE 2 THEN cgPLOT,xaxis,tot_profile_major,COLOR='red',THICK=2,LINE=0,/OVERPLOT

cgPLOT,xaxis,mag_img_profile_major,xtit='Major axis (kpc)',ytit=textoidl('Surface Brightness (mag.arcsec^{-2})'),thick=3,xs=1,xr=xlimits,yr=ylimits_mag,ys=1,xthick=2,ythick=2,charsize=1,color='black',charthick=2,aspect=1.,Position=pos[*,1], /NoErase
FOR k=0,Ncomp-1 DO BEGIN
   cgPLOT,xaxis,mag_model_profile_major[*,k],COLOR=Components[k].Color,THICK=2,LINE=2,/OVERPLOT
ENDFOR
IF ncomp GE 2 THEN cgPLOT,xaxis,mag_tot_profile_major,COLOR='red',THICK=2,LINE=0,/OVERPLOT

cgPLOT,xaxis,img_profile_minor,xtit='Minor axis (kpc)',ytit=textoidl('Flux ('+Z_label+')'),thick=3,xs=1,xr=xlimits,yr=ylimits_flux,ys=1,xthick=2,ythick=2,charsize=1,color='black',charthick=2,aspect=1.,Position=pos[*,2] , /NoErase
FOR k=0,Ncomp-1 DO BEGIN
   cgPLOT,xaxis,model_profile_minor[*,k],COLOR=Components[k].Color,THICK=2,LINE=2,/OVERPLOT
ENDFOR
IF ncomp GE 2 THEN cgPLOT,xaxis,tot_profile_minor,COLOR='red',THICK=2,LINE=0,/OVERPLOT

cgPLOT,xaxis,mag_img_profile_minor,xtit='Minor axis (kpc)',ytit=textoidl('Surface Brightness (mag.arcsec^{-2})'),thick=3,xs=1,xr=xlimits,yr=ylimits_mag,ys=1,xthick=2,ythick=2,charsize=1,color='black',charthick=2,aspect=1.,Position=pos[*,3], /NoErase
FOR k=0,Ncomp-1 DO BEGIN
   cgPLOT,xaxis,mag_model_profile_minor[*,k],COLOR=Components[k].Color,THICK=2,LINE=2,/OVERPLOT
ENDFOR
IF ncomp GE 2 THEN cgPLOT,xaxis,mag_tot_profile_minor,COLOR='red',THICK=2,LINE=0,/OVERPLOT


;;; LEGEND
IF ncomp GE 2 THEN cgLEGEND,titles=['observation',Components[*].type,'total model'],colors=['black',Components[*].Color,'red'],length=0.02,linestyles=[0,REPLICATE(2,ncomp),0],LOCATION=[0.1,0.95],thick=2,charsize=1.,vspace=1. ELSE cgLEGEND,titles=['observation',Components[*].type],colors=['black',Components[*].Color],length=0.02,linestyles=[0,REPLICATE(2,ncomp)],LOCATION=[0.1,0.95],thick=2,charsize=1.,vspace=1.

cgPS_Close, Width=600

end_error:
END
