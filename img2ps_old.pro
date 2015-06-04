pro img2ps_old,img,ct=ct,reverse=reverse,plot_title=plot_title,mask=mask,mcolor=mcolor $
           ,fileps=fileps,grid=grid,STC=STC,plotgrid=plotgrid,myformat=myformat $
           ,scalerange=scalerange,plottick=plottick,YXratio=YXratio,Chsize=Chsize $
           ,noframe=noframe,physcal=physcal,xtitle=xtitle,ytitle=ytitle,xzoom=xzoom $
           ,nocolorbar=nocolorbar, fontsize=fontsize,userback=userback,nocolorps=nocolorps $
           ,invert_colorbar=invert_colorbar

; mask  -- can be a value or vetor index of img.
; ct -- color table. If not given, then ct=0
; reverse -- use this keyword to reverse the color tables
; chsize -- charactere size (xtitle, ytitle, physcal)

IF not KEYWORD_SET(fontsize) THEN fontsize=0.7

;; deal with mask and get the min and max of data
IF KEYWORD_SET(mask) THEN BEGIN
   siz=SIZE(mask)               ; get size
   IF siz[0] EQ 0 THEN BEGIN    ; if mask is a value, try to get mask index
      mask=WHERE(img EQ mask,Nmask)
   ENDIF ELSE BEGIN
      Nmask=N_elements(mask)
   ENDELSE
   IF Nmask GT 0 THEN img[mask]=!values.F_nan 
ENDIF ELSE BEGIN
   mask=-1
   Nmask=0
ENDELSE

idx_eff=WHERE(FINITE(img) EQ 1,Neff)
IF Nmask GT 0 THEN img[mask]=0

; get data min max
IF Neff NE 0 THEN BEGIN 
   datamax=MAX(img[idx_eff]) & datamin=MIN(img[idx_eff])
ENDIF ELSE BEGIN
   datamax=1. & datamin=0
ENDELSE

; set the mask color for mask
IF not KEYWORD_SET(mcolor) THEN mcolor=0
; deal with color table
IF not KEYWORD_SET(ct) THEN ct=0

LOADCT,ct,/SILENT
TVLCT,r,g,b,/GET
; reverse color table if required

IF KEYWORD_SET(reverse) THEN BEGIN
   r=REVERSE(r) & g=REVERSE(g) & b=REVERSE(b) 
ENDIF
 
; change background color , if set
siz=SIZE(mcolor)
IF siz[0] EQ 1 AND siz[1] EQ 3 THEN BEGIN
    r[0]=mcolor[0]
    g[0]=mcolor[1]
    b[0]=mcolor[2]
ENDIF
mcolor=0 ; set the background color index for displaying.
; setting current color talbe with above changes.

; set some reserved color
r(1)=192 & g(1)=192 & b(1)=192
r(2)=210 & g(2)=210 & b(2)=210
r(3)=255 & g(3)=0 & b(3)=0
r(4)=0 & g(4)=0 & b(4)=0
r(5)=255 & g(5)=255 & b(5)=255
TVLCT,r,g,b

; scale images to a good range, and adjust the colorbar
IF KEYWORD_SET(invert_colorbar) THEN colorbar=256.-FINDGEN(256) ELSE colorbar=FINDGEN(256)
background=15 ;& if ct eq 0 or ct eq 3 then background=50
IF KEYWORD_SET(userback) THEN background=userback

IF not KEYWORD_SET(scalerange) THEN scalerange=[datamin,datamax]
img=BYTSCL(img,min=scalerange[0],max=scalerange[1],top=255-background)+background
idx=WHERE(colorbar GT background,nidx)
IF Nidx NE 0 THEN colorbar=colorbar[idx]

colorbar=TRANSPOSE(colorbar)
;; apply mask et mcolor
IF Nmask GT 0 THEN BEGIN
    img[mask]=mcolor
ENDIF

IF KEYWORD_SET(mask) THEN img=img*mask


;scalerange(0)=scalerange(0)+0.0001
;scalerange(1)=scalerange(1)-0.0001

;;;;;;;;;;;;;;;;;;;;;;;;;;;;
SET_PLOT,'ps'
; define the paper size to be 5 inch in sqare for the ploting region.

Xbase=5          ; inch
if NOT keyword_set(YXratio) THEN YXratio=1
Ybase=Xbase*YXratio  
PaperY=Ybase       ; inch
IF KEYWORD_SET(plottick) THEN ext=0.32 else ext=0.25
IF KEYWORD_SET(nocolorbar) THEN ext=0.03

PaperX=Xbase*(1+ext)    ; inch, with 20% more for color bar and numbers.
pf=PaperY/PaperX/YXratio ; factor to go back square ploting region.
zoom=0.999         ; zoom the image on paper centering at the center the paper.

IF keyword_set(xzoom) THEN zoom=xzoom
yoff=(1-zoom)
xoff=yoff*pf
dy=zoom*0.992
;dy=zoom*0.98
;print,pf
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;                     x               y            dx          dy
tvpos=[       xoff+0.1,   yoff+0.1,     dy*pf-0.1,   dy-0.12]
tvpos_plot=[tvpos(0),tvpos(1),tvpos(0)+tvpos(2),tvpos(1)+tvpos(3)]
cbpos=[  tvpos_plot(2)+0.005*zoom, tvpos(1), 0.05*zoom, dy-0.12]
cbpos_plot=[cbpos(0),cbpos(1)+0.1,cbpos(0)+cbpos(2),cbpos(1)+cbpos(3)]
if not keyword_set(Chsize) then Chsize=26
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

!P.FONT = 0 
IF KEYWORD_SET(nocolorps) THEN indcolor=0 ELSE indcolor=1
DEVICE, /ENCAPSULATED, BITS_PER_PIXEL=24, FILENAME=fileps , FONT_SIZE=Chsize*zoom ,SET_FONT='Times-Bold', XSIZE=PaperX,YSIZE=PaperY, /INCHES, COLOR=indcolor

; show map
TV,img,tvpos(0),tvpos(1),XSIZE=tvpos(2),YSIZE=tvpos(3),/normal
IF KEYWORD_SET(grid) THEN BEGIN
   PLOT,[0,grid(0)],[.0,grid(1)],/NODATA,/OERASE,POS=tvpos_plot,XSTYLE=1,YSTYLE=1,COLOR=5,XTICKLAYOUT=1,YTICKLAYOUT=1

   IF not KEYWORD_SET(noframe) THEN plots,[0.,grid(0),grid(0),0.,0.],[0.,0.,grid(1),grid(1),0.],COLOR=4

   IF KEYWORD_SET(plotgrid) THEN BEGIN
      FOR i=1, grid(0)-1 DO BEGIN
         plots,[i,i],[0,grid(1)],color=2,line=1
      ENDFOR
      FOR i=1, grid(1)-1 DO BEGIN
         plots,[0,grid(0)],[i,i],color=2,line=1
      ENDFOR
   ENDIF
ENDIF

if keyword_set(STC) then begin
    if( total (STC) ne 0) then begin
        A =  FINDGEN(17) *  (!PI*2/16.) 
        USERSYM, 0.6*COS(A), 0.6*SIN(A), /FILL 
        plots,[stc(0)],[stc(1)],psym=8,color=2
        USERSYM, 0.3*COS(A), 0.3*SIN(A), /FILL 
        plots,[stc(0)],[stc(1)],psym=8,color=3
    endif
  ENDIF


;To plot the grid in kpc
; the coordinate box for image
plot, [0, 0], /nod, /noer, position=[tvpos(0),tvpos(1),tvpos(0)+tvpos(2),tvpos(1)+tvpos(3)], xst=1, yst=1, color=4, charsize = fontsize, ythick = 1.,xthick = 1., xr = [physcal(0),physcal(1)], xticks = 2.,yr =[physcal(2),physcal(3)], yticks = 2., yminor = 4, xminor = 4, xtitle=xtitle, ytitle=ytitle

;AXIS, 0, 0, xax = 0., /dat
;AXIS, YAXIS=1, YRANGE=[0, 6], YSTYLE=4, YTICKFORMAT='(I2)', YTICKS=6, YTICKLEN=ticklen, COLOR=4,  ythick = 3., charsize = 0.
;AXIS, XRANGE=[0, 8], XSTYLE=1, XTICKFORMAT='(I2)', XTICKS=8, XTICKLEN=ticklen,  Xthick = 3. 
;xyouts, 25/260., 198/230., objname, /norm, charsize=1.5, charthick = 2  ; label text
;xyouts, 175/260., 198/230., redshift, /norm, charsize=1.5, charthick = 2  ; label text
;print,  [tvpos(0),tvpos(1),tvpos(0)+tvpos(2),tvpos(1)+tvpos(3)]

dshft=0.05

; show colorbar
if NOT keyword_set(nocolorbar) then tv,colorbar,cbpos(0)+dshft,cbpos(1),XSIZE=cbpos(2)*1.5,YSIZE=cbpos(3),/normal

; mark for the colorbar
; the coordinate box for color bar
delta = scalerange(1)-scalerange(0)
;stop
divisions = 4. ; the number of major ticks 
ticklen = 0.5  &  format = '(F5.1)' &  charsize = fontsize & bottom = 0 & minor = 1. 
if keyword_set(myformat) then format=myformat
;;;;0.845, 0.1, 0.925, 0.97
;plot, [0,1], [scalerange(0), scalerange(1)], /nod, /noer, /norm, position=[cbpos(0)+0.125,cbpos(1),cbpos(0)+cbpos(2),cbpos(1)+cbpos(3)], XTICKS=1, YTICKS=divisions, XSTYLE=1, YSTYLE=1, YTICKFORMAT='(A1)', XTICKFORMAT='(A1)', YTICKLEN=ticklen , YRANGE=[scalerange(0), scalerange(1)], YMINOR=minor, color=4,  ythick = 3. 
;plot, [0,1], [scalerange(0), scalerange(1)], /nod, /noer, /norm, position=[cbpos(0)+0.125+cbpos(2),cbpos(1),cbpos(0)+cbpos(2)+cbpos(2),cbpos(1)+cbpos(3)],color=2
;AXIS, YAXIS=1, YRANGE=[scalerange(0), scalerange(1)], YSTYLE=1, YTICKFORMAT=format, YTICKS=divisions, YTICKLEN=ticklen, CHARSIZE=charsize, YMINOR=minor, COLOR=4,  ythick = 3.

;print,cbpos(0)+0.125,cbpos(1),cbpos(0)+cbpos(2),cbpos(1)+cbpos(3)
if NOT keyword_set(nocolorbar) then  plot, [0,1], [scalerange(0), scalerange(1)], /nod, /noer, /norm, position=[cbpos(0)+dshft, cbpos(1), cbpos(0)+cbpos(2)*1.5+dshft, cbpos(1)+cbpos(3)], XTICKS=1, YTICKS=divisions, XSTYLE=1, YSTYLE=1, YTICKFORMAT='(A1)', XTICKFORMAT='(A1)', YTICKLEN=ticklen , YRANGE=[scalerange(0), scalerange(1)], YMINOR=minor, color=4,  ythick = 3.
if NOT keyword_set(nocolorbar) then  AXIS, YAXIS=1, YRANGE=[scalerange(0), scalerange(1)], YSTYLE=1, YTICKFORMAT=format, YTICKS=divisions, YTICKLEN=ticklen, CHARSIZE=charsize, YMINOR=minor, COLOR=4,  ythick = 3.

; delta = scalerange(1)-scalerange(0)
; print, [cbpos(0)+0.2,cbpos(1),cbpos(0)+cbpos(2)-0.05,cbpos(1)+cbpos(3)]
; plot, findgen(delta*10.),xra = [0, 1], yra=[scalerange(0),scalerange(1)], /nod, /noer, position=[cbpos(0)+0.125,cbpos(1),cbpos(0)+cbpos(2),cbpos(1)+cbpos(3)], xst=1, yst=1, color=4, charsize = 0.7, ythick = 3., yticklen = 0.1
; ;loadct,ct
; ;plot,[0,0,1,0],[scalerange(0), scalerange(1)],/nodata,/noerase,pos=cbpos_plot,/normal,XSTYLE=1,YSTYLE=1


device,/COURIER
if keyword_set(plottick) then axis,yaxis=1,yr=[scalerange(0),scalerange(1)],ys=1,charsize=.6*sqrt(sqrt(zoom))
device,SET_FONT='Times-Bold'
if keyword_set(plottick) then CHoff=1.8 else CHoff=1.
;xyouts,Choff,0.01,string(datamin,format=myformat)
;xyouts,CHoff,0.9,string(datamax,format=myformat)
if not keyword_set(plot_title) then plot_title=""
xyouts,2.5+CHoff,0.5,string(plot_title), ALIGNMENT=0.5,ORIENTATION=90
; close device
DEVICE, /CLOSE 
set_plot,'x'
end
