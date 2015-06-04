PRO SUM_All

path='/Users/hypatia/Documents/IMAGES_Kinematics/3D_HST/Morpho/'
READCOL,path+'KMOS3D_Wisnioski2014_z1.cat',name,dec,ra,redshift,FORMAT='(a,f,f,f)'

FOR k=0,N_ELEMENTS(name)-1 DO BEGIN
im_I=READFITS(path+'SUM/'+name[k]+'_I_convol.fits',/SILENT)
im_J=READFITS(path+'SUM/'+name[k]+'_J_convol.fits',header,/SILENT)
im_H=READFITS(path+'Cutimages_15arcsec/'+name[k]+'_H.fits',header,/SILENT)

SUM = im_I + im_J + im_H
WRITEFITS,path+'SUM/'+name[k]+'_sum.fits',SUM,header
	
ENDFOR   


END
