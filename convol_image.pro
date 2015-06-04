PRO convol_image

path='/Users/hypatia/Documents/3D_HST/Morpho/'
READCOL,path+'/KMOS/KMOS3D_Wisnioski2014_z1.cat',name,dec,ra,redshift,FORMAT='(a,f,f,f)'

Ref_band='K'
Ref_ps=0.18 # reference pixel scale in "/pixel
Ref_psf = 0.17 # reference psfin "

Conv_band='I'
Conv_ps=0.05 # reference pixel scale in "/pixel
Conv_psf = 0.09 # reference psfin "

FOR k=0,N_ELEMENTS(name)-1 DO BEGIN
result_conv = FILE_TEST(path+'Cutimages_8arcsec/'+name[k]+'_I.fits')
result_ref = FILE_TEST(path+'Cutimages_8arcsec/'+name[k]+'_J.fits')
	IF result_conv+result_ref EQ 2 then begin 

   im_2conv=READFITS('Cutimages_8arcsec/'+name[k]+'_'+Conv_band+'.fits',/SILENT)
   im_ref=READFITS('Cutimages_8arcsec/'+name[k]+'_'+Ref_band+'.fits',header,/SILENT)
   
   min_size=MIN([(SIZE(im_2conv))[1],(SIZE(im_2conv))[2]])
   psf=PSF_GAUSSIAN(NPIXEL=min_size,FWHM=[5.,5.],/NORMAL) ;;; verifier FWHM (en pixels, convertis en utilisant le piscale de l'image qui sera convoluee soit 0.03 pour ACS

   ;;; IF spatial resolution is not similar on the two images, convolve
;;; the finest image using a kernel size W such as
;;; W=SQRT(fwhm_max^2-fwhm_min^2)
;;;; a verifier : quel fwhm pour les images WFC3 IR ? et normalement
;;;; la fwhm pour ACS est 0.1 arcsec, a verifier. 

   im_convol=convol_edge(im_2conv,psf)
   im_conv_rebin=FREBIN(im_convol,(SIZE(im_convol))[1]/2,(SIZE(im_convol))[2]/2,/TOTAL)

   WRITEFITS,'images/'+name[k]+'_'+Conv_band+'_convol.fits',im_conv_rebin,header
	ENDIF

ENDFOR   


FOR k=0,N_ELEMENTS(name)-1 DO BEGIN
result_I = FILE_TEST('Cutimages_8arcsec/'+name[k]+'_I_wht.fits')
result_J = FILE_TEST('Cutimages_8arcsec/'+name[k]+'_J_wht.fits')
	IF result_I+result_J EQ 2 then begin 

   im_i=READFITS('Cutimages_8arcsec/'+name[k]+'_I_wht.fits',/SILENT)
   im_J=READFITS('Cutimages_8arcsec/'+name[k]+'_J_wht.fits',header,/SILENT)
   
   min_size=MIN([(SIZE(im_i))[1],(SIZE(im_i))[2]])
   psf=PSF_GAUSSIAN(NPIXEL=min_size,FWHM=[5.,5.],/NORMAL) ;;; verifier FWHM (en pixels, convertis en utilisant le piscale de l'image qui sera convoluee soit 0.03 pour ACS

   ;;; IF spatial resolution is not similar on the two images, convolve
;;; the finest image using a kernel size W such as
;;; W=SQRT(fwhm_max^2-fwhm_min^2)
;;;; a verifier : quel fwhm pour les images WFC3 IR ? et normalement
;;;; la fwhm pour ACS est 0.1 arcsec, a verifier. 

   im_i_convol=convol_edge(im_i,psf)
   im_i_rebin=FREBIN(im_i_convol,(SIZE(im_i_convol))[1]/2,(SIZE(im_i_convol))[2]/2,/TOTAL)

   WRITEFITS,'Cutimages_8arcsec/'+name[k]+'_i_convol_wht.fits',im_i_rebin,header
	ENDIF

ENDFOR   


END
