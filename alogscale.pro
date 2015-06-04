;+
; NAME: alogscale.pro
; PURPOSE:
; 	intelligently logarithmicly scale an image for 
;	display. 
; NOTES:
;	Based on the log scale code from ATV.pro
;
; INPUTS:
; KEYWORDS:
; 	/print
; 	/auto	like ATV's autoscale
;   scale = scale Default = 0.5
;   sigma_scale_min = scale for auto mode Default = 10
;   sigma_scale_max = scale for auto mode Default = 12
; OUTPUTS:
;
; HISTORY:
; 	Began 2003-10-20 01:23:02 by Marshall Perrin 
; 	2004-09-15		Made NaN-aware		MDP
;   2015-04-28 Add keyword scale by Myriam R. 
;     

FUNCTION alogscale,image,minval,maxval,min=min,print=print,$
	auto=auto,sigma_scale_max=sigma_scale_max,sigma_scale_min=sigma_scale_min

	if n_elements(min) gt 0 then minval=min
	if ~keyword_set(scale) then scale=.5
	if ~keyword_set(sigma_scale_min) then sigma_scale_min=10
	if ~keyword_set(sigma_scale_max) then sigma_scale_max=12

	if keyword_set(auto) then begin
		med = median(image)
		sig = stddev(image,/NaN)
		maxval = (med + (sigma_scale_max * sig)) < max(image,/nan)
		minval = (med - (sigma_scale_min * sig))  > min(image,/nan)
	endif

	
	if (n_elements(minval) eq 0) then minval = min(image,/nan)
	if (n_elements(maxval) eq 0) then maxval = max(image,/nan)

	minval=float(minval)
	maxval=float(maxval)
	

    offset = minval - (maxval - minval) * scale
      

	if keyword_set(print) then print,minval,maxval,offset

     scaled_image = $
          bytscl( alog10(image - offset), $
                  min=alog10(minval - offset), /nan, $
                  max=alog10(maxval - offset))

   return,scaled_image 

end