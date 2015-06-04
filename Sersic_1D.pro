; NAME:
; 		 Sersic_1D
; PURPOSE: 
; 		produce the intensity of a Sersic function as a function of radius
;
; CALLING SEQUENCE:
;    Intensity_sersic = Sersic_1D(RADIUS, [n, R_e, I_e], psf = psf)
;
; INPUT:
;   RADIUS = 1D array with the radius    
;   n = sersic index   
;   R_e = Effectif radius   
;   I_e = Intensity at Effectif radius 
;
; OPTIONAL INPUT KEYWORDS:
;   psf = FWHM of the PSF in pixel. The sersic profile is convolved with a gaussian of width FWHM = pSF
; 
; OUTPUT:
;  Intensity_sersic  =  intensity of the sersic profile. 1D array of the same size tha RADIUS
;
; PROCEDURES CALLED : Gamma
; MODIFICATION HISTORY: 
; 		Created by Myriam R. 06/05/2015 
; 

 
; parameters [n, re, Ie] 
Function Sersic_1D, X, P ,PSF=PSF

;Compute b(n) from Ciotti & Bertin 1999
IF P[0] LE 0.36 then begin
b_n = 0.01945 -0.8902 * P[0] + 10.95 * P[0]^2  -19.67 * P[0]^3 + 13.43 * P[0]^4
endif else begin
b_n = 2*P[0] -1./3. +4./(405*P[0]) + 131/(1148175 *P[0]^3) - 2194697 / (30690717750 * P[0]^4)
endelse 
Intensity=P[2] * exp(-b_n *( (X/P[1])^(1./P[0]) -1 ))

IF KEYWORD_SET(PSF) then begin
gauss = PSF_GAUSSIAN( NP=3, FWHM=PSF, /NORMALIZE, NDIMEN=1 )
Intensity  = CONVOL( Intensity, gauss, /CENTER, /EDGE_TRUNCATE)
endif
return, Intensity

END