; make_mask_ds9
;
; This routine create a masks of neigbouring companion using ds9 .reg output ;
;
; --INPUT --
;  NAME: Name of the object 
;  FILE_DS9: Ds9 region file .reg 
;  FILE_FITS: Input fits file to mask 

;
;--OUTPUT --
;  MASKFILE: Mask for INFILE
;			 The regions to mask have 0 values.
;
; by Myriam Rodrigues 04/10/2011
; modify Myriam Rodrigues 27/04/2015

PRO make_mask_ds9, name, file_ds9, file_fits
factor_zoom=2
READCOL,file_ds9,format='(f,f,f)',xc,yc,r

n_contamin=n_elements(xc)
print,'Number of contaminated regions:',n_contamin


image=readfits(path+name+'.fits',header)
nx=n_elements(image(*,1))
ny=n_elements(image(1,*))
mask=image*0+1
;mask(WHERE(image EQ 0))=mask(WHERE(image EQ 0))*0

	for i=0,n_contamin -1 do begin
	Conta_radius=image
            for xx=0, nx -1 do begin
            	for yy=0,ny -1 do begin
            	Conta_radius[xx,yy]=sqrt((xc(i)-xx)^2+(yc(i)-yy)^2)
           		endfor
	endfor
	mask(WHERE(Conta_radius LE r(i)))= mask(WHERE(Conta_radius LE r(i)))*0.
	endfor
	
mkhdr,header,FIX(mask)
sxaddpar,header,'TYPE','Mask'
writefits,path+name+'_mask.fits',FIX(mask),header



END


; Make_all_ds9_mask 
;
; This routine is a wrapper for create make_mask_ds9
;

PRO Make_all_ds9_mask

path='Sum/'
READCOL, path+'Rhalh_3DHST_input.cat', name,file,redshift,pix_size,FORMAT = '(A,A,F,F)'

for i=0, n_elements(name) do begin
file=path+name(i)+'_ds9.reg'
fits_file=path+name(i)+'_sum.fits'
make_mask_ds9,name(i), file,fits_file
endfor
END
