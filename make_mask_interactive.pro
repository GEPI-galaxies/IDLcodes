; make_mask_interactive 
;
; This routine create a masks of neigbouring companion interactively using circles. ;
;
; --INPUT --
;  NAME: Name of the object 
;  FILE: INPUT file in fits 
;
;
;--OUTPUT --
;  MASKFILE: Mask for INFILE
;			 The regions to mask have 0 values.
;
; by Myriam Rodrigues 04/10/2011
; modify Myriam Rodrigues 27/04/2015


PRO make_mask_interactive, name, file

factor_zoom=2

print,'++++++++ '+name(i)+' ++++++++ '
image=readfits(file,header)
nx=n_elements(image(*,1))
ny=n_elements(image(1,*))
mask=image*0+255

cgDisplay ,nx*factor_zoom ,ny*factor_zoom
cgIMAGE, hist_equal(image)

interactive_loop=1
print,'q to quit'
print,'n - new circle'
while interactive_loop EQ 1 do begin
action_event=GET_KBRD(1) 
 
	if STRCMP(action_event,'n') then begin 
	cursor,x1,y1,/DEVICE,/DOWN
	cursor,x2,y2,/DEVICE,/UP
	print,x1,y1,x2,Y2
	yc=y1/2.
	xc=x1/2.
	r=sqrt(((x1-x2)/2.)^2+((y1-y2)/2.)^2)
	print, xc,yc,r
	Conta_radius=image
            for xx=0, nx -1 do begin
            	for yy=0,ny -1 do begin
            	Conta_radius[xx,yy]=sqrt((xc-xx)^2+(yc-yy)^2)
           		endfor
           		endfor
		mask(WHERE(Conta_radius LE r))= mask(WHERE(Conta_radius LE r))*0.
		
	endif 
	
	if STRCMP(action_event,'q') then interactive_loop=0	

endwhile

;cgImage,mask 
	
mkhdr,header,FIX(mask)
sxaddpar,header,'TYPE','Mask'
writefits,path+name(i)+'_sum_mask.fits',FIX(mask),header


END

; Make_mask_all 
;
; This routine is a wrapper for create make_mask_interactive
;
; --INPUT --

PRO Make_mask_all

path='Sum/'
READCOL, PATH_CATALOGUE+CATALOGUE_INPUT, name,file,redshift,pix_size,FORMAT = '(A,A,F,F)'

for i=0, n_elements(name) -1 do begin 

make_mask_interactive,name(i),file(i)
endfor