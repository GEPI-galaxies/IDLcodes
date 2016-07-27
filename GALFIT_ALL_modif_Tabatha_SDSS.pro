PRO GALFIT_ALL
@Config_prep_GALFIT

READCOL, PATH_CATALOGUE+CATALOGUE_INPUT, name,file,redshift,pix_size,ZP, FORMAT = '(A,A,F,F,F)'

for i=0, n_elements(name)-1 do begin
GALFIT_galaxy, name(i) , redshift(i), STEP='Step_3' 
endfor
END
