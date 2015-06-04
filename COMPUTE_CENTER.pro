;Compute Center 

PRO COMPUTE_CENTER, OBJECT,Path_IN,Path_OUT,REDSHIFT, ZP

SUFFIXE_IN = '_H.fits'
SUFFIXE_ELLIPSE = '_ellipse_Guess.tab'
SUFFIXE_OUT_DAT = '_ellipse_Guess.dat'
SUFFIXE_CL = '_guess.cl'

FILE_CL = Path_OUT + OBJECT + SUFFIXE_CL
FILE_ORG = Path_IN + OBJECT +SUFFIXE_IN
FILE_IN = Path_OUT + OBJECT +SUFFIXE_IN
FILE_ELLIPSE = Path_OUT + OBJECT +SUFFIXE_ELLIPSE 
FILE_TMP = Path_OUT + OBJECT +'_temp.fits' 
FILE_DAT = Path_OUT + OBJECT +SUFFIXE_OUT_DAT 

;Make local copy of the input file
;spawn,"cp "+ FILE_ORG + " "+FILE_IN
;Add redshift keyword
tmp=readfits(FILE_IN,header,/silent)
sxaddpar,header,'REDSHIFT',REDSHIFT
sxaddpar,header,'OBJECT',OBJECT
modfits,FILE_IN,tmp,header 

Comd_FileIN="'s%$FILE_IN%"+FILE_IN+"%' "
Comd_FileEllipse="'s%$FILE_ELLIPSE%"+FILE_ELLIPSE+"%' "
Comd_FileTmp="'s%$FILE_TMP%"+FILE_TMP+"%' "
Comd_FileFinal="'s%$FILE_DAT%"+FILE_DAT+"%' "
Comd_X0="'s%$XCENTER%INDEF%' "
Comd_Y0="'s%$YCENTER%INDEF%' "
Comd_mag0="'s%$mag0%"+STRCOMPRESS(string(ZP))+"%' "
Comd_centerFlag="'s%$recente_FLAG%yes%' "
Comd_config="sed -e "+Comd_FileIN+"-e "+Comd_FileEllipse+"-e "+Comd_FileTmp+"-e "+Comd_FileFinal+"-e "+Comd_X0+"-e "+Comd_Y0+"-e "+Comd_centerFlag+ "-e "+Comd_mag0+"< Template_ellipse.dat > "+ FILE_CL
print,Comd_config
spawn,Comd_config
spawn,"chmod 755 "+ FILE_CL

END


PRO Compute_Center_all

@Config_Ellipse

READCOL, PATH_CATALOGUE+CATALOGUE_INPUT, OBJECT,file,redshift,pix_size,ZP, FORMAT = '(A,A,F,F,F)'
for i=0, n_elements(OBJECT) -1 do begin 
COMPUTE_CENTER, OBJECT(i),Path_ELLIPSE1_IN,Path_GUESS_OUT,REDSHIFT(i), ZP(i)
endfor

END


