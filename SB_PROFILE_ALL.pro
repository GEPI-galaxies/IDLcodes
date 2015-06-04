PRO SB_PROFILE_ALL

@Config_Ellipse
READCOL, PATH_CATALOGUE+CATALOGUE_INPUT, name,file,redshift,pix_size,ZP, FORMAT = '(A,A,F,F,F)'


SUFFIXE_IN = '_H.fits'
SUFFIXE_ELLIPSE_DAT = '_ellipse.dat'
SUFFIXE_PROFILE = '_profile.dat'
SUFFIXE_PROFILE_PLOT = '_profile.eps'

for i=0, n_elements(name) -1 do begin 
print,name[i]
SB_PROFILE,Path_GUESS_OUT+name(I)+SUFFIXE_ELLIPSE_DAT,Path_GUESS_OUT+name(I)+SUFFIXE_IN, ZP(i),$
			 pix_size(i), redshift(i), Path_GUESS_OUT+name(I)+SUFFIXE_PROFILE, /PLOT, $
			 SAVE_PLOT=Path_GUESS_OUT+name(I)+SUFFIXE_PROFILE_PLOT, /COSMO_DIMMING
pause
endfor

END