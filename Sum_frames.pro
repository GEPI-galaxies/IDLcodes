PRO Sum_frames

@Config_Ellipse

READCOL, PATH_CATALOGUE+CATALOGUE_INPUT, name,file,redshift,pix_size,ZP, FORMAT = '(A,A,F,F,F)'


for i=0, n_elements(name) -1 do begin 
print, name(i)

image0 = readfits(PATH_DATA+name(i)+'_'+BANDS[0]+'.fits', header_I)
image1 = readfits(PATH_DATA+name(i)+'_'+BANDS[1]+'.fits', header_J)
image2 = readfits(PATH_DATA+name(i)+'_'+BANDS[2]+'.fits', header_H)

Sum_frame = image0 * 0.
Sum_frame = image0 + image1 + image2

writefits, PATH_SUM+name(i)+SUFIXE_sum , Sum_frame,header_I


; compute masked 

MASKFILE=PATH_SUM+name(i)+'_mask.fits'
OBJFILE=PATH_SUM+name(i)+'_sum_clean.fits'
SEGFILE=PATH_SUM+name(i)+'_seg.fits'
OUTFILE=PATH_SUM+name(i)+'.ASC'
Sextractor_morpho,PATH_SUM+name(i)+SUFIXE_sum, ZP(i), OBJFILE, SEGFILE, MASKFILE, OUTFILE ,/RUN_SEX, DETECT_THRESH=SEX_DETECT_THRESH, ANALYSIS_THRESH=SEX_ANALYSIS_THRESH


endfor

END
