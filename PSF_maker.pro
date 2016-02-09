PRO PSF_maker

INFILE= readfits('cut_80_J140320.74-003259.7_1643.fits',/SILENT)

psf=PSF_GAUSSIAN(NPIXEL=((size(INFILE))[1]),FWHM=[2.2,2.2],/NORMAL)

writefits,PATH_DATA+'psf.fits',psf

END
