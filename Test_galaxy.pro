PRO Test_galaxy

PATH='/Users/hypatia/Documents/IMAGES_Kinematics/3D_HST/test/'
file='J033243.21-274457.0.fits'
name = 'J033243.21-274457.0'
pixelscale=0.03
ZP = 24.862
redshift=0.575

MASKFILE=PATH+name+'_mask.fits'
OBJFILE=PATH+name+'_sum_clean.fits'
SEGFILE=PATH+name+'_seg.fits'
OUTFILE=PATH+name+'.ASC'
print,"----------------------"
print,'run sextractor :'
Sextractor_morpho,PATH+file, ZP, OBJFILE, SEGFILE, MASKFILE, OUTFILE ,/RUN_SEX, DETECT_THRESH=2.5, ANALYSIS_THRESH=3.

; PA, E, FLUX and Radius with sextractor
im=readfits(OBJFILE,header,/silent)
PA =  SXPAR( header, 'PA')
Xc =  SXPAR( header, 'XCENTER')
Yc =  SXPAR( header, 'YCENTER')
 E =  SXPAR( header, 'ELLIP')		
RADIUS =SXPAR( header, 'RADIUS')
FLUXTOT =  SXPAR( header, 'FLUXTOT')
print,"----------------------"
print,"PA (Sextractor)",PA
print,"E (Sextractor)", E
print,"R_iso (Sextractor)", RADIUS
print,"Flux total (Sextractor)", FLUXTOT
print,"Mag total (Sextractor)", -2.5*alog10(FLUXTOT) + ZP
print,"----------------------"
; R half 
rhalf=Rhalf(im, Xc, Yc, E, PA, Major_axis=RADIUS, PLOT=PLOT, FLUXTOT=FLUXTOT)
rhalf_Kpc=pix2kpc(pixelscale,redshift,rhalf)
print,'Half light radius [kpc] (curve of growth): ',rhalf_Kpc[0]
print,'Half light radius [kpc] (sextractor): ',rhalf_Kpc[1]
err_radiusKpc=abs(rhalf_Kpc[0]-rhalf_Kpc[1])/2.
print,'Error : +/-',err_radiusKpc

COMPUTE_CENTER, name,PATH,PATH,redshift, ZP
Ellipse_maker, name,PATH,PATH,redshift,ZP

SUFFIXE_IN = '_sum_clean.fits'
SUFFIXE_ELLIPSE_DAT = '_ellipse.dat'
SUFFIXE_PROFILE = '_profile.dat'
SUFFIXE_PROFILE_PLOT = '_profile.eps'

SB_PROFILE,PATH+name+SUFFIXE_ELLIPSE_DAT,PATH+name+SUFFIXE_IN, ZP,$
			 pixelscale, redshift, PATH+name+SUFFIXE_PROFILE, /PLOT, $
			 SAVE_PLOT=PATH+name+SUFFIXE_PROFILE_PLOT;, /COSMO_DIMMING
			 
			 
			 
END


