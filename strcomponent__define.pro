pro strcomponent__define
 
;  This routine defines the structure for morphological components
 
  tmp = {strcomponent, $
         type:' ',$      ; Type of component : exponential disk or sersic
         n: 0.d,   $     ; Sersic index
         n_err : 0.d, $  ; Sersic index uncertainty    
         Re: 0.d, $      ; Effective radius
         Re_err: 0.d, $  ; Effective radius uncertainty       
         Ie: 0.d,   $    ; Intensity at Re
         Ie_err: 0.d, $  ; Intensity at Re uncertainty
         Mag_T: 0.,   $  ; Total magnitude of the component
         Mag_T_err: 0., $  ; Total magnitude of the component  uncertainty       
         PA: 0.d,   $    ; PA of the component       
         PA_err: 0.d, $  ; PA of the component       
         b_a: 0.d,   $   ; b/a ratio  
         b_a_err: 0.d,$  ; b/a ratio  
         x0: 0.d,   $    ; center X component       
         x0_err: 0.d,$   ; enter X component uncertainty       
         y0: 0.d,   $    ; center X component        
         y0_err: 0.d, $  ; enter Y component uncertainty 
         sky: 0.d, $	 ; Sky value (only for sky component)      
         err_sky_value: 0.d, $	 ; Sky value (only for sky component)      
         dxsky: 0.d, $	 ; Sky value (only for sky component)      
         dysky: 0.d, $	 ; Sky value (only for sky component)      
		 err_dxsky: 0.d, $
		 err_dysky: 0.d, $
         Color:''	$	 ; Default color for plotting 
         }
 
end
 

