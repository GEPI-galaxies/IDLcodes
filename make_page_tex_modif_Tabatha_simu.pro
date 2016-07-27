PRO make_page_tex, name, LOG_FILE, OUTEPS_profile,OUTEPS1,OUTEPS2,OUTEPS3 ,TOTEXFILE


openw, lun, TOTEXFILE, /get_lu

readlog, LOG_FILE, Components, chi2=chi2
Ncomp=N_ELEMENTS(Components.type)
ind_expdisk = WHERE(STRMATCH(Components[*].type,'expdisk') EQ 1, Nexpdisk)
ind_sersic = WHERE(STRMATCH(Components[*].type,'sersic') EQ 1, Nsersic)
ind_psf = WHERE(STRMATCH(Components[*].type,'psf') EQ 1, Npsf)
ind_sky = WHERE(STRMATCH(Components[*].type,'sky') EQ 1, Nsky)

printf, lun, format='(a)','\documentclass{article}'
printf, lun, format='(a)','\usepackage{graphicx}'
printf, lun, format='(a)','\usepackage{tabularx}'
printf, lun, format='(a)','\begin{document}'

printf, lun ,format='(a)','\begin{table}'
printf, lun ,format='(a)','\caption{Fit parameters}'
printf, lun ,format='(a)','\begin{center}'
printf, lun ,format='(a)','\begin{tabular}{|c|c|c|c|c|c|}'
printf, lun ,format='(a)','\hline'
printf, lun ,format='(a)','Component & log(dmass) Total & Sersic & $R_e/R_d$&PA & $b/a$\\'
printf, lun ,format='(a)','\hline'


;;;;;;;;CALCUL B/T;;;;;;;;;;;;;;;;;;;;
exptime=1.
zp=26.
print,'Ncomp=',Ncomp

if (Ncomp eq 1) then begin
	BT=0.00	
endif

if (Ncomp eq 2) then begin
	BT=0.00	
endif

if (Ncomp eq 3) then begin
	mag_tot=-2.5*alog10(10^(-(Components[0].Mag_T-zp)/2.5)+10^(-(Components[1].Mag_T-zp)/2.5))+zp
	flux_bulge=exptime*10^(-(Components[0].Mag_T-zp)/2.5)
	flux_disk=exptime*10^(-(Components[1].Mag_T-zp)/2.5)
	flux_tot=exptime*10^(-(mag_tot-zp)/2.5)
	BT=flux_bulge/flux_tot

endif

if (Ncomp eq 4) then begin
	mag_tot=-2.5*alog10(10^(-(Components[0].Mag_T-zp)/2.5)+10^(-(Components[1].Mag_T-zp)/2.5)+10^(-(Components[2].Mag_T-zp)/2.5))+zp
	flux_bulge=exptime*10^(-(Components[0].Mag_T-zp)/2.5)
	flux_disk=exptime*10^(-(Components[1].Mag_T-zp)/2.5)
	flux_bar=exptime*10^(-(Components[2].Mag_T-zp)/2.5)
	flux_tot=exptime*10^(-(mag_tot-zp)/2.5)
	BT=flux_bulge/flux_tot

endif
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;





for i=0, Ncomp-1 do begin

print,' '
print,'mag :', Components[i].Mag_T
Components[i].Mag_T=(Components[i].Mag_T-(2.5*10)-26.0)/(-2.5)
print,'log(dmass) :', Components[i].Mag_T
print,'Re (pix):', Components[i].Re
Components[i].Re=Components[i].Re*0.15
print,'Re (kpc):', Components[i].Re


IF STRMATCH(COMPONENTS[i].type,'sky') EQ 0 THEN BEGIN
	IF STRMATCH(Components[i].type,'expdisk') EQ 1 THEN components[i].n=1.00 ;;; to be changed !
	
	printf, lun ,format='(a)',Components[i].type+'&'+strn(Components[i].Mag_T,format='(f6.2)')$
						+'&'+strn(Components[i].n,format='(f6.2)')	+'&'+strn(Components[i].Re,format='(f6.2)')$
						+'&'+strn(Components[i].PA,format='(f6.2)')+'&'+strn(Components[i].b_a,format='(f6.2)')+'\\'
	printf, lun ,format='(a)','\hline'
ENDIF
endfor


printf, lun ,format='(a)','\end{tabular}'
printf, lun ,format='(a)','\end{center}'
printf, lun ,format='(a)','\end{table}'




printf,lun,format='(a,f6.2)','B/T=',BT

printf, lun ,format='(a)','\begin{table}[h!]'
printf, lun ,format='(a)','\caption{Image - Model - Residu}'
printf, lun ,format='(a)','\centering'
printf, lun ,format='(a)','\begin{tabular}{ccc}'
printf, lun ,format='(a)','\includegraphics[scale=0.25]{'+OUTEPS1+'}&\includegraphics[scale=0.25]{'+OUTEPS2+'}&\includegraphics[scale=0.25]{'+OUTEPS3+'} \\'
printf, lun ,format='(a)','\end{tabular}'
printf, lun ,format='(a)','\label{tab:gt}'
printf, lun ,format='(a)','\end{table}'

printf, lun ,format='(a)','\begin{figure}[h!]'
printf, lun ,format='(a)','\begin{center}'
printf, lun ,format='(a)','\includegraphics[scale=0.5,angle=0,origin=c]{'+OUTEPS_profile+'}\\'
printf, lun ,format='(a)','\end{center}'
printf, lun ,format='(a)','\end{figure}'
printf, lun ,format='(a)','\end{document}'
free_lun, lun

spawn,'latex '+TOTEXFILE
spawn,'open 3_fgas07_10.dvi'

END



