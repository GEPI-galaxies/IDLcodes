pro bruit


im=readfits('bdivide_3_fgas07_10.fits')

im_2=im+randomn(seed,400,400)*0.001

writefits,'3_fgas07_10.fits',im_2 



end 
