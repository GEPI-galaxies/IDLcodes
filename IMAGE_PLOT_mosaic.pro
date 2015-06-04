PRO IMAGE_PLOT_mosaic

READCOL,'../Catalogue/KMOS3D_Wisnioski2014_z1.cat',id,dec,ra,redshift,FORMAT='(a,f,f,f)'
Path_image_cut = '../Imagery/Cutimages_8arcsec/'
Path_image_mosaic='../Imagery/Color_Mosaic/'
;!P.Multi=[0,2,2]


for i=0, n_elements(id) -1 do begin 
cgDisplay ,700 ,700, ASPECT=1
pos = cgLayout([2,2], OXMargin=[1,1], OYMargin=[1,1], XGap=2, YGap=2)

print,id[i]
	loadct,0
	result = FILE_TEST(Path_image_cut +id[i]+'_V.fits')
	IF result then begin 
	image_V=readfits(Path_image_cut+id[i]+'_V.fits',header)
	imageV_scl=alogscale(255-image_V, /auto)  
	cgIMAGE, imageV_scl, NoErase=0 NE 0, Position= pos[*,0],/scale
	loadct,12
	endif
	cgText, 0.04,0.95, 'V-band', COLOR='dodger blue',/NORMAL, width=1.5
	ARCBAR, header, 1,/SECONDS ,POSITION=[0.43,0.95],/NORMAL,color=175
	loadct,0

	result = FILE_TEST(Path_image_cut+id[i]+'_I.fits')
	IF result then begin 
	image_I=readfits(Path_image_cut+id[i]+'_I.fits',header)
	imageI_scl=alogscale(255-image_I,/auto)
	cgIMAGE, imageI_scl, NoErase=1 NE 0, Position= pos[*,1]
	loadct,12
	endif
	cgText, 0.54,0.95, 'I-band', COLOR='dodger blue',/NORMAL
	ARCBAR, header, 1,/SECONDS ,POSITION=[0.93,0.95],/NORMAL,color=175
	loadct,0

	result = FILE_TEST(Path_image_cut+id[i]+'_J.fits')
	IF result then begin 
	image_J=readfits(Path_image_cut+id[i]+'_J.fits',header)
	imageJ_scl=alogscale(255-image_J, /auto)
	cgIMAGE, imageJ_scl, NoErase=2 NE 0, Position= pos[*,2]
	loadct,12
	endif
	cgText, 0.04,0.45, 'J-band', COLOR='dodger blue',/NORMAL
	ARCBAR, header, 1,/SECONDS ,POSITION=[0.43,0.45],/NORMAL,color=175
	loadct,0

	result = FILE_TEST(Path_image_cut+id[i]+'_H.fits')
	IF result then begin 
	image_H=readfits(Path_image_cut+id[i]+'_H.fits',header)
	imageH_scl=alogscale(255-image_H, /auto)
	cgIMAGE, imageJ_scl, NoErase=3 NE 0, Position= pos[*,3]
	loadct,12
	endif
	cgText, 0.54,0.45, 'H-band', COLOR='dodger blue',/NORMAL
	ARCBAR, header, 1,/SECONDS ,POSITION=[0.93,0.45],/NORMAL,color=175
	loadct,0



;thisPostion = [0.1, 0.1, 0.9, 0.9] POSITION=thisPosition, /KEEP_ASPECT_RATIO
;,OUTPUT='PDF', OUTFILENAME='images/3D_COS3_644_V.pdf' ;,FILENAME ='images/3D_COS3_644_V.pmg'
void = cgSnapshot(FILENAME=Path_image_mosaic+id[i]+'.png',/nodialog)
endfor
;!P.Multi = 0
 
 
END