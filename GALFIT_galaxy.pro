PRO GALFIT_galaxy, name , redshift, STEP=STEP 

@Config_prep_GALFIT

INFILE= PATH_DATA+name+INFILE_SUFFIXE
WHTFILE= PATH_DATA+name+WHTFILE_SUFFIXE

MASKFILE=PATH_GALFIT+name+MASKFILE_SUFFIXE
OBJFILE=PATH_GALFIT+name+OBJFILE_SUFFIXE
SEGFILE=PATH_GALFIT+name+SEGFILE_SUFFIXE
OUTFILE=PATH_GALFIT+name+OUTFILE_SUFFIXE
GALFILE=PATH_GALFIT+name+GALFILE_SUFFIXE
NOISEFILE=PATH_GALFIT+name+NOISEFILE_SUFFIXE

SBPROFILE= PATH_GALFIT+name+SBProfile_out_SUFFIXE
PRINT_LOG_1DPROFILE = PATH_GALFIT+name+PRINT_LOG_SUFFIXE
SAVE_PLOT_1DPROFILE = PATH_GALFIT+name+SAVE_PLOT_SUFFIXE

GALOUT= PATH_GALFIT+name+ GALOUT_SUFFIXE
GALLOG1= PATH_GALFIT+name+ GALLOG1_SUFFIXE
GALLOG2= PATH_GALFIT+name+ GALLOG2_SUFFIXE
SUBCOMPS= PATH_GALFIT+name+ SUBCOMPS_SUFFIXE
PSFFILE = PSF_PATH+PSF_FILE
OUTEPS1=PATH_GALFIT+name+'_im.eps'
OUTEPS2=PATH_GALFIT+name+'_model.eps'
OUTEPS3=PATH_GALFIT+name+'_res.eps'
OUTEPS_profile=PATH_GALFIT+name+'_gal_profile.eps'
DS9FILE= PATH_GALFIT+name+ '_ds9.sh'

IF kEYWORD_SET(STEP) then begin
	Case STEP OF
	'Step_1': goto, Step1
	'Step_2': goto, Step2
	'Step_3': goto, Step3
	'Step_4': goto, Step4
	'Step_5': goto, Step5	
	ENDCASE
ENDIF

Step1:
Prep_images_Galfit, name, INFILE, WHTFILE , ZP , pix_size, OBJFILE, SEGFILE , MASKFILE, OUTFILE, GALFILE, NOISEFILE, PSFFILE,GALOUT, SEX_DETECT_THRESH, SEX_ANALYSIS_THRESH

Step2:
FIT_Profile : 
FIT_1D_SB_Profile, SBPROFILE , Resolution/pix_size , ZP, PRINT_LOG = PRINT_LOG_1DPROFILE , pixel_scale = pix_size , SAVE_PLOT=SAVE_PLOT_1DPROFILE ,  CUT_PROFILE=OBJFILE
Flag_fit=''
READ, Flag_fit, PROMPT="Continue with Galfit (any key) or fit the profile again (f):"
IF STRCMP(Flag_fit,'f') then GOTO, FIT_Profile

;Merge logfile to galfit.input
spawn,'cat '+PRINT_LOG_1DPROFILE+' >> '+ GALFILE
spawn,'rm '+PRINT_LOG_1DPROFILE

Step3:
; Run Galfit
spawn, '/Users/hypatia/Software/Galfit/galfit '+GALFILE 

Step4:
spawn, '/Users/hypatia/Software/Galfit/galfit -o3 galfit.01' 
print,'Produce subcomps'
spawn, 'mv subcomps.fits '+SUBCOMPS
spawn,'mv galfit.01 '+GALLOG1
spawn,'mv fit.log '+GALLOG2

Step5:
GALOUT_IMAGES,GALOUT, OUTEPS1, OUTEPS2, OUTEPS3, REDSHIFT=redshift,KPC_SCALE=50.,MSKFILE=MASKFILE,PIXSCALE=pix_size,Z_label='e-/s'
plotprofile,ZP,pix_size,'',GALLOG2, SUBCOMPS, OUTEPS_profile,xaxis_unit='kpc',redshift=redshift,scale=40.
Ds9_make, GALOUT, DS9FILE
spawn, 'chmod 755 '+DS9FILE
;make_page_tex, name, GALLOG2, OUTEPS_profile,OUTEPS1,OUTEPS2,OUTEPS3, TOTEXFILE
make_table_tex, name, PATH_GALFIT, GALLOG2,ZP
END



PRO GALFIT_ALL
@Config_prep_GALFIT

READCOL, PATH_CATALOGUE+CATALOGUE_INPUT, name,file,redshift,pix_size,ZP, FORMAT = '(A,A,F,F,F)'

for i=0, n_elements(name)-1 do begin
GALFIT_galaxy, name(i) , redshift(i), STEP='Step_5' 
endfor
END