

; NAME:
; 		 SERSIC_SCALE_FACTOR
; PURPOSE: 
; 		Compute the scaling factor for total flux calculation from sersic profile
;
; CALLING SEQUENCE:
;    Factor=sersic_scale_factor(n)
;
; INPUT:
;   n = Sersic index   
;
; OUTPUT:
;  Scale_factor  =  sersic_scale_factor
; 		    The total flux is given by 
; 		    Ftot = 2* !pi * I_0 *  sersic_scale_factor(n) * b/a
;
; PROCEDURES CALLED : Gamma
; MODIFICATION HISTORY: 
; 		Created by Myriam R. 06/05/2015 
; 
FUNCTION sersic_scale_factor, n

;Compute b(n) from Ciotti & Bertin 1999
IF n LE 0.36 then begin
b_n = 0.01945 -0.8902 * n + 10.95 * n^2  -19.67 * n^3 + 13.43 * n^4
endif else begin
b_n = 2*n-1./3. +4/(405*n) + 131/(1148175 *n^3) - 2194697 / (30690717750 * n^4)
endelse 
return, exp(b_n) * n * b_n ^(-2*n) * gamma(2*n)
END


; NAME:
; 		 FIT_1D_SB_Profile
; PURPOSE: 
; 		Interactively fit the radial surface brigthness profile with 2 components : a sersic profile + an exponential disk
;		This routine uses as input the output file from SB_PROFILE and ELLIPSE(IRAF)
; 		
; CALLING SEQUENCE:
;    FIT_1D_SB_Profile, SBProfile_out , PSF , ZP, PRINT_LOG= PRINT_LOG , pixel_scale = pixel_scale , SAVE_PLOT=SAVE_PLOT
;
; INPUT:
;   SBProfile_out = Output file from SB_PROFILE.pro
;   		  PSF = FHWM of the psf in pixel (the model will be convolved by the psf in the fitting process) 
;   		   ZP = Zero point  
;	
; OPTIONAL INPUT KEYWORDS:
;	  PRINT_LOG	= Name of the output logfile in galfit format
; 	  SAVE_PLOT = Name of the eps file with the fitted profile
;     pixel_scale = Pixel size - requiere for SAVE_PLOT
; 
; OUTPUT:
;  		Re, Ie, Mtot, n for the 2 component
;
; PROCEDURES CALLED : SERSIC_SCALE_FACTOR
; MODIFICATION HISTORY: 
; 		Created by Myriam R. 06/05/2015 

PRO FIT_1D_SB_Profile, SBProfile_out , PSF , ZP, PRINT_LOG= PRINT_LOG , pixel_scale = pixel_scale , SAVE_PLOT=SAVE_PLOT , CUT_PROFILE = CUT_PROFILE

!P.Thick = 1
!P.CharThick = 1
!X.Thick = 1
!Y.Thick = 1
!Z.Thick = 1
!P.Font = 1.0
	   
readcol,SBProfile_out, format='(i,f,f,f,f,f,f,f,f,f,f,f,f,f)', sma,x_kpc,Int, I_err, SB, SB_low, SB_high, PA, PA_err, E,E_err, xc,yc,Tota_mag_ellipse,/SILENT
;Set error equal to 0, to the minimum error
;bad_err = WHERE(I_err EQ 0, n_bad)
;IF n_bad GT 1 then I_err(WHERE(I_err EQ 0))= min(I_err(WHERE(I_err GT 0)))

cgplot, sma,Int,psym=2,/ylog, yrange=[min(Int)*0.5, max(Int)*1.5],xrange=[-10,150],ytitle='log10(Intensity)',xtitle='radius (pix)',title='Luminosity profile of J094949 (R Band)'

IF KEYWORD_SET(CUT_PROFILE) then begin
Image = readfits(CUT_PROFILE, header)
PA_sex = SXPAR( header, 'PA') - 90
X0_sex = SXPAR( header, 'XCENTER')
Y0_sex = SXPAR( header, 'YCENTER')
Profile= img2profile(Image,PA_sex,[X0_sex,Y0_sex],5)
max_profile = max(Profile,center_profile)
profile_left = INTERPOL(REVERSE(Profile[0:center_profile-1]),indgen(center_profile)+1,sma)
profile_right = INTERPOL(Profile[center_profile : n_elements(profile) -1  ],indgen(N_elements(profile) - center_profile)+1,sma)

cgoplot,sma,profile_left , color='coral',psym=2
cgoplot,sma, profile_right, color='blue',psym=2
; STEP 1 : Evaluate the Sky Background
print,"-> 0) Select profile "
print, "   'l' - left side of the major axis cut (red)"
print, "   'r' - right side of the major axis cut (blue)"
print, "   'e/or any' - Ellipse profile (black)"
cut_type =''
READ, cut_type, PROMPT=" Cut : "
CASE cut_type OF
		'l' : Int = profile_left
		'r' : Int = profile_right
		ELSE: Int=Int
	ENDCASE

ENDIF


; STEP 1 : Evaluate the Sky Background
print,"-> 1) Evaluate the sky background "
cursor,Cont_x1,Cont_y1,/DATA,/DOWN
cursor,Cont_x2,Cont_y2,/DATA,/UP
sky=median(Int[Cont_x1:Cont_x2])
print, "       [Sky]=",strcompress(string(sky),/REMOVE_ALL)
cgOPlot,[Cont_x1,Cont_x2],[sky,sky],linestyle =2,color='grey', linesty=2
Int_skysub=Int-sky

; STEP 2 : Define components 
print,"-> 2) Define components "
READ, n_component, PROMPT="Number of components to fit :"
Components= REPLICATE({strcomponent}, n_component)
type_comp=' '

; STEP 3 : Fit components 
for i=0, n_component -1 do begin
ask_component:
READ, type_comp, PROMPT="[Comp #"+STRN(i)+"] Sersic (s) or Disk (d):"
	CASE type_comp OF
		's' : Components[i].type = 'sersic'
		'd' : Components[i].type = 'expdisk'
		ELSE: goto, ask_component
	ENDCASE
endfor

print," -> 3) Constrain components "
Model_final = fltarr(n_elements(sma))
Model_final(*) = sky

for i=0, n_component -1 do begin
	print,"[Comp #"+STRN(i)+"] : "+ Components[i].type
	print,"		  - region to fit (click region)"
	cursor,x1,y1,/DATA,/DOWN
	cursor,x2,y2,/DATA,/UP
	cgOPlot,[x1,x2],[min(Int),min(Int)],linestyle =1,color='grey',thick=4

	parinfo = replicate({value:0.D, fixed:0, limited:[0,0], $
                       limits:[0.D,0.D]}, 3)
	parinfo[1].limited[0]  = 1. ;Limits for Re
	parinfo[1].limits[0] = 0. 
	parinfo[2].limited[1]  = 1. ;Limits for Ie
	parinfo[2].limits[1] = max(Int_skysub)
	parinfo[2].limited[0] = 1.
	parinfo[2].limits[0]  = 0. 

	CASE Components[i].type OF
	'sersic' : BEGIN
				parinfo[0].limited[0] = 1
				parinfo[0].limits[0] =0.01
			   	parinfo[*].value = [1.2,mean([x1,x2]),mean(Int_skysub[0:5])]
			   	start_parm = parinfo[*].value
			   	Components[i].Color='Red'
			   END

	'expdisk' : BEGIN
				;start_param= [1,mean([x1,x2]),mean(Int_skysub[0:5])*0.6]
				parinfo[0].fixed = 1
				parinfo[*].value = [1,mean([x1,x2]),mean(Int_skysub[0:5])*0.6]
			   	start_parm = parinfo[*].value				
				Components[i].Color='Blue'
				END
	 ENDCASE		

	Fit_results = mpfitfun('Sersic_1D', sma[x1:x2],Int_skysub[x1:x2], I_err[x1:x2],$
					start_parm,PARINFO=parinfo, functargs={PSF:PSF},/QUIET)
	Model_Int = Sersic_1D(sma,Fit_results,psf=psf)
	CASE Components[i].type OF
		'sersic' : BEGIN
				   Components[i].n = Fit_results[0]
				   Components[i].Re = Fit_results[1]
				   Components[i].Ie = Fit_results[2]
				   Components[i].PA = PA[round(Components[i].Re)]	
				   Components[i].b_a = 1-E[round(Components[i].Re)]		
				   Components[i].Mag_T = -2.5* alog10( 2 * !pi * Components[i].Re^2 * Components[i].n $
				   					* sersic_scale_factor(Components[i].n) * Components[i].b_a ) + ZP 
				   END
				   
	    'expdisk' : BEGIN
	    			Components[i].n = 1
					Components[i].Re = Fit_results[1]/1.678 
					Components[i].Ie = Fit_results[2]
				    Components[i].PA = PA[round(Components[i].Re)]	
				    Components[i].b_a = 1-E[round(Components[i].Re)]					
					Components[i].Mag_T = -2.5* alog10( 2 * !pi * Components[i].Re^2 * Model_Int[0] * Components[i].b_a ) +ZP

					END
	ENDCASE
	print,"       n ="+STRN(Components[i].n)
	print,"       Re ="+STRN(Components[i].Re)
	print,"       Ie ="+STRN(Components[i].Ie)
	print,"       Mag_T ="+STRN(Components[i].Mag_T)
	print,"       PA ="+STRN(Components[i].PA)
	print,"       b/a ="+STRN(Components[i].b_a)
    print," "
    
	cgoplot,sma,  Model_Int + sky,color=Components[i].Color,thic=2
	Int_skysub=Int_skysub-Sersic_1D(sma,Fit_results)
	Model_final = Model_final+ Sersic_1D(sma,Fit_results,psf=psf)
endfor

cgoplot,sma, Model_final ,color='green',thic=2


 
IF KEYWORD_SET(SAVE_PLOT) then begin
	   !P.Thick = 4
	   !P.CharThick = 4
	   !X.Thick = 4
	   !Y.Thick = 4
	   !Z.Thick = 4
	   !P.Font = 1.0
	   
	cgPS_Open, Filename=SAVE_PLOT
	SB_profile =  -2.5 * alog10( Int ) + ZP + 2.5*alog10(pixel_scale^2) 
	cgplot, sma , SB_profile, yrange = [29,min(SB_profile)] , thick =2 , xtit='R [pixel]' , ytit='Surface magnitude [mag/arcsec^2]' 
	 
	FOR i=0, n_component -1 do begin  
	model_comp = Sersic_1D(sma,[Components[i].n,Components[i].Re,Components[i].Ie],psf=psf)
	cgoplot,sma, -2.5 * alog10( model_comp) + ZP + 2.5*alog10(pixel_scale^2) , color = Components[i].Color , thick = 3 , linesty=2
	ENDFOR
	cgoplot,sma, -2.5 * alog10( Model_final ) + ZP + 2.5*alog10(pixel_scale^2) , color = 'green'
	cgPS_Close
ENDIF


IF KEYWORD_SET(PRINT_LOG) then begin 
	openw, lun, PRINT_LOG, /get_lun
	FOR i=0 , n_component -1 do begin 
	printf,lun,format='(a)','#  FUNCTION '                                                            	
	printf,lun,format='(a)',' 0) '+ Components[i].type + '      		#  object type    '                                 
	printf,lun,format='(a)',' 1) '+ strn(xc[0], format='(f12.2)' ) +" "+ strn(yc[0], format='(f12.2)' ) +'  1  1        #  position x, y   '                  
	printf,lun,format='(a)',' 3) '+ strn(Components[i].mag_T, format='(f6.2)' ) +'  1        #  Total magnitude  '	                     	
	printf,lun,format='(a)',' 4) '+ strn(Components[i].Re, format='(f6.2)' ) + ' 1        #  R_e (Effective radius or disk scale)  [pix] '        
	printf,lun,format='(a)',' 5) '+ strn(Components[i].n, format='(f6.2)' ) +'  1        #  Sersic index n (de Vaucouleurs n=4,exponential disk n=1)'      
	printf,lun,format='(a)',' 9) '+ strn(Components[i].b_a, format='(f4.2)' )+'  1        #  axis ratio (b/a)                                  
	printf,lun,format='(a)','10) '+ strn(Components[i].PA, format='(f6.2)' )+'  1        #  position angle (PA) [deg: Up=0, Left=90] '       
	printf,lun,format='(a)',' Z) 0                      		#  output option (0 = resid., 1 = Don not subtract)' 
	ENDFOR
		
	printf,lun,format='(a)','# SKY'                                                              						
	printf,lun,format='(a)',' 0) sky                    #  object type'                                       			
	printf,lun,format='(a)',' 1)  '+ strn(sky, format='(f8.6)' ) +'      0        #  sky background at center of fitting region [ADUs] '	
	printf,lun,format='(a)',' 2) 0.0000      0          #  dsky/dx (sky gradient in x)   '                    			
	printf,lun,format='(a)',' 3) 0.0000      0          #  dsky/dy (sky gradient in y)   '                    			
	printf,lun,format='(a)',' Z) 0                      #  output option (0 = resid., 1 = Do not subtract) ' 		
	free_lun, lun
	
ENDIF


END

