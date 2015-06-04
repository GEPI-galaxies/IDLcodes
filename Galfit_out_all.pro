PRO Galfit_out_all

@Config_prep_Galfit

READCOL, PATH_CATALOGUE+CATALOGUE_INPUT, name,file,redshift,pix_size,ZP, FORMAT = '(A,A,F,F,F)'


for i=0, n_elements(name) -1 do begin 

INFILE= PATH_SUM+name(i)+'_'+BANDS[0]+'.fits'
WHTFILE= PATH_SUM+name(i)+'_'+BANDS[0]+'_wht.fits'
MSKFILE= PATH_SUM+name(i)+'_'+BANDS[0]+'_msk.fits'

LOG_FILE=PATH_SUM+name(i)+'_'+BANDS[0]+'.log'
GALOUT_FILE=PATH_SUM+name(i)+'_'+BANDS[0]+'_galout.fits'
SUBCOMP_FILE=PATH_SUM+name(i)+'_'+BANDS[0]+'_subcomps.fits'
INIFILE=PATH_SUM+name(i)+'_'+BANDS[0]+'.in'
OUTFILE=PATH_SUM+name(i)+'_'+BANDS[0]+'_galfit.txt'
OUTEPS1=PATH_SUM+name(i)+'_'+BANDS[0]+'_im.eps'
OUTEPS2=PATH_SUM+name(i)+'_'+BANDS[0]+'_mod.eps'
OUTEPS3=PATH_SUM+name(i)+'_'+BANDS[0]+'_res.eps'
OUTEPS_profile=PATH_SUM+name(i)+'_'+BANDS[0]+'_profile_galfit.eps'

GALOUT_IMAGES,GALOUT_FILE, OUTEPS1, OUTEPS2, OUTEPS3, $
			  REDSHIFT=redshift[i],KPC_SCALE=50.,MSKFILE=mskfile,PIXSCALE=pix_size[i],Z_label=Z_label

plotprofile,zp[i],pix_size[i],'e/s',LOG_FILE, SUBCOMP_FILE, OUTEPS_profile,xaxis_unit='kpc',redshift=redshift[i],scale=50.


endfor
END
