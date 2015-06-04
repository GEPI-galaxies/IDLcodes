pro write_sky,file,sky,fit_sky

IF sky LE 10. AND sky GE 0.0001 THEN BEGIN
   str_csky=STRN(sky,format='(f12.6)')
ENDIF ELSE IF sky LE 0.0001 THEN BEGIN
   str_csky=STRN(sky,format='(e12.6)')
ENDIF ELSE IF sky GT 10 THEN BEGIN 
   str_csky=STRN(sky,format='(f12.2)')
ENDIF
str_fit_sky = STRN(fit_sky,format='(i)')   

OPENU, U,file,/append,/GET_LUN

PRINTF, U,  '# SKY'
PRINTF, U,  ' 0) sky                    #  object type'
PRINTF, U,  ' 1)  '+str_csky+'      '+str_fit_sky+'        #  sky background at center of fitting region [ADUs]'
PRINTF, U,  ' 2) 0.0000      0          #  dsky/dx (sky gradient in x)'
PRINTF, U,  ' 3) 0.0000      0          #  dsky/dy (sky gradient in y)'
PRINTF, U,  ' Z) 0                      #  output option (0 = resid., 1 = Do not subtract)'
PRINTF, U,  ' '
PRINTF, U,  '================================================================================'
PRINTF, U,  ' '                  
               
free_lun,U

END


PRO write_psf,file,xc,fit_xc,yc,fit_yc,mag,fit_mag

str_xc = STRN(xc,FORMAT='(f8.4)')
str_fit_xc = STRN(fit_xc,FORMAT='(i)')
str_yc = STRN(yc,FORMAT='(f8.4)')
str_fit_yc = STRN(fit_yc,FORMAT='(i)')
str_mag = STRN(mag,FORMAT='(f8.4)')
str_fit_mag = STRN(fit_mag,FORMAT='(i)')

OPENU, U,file,/append,/GET_LUN

PRINTF, U,  '# PSF'
PRINTF, U,  ' 0) psf                 		#  object type'
PRINTF, U,  ' 1) '+str_xc+'  '+str_yc+'  '+str_fit_xc+'  '+str_fit_yc+'        #  position object x, y'
PRINTF, U,  ' 3) '+str_mag+'  '+str_fit_mag+'        #  total mag'
PRINTF, U,  ' Z) 0                      		#  output option (0 = resid., 1 = Do not subtract)'
PRINTF, U,  '	'

FREE_LUN,U


END

PRO write_gauss,file,xc,fit_xc,yc,fit_yc,fwhm,fit_fwhm,q,fit_q,theta,fit_theta

str_xc = STRN(xc,FORMAT='(f8.4)')
str_fit_xc = STRN(fit_xc,FORMAT='(i)')
str_yc = STRN(yc,FORMAT='(f8.4)')
str_fit_yc = STRN(fit_yc,FORMAT='(i)')
str_fwhm = STRN(fwhm,FORMAT='(f8.4')
str_fit_fwhm = STRN(fit_fwhm,FORMAT='(i)')
str_q = STRN(q,FORMAT='(f8.4)')
str_fit_q = STRN(fit_q,FORMAT='(i)')
str_theta = STRN(theta,FORMAT='(f8.4)')
str_fit_theta = STRN(fit_theta,FORMAT='(i)')

OPENU, U,file,/append,/GET_LUN

PRINTF, U,  '# GAUSS FUNCTION'
PRINTF, U,  ' 0) gauss                 		#  object type'
PRINTF, U,  ' 1) '+str_xc+'  '+str_yc+'  '+str_fit_xc+'  '+str_fit_yc+'        #  position object x, y'
PRINTF, U,  ' 3) '+str_fwhm+'  '+str_fit_fwhm+'        #  FWHM'
PRINTF, U,  ' 4) '+str_q+'  '+str_fit_q+'        #  axis ratio (b/a)'
PRINTF, U,  ' 5) '+str_theta+'  '+str_fit_theta+'        #  position angle (PA) [deg: Up=0, Left=90]'
PRINTF, U,  ' Z) 0                      		#  output option (0 = resid., 1 = Do not subtract)'
PRINTF, U,  '	'

FREE_LUN,U

END


PRO write_expdisk,file,xc,fit_xc,yc,fit_yc,mag,fit_mag,rd,fit_rd,i,fit_i,pa,fit_pa

str_xc = STRN(xc,format='(f8.2)')
str_yc = STRN(yc,format='(f8.2)')
str_fit_xc = STRN(fit_xc,format='(i)')
str_fit_yc = STRN(fit_yc,format='(i)')
str_mag = STRN(mag,format='(f8.2)')
str_fit_mag = STRN(fit_mag,format='(i)')
str_Rd = STRN(Rd,format='(f8.2)')
str_fit_Rd = STRN(fit_Rd,format='(i)')
str_i = STRN(i,format='(f8.2)')
str_fit_i = STRN(fit_i,format='(i)')
str_pa = STRN(pa,format='(f8.2)')
str_fit_pa = STRN(fit_pa,format='(i)')

OPENU, U,file,/append,/GET_LUN
PRINTF, U,  '# EXPONENTIAL FUNCTION'
PRINTF, U,  ' 0) expdisk                    #  object type'
PRINTF, U,  ' 1) '+str_xc+'	 '+str_yc+'  '+str_fit_xc+'  '+str_fit_yc+'        #  position x, y'
PRINTF, U,  ' 3) '+str_mag+'  '+str_fit_mag+'        #  Integrated magnitude'
PRINTF, U,  ' 4) '+str_Rd+'  '+str_fit_Rd+'        #  R_e (half-light radius)   [pix]'
PRINTF, U,  ' 9) '+str_i+'  '+str_fit_i+'        #  axis ratio (b/a)'
PRINTF, U,  '10) '+str_pa+'  '+str_fit_pa+'        #  position angle (PA) [deg: Up=0, Left=90]'
PRINTF, U,  ' Z) 0                      		#  output option (0 = resid., 1 = Don not subtract)'
PRINTF, U,  ' '

free_lun,U

END


PRO write_sersic,file,xc,fit_xc,yc,fit_yc,mag,fit_mag,re,fit_re,i,fit_i,pa,fit_pa,n,fit_n

 str_xc = STRN(xc,format='(f8.2)')
 str_yc = STRN(yc,format='(f8.2)')
 str_fit_xc = STRN(fit_xc,format='(i)')
 str_fit_yc = STRN(fit_yc,format='(i)')
 str_mag = STRN(mag,format='(f8.2)')
 str_fit_mag = STRN(fit_mag,format='(i)')
 str_Re = STRN(Re,format='(f8.2)')
 str_fit_Re = STRN(fit_Re,format='(i)')
 str_n = STRN(n,format='(f8.2)')
 str_fit_n = STRN(fit_n,format='(i)')
 str_i = STRN(i,format='(f8.2)')
 str_fit_i = STRN(fit_i,format='(i)')
 str_pa = STRN(pa,format='(f8.2)')
 str_fit_pa = STRN(fit_pa,format='(i)')


OPENU, U,file,/append,/GET_LUN

PRINTF, U,  '# SERSIC FUNCTION'
PRINTF, U,  ' 0) sersic                 		#  object type'
PRINTF, U,  ' 1) '+str_xc+'  '+str_yc+'  '+str_fit_xc+'  '+str_fit_yc+'        #  position object x, y'
PRINTF, U,  ' 3) '+str_mag+'  '+str_fit_mag+'        #  Integrated magnitude'
PRINTF, U,  ' 4) '+str_Re+'  '+str_fit_Re+'        #  R_e (half-light radius)   [pix]'
PRINTF, U,  ' 5) '+str_n+'  '+str_fit_n+'        #  Sersic index n (de Vaucouleurs n=4,exponential disk n=1)'
PRINTF, U,  ' 9) '+str_i+'  '+str_fit_i+'        #  axis ratio (b/a)'
PRINTF, U,  '10) '+str_pa+'  '+str_fit_pa+'        #  position angle (PA) [deg: Up=0, Left=90]'
;PRINTF, U,  'C0) 0.0000      0          #  diskyness(-)/boxyness(+)	'
PRINTF, U,  ' Z) 0                      		#  output option (0 = resid., 1 = Do not subtract)'
PRINTF, U,  ' '

free_lun,U

END


PRO write_comp,file,comp,param
  
  IF STRCMP(comp,'sersic') EQ 1 THEN BEGIN
     IF N_ELEMENTS(param) NE 14 THEN STOP
     write_sersic,file,param[0],param[1],param[2],param[3],param[4],param[5],param[6],param[7],param[8],param[9],param[10],param[11],param[12],param[13]
  
  ENDIF ELSE IF STRCMP(comp,'expdisk') EQ 1 THEN BEGIN
     IF N_ELEMENTS(param) NE 12 THEN STOP
     write_expdisk,file,param[0],param[1],param[2],param[3],param[4],param[5],param[6],param[7],param[8],param[9],param[10],param[11]
  
  ENDIF ELSE IF STRCMP(comp,'psf') EQ 1 THEN BEGIN
     IF N_ELEMENTS(param) NE 6 THEN STOP
     write_psf,file,param[0],param[1],param[2],param[3],param[4],param[5]

  ENDIF ELSE IF STRCMP(comp,'sky') EQ 1 THEN BEGIN
     IF N_ELEMENTS(param) NE 2 THEN STOP
     write_sky,file,param[0],param[1]
     
  ENDIF
  

END
