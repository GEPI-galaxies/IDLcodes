function convol_edge, image, psf, FT_PSF=psfFT, FT_IMAGE=imFT, PADDING=padding

sav_image=image

taille_psf=size(psf)
taille_imstart=size(image)

;image padding (nearest 2^n for speed)
IF keyword_set(PADDING) THEN BEGIN
    ;padding_rate=CEIL(taille_psf/2)
    padding_rate=2^CEIL(ALOG10(taille_psf/2)/ALOG10(2))
    padded_im=FLTARR(taille_imstart[1]+padding_rate[1], taille_imstart[2]+padding_rate[2])
    padded_im[0:taille_imstart[1]-1, 0:taille_imstart[2]-1]=image
    imstart=image
    image=padded_im
ENDIF

taille_im=size(image)
npix = N_elements( image )

;FT psf if not supplied + psf padding
IF NOT keyword_set(FT_PSF) THEN BEGIN
    Loc = ( taille_im/2 - taille_psf/2 ) > 0 ;center PSF in new array,
    s = (taille_psf/2 - taille_im/2) > 0 ;handle all cases: smaller or bigger
    L = (s + taille_im-1) < (taille_psf-1)
    psfFT = complexarr( taille_im[1], taille_im[2] )
    psfFT[ Loc[1], Loc[2] ] = psf[ s[1]:L[1], s[2]:L[2] ]
    psfFT = FFT( psfFT, -1, /OVERWRITE )
ENDIF


;FT image if not supplied
IF NOT keyword_set(FT_IMAGE) THEN BEGIN
    imFT=FFT(image,-1)
ENDIF


;convolution
conv = npix * float( FFT( imFT * psfFT, 1 ) )


;shift correction for odd size images
sc = taille_im/2 + (taille_im MOD 2)
conv=shift( conv, sc[1], sc[2] )


;res extraction
IF keyword_set(PADDING) THEN BEGIN
    conv=conv[0:taille_imstart[1]-1, 0:taille_imstart[2]-1]
ENDIF

image=sav_image

return, conv
end
