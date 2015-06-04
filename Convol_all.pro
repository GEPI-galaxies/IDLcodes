PRO Convol_all

path='/Users/hypatia/Documents/IMAGES_Kinematics/3D_HST/Morpho/'
READCOL,path+'KMOS3D_Wisnioski2014_z1.cat',name,dec,ra,redshift,FORMAT='(a,f,f,f)'

Ref_band='H'
Ref_ps=0.06 ; reference pixel scale in "/pixel
Ref_psf = 0.15 ; reference psfin "

Conv_band=['I','J']
Conv_ps=[0.06,0.06] ; reference pixel scale in "/pixel
Conv_psf = [0.09,0.13] ; reference psfin "

FOR k=0,N_ELEMENTS(name)-1 DO BEGIN
result_ref = FILE_TEST(path+'Cutimages_15arcsec/'+name[k]+'_'+Ref_band+'.fits')

	FOR i=0,N_ELEMENTS(Conv_band)-1 DO BEGIN

	result_conv = FILE_TEST(path+'Cutimages_15arcsec/'+name[k]+'_'+Conv_band[i]+'.fits')

	IF result_conv+result_ref EQ 2 then begin 

   im_2conv=READFITS(path+'Cutimages_15arcsec/'+name[k]+'_'+Conv_band[i]+'.fits',/SILENT)
   im_ref=READFITS(path+'Cutimages_15arcsec/'+name[k]+'_'+Ref_band+'.fits',header,/SILENT)
   min_size=MIN([(SIZE(im_2conv))[1],(SIZE(im_2conv))[2]])
   psf_kernel=sqrt(Ref_psf^2 - Conv_psf[i]^2) / Conv_ps[i]
   psf=PSF_GAUSSIAN(NPIXEL=min_size,FWHM=[psf_kernel,psf_kernel],/NORMAL) 
   ;;; verifier FWHM (en pixels, convertis en utilisant le piscale de l'image qui sera convoluee soit 0.03 pour ACS

   ;;; IF spatial resolution is not similar on the two images, convolve
;;; the finest image using a kernel size W such as
;;; W=SQRT(fwhm_max^2-fwhm_min^2)
;;;; a verifier : quel fwhm pour les images WFC3 IR ? et normalement
;;;; la fwhm pour ACS est 0.1 arcsec, a verifier. 

   im_convol=convol_edge(im_2conv,psf)
   im_conv_rebin=FREBIN(im_convol,(SIZE(im_convol))[1],(SIZE(im_convol))[2],/TOTAL)

   WRITEFITS,path+'SUM/'+name[k]+'_'+Conv_band[i]+'_convol.fits',im_conv_rebin,header
	ENDIF
ENDFOR
ENDFOR   

END