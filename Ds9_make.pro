PRO Ds9_make, GALOUT, DS9FILE

openw, lun, DS9FILE, /get_lu

printf, lun,format='(a)', 'ds9 -scale asinh -tile '+GALOUT+'[1] -zoom 2 -invert -scale asinh -tile '+GALOUT+'[2] -invert -scale asinh -tile '+GALOUT+'[3] -invert'

free_lun, lun

END

PRO Ds9_make_all
@Config_prep_GALFIT

READCOL, PATH_CATALOGUE+CATALOGUE_INPUT, name,file,redshift,pix_size,ZP, FORMAT = '(A,A,F,F,F)'

for i=0, n_elements(name)-1 do begin
GALOUT= PATH_GALFIT+name(i)+ GALOUT_SUFFIXE
DS9FILE= PATH_GALFIT+name(i)+ '_ds9.sh'
Ds9_make, GALOUT, DS9FILE
spawn, 'chmod 755 '+DS9FILE
endfor
END