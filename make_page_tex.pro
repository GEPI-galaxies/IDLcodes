PRO make_page_tex, name, LOG_FILE, OUTEPS_profile,OUTEPS1,OUTEPS2,OUTEPS3 ,TOTEXFILE

openw, lun, TOTEXFILE, /get_lu

readlog, LOG_FILE, Components, chi2=chi2
Ncomp=N_ELEMENTS(Components.type)
ind_expdisk = WHERE(STRMATCH(Components[*].type,'expdisk') EQ 1, Nexpdisk)
ind_sersic = WHERE(STRMATCH(Components[*].type,'sersic') EQ 1, Nsersic)
ind_psf = WHERE(STRMATCH(Components[*].type,'psf') EQ 1, Npsf)
ind_sky = WHERE(STRMATCH(Components[*].type,'sky') EQ 1, Nsky)

printf, lun ,format='(a)','\section{'+name+'}'

printf, lun ,format='(a)','\begin{table}[htdp]'
printf, lun ,format='(a)','\caption{default}'
printf, lun ,format='(a)','\begin{center}'
printf, lun ,format='(a)','\begin{tabular}{|c|c|c|c|c|c|}'
printf, lun ,format='(a)','\hline'
printf, lun ,format='(a)','Component & Mag Total & Sersic & $R_e/R_d$&PA & $b/a$\\'
printf, lun ,format='(a)','\hline'
for i=0, n_elements(Ncomp)-1 do begin
printf, lun ,format='(a)',Components[i].type+'&'+strn(Components[i].Mag_T,format='(f6.2)')+'&'+strn(Components[i].Mag_T,format='(f6.2)')$
						+'&'+strn(Components[i].n,format='(f6.2)')+'&'+strn(Components[i].Re,format='(f6.2)')$
						+'&'+strn(Components[i].PA,format='(f6.2)')+'&'+strn(Components[i].b_a,format='(f6.2)')+'\\'
printf, lun ,format='(a)','\hline'
endfor
printf, lun ,format='(a)','\end{tabular}'
printf, lun ,format='(a)','\end{center}'
printf, lun ,format='(a)','\end{table}'


printf, lun ,format='(a)','\begin{table}[h!]'
printf, lun ,format='(a)','\caption{A table arranging  images}'
printf, lun ,format='(a)','\centering'
printf, lun ,format='(a)','\begin{tabular}{ccc}'
printf, lun ,format='(a)','\includegraphics[scale=1]{graphic1}&\includegraphics[scale=1]{graphic2}\\'
printf, lun ,format='(a)','\includegraphics[scale=1]{graphic3}&\includegraphics[scale=1]{graphic4}\\'
printf, lun ,format='(a)','\end{tabular}'
printf, lun ,format='(a)','\label{tab:gt}'
printf, lun ,format='(a)','\end{table}'

printf, lun ,format='(a)','\begin{figure}[h!]'
printf, lun ,format='(a)','\begin{center}'
printf, lun ,format='(a)','\includegraphics[scale=0.55,angle=-90,origin=c]{'+OUTEPS_profile+'}\\'
printf, lun ,format='(a)','\end{center}'
printf, lun ,format='(a)','\end{figure}'
printf, lun ,format='(a)','\end{document}'
free_lun, lun

END



