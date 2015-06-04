; Plot surface brithgness profile and PA vs radius 
; from iraf ellipse output 
 
; PLOT_SB_PA,file,'3D_COS3_10857_radialSB.dat',0.952

PRO PLOT_SB_PA,ellipse_out,image_file

image = readfits(image_file,header)
redshift = SXPAR( header, 'REDSHIFT')
Name = SXPAR( header, 'OBJECT')

Pixel_scale = 0.05
ZP = 26. + 2.5*alog10(3.)

SB_limit = 24 ;
mu_lim_COSMOS = 26.13 + 2.5*alog10(!pi) - 2.5*alog10(3.); mag par arc^2
mu_lim_GS =  26.56 + 2.5*alog10(!pi) - 2.5*alog10(3.); mag par arc^2
mu_lim_UDS =  26.166 + 2.5*alog10(!pi) - 2.5*alog10(3.); mag par arc^2

cgPS_Open, Filename=Name+'_SB_profile.ps'
;INDEF_VALUE ='-999'
;Comd_FileIN="'s%INDEF%"+INDEF_VALUE+"%' "
;Comd_config="sed -e "+Comd_FileIN +"< "+ellipse_out+" > "+ellipse_out+'.txt'
;print,Comd_config
;spawn,Comd_config

readcol,ellipse_out,format='(i,f,f,f,f,f,f,f,f,f)', row,sma,I,I_err,E,E_err,PA,PA_err,xc,yc,/silent

;fnu_ZP =  10^(-0.4*(mu_lim +48.6))
;I_ZP= 0.017 *5 / sqrt(3);/Pixel_scale^2
;Mag = -2.5*alog10( I * fnu_ZP /I_ZP) -48.6
;SB = Mag  - 10*alog10(1+redshift)

x_kpc = pix2kpc(Pixel_scale,redshift,sma);^0.25

SB = -2.5*alog10(I)+ZP + 2.5*alog10(Pixel_scale^2) - 10*alog10(1+redshift)
SB_low = -2.5*alog10(I - I_err)+ZP + 2.5*alog10(Pixel_scale^2)- 10*alog10(1+redshift)
SB_high = -2.5*alog10(I + I_err)+ZP + 2.5*alog10(Pixel_scale^2)- 10*alog10(1+redshift)
without_err =WHERE(PA_err LE -999 OR E_err LE -999, COMPLEMENT=with_err)

;Compute R at m_0 = 24 mag / arcsec ^2
min_tmp=min(abs(SB - SB_limit ),R_24_ind)
;print,"Radius (J =24)" , x_kpc[R_24_ind]
sky_sigma=Randomn_sky_stat(image)
SNR=I/sky_sigma
SN_thresold=3.
min_SNR=min(abs(SNR - SN_thresold),ind)
print,"Sky sigma" , sky_sigma
print,"Radius (sN=3)" , x_kpc[ind]
print,"PA (@sN=3)" , PA[ind] , PA_err[ind] 
print,"E (@sN=3)" , E[ind] ,E_err[ind]

rangeX= minmax(x_kpc)

;window,1,xsize=700,ysize=600,TITLE=name+' PROFILE'
cgplot, x_kpc,SB,yrange=[27,16],XTITLE='Radius [Kpc]',YTITLE='Surface magnitude [mag/arcsec]',col='red', Position=[0.05, 0.10, 0.40, 0.90],xthic=2,ythic=2, charsize=1.5,CHARTHICK=2;, TITLE=Name,thic=2
cgoplot,x_kpc,mu_lim_COSMOS+x_kpc*0.,col='Selected'
cgoplot,x_kpc,mu_lim_GS+x_kpc*0.,col='Thistle'

loadct,0
oploterror, x_kpc, SB, SB - SB_low, psym=3,/HIBAR,ERRCOLOR=150
oploterror, x_kpc, SB, SB_high - SB, psym=3,/LOBAR,ERRCOLOR=150
;cgoplot,x_kpc,SB,col='red',thic=2
oplot, [x_kpc[ind],x_kpc[ind]],[-10,30],LINESTYLE=2,col='120'


cgplot,x_kpc,PA,YTITLE='PA [deg]',xrange=rangeX,col='red',thic=2, Position=[0.55, 0.55, 0.95, 0.90],xthic=2,ythic=2, charsize=1.5,CHARTHICK=1.2, /NoErase,XS=1
oploterror,x_kpc[with_err],PA[with_err],PA_err[with_err], psym=3,ERRCOLOR=50
oplot, [x_kpc[ind],x_kpc[ind]],[-100,100],LINESTYLE=2,col='120'


cgplot,x_kpc,E,thic=2,XTITLE='Radius [Kpc]',YTITLE='E',xrange=rangeX, Position=[0.55, 0.10, 0.95, 0.45],xthic=2,ythic=2, charsize=1.5,col='red', CHARTHICK=1.2,/NoErase,XS=1
oploterror,x_kpc[with_err],E[with_err],E_err[with_err], psym=3,ERRCOLOR=50
;oplot, [0,200],[SN_thresold,SN_thresold],LINESTYLE=2,col='120'
oplot, [x_kpc[ind],x_kpc[ind]],[-10,200],LINESTYLE=2,col='120'

cgPS_Close

size_data = 200
scale_zoom=2

Window, 2,xsize=size_data * scale_zoom,ysize=size_data * scale_zoom,TITLE=name
image_CROP =   CONGRID( image(150:350, 150:350),size_data * scale_zoom, size_data * scale_zoom)
image_scl=alogscale(255-image_CROP,/auto)

loadct,0

TVSCL, image_scl;, size_data * scale_zoom, size_data * scale_zoom
;cgLegend, 150, 150,name,color='red'
X_center=xc -150
Y_center=yc -150
loadct,12
for i=0, n_elements(sma)-1 do begin
IF ((i MOD 2) EQ 0) then TVELLIPSE, sma[i]*scale_zoom, scale_zoom*(1 -E[i]) * sma[i],scale_zoom* X_center[i], scale_zoom* Y_center[i],  PA[i] - 90 ,color=200
endfor
TVELLIPSE, sma[ind]*scale_zoom, scale_zoom*(1 -E[ind]) * sma[ind],scale_zoom* X_center[ind], scale_zoom* Y_center[ind],  PA[ind] - 90 ,color=120, thick=2
END

FUNCTION Randomn_sky_stat,image

n_sample=1000.
pixel_scale=0.05
radius_sky =floor(1./pixel_scale )
nx=n_elements(image[*,1])
ny=n_elements(image[1,*])

x_sky=ceil(randomu(seed,n_sample)*(nx  - radius_sky *2) + radius_sky)
y_sky=ceil(randomu(seed,n_sample)*(ny  - radius_sky *2 ) + radius_sky )
close_obj=WHERE(x_sky GT 150 AND x_sky LT 350 AND y_sky GT 150 AND y_sky LT 350)
remove,close_obj,x_sky, y_sky
Sky=fltarr(n_elements(x_sky))
for k=0,n_elements(x_sky) -1  do begin
area= [x_sky[k] - radius_sky/2, x_sky[k] + radius_sky/2 ,  y_sky[k] - radius_sky/2 , y_sky[k] + radius_sky/2 ]
Sky[k]=sigma(image[x_sky[k] - radius_sky/2 : x_sky[k] + radius_sky/2, y_sky[k] - radius_sky/2 : y_sky[k] + radius_sky/2])
endfor
Sky_sigma=mean(Sky,/nan)
return,Sky_sigma

END


PRO Profile_all

Path_IN='/Users/hypatia/Documents/IMAGES_Kinematics/3D_HST/Morpho/Profiles/'
SUFFIXE_IN = '_sum_clean.fits'
SUFFIXE_ELLIPSE_DAT = '_ellipse.dat'

readcol,'../KMOS3D_Wisnioski2014_z1.cat',format='(a,d,d,f)',OBJECT,RA,DEC,redshift


for i=0, n_elements(OBJECT) -1 do begin 

PLOT_SB_PA,Path_IN+OBJECT(i)+SUFFIXE_ELLIPSE_DAT,Path_IN+OBJECT(i)+SUFFIXE_IN
PAUSE
endfor

END