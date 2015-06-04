PRO init_galfitfile,file,image,zeropt,pixscale,psf_sampling,OBJFILE, GALOUT, sigma=sigma,psf_file=psf_file,maskfile=maskfile,constfile=constfile,zoneFit=zoneFit

IF not keyword_set(sigma) THEN sigma='none'
IF not keyword_set(maskfile) THEN maskfile='none'
IF not keyword_set(constfile) THEN constfile='none'

ZP = STRTRIM(STRING(zeropt,format='(f8.3)'),2)
px = STRTRIM(STRING(pixscale,format='(f8.3)'),2)
fine_sampling = STRTRIM(STRING(psf_sampling,format='(i)'),2)

x1_zoneFit = STRTRIM(STRING(zoneFit(0),format='(i)'),2)
x2_zoneFit = STRTRIM(STRING(zoneFit(1),format='(i)'),2)
y1_zoneFit = STRTRIM(STRING(zoneFit(2),format='(i)'),2)
y2_zoneFit = STRTRIM(STRING(zoneFit(3),format='(i)'),2)

x_sizeBox = STRTRIM(STRING(zoneFit(1)-zoneFit(0)+1,format='(i)'),2)
y_sizeBox = STRTRIM(STRING(zoneFit(3)-zoneFit(2)+1,format='(i)'),2)

OPENW, U,file,/GET_LUN

; ECRITURE DU FICHIER DE CONFIG COMPATIBLE AVEC LA VERSION GALFIT 3.0 ET PLUS RECENTES

PRINTF, U,  '=============================================================================== '
PRINTF, U,  '# IMAGE and GALFIT CONTROL PARAMETERS'
PRINTF, U,  'A) '+OBJFILE+'			# Input data image (FITS file)'
PRINTF, U,  'B) '+GALOUT+'	# Output data image block'
PRINTF, U,  'C) '+sigma+'       # Sigma image name (made from data if blank or "none'
PRINTF, U,  'D) '+psf_file+'    # Input PSF image and (optional) diffusion kernel'
PRINTF, U,  'E) '+fine_sampling+          '         			# PSF fine sampling factor relative to data'
PRINTF, U,  'F) '+maskfile+'       # Bad pixel mask (FITS image or ASCII coord list)'
PRINTF, U,  'G) '+constfile+'         # File with parameter constraints (ASCII file)'
PRINTF, U,  'H) '+x1_zoneFit+' '+x2_zoneFit+' '+y1_zoneFit+' '+y2_zoneFit+'   		# Image region to fit (xmin xmax ymin ymax)'
PRINTF, U,  'I) '+x_sizeBox+'   '+y_sizeBox+'		# Size of the convolution box (x y) '
PRINTF, U,  'J) '+ZP+'                 	# Magnitude photometric zeropoint'
PRINTF, U,  '#K) '+px+'	'+px+'          			# Plate scale (dx dy)    [arcsec per pixel]'
PRINTF, U,  'O) regular             			# Display type (regular, curses, both) '
PRINTF, U,  'P) 0                   			# Create ouput only? (1=yes; 0=optimize)'
PRINTF, U, FORMAT='(A)', 'S) 0		            # Modify/create objects interactively?'
PRINTF, U,  '  '
PRINTF, U,  '# INITIAL FITTING PARAMETERS '
PRINTF, U,  '#  '
PRINTF, U,  '#   For object type, the allowed functions are:                                 		'
PRINTF, U,  '#       nuker, sersic, expdisk, devauc, king, psf, gaussian, moffat,            		'
PRINTF, U,  '#       ferrer, powsersic, sky, and isophote.                                   		'
PRINTF, U,  '#                                                                               		'
PRINTF, U,  '#   Hidden parameters will only appear when they are specified:                 		'
PRINTF, U,  '#       C0 (diskyness/boxyness),                                                		'
PRINTF, U,  '#       Fn (n=integer, Azimuthal Fourier Modes),                                		'
PRINTF, U,  '#       R0-R10 (PA rotation, for creating spiral structures).                   		'
PRINTF, U,  '#                                                                               		'
PRINTF, U,  '# ----------------------------------------------------------------------------- 		'
PRINTF, U,  '#   par)    par value(s)    fit toggle(s)    # parameter description            		'
PRINTF, U,  '# ----------------------------------------------------------------------------- 		'
PRINTF, U,  '												'

free_lun,U


END
