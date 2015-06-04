PRO Fit_1D_SB_all

@Config_prep_Galfit
READCOL, PATH_CATALOGUE+CATALOGUE_INPUT, name,file,redshift,pix_size,ZP, FORMAT = '(A,A,F,F,F)'


for i=0, n_elements(name) -1 do begin 
print,name[i]
SBProfile_out= PATH_SUM+name(i)+'_profile.dat'
PRINT_LOG= PATH_SUM+name(i)+'_'+BANDS[0]+'_model.log'
SAVE_PLOT= PATH_SUM+name(i)+'_'+BANDS[0]+'_model.eps'

print,'FIT_1D_SB_Profile,'+SBProfile_out+', '+0.15/pix_size[i]+','+ZP[i]+', PRINT_LOG = '+PRINT_LOG+', pixel_scale ='+pix_size[i]+', SAVE_PLOT='+SAVE_PLOT
FIT_1D_SB_Profile, SBProfile_out , 0.15/pix_size[i] , ZP[i], PRINT_LOG = PRINT_LOG , pixel_scale = pix_size[i] , SAVE_PLOT=SAVE_PLOT
PAUSE

endfor

END