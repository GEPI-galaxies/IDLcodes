FUNCTION PA_E_FromEllipse, SBProfile_out, SB_limit = SB_limit, SN_threshold=SN_threshold

readcol,SBProfile_out, format='(i,f,f,f,f,f,f,f,f,f,f,f,f,f)', sma,x_kpc,Int, I_err, SB, SB_low, SB_high, PA, PA_err, E,E_err, xc,yc,Tota_mag_ellipse

;Compute R at SB_R
min_tmp=min(abs(SB - SB_limit ),R_SB_ind)
print,"---- Surface brigthness threshold -----"
print," SB limit :",SB_limit
print,"Radius :", x_kpc[R_SB_ind]
ind_array=indgen(5)-2+R_SB_ind 
print,"PA :", median(PA[ind_array]) ;+' +/- '+PA_err[R_SB_ind]
print,"E :", median(E[ind_array]) ;+' +/- '+E_err[R_SB_ind]

IF KEYWORD_SET(SN_threshold) then begin
;Compute R at SB_R
sky_sigma=Randomn_sky_stat(image)
sky_mag= -2.5*alog10(3*sky_sigma) + 26. -10*alog10(1.535)
print,sky_mag
print,-2.5*alog10(sky_sigma) + 26.
SNR=SB/sky_mag
SN_thresold=3.
min_SNR=min(abs(SNR - SN_thresold),ind)
print,"Sky sigma" , sky_sigma
print,"Mag Sky",sky_mag
print,"Radius (sN=3)" , x_kpc[ind]
print,"PA (@sN=3)" , PA[ind] , PA_err[ind] 
print,"E (@sN=3)" , E[ind] ,E_err[ind]
endif

return,[R_SB_ind,x_kpc[R_SB_ind],PA[R_SB_ind],E[R_SB_ind],xc[0],yc,[0]]

END

Pro PA_E_FromEllipse_all
@Config_Ellipse
READCOL, PATH_CATALOGUE+CATALOGUE_INPUT, name,file,redshift,pix_size,ZP, FORMAT = '(A,A,F,F,F)'

file_out = PATH_CATALOGUE + 'PA_E_fromEllipse.dat'

SUFFIXE_IN = '_sum_clean.fits'
SUFFIXE_ELLIPSE_DAT = '_ellipse.dat'
SUFFIXE_PROFILE = '_profile.dat'
SUFFIXE_PROFILE_PLOT = '_profile.eps'
SB_limit=22.5

openw, lun, file_out, /get_lu
printf,lun,format='(a)','PA and E from PA_E_FromEllipse.pro'
printf,lun,format='(a)','SB limit ='+string(SB_limit)
for i=0, n_elements(name) -1 do begin 
print,name[i]
results=PA_E_FromEllipse(Path_GUESS_OUT+name(I)+SUFFIXE_PROFILE, SB_limit=SB_limit)
printf,lun,format='(a,f8.4,2x,f8.4,2x,f8.4,2x,f8.4)', name[i], results[0],results[1],results[2],results[3]

size_data = 200
scale_zoom=2
image_name=Path_GUESS_OUT+name(I)+SUFFIXE_IN
image=readfits(image_name,header)


;Window, 2,xsize=size_data * scale_zoom,ysize=size_data * scale_zoom
;cgPS_Open, Path_GUESS_OUT+name(I)+'_PA_E.eps'

image_CROP =   CONGRID( image(150:350, 150:350),size_data * scale_zoom, size_data * scale_zoom)
;image_scl=alogscale(255-image_CROP,/auto)
image_scl = 255-BytScl(image_CROP, Min=min(image_CROP)/80, Max=max(image_CROP)/120., /NAN)
loadct,0
TVSCL, image_scl
XYOUTS, 10, 380,name(i),color=50, /DEVICE, CHARSIZE=2.0, CHARTHICK=2
XYOUTS, 10, 360,'PA = '+strcompress(string(results[2]),/REMOVE_ALL),color=50, /DEVICE, CHARSIZE=1.5, CHARTHICK=1
XYOUTS, 10, 340,'E = '+strcompress(string(results[3]),/REMOVE_ALL),color=50, /DEVICE, CHARSIZE=1.5, CHARTHICK=1

X_center=results[4] -150
Y_center=results[5] -150


loadct,12
TVELLIPSE, results[0]*scale_zoom, $
		scale_zoom*(1 -results[3]) * results[0],scale_zoom* X_center, scale_zoom* Y_center,  results[2] - 90 ,color=150
WRITE_PNG,  Path_GUESS_OUT+name(I)+'_PA_E.png', TVRD(/TRUE)
;cgPS_Close

endfor
free_lun, lun

END