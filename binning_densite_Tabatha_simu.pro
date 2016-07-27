pro binning_densite

im=readfits('fichier_ima_sort_star_edge_on_4000_1.fits',h)

result1 = im/(0.015*0.015)

writefits, 'densite_3_fgas07_10.fits', result1, h

result2=result1/(1e10) + 0.1


writefits, 'divide_3_fgas07_10.fits', result2, h

; puis dans iraf :
; blkavg divide_3_fgas07_10.fits bdivide_3_fgas07_10.fits 10 10

; puis bruit.pro


end
