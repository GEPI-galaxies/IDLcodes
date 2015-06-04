PRO COLORIMAGE_AUTO

@Config_imagery_plot

READCOL,PATH_CATALOGUE+INPUT_CATALOGUE,id,dec,ra,redshift,FORMAT='(a,f,f,f)'


for i=0, n_elements(id) -1 do begin 
print,id[i]
loadct,0

File_0 = FILE_TEST(PATH_DATA+id[i]+'_'+BANDS[0]+'.fits')
File_1 = FILE_TEST(PATH_DATA+id[i]+'_'+BANDS[1]+'.fits')
File_2 = FILE_TEST(PATH_DATA+id[i]+'_'+BANDS[2]+'.fits')

IF File_0+File_1+File_2 EQ 3 then begin 
image_0=readfits(PATH_DATA+id[i]+'_'+BANDS[0]+'.fits',header,/SILENT)
image_1=readfits(PATH_DATA+id[i]+'_'+BANDS[1]+'.fits',header,/SILENT)
image_2=readfits(PATH_DATA+id[i]+'_'+BANDS[2]+'.fits',header,/SILENT)
size_0=size(image_0)

cgDisplay, size_0[1]*ZOOM_SCALE_color_images, size_0[2]*ZOOM_SCALE_color_images, ASPECT=1

image0_scl=alogscale(image_0,/auto, sigma_scale_min=scale_min, sigma_scale_max=scale_max)
image1_scl=alogscale(image_1,/auto, sigma_scale_min=scale_min, sigma_scale_max=scale_max)
image2_scl=alogscale(image_2,/auto, sigma_scale_min=scale_min, sigma_scale_max=scale_max)

Device,DECOMPOSED=0
imageRGB = BYTARR(3, ZOOM_SCALE_color_images*size_0[1], ZOOM_SCALE_color_images* size_0[2], /NOZERO)
imageRGB[0, *, *] =  CONGRID( image2_scl,ZOOM_SCALE_color_images*size_0[1], ZOOM_SCALE_color_images* size_0[2])
imageRGB[1, *, *] =  CONGRID( image1_scl,ZOOM_SCALE_color_images*size_0[1], ZOOM_SCALE_color_images* size_0[2])
imageRGB[2, *, *] =  CONGRID( image0_scl,ZOOM_SCALE_color_images*size_0[1], ZOOM_SCALE_color_images* size_0[2])
TVSCL, imageRGB, TRUE=1
void = cgSnapshot(FILENAME=PATH_COLOR_OUT+id[i]+SUFIXE_color,/nodialog)
PAUSE
ENDIF
ERASE

ENDFOR

END