; 
; Create iraf routine for ellipse fitting
; Add redshift keyword to the image
;
; INPUT : 
;		OBJECT 	 = Object_name
; 		Path_IN  = Path of the input file		 
; 		Path_OUT = Path of the output file
; 		REDSHIFT = redshift of the object
; 

PRO Ellipse_maker, OBJECT,Path_IN,Path_OUT,REDSHIFT,ZP

SUFFIXE_IN = '_H.fits'
SUFFIXE_ELLIPSE = '_ellipse.tab'
SUFFIXE_ELLIPSE_DAT = '_ellipse.dat'
SUFFIXE_ELLIPSE_CL = '_ellipse.cl'
SUFFIXE_GUESS = '_ellipse_Guess.dat'

FILE_CL = Path_OUT + OBJECT + SUFFIXE_ELLIPSE_CL
FILE_ORG = Path_IN + OBJECT +SUFFIXE_IN
FILE_IN = Path_OUT + OBJECT +SUFFIXE_IN
FILE_ELLIPSE = Path_OUT + OBJECT +SUFFIXE_ELLIPSE 
FILE_TMP = Path_OUT + OBJECT +'_temp.fits' 
FILE_DAT = Path_OUT + OBJECT +SUFFIXE_ELLIPSE_DAT 
FILE_GUESS = Path_OUT + OBJECT +SUFFIXE_GUESS 

; read first guess 
readcol,FILE_GUESS,format='(i,f,f,f,f,f,f,f,f,f)', row,sma,Int,I_err,E,E_err,PA,PA_err,xc,yc
centerX=STRCOMPRESS(string(mean(xc)),/REMOVE_ALL)
centerY=STRCOMPRESS(string(mean(yc)),/REMOVE_ALL)

Comd_FileIN="'s%$FILE_IN%"+FILE_IN+"%' "
Comd_FileEllipse="'s%$FILE_ELLIPSE%"+FILE_ELLIPSE+"%' "
Comd_FileTmp="'s%$FILE_TMP%"+FILE_TMP+"%' "
Comd_FileFinal="'s%$FILE_DAT%"+FILE_DAT+"%' "
Comd_X0="'s%$XCENTER%"+centerX+"%' "
Comd_Y0="'s%$YCENTER%"+centerY+"%' "
Comd_mag0="'s%$mag0%"+STRCOMPRESS(string(ZP))+"%' "
Comd_centerFlag="'s%$recente_FLAG%no%' "
Comd_config="sed -e "+Comd_FileIN+"-e "+Comd_FileEllipse+"-e "+Comd_FileTmp+"-e "+Comd_FileFinal+"-e "+Comd_X0+"-e "+Comd_Y0+"-e "+Comd_centerFlag+ "-e "+Comd_mag0+"< Template_ellipse.dat > "+ FILE_CL
print,Comd_config
spawn,Comd_config
spawn,"chmod 755 "+ FILE_CL

END


PRO Ellipse_all

@Config_Ellipse
READCOL, PATH_CATALOGUE+CATALOGUE_INPUT, name,file,redshift,pix_size,ZP, FORMAT = '(A,A,F,F,F)'
for i=0, n_elements(name) -1 do begin 
Ellipse_maker, name(i),Path_GUESS_OUT,Path_GUESS_OUT,REDSHIFT(i),ZP(i)
endfor

END