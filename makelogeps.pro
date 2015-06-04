PRO makelogeps,name, pixscale, MSKFILE, LOG_FILE, GALOUT_FILE, SUBCOMP_FILE, MSKFILE, OUTFILE , OUTEPS1, OUTEPS2, OUTEPS3, REDSHIFT=redshift,SCALE=scale,GOODS=goods,THRESH=thresh,KPC=kpc,readini=readini

IF KEYWORD_SET(redshift) THEN zz=redshift ELSE zz=0.

OPENU,unit,'skysub_eps_making.log',/GET_LUN,/APPEND

LOADCT,0,/SILENT
IF NOT KEYWORD_SET(scale) THEN scale=50. ;;; default size stamps : 50 kpc
IF NOT KEYWORD_SET(thresh) THEN thresh=1.   ;;;; cut above the background for the eps stamps
 
fimg=GALOUT_FILE
fimg2=SUBCOMP_FILE

feps=OUTEPS1
feps2=OUTEPS2
feps3=OUTEPS3



IF KEYWORD_SET(readini) THEN BEGIN
   filename=readini
   read_ini,filename,name=name_comp,comp=comp,sky=sky
ENDIF ELSE BEGIN
   filename = LOG_FILE
   readlog,filename,name=name_comp,comp=comp,sky=sky
ENDELSE
   
Ncomp = N_ELEMENTS(name_comp)

img=READFITS(fimg,EXTEN_NO=1,/SILENT)
img2=READFITS(fimg,EXTEN_NO=2,/SILENT)
img3=READFITS(fimg,EXTEN_NO=3,/SILENT)

IF KEYWORD_SET(GOODS) THEN BEGIN
   img=img+100
   img2=img2+100
   img3=img3+100
ENDIF

mask=READFITS(MSKFILE,/SILENT)

xc = (SIZE(img))[1]/2.
yc = (SIZE(img))[2]/2.

IF not KEYWORD_SET(scale) THEN BEGIN
   xymax=(MIN([(SIZE(img))[1],(SIZE(img))[2]])-1)/2.
   IF KEYWORD_SET(kpc) THEN BEGIN
      scale=pix2kpc(pixscale,zz,2*xymax)
      xlabel='kpc'
      ylabel='kpc'
   ENDIF ELSE BEGIN
      scale=2*xymax
      xlabel='pix'
      ylabel='pix'
   ENDELSE
ENDIF ELSE BEGIN
   IF KEYWORD_SET(kpc) THEN BEGIN
      dd=zang(scale,zz,/SILENT)
      ddp=long(dd/pixscale)
      xymax = ROUND(ddp/2.)
      IF xymax GE MIN([(SIZE(img))[1],(SIZE(img))[2]])/2. THEN BEGIN
         xymax = (MIN([(SIZE(img))[1],(SIZE(img))[2]])-1)/2.
         scale = pix2kpc(pixscale,zz,2*xymax)
      ENDIF
      xlabel='kpc'
      ylabel='kpc'
   ENDIF ELSE BEGIN
      xymax=scale/2.
      IF xymax GE MIN([(SIZE(img))[1],(SIZE(img))[2]])/2. THEN BEGIN
         xymax = (MIN([(SIZE(img))[1],(SIZE(img))[2]])-1)/2.
         scale = (MIN([(SIZE(img))[1],(SIZE(img))[2]])-1)
      ENDIF
      xlabel='pix'
      ylabel='pix'
   ENDELSE
ENDELSE

;img=img50(img,RR)
;img2=img50(img2,RR)
;img3=img50(img3,RR)

;; make transformation to log-scale
MMM,img,bg,bgs,/SILENT
IF bgs EQ -1 THEN PRINTF,unit,name+'_im : error in computing sky value (mmm)',FORMAT='(a)'
img=img-bg-0*bgs
img=ALOG10(img)
img=img>thresh*ALOG10(bgs)
idx=WHERE(FINITE(img) EQ 0,nidx)
IF nidx NE 0 THEN img[idx]=0
imgscale=[MIN(img[WHERE(mask NE 1)]),MAX(img[WHERE(mask NE 1)])*1.03]

MMM,img2,bg2,bgs2,/SILENT
IF bgs2 EQ -1 THEN PRINTF,unit,name+'_mod : error in computing sky value (mmm)',FORMAT='(a)'
img2=img2-bg2-0*bgs2
img2=ALOG10(img2)
img2=img2>thresh*ALOG10(bgs)
idx2=WHERE(FINITE(img2) EQ 0,nidx)
IF nidx NE 0 THEN img2[idx2]=0
imgscale2=[MIN(img2[WHERE(mask NE 1)]),MAX(img2[WHERE(mask NE 1)])*1.03]

MMM,img3,bg3,bgs3,/SILENT
IF bgs3 EQ -1 THEN PRINTF,unit,name+'_res : error in computing sky value (mmm)',FORMAT='(a)'
img3=img3-bg3-0*bgs3
img3=ALOG10(img3)
img3=img3>thresh*ALOG10(bgs)
idx3=WHERE(FINITE(img3) EQ 0,nidx)
IF nidx NE 0 THEN img3[idx3]=0
imgscale3=[MIN(img3[WHERE(mask NE 1)]),MAX(img3[WHERE(mask NE 1)])*1.03]

img2ps_old,img[xc-xymax:xc+xymax,yc-xymax:yc+xymax],ct=0,fileps=feps,myformat='(f8.5)',scalerange=imgscale,xtitl=xlabel,ytitle=ylabel,/nocolorbar,YXratio=1.,Chsize=25,physcal=[-scale/2,scale/2,-scale/2,scale/2], xzoom=0.95, userback=5, /nocolorps
img2ps_old,img2[xc-xymax:xc+xymax,yc-xymax:yc+xymax],ct=0,fileps=feps2,myformat='(f8.5)',scalerange=imgscale2,xtitl=xlabel,ytitle=ylabel,/nocolorbar,YXratio=1.,Chsize=25,physcal=[-scale/2,scale/2,-scale/2,scale/2], xzoom=0.95, userback=5, /nocolorps
img2ps_old,img3[xc-xymax:xc+xymax,yc-xymax:yc+xymax],ct=0,fileps=feps3,myformat='(f8.5)',scalerange=imgscale3,xtitl=xlabel,ytitle=ylabel,/nocolorbar,YXratio=1.,Chsize=25,physcal=[-scale/2,scale/2,-scale/2,scale/2], xzoom=0.95, userback=5, /nocolorps		


SET_PLOT, 'x'
FREE_LUN,unit

END
