PRO MAKE_TABLE_TEX, name,PATH_OUT,LOG_FILE,ZP
TOTEXFILE=PATH_OUT+name+ '.tex'
TODIVFILE=PATH_OUT+name+ '.dvi'
TOPSFILE=PATH_OUT+name+ '.pdf'
TOTABLEFILE=PATH_OUT+name+ '_galfit_table.png'

openw, lun, TOTEXFILE, /get_lun

readlog, LOG_FILE, Components, chi2=chi2
Ncomp=N_ELEMENTS(Components.type)

ind_expdisk = WHERE(STRMATCH(Components[*].type,'expdisk') EQ 1, Nexpdisk)
ind_sersic = WHERE(STRMATCH(Components[*].type,'sersic') EQ 1, Nsersic)
ind_psf = WHERE(STRMATCH(Components[*].type,'psf') EQ 1, Npsf)
ind_sky = WHERE(STRMATCH(Components[*].type,'sky') EQ 1, Nsky)


printf, lun ,format='(a)','\documentclass{standalone}'
printf, lun ,format='(a)','\usepackage{booktabs}'
printf, lun ,format='(a)','\begin{document}'
printf, lun ,format='(a)','\begin{tabular}{|c|c|c|c|c|c|}'
printf, lun ,format='(a)','\hline'
printf, lun ,format='(a)','Component & Mag Total & Sersic & $R_e/R_d$&PA & $b/a$\\'
printf, lun ,format='(a)','\hline'
for i=0, Ncomp-1 do begin
IF ~STRMATCH(Components[i].type,'sky') THEN printf, lun ,format='(a)',Components[i].type+'&'+strn(Components[i].Mag_T,format='(f6.2)')$
						+'&'+strn(Components[i].n,format='(f6.2)')+'&'+strn(Components[i].Re,format='(f6.2)')$
						+'&'+strn(Components[i].PA,format='(f6.2)')+'&'+strn(Components[i].b_a,format='(f6.2)')+'\\'
printf, lun ,format='(a)','\hline'
endfor
IF (Nexpdisk EQ 1 AND Nsersic GE 1) then begin
B_T = mag2flux(Components[ind_sersic[0]].Mag_T,ZP)/(mag2flux(Components[ind_expdisk].Mag_T,ZP) + mag2flux(Components[ind_sersic[0]].Mag_T,ZP))
printf, lun ,format='(a)','\hline'
printf, lun ,format='(a)','$B/T$ &'+strn(B_T,format='(f6.2)')+'& & & &\\'
printf, lun ,format='(a)','\hline'
print,B_T
endif
printf, lun ,format='(a)','\end{tabular}'
printf, lun ,format='(a)','\end{document}'

free_lun, lun
spawn,'pdflatex '+TOTEXFILE
spawn,'cp '+name+ '.pdf'+' '+TOPSFILE
spawn,'rm *.dvi'
spawn,'rm *.aux'
spawn,'rm '+name+'.log'
spawn,'rm '+name+'.pdf'
;spawn,'convert '+TOPSFILE+' '+TOTABLEFILE
END
