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

;;; comprendre a quoi cela sert
;IF KEYWORD_SET(SN_threshold) then begin
;Compute R at SB_R
;sky_sigma=Randomn_sky_stat(image)
;sky_mag= -2.5*alog10(3*sky_sigma) + 26. -10*alog10(1.535)
;print,sky_mag
;print,-2.5*alog10(sky_sigma) + 26.
;SNR=SB/sky_mag
;SN_thresold=3.
;min_SNR=min(abs(SNR - SN_thresold),ind)
;print,"Sky sigma" , sky_sigma
;print,"Mag Sky",sky_mag
;print,"Radius (sN=3)" , x_kpc[ind]
;print,"PA (@sN=3)" , PA[ind] , PA_err[ind] 
;print,"E (@sN=3)" , E[ind] ,E_err[ind]
;endif

return,[R_SB_ind,x_kpc[R_SB_ind],PA[R_SB_ind],E[R_SB_ind],xc[0],yc,[0]]

END

Pro PA_E_FromEllipse_all
@Config_Ellipse
READCOL, PATH_CATALOGUE+CATALOGUE_INPUT, name,file,redshift,pix_size,ZP, FORMAT = '(A,A,F,F,F)'

file_out = PATH_ELLIPSE + 'PA_E_fromEllipse.dat'

SUFFIXE_PROFILE = '_profile.dat'
SUFFIXE_ELLIPSE = '_ellipse.dat'

openw, lun, file_out, /get_lun
printf,lun,format='(a)','PA and E from PA_E_FromEllipse.pro'
printf,lun,format='(a)','SB limit ='+string(SB_limit)
printf, lun,format='(a)','name  index x(kpc) PA  E  '
for i=0, n_elements(name) -1 do begin 
   print,name[i]
   results=PA_E_FromEllipse(Path_ELLIPSE+name(i)+SUFFIXE_PROFILE, SB_limit=SB_limit)
   printf,lun,format='(a,2x,f8.4,2x,f8.4,2x,f8.4,2x,f8.4)', name[i], results[0],results[1],results[2],results[3]
;;; results[0]=index
;;; results[1]=x_kpc
;;; results[2]=PA
;;; results[3]=E
;;; results[4]=xc
;;; results[5]=yc

   image_name=Path_data+name(i)+SUFFIXE_im
   image=readfits(image_name,header)

   size_x=(SIZE(image))[1]
   size_y=(SIZE(image))[2]
   size_data = 300
   IF size_x LT size_data OR size_y LT size_data THEN size_data=MIN([size_x,size_y])-1
   scale_zoom=2

   xc=(SIZE(image))[1]/2.
   yc=(SIZE(image))[2]/2.

   cgDisplay, xsize=size_data * scale_zoom,ysize=size_data * scale_zoom

   image_CROP = CONGRID( image(xc-size_data/2:xc+size_data/2, yc-size_data/2:yc+size_data/2),size_data * scale_zoom, size_data * scale_zoom)
   
   image_scl = 255-BytScl(image_CROP, Min=min(image_CROP)/15., Max=max(image_CROP)/10., /NAN)

   loadct,0
   TVSCL, image_scl
   XYOUTS, 0.05, 0.92,'PA = '+strcompress(string(results[2], FORMAT='(f10.2)'),/REMOVE_ALL),color=50, /NORMAL, CHARSIZE=3, CHARTHICK=2
   XYOUTS, 0.05, 0.82,'E  = '+strcompress(string(results[3],FORMAT='(f10.2)'),/REMOVE_ALL),color=50, /NORMAL, CHARSIZE=3, CHARTHICK=2

   ;;; plot all ellipses
   ellipse_out=path_ellipse+name(i)+suffixe_ellipse
   readcol, ellipse_out,format='(i,f,f,f,f,f,f,f,f,f,f,f,f)', row,sma,Int,I_err,E,E_err,PA,PA_err,xc_ell,yc_ell, TFLUX_C,TMAG_E,NPIX_E,/silent

   loadct,13
   X_centerini= xc_ell - (xc - size_data/2.)
   Y_centerini= yc_ell - (yc - size_data/2.)
   
   for k=0, n_elements(sma)-1 do begin
      IF ((k MOD 6) EQ 0 and sma[k] LT results[0]-1) then TVELLIPSE, sma[k]*scale_zoom, $
         scale_zoom*(1 -E[k]) * sma[k],scale_zoom* X_centerini[k], scale_zoom* Y_centerini[k],  PA[k] - 90 ,color=250, thick=2
   endfor

   ;; plot external ellipse (giving PA and E)
   X_center=results[4] - (xc - size_data/2.)
   Y_center=results[5] - (yc - size_data/2.)

   TVELLIPSE, results[0]*scale_zoom, $
              scale_zoom*(1 -results[3]) * results[0],scale_zoom* X_center, scale_zoom* Y_center,  results[2] - 90 ,color=50,thick=3

   void=cgsnapshot(file=Path_ELLIPSE+name(i)+'_PA_E.png', /NODIALOG)

endfor
free_lun, lun

END
