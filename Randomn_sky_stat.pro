FUNCTION Randomn_sky_stat,image

n_sample=10.
pixel_scale=0.03
radius_sky =floor(1./pixel_scale )
nx=n_elements(image[*,1])
ny=n_elements(image[1,*])

x_sky=ceil(randomu(seed,n_sample)*(nx  - radius_sky *2) + radius_sky)
y_sky=ceil(randomu(seed,n_sample)*(ny  - radius_sky *2 ) + radius_sky )
close_obj=WHERE(x_sky GT 150 AND x_sky LT 350 AND y_sky GT 150 AND y_sky LT 350)
remove,close_obj,x_sky, y_sky
Sky=fltarr(n_elements(x_sky))
for k=0,n_elements(x_sky) -1  do begin
area= [x_sky[k] - radius_sky/2, x_sky[k] + radius_sky/2 ,  y_sky[k] - radius_sky/2 , y_sky[k] + radius_sky/2 ]
Sky[k]=sigma(image[x_sky[k] - radius_sky/2 : x_sky[k] + radius_sky/2, y_sky[k] - radius_sky/2 : y_sky[k] + radius_sky/2])
endfor
Sky_sigma=mean(Sky,/nan)
return,Sky_sigma

END
