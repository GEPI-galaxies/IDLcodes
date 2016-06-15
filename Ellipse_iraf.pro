;; code idl rassemblant compute_center et ellipse_maker

;; 2 modes de fonctionnement : avant et apres

PRO Ellipse_iraf, OBJECT, FILE_IN, PATH_OUT, ZP, step=step

IF not KEYWORD_SET(step) THEN step='guess'

IF STRMATCH(step,'guess') THEN BEGIN

   SUFFIXE_TAB = '_ellipse_Guess.tab'
   SUFFIXE_DAT = '_ellipse_Guess.dat'
   SUFFIXE_CL = '_guess.cl'

ENDIF ELSE IF STRMATCH(step,'final') THEN BEGIN

   SUFFIXE_TAB = '_ellipse.tab'
   SUFFIXE_DAT = '_ellipse.dat'
   SUFFIXE_CL = '_ellipse.cl'

   SUFFIXE_GUESS = '_ellipse_Guess.dat'
   FILE_GUESS = PATH_OUT + OBJECT + SUFFIXE_GUESS

ENDIF

FILE_CL = PATH_OUT + OBJECT + SUFFIXE_CL
FILE_TAB = PATH_OUT + OBJECT + SUFFIXE_TAB
FILE_DAT = PATH_OUT + OBJECT + SUFFIXE_DAT
FILE_TMP = PATH_OUT + OBJECT + '_temps.fits'

Cmd_FileIN = "'s%$FILE_IN%"+FILE_IN+"%' "
Cmd_FileEllipse = "'s%$FILE_ELLIPSE%"+FILE_TAB+"%' "
Cmd_FileTmp = "'s%$FILE_TMP%"+FILE_TMP+"%' "
Cmd_FileFinal = "'s%$FILE_DAT%"+FILE_DAT+"%' "

IF STRMATCH(step,'guess') THEN BEGIN
   Cmd_X0 = "'s%$XCENTER%INDEF%' "
   Cmd_Y0 = "'s%$YCENTER%INDEF%' "
   Cmd_centerFlag = "'s%$recente_FLAG%yes%' "
ENDIF ELSE IF STRMATCH(step,'final') THEN BEGIN
   readcol,FILE_GUESS,format='(i,f,f,f,f,f,f,f,f,f)', row,sma,Int,I_err,E,E_err,PA,PA_err,xc,yc
   centerX=STRCOMPRESS(string(mean(xc)),/REMOVE_ALL)
   centerY=STRCOMPRESS(string(mean(yc)),/REMOVE_ALL)

   Cmd_X0 = "'s%$XCENTER%"+centerX+"%' "
   Cmd_Y0 = "'s%$YCENTER%"+centerY+"%' "
   Cmd_centerFlag = "'s%$recente_FLAG%no%' "
ENDIF

Cmd_mag0 = "'s%$mag0%"+STRCOMPRESS(string(ZP))+"%' "

Cmd_config = "sed -e "+Cmd_FileIN+"-e "+Cmd_FileEllipse+"-e "+Cmd_FileTmp+"-e "+Cmd_FileFinal+"-e "+Cmd_X0+"-e "+Cmd_Y0+"-e "+Cmd_centerFlag+ "-e "+Cmd_mag0+"< Template_ellipse.dat > "+ FILE_CL

spawn,Cmd_config
spawn,"chmod 755 "+ FILE_CL

END

PRO Ellipse_iraf_all, step=step

@Config_Ellipse

READCOL, PATH_CATALOGUE+CATALOGUE_INPUT, OBJECT,file,redshift,pix_size,ZP, FORMAT = '(A,A,F,F,F)'

FILE_IN = PATH_DATA + OBJECT + SUFFIXE_im

;;; first step
IF STRMATCH(step,'guess') THEN BEGIN
   OPENW,unit,'script_guess.cl',/GET_LUN    ;;; script qui permettra de tout executer d'un coup ... attention control visuel necessaire
   FOR i=0,N_ELEMENTS(OBJECT)-1 DO BEGIN
      Ellipse_iraf, OBJECT[i],FILE_IN[i],PATH_ELLIPSE,ZP,step='guess'
      PRINTF,unit,'cl < '+OBJECT[i]+'_guess.cl'
   ENDFOR
   FREE_LUN,unit
ENDIF
;;;; open an iraf term and follow this : 
;; > cl
;; > stsdas
;; > analysis
;; > isophote
;; > cl < script_guess.cl

;;; second step
IF STRMATCH(step,'final') THEN BEGIN
   OPENW,unit,'script_ellipse.cl',/GET_LUN   
   FOR i=0,N_ELEMENTS(OBJECT)-1 DO BEGIN
      Ellipse_iraf, OBJECT[i],FILE_IN[i],PATH_ELLIPSE,ZP,step='final'
      PRINTF,unit,'cl < '+OBJECT[i]+'_ellipse.cl'
   ENDFOR
   FREE_LUN,unit
ENDIF

;;;; open an iraf term and follow this : 
;; > cl
;; > stsdas
;; > analysis
;; > isophote
;; > cl < script_ellipse.cl
END

 
