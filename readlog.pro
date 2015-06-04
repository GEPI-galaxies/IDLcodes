; NAME:
; 	        READLOG
; PURPOSE:
; 		Reads the log file produced by GALFIT and return the
; 		number of modelled components, their name and fitted
; 		parameters, and the chi2 value in a array
; 		
; CALLING SEQUENCE:
;    readlog,file,name=name,comp=comp,sky=sky,chi2=chi2
;
; INPUT:
;   file = log file to read
;   
;   FILE FORMAT : (3 types of components can be read in this version :
;   expdisk, sersic, psf 
;   
;   -----------------------------------------------------------------------------
;
;   Input image     : J33244.861-274727.59_i.fits[1:301,1:301] 
;   Init. par. file : J33244.861-274727.59_i.in 
;   Restart file    : galfit.01 
;   Output image    : J33244.861-274727.59_i_galout.fits 
;
;   psf       : (  251.84,   251.40)   20.30
;             (    0.05,     0.05)    0.03
;   sersic    : ( [148.50], [151.50])  20.62     15.78    2.56    0.32    61.29
;             (   [0.00],   [0.00])   0.04      0.68    0.06    0.00     0.18
;   expdisk   : ( [148.50], [151.50])  18.87     20.68    0.49    84.70
;             (   [0.00],   [0.00])   0.01      0.05    0.00     0.19
;   sky       : [151.00, 151.00]  [1.12e-03]  [0.00e+00]  [0.00e+00]
;                                [0.00e+00]  [0.00e+00]  [0.00e+00]
;   Chi^2 = 33919462.93818,  ndof = 63666
;   Chi^2/nu = 532.772 
;
;   -----------------------------------------------------------------------------
;	
; OUTPUT (keywords)
;   name = string array containing the component names
;   comp = float array containing the model parameters for each component :
;       comp[n,*]=[xc,err_xc,yc,err_yc,mag,err_mag,re,err_re,rd,err_rd,n,err_n,q,err_q,pa,err_pa] (default values of the parameters are -99.) where designed the (n-1)e component
;   chi2 = float array containing chi2 and chi2nu
;
; MODIFICATION HISTORY: 
; 		Created by Karen D. 07/2013 


FUNCTION read_expdisk,lines_to_read
Component_str={strcomponent}
Component_str.type = 'expdisk'
Component_str.Color = 'Dodger blue'
line_extracted=lines_to_read[0]
subline=STRSPLIT(line_extracted,/EXTRACT)
FOR k=3,N_ELEMENTS(subline)-1 DO BEGIN
   lineDisk = STRSPLIT(subline[k],/EXTRACT,ESCAPE=',[*]')
   IF k EQ 3 THEN Component_str.x0=FLOAT(lineDisk)
   IF k EQ 4 THEN Component_str.y0=FLOAT(lineDisk)
   IF k EQ 5 THEN Component_str.Mag_T=FLOAT(lineDisk)
   IF k EQ 6 THEN Component_str.Re=FLOAT(lineDisk)
   IF k EQ 7 THEN Component_str.b_a=FLOAT(lineDisk)
   IF k EQ 8 THEN Component_str.PA=FLOAT(lineDisk)
ENDFOR
line_extracted=lines_to_read[1]
subline=STRSPLIT(line_extracted,/EXTRACT)

FOR k=1,N_ELEMENTS(subline)-1 DO BEGIN
   errDisk = STRSPLIT(subline[k],/EXTRACT,ESCAPE=',[*]')
   IF k EQ 1 THEN Component_str.x0_err=FLOAT(errDisk)
   IF k EQ 2 THEN Component_str.y0_err=FLOAT(errDisk)
   IF k EQ 3 THEN Component_str.Mag_T_err=FLOAT(errDisk)
   IF k EQ 4 THEN Component_str.Re_err=FLOAT(errDisk)
   IF k EQ 5 THEN Component_str.b_a_err=FLOAT(errDisk)
   IF k EQ 6 THEN Component_str.PA_err=float(errDisk)
ENDFOR
RETURN,Component_str
END

FUNCTION read_sersic,lines_to_read
Component_str={strcomponent}
Component_str.type = 'sersic'
Component_str.Color = 'dark orchid' 

line_extracted=lines_to_read[0]
subline=STRSPLIT(line_extracted,/EXTRACT)
FOR k=3,N_ELEMENTS(subline)-1 DO BEGIN
   lineSersic = STRSPLIT(subline[k],/EXTRACT,ESCAPE=',[*]')
   IF k EQ 3 THEN Component_str.x0=FLOAT(lineSersic)
   IF k EQ 4 THEN Component_str.y0=FLOAT(lineSersic)
   IF k EQ 5 THEN Component_str.Mag_T=FLOAT(lineSersic)
   IF k EQ 6 THEN Component_str.Re=FLOAT(lineSersic)
   IF k EQ 7 THEN Component_str.n = FLOAT(lineSersic)
   IF k EQ 8 THEN Component_str.b_a=FLOAT(lineSersic)
   IF k EQ 9 THEN Component_str.PA=FLOAT(lineSersic)
ENDFOR

line_extracted=lines_to_read[1]
subline=STRSPLIT(line_extracted,/EXTRACT)
		
FOR k=1,N_ELEMENTS(subline)-1 DO BEGIN
   errSersic = STRSPLIT(subline[k],/EXTRACT,ESCAPE=',[*]')
   IF k EQ 1 THEN Component_str.x0_err=FLOAT(errSersic)
   IF k EQ 2 THEN Component_str.y0_err=FLOAT(errSersic)
   IF k EQ 3 THEN Component_str.Mag_T_err=FLOAT(errSersic)
   IF k EQ 4 THEN Component_str.Re_err=FLOAT(errSersic)
   IF k EQ 5 THEN Component_str.n_err=FLOAT(errSersic)
   IF k EQ 6 THEN Component_str.b_a_err=FLOAT(errSersic)
   IF k EQ 7 THEN Component_str.PA_err=FLOAT(errSersic)
ENDFOR
return, Component_str
END

FUNCTION read_psf,lines_to_read, Component
Component_str={strcomponent}
Component_str[k].type = 'psf'
Component_str[k].Color = 'blue'  
line_extracted=lines_to_read[0]
subline=STRSPLIT(line_extracted,/EXTRACT,ESCAPE='[(*)]')
FOR k=3,N_ELEMENTS(subline)-1 DO BEGIN
   ;stop
   linePsf = STRSPLIT(subline[k],/EXTRACT,ESCAPE=',')
   IF k EQ 3 THEN Component_str.x0=FLOAT(linePsf)
   IF k EQ 4 THEN Component_str.y0=FLOAT(linePsf)
   IF k EQ 5 THEN Component_str.Mag_T=FLOAT(linePsf)
ENDFOR

line_extracted=lines_to_read[1]
subline=STRSPLIT(line_extracted,/EXTRACT,ESCAPE='[(*)]')
FOR k=1,N_ELEMENTS(subline)-1 DO BEGIN
   errPsf = STRSPLIT(subline[k],/EXTRACT,ESCAPE=',')
   IF k EQ 1 THEN Component_str.x0_err=FLOAT(errPsf)
   IF k EQ 2 THEN Component_str.y0_err=FLOAT(errPsf)
   IF k EQ 3 THEN Component_str.Mag_T_err=FLOAT(errPsf)
ENDFOR
RETURN,Component_str
END

FUNCTION read_sky,lines_to_read
Component_str={strcomponent}
Component_str.type = 'sky'
Component_str.Color = 'grey' 
line_extracted=lines_to_read[0]
subline=STRSPLIT(line_extracted,/EXTRACT,ESCAPE='[(*)]')
FOR k=2,N_ELEMENTS(subline)-1 DO BEGIN
   lineSky = STRSPLIT(subline[k],/EXTRACT,ESCAPE=',')
   IF k EQ 2 THEN Component_str.x0 = DOUBLE(lineSky)
   IF k EQ 3 THEN Component_str.y0 = DOUBLE(lineSky)
   IF k EQ 4 THEN Component_str.sky = DOUBLE(lineSky)
   IF k EQ 5 THEN Component_str.dxsky = DOUBLE(lineSky)
   IF k EQ 6 THEN Component_str.dysky = DOUBLE(lineSky) 
ENDFOR

line_extracted=lines_to_read[1]
subline=STRSPLIT(line_extracted,/EXTRACT,ESCAPE='[(,*)]')
FOR k=0,N_ELEMENTS(subline)-1 DO BEGIN
   errSky = subline[k]
   IF k EQ 0 THEN Component_str.err_sky_value = FLOAT(errSky)
   IF k EQ 1 THEN Component_str.err_dxsky = FLOAT(errSky)
   IF k EQ 2 THEN Component_str.err_dysky = FLOAT(errSky)
ENDFOR
RETURN,Component_str
END

PRO readlog,file,Components,chi2=chi2

 ;;;; compter le nombre de fois que l'on rencontre sersic,
 ;;;; expdisk, etc. dans *.log
SPAWN,'res=$(grep sersic  '+file+' -c) ; echo $res',Nsersic
SPAWN,'res=$(grep expdisk  '+file+' -c) ; echo $res',Nexpdisk
SPAWN,'res=$(grep sky  '+file+' -c) ; echo $res',Nsky
SPAWN,'res=$(grep psf  '+file+' -c) ; echo $res',Npsf

Nsersic = FIX(FLOAT(Nsersic[0]))
Nexpdisk = FIX(FLOAT(Nexpdisk[0]))
Npsf = FIX(FLOAT(Npsf[0]))
Nsky = FIX(FLOAT(Nsky[0]))

line=RD_TFILE(file)  ; lit le fichier en entier et retourne chaque ligne dans un element du tableau line

;;;;;;;; determination du nombre de composantes ;;;;;;;;;;;;;
n_component = Nsersic + Nexpdisk + Npsf + Nsky
Components= REPLICATE({strcomponent}, n_component)

lines_comp = line[7:N_ELEMENTS(line)-5]
index = 0
FOR k=0,n_component -1  DO BEGIN
   line_extracted = lines_comp[index]
   subline=STRSPLIT(line_extracted,/EXTRACT,ESCAPE='[]')
   type=subline[0]
CASE type OF
    'sersic' : Components[k] = read_sersic(lines_comp[index:index+1])
	'expdisk': Components[k] = read_expdisk(lines_comp[index:index+1]) 
		'psf': Components[k] = read_psf(lines_comp[index:index+1]) 	   
		'sky': Components[k] = read_sky(lines_comp[index:index+1])
ENDCASE			   		   			   
index = index + 2
ENDFOR

chi2 = FLTARR(2)
line_number = index + 7
subline = STRSPLIT(line[line_number],/EXTRACT,ESCAPE=',')
chi2[0] = DOUBLE(subline[2])
subline = STRSPLIT(line[line_number+1],/EXTRACT,ESCAPE=',')
chi2[1] = DOUBLE(subline[2])

END




