pro cut_images

im=readfits('80_J140320.74-003259.7_1643.fits',h)

im_reduite=im[1482:1981,958:1457]

writefits,'cut_80_J140320.74-003259.7_1643.fits',im_reduite,h

end
